/**
 * Created by santhosh on 03-10-2019.
 */

global without sharing class FS_InsertProductRule extends Framework.Domain{

    private static final String ERROR_MESSAGE = 'Item has Linked Product, cannot update Sold by Sales Team to FALSE';

    public FS_InsertProductRule(List<OrderApi__Item__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_InsertProductRule(sObjectList);
        }
    }

    public override void afterInsert() {
        Framework.Log.push(FS_InsertProductRule.class.getName(), 'afterInsert');
        insertOrUpdateProduct((OrderApi__Item__c[]) records,null, false);
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> oldRecords) {
        Framework.Log.push(FS_InsertProductRule.class.getName(), 'beforeUpdate');
        insertOrUpdateProduct((OrderApi__Item__c[]) records,(Map<Id, OrderApi__Item__c>) oldRecords,true);
        addError((OrderApi__Item__c[]) records,(Map<Id, OrderApi__Item__c>) oldRecords);
        Framework.Log.pop();
    }

    private static void addError(List<OrderApi__Item__c> items,Map<Id,OrderApi__Item__c> oldMap){
        Set<Id> prodIds = new Set<Id>();
        for(OrderApi__Item__c item : items){
            prodIds.add(item.FS_Linked_Product__c);
        }

        Map<Id, Product2> productMap= new Map<Id, Product2>([SELECT Id,Name,Description FROM Product2 WHERE Id IN :prodIds]);

        for(OrderApi__Item__c item : items){
            if(item.FS_Linked_Product__c  != null && oldMap.get(item.Id).FS_Sold_By_Sales_Team__c != item.FS_Sold_By_Sales_Team__c
                    && item.FS_Sold_By_Sales_Team__c == false){
                if(productMap.get(item.FS_Linked_Product__c) != null){
                    item.FS_Sold_By_Sales_Team__c.addError(ERROR_MESSAGE);
                }else{
                    item.FS_Linked_Product__c = null;
                }
            }
        }
    }

    private static void insertOrUpdateProduct(List<OrderApi__Item__c> items,Map<Id,OrderApi__Item__c> oldMap,
            Boolean isUpdate){
        Map<Id, Product2> insertProdMap = new Map<Id, Product2>();
        Set<Id> idsToUpdateProd = new Set<Id>();
        Set<Id> idsToUpdatePrice = new Set<Id>();
        Map<Id,Id> idProdIdMap = new Map<Id, Id>();
        Map<Id,OrderApi__Item__c> itemsMap = new Map<Id, OrderApi__Item__c>();

        for(OrderApi__Item__c item: items){
            if(isUpdate){
                OrderApi__Item__c oldItem = oldMap.get(item.Id);
                if(oldItem != null){
                    //If Item Sold By Sales Team is updated then inserting product with same item name description
                    if(oldMap.get(item.Id).FS_Sold_By_Sales_Team__c!=item.FS_Sold_By_Sales_Team__c && item.FS_Sold_By_Sales_Team__c){
                        Product2 product2 = new Product2(Name=item.Name,Description=item.OrderApi__Line_Description__c,IsActive=true);
                        insertProdMap.put(item.Id, product2);
                    }else {
                        /*Adding Item Ids to idsToUpdateProd set and idProdIdMap map if any changes in either name or description or active flag of the item
                        so it helps to update only those products*/
                        if(item.FS_Linked_Product__c != null && oldItem.Name != item.Name || oldItem.OrderApi__Line_Description__c != item.OrderApi__Line_Description__c ||
                                oldItem.OrderApi__Is_Active__c != item.OrderApi__Is_Active__c){
                            idsToUpdateProd.add(item.Id);
                            idProdIdMap.put(item.Id, item.FS_Linked_Product__c);
                        }
                        /*Adding Item Ids to idsToUpdateProd set and idProdIdMap map if any changes in price of the item
                         so it helps to update only those products*/
                        if (item.FS_Linked_Product__c != null && oldItem.OrderApi__Price__c != item.OrderApi__Price__c){
                            idsToUpdatePrice.add(item.Id);
                            idProdIdMap.put(item.Id, item.FS_Linked_Product__c);
                        }
                    }
                }
            }else{
                if(item.FS_Sold_By_Sales_Team__c){//For Insert operation on Item
                    Product2 product2 = new Product2(Name=item.Name,Description=item.OrderApi__Line_Description__c,IsActive=true);
                    insertProdMap.put(item.Id, product2);
                }
            }
        }

        //Inserting products
        if(!insertProdMap.values().isEmpty()){
            insert insertProdMap.values();
        }

        Map<Id, Product2> productMap= new Map<Id, Product2>();
        if(!idProdIdMap.values().isEmpty()){
            productMap = new Map<Id, Product2>([SELECT Id,Name,Description,(SELECT Id,UnitPrice,Product2Id FROM PricebookEntries) FROM Product2 WHERE Id IN :idProdIdMap.values()]);
        }
        //Soql query for fetching Standard Price Book record in PriceBook2
        List<Pricebook2> pricebook2List =[SELECT Id,Name FROM Pricebook2 WHERE Name='Standard Price Book'];

        List<Product2> updateProducts = new List<Product2>();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();

        for(OrderApi__Item__c item: items){
            //Inserting PricebookEntry object with Unit price value taking it from the item
            if(insertProdMap.get(item.Id) != null){
                Product2 product2 = insertProdMap.get(item.Id);
                if(isUpdate){
                    item.FS_Linked_Product__c=product2.Id;
                }else{
                    itemsMap.put(item.Id, new OrderApi__Item__c(Id=item.Id, FS_Linked_Product__c=product2.Id));
                }
                PricebookEntry pEntry = new PricebookEntry(UnitPrice=item.OrderApi__Price__c,Pricebook2Id=pricebook2List[0].Id,Product2Id=product2.Id,IsActive=true);
                pricebookEntries.add(pEntry);
            }

            if(productMap.get(item.FS_Linked_Product__c) != null && isUpdate){
                Product2 product = productMap.get(item.FS_Linked_Product__c);
                //Updating the product object if any changes in either name or description of the Item
                if(idsToUpdateProd.contains(item.Id)){
                    product.Name = item.Name;
                    product.Description=item.OrderApi__Line_Description__c;
                    product.IsActive = item.OrderApi__Is_Active__c;
                    updateProducts.add(product);
                }
                //Updating the PricebookEntry object if any changes in price of the Item
                if(idsToUpdatePrice.contains(item.Id) && product.PricebookEntries != null
                        && product.PricebookEntries.size() > 0){
                    if (product.PricebookEntries[0] != null) {
                        PricebookEntry pEntry =  product.PricebookEntries[0];
                        pEntry.UnitPrice = item.OrderApi__Price__c;
                        pricebookEntries.add(pEntry);
                    }
                }
            }
        }
        if(!updateProducts.isEmpty()){
            update updateProducts;
        }
        if(!pricebookEntries.isEmpty()){
            upsert pricebookEntries;
        }

        if(!itemsMap.values().isEmpty()){
            update itemsMap.values();
        }
    }


}