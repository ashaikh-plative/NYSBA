/**
 * Created by santhosh on 04-04-2020.
 */

@RestResource(urlMapping='/itemsLastModified/*')
global without sharing class FS_ItemsLastModifiedRestService {

    private static final String BUSINESS_GROUP_NAME = 'NYSBA';
    private static final String ITEM_CLASS_NAME = 'NYSBA Legacy Product';

    @HttpGet
    global static List<OrderApi__Item__c> getItemsList() {
        List<OrderApi__Item__c> itemsList = new List<OrderApi__Item__c>();

        try{
            Set<Id> itemIdsSet = new Set<Id>();
            Date modifiedDate = System.today();
            RestRequest req = RestContext.request;
            try{
                modifiedDate = System.today() - Integer.valueOf(req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
            }catch (Exception e){
                RestResponse response = RestContext.response;
                response.statusCode = 400;
                System.debug(LoggingLevel.ERROR, 'itemsLastModified API Request URL:'+req.requestURI);
                System.debug(LoggingLevel.ERROR, e.getStackTraceString()+' : '+ e.getMessage());
                return itemsList;
            }

            getLastModifiedPriceRules(modifiedDate, itemIdsSet);

            itemsList = getRelevantItems(modifiedDate, itemIdsSet);
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getStackTraceString()+' : '+ e.getMessage());
        }
        return itemsList;
    }

    private static List<OrderApi__Item__c> getRelevantItems(Date lastModifiedDateCutOff, Set<Id> itemIds) {
        return [SELECT Id, Name,FS_Do_Not_Display_on_Web__c, OrderApi__Is_Active__c,
                LastModifiedDate, FS_Lead_Product__c, OrderApi__Item_Class__c, OrderApi__Item_Class__r.Name
                FROM OrderApi__Item__c WHERE Id IN :itemIds OR ( LastModifiedDate > :lastModifiedDateCutOff
                AND OrderApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME
                AND OrderApi__Is_Event__c = FALSE AND OrderApi__Is_Subscription__c = FALSE
                AND OrderApi__Item_Class__r.FS_Is_Merchandise__c = TRUE
                AND OrderApi__Item_Class__r.Name != :ITEM_CLASS_NAME )];
    }

    private static void getLastModifiedPriceRules(Date lastModifiedDateCutOff, Set<Id> itemIdsSet) {
        for(OrderApi__Price_Rule__c priceRule : [SELECT Id, OrderApi__Item__c FROM OrderApi__Price_Rule__c
                                                 WHERE LastModifiedDate > :lastModifiedDateCutOff
                                                 AND OrderApi__Item__r.OrderApi__Business_Group__r.Name = :BUSINESS_GROUP_NAME
                                                 AND OrderApi__Item__r.OrderApi__Is_Event__c = FALSE AND OrderApi__Item__r.OrderApi__Is_Subscription__c = FALSE
                                                 AND OrderApi__Item__r.OrderApi__Item_Class__r.FS_Is_Merchandise__c = TRUE
                                                 AND OrderApi__Item__r.OrderApi__Item_Class__r.Name != :ITEM_CLASS_NAME]){
            itemIdsSet.add(priceRule.OrderApi__Item__c);
        }
    }
}