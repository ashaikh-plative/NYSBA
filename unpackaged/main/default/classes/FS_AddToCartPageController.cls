/**
 * Created by dfitzgerald on 2019-09-04.
 */

public without sharing class FS_AddToCartPageController {
    private final String URL_ENCODING_SCHEME = 'UTF-8';
    private final String ERROR_STATUS = 'ERROR';
    private final String MISSING_PARAMETER_MESSAGE = 'Missing required parameters';
    private final String INVALID_PRODUCT_ID_MESSAGE = 'Invalid product ID';
    private final String INVALID_PARAMETER_VALUE_MESSAGE = 'A parameter has an invalid value';

    public String redirectUrl {get;set;}
    public String returnParameterString {get;set;}
    public Boolean redirectMissing {get;set;}
    public Boolean parametersValid {get;set;}
    public Id userId {get;set;}
    public Id contactId {get;set;}
    public Id salesOrderId {get;set;}
    public String productId {get;set;}
    public Decimal quantity {get;set;}
    //public Decimal overrideUnitPrice {get;set;}  Not using price overrides until security issues are resolved
    public Boolean dmlRun {get;set;}
    public Integer numItemsInCart;

    //constructor
    public FS_AddToCartPageController() {
        //get url parameters
        String productIdIn = ApexPages.currentPage().getParameters().get('productId');
        String quantityStringIn = ApexPages.currentPage().getParameters().get('qty');
        String overrideUnitPriceStringIn = ApexPages.currentPage().getParameters().get('overrideUnitPrice');
        redirectUrl = ApexPages.currentPage().getParameters().get('redirectUrl');

        returnParameterString = '?';
        userId = UserInfo.getUserId();
        contactId = getContactId();

        if (this.redirectUrl == null
            || !(redirectUrl.startsWith('https://staging.nysba.cliquedomains.com/')
                || redirectUrl.startsWith('https://nysba.org/')
                || redirectUrl.startsWith('https://www.nysba.org/'))) {
            this.redirectMissing = true;
        } else {
            this.redirectMissing = false;
        }

        parametersValid = validateParameters(productIdIn, quantityStringIn, overrideUnitPriceStringIn);

        if (parametersValid) {
            if (salesOrderId == null){ //should always be null for now, but may add feature in the future
                salesOrderId = getSalesOrderId(); //creates new sales order if none found
            }
        }
    }

    private Id getContactId() {
        return [SELECT ContactId FROM User WHERE Id = :userId][0].ContactId;
    }

    private Boolean validateParameters(String productIdIn, String quantityStringIn, String overrideUnitPriceStringIn) {
        if (productIdIn == null || quantityStringIn == null || this.redirectUrl == null) {
            returnParameterString += 'status='+EncodingUtil.urlEncode(ERROR_STATUS, URL_ENCODING_SCHEME);
            returnParameterString += '&errorMsg='+EncodingUtil.urlEncode(MISSING_PARAMETER_MESSAGE, URL_ENCODING_SCHEME);
            return false;
        } else if (productIdIn.length() != 18) { //item ids should always be 18 characters long
            returnParameterString += 'status='+EncodingUtil.urlEncode(ERROR_STATUS, URL_ENCODING_SCHEME);
            returnParameterString += '&errorMsg='+EncodingUtil.urlEncode(INVALID_PRODUCT_ID_MESSAGE, URL_ENCODING_SCHEME);
            return false;
        } else {
            try {
                productId = productIdIn;
                quantity = Decimal.valueOf(quantityStringIn);
                if (quantity < 1) {
                    returnParameterString += 'status='+EncodingUtil.urlEncode(ERROR_STATUS, URL_ENCODING_SCHEME);
                    returnParameterString += 'errorMsg='+EncodingUtil.urlEncode(INVALID_PARAMETER_VALUE_MESSAGE, URL_ENCODING_SCHEME);
                    return false;
                }
                //if (overrideUnitPriceStringIn != null) {
                //    overrideUnitPrice = Decimal.valueOf(overrideUnitPriceStringIn);
                //}
            } catch (Exception e) {
                returnParameterString += 'status='+EncodingUtil.urlEncode(ERROR_STATUS, URL_ENCODING_SCHEME);
                returnParameterString += 'errorMsg='+EncodingUtil.urlEncode(INVALID_PARAMETER_VALUE_MESSAGE, URL_ENCODING_SCHEME)+':'+e.getMessage();
                return false;
            }
        }
        return true;
    }

    //get most recent salesOrderId for current contact. If no salesOrder is found, create a new one
    private Id getSalesOrderId() {

        User loggedInUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()
                    AND (NOT Profile.UserLicense.Name LIKE '%Guest%')];
        //get most recent sales order id
        List<OrderApi__Sales_Order__c> salesOrders = [
                SELECT Id, Name, OrderApi__Item_Count__c
                FROM OrderApi__Sales_Order__c
                WHERE
                (OrderApi__Status__c = 'Open' OR (OrderApi__Status__c = 'Closed' AND OrderApi__Posting_Status__c = 'Pending'))
                AND OrderApi__Contact__c = :contactId
                AND CreatedBy.ContactId = :loggedInUser.ContactId
                ORDER BY LastModifiedDate DESC LIMIT 1];
        
        if (!salesOrders.isEmpty()) {
            numItemsInCart = Integer.valueOf(calculateNumberInCart());
            return salesOrders[0].Id;
        } else {
            //no sales order found, will create one when runDMLApex is called
            return null;
        }
    }

    //Inserts new salesorder if needed and calls function to create and insert new salesorderline. DML cannot be run from constructor.
    public void runDMLApex(){
        if (this.parametersValid) {
            if (this.salesOrderId == null) {
                OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c(
                        OrderApi__Contact__c = contactId
                );
                insert salesOrder;
                this.salesOrderId = salesOrder.Id;
                this.numItemsInCart = 0;
            }
            addItemToSalesOrderLine();
        }
        this.DMLRun = true;
    }

    //Create and insert new salesorderline
    private Boolean addItemToSalesOrderLine() {
        list<OrderApi__Item__c> items = [SELECT Id, OrderApi__Item_Class__c FROM OrderApi__Item__c WHERE Id = :this.productId];
        if (!items.isEmpty()) {
            OrderApi__Item__c item = items[0];

            //find a pre-existing sales order line
            List<OrderApi__Sales_Order_Line__c> relevantSalesOrderLines =
                [SELECT Id, OrderApi__Quantity__c FROM OrderApi__Sales_Order_Line__c
                    WHERE OrderApi__Item__c = :item.Id AND OrderApi__Sales_Order__c = :this.salesOrderId
                ORDER BY LastModifiedDate DESC LIMIT 1];

            if(relevantSalesOrderLines.size() == 0) {

                OrderApi__Sales_Order_Line__c orderLine = new OrderApi__Sales_Order_Line__c(
                        OrderApi__Item__c = item.Id,
                        OrderApi__Item_Class__c = item.OrderApi__Item_Class__c,
                        OrderApi__Quantity__c = this.quantity,
                        OrderApi__Sales_Order__c = this.salesOrderId
                );

                //if (overrideUnitPrice != null) {
                //    orderLine.OrderApi__Price_Override__c = true;
                //    orderLine.OrderApi__Sale_Price__c = overrideUnitPrice;
                //}

                insert orderLine;
            } else {
                relevantSalesOrderLines[0].OrderApi__Quantity__c += this.quantity;
                update relevantSalesOrderLines[0];
            }
            numItemsInCart = calculateNumberInCart();
            returnParameterString += 'status=SUCCESS';
            returnParameterString += '&salesOrderId='+salesOrderId;
            returnParameterString += '&numberOfItemsInCart=' + numItemsInCart;
            return true;
        } else {
            returnParameterString += 'status=ERROR';
            returnParameterString += '&errorMsg=Invalid%20product%20Id';
            return false;
        }
    }

    private Integer calculateNumberInCart() {
//        List<OrderApi__Sales_Order_Line__c> salesOrderLinesInCart =
//        [SELECT Id, OrderApi__Quantity__c FROM OrderApi__Sales_Order_Line__c
//                    WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Display_Item__c = TRUE];

        Integer cartCount = 0;
        for (OrderApi__Sales_Order_Line__c currSalesOrderLine : [SELECT Id, OrderApi__Quantity__c FROM OrderApi__Sales_Order_Line__c
                WHERE OrderApi__Sales_Order__c = :salesOrderId AND OrderApi__Item__r.OrderApi__Is_Shipping_Rate__c = FALSE
                                                                AND OrderApi__Item__r.OrderApi__Is_Tax__c = FALSE]) {
            cartCount += Integer.valueOf(currSalesOrderLine.OrderApi__Quantity__c);
        }

        numItemsInCart = cartCount;
        return numItemsInCart;
    }

    //create page reference used for redirect
    public PageReference redirectApex() {
        if (redirectUrl!=null) {
            PageReference pageRef = new PageReference(redirectUrl+returnParameterString);
            return pageRef;
        } else {
            redirectMissing = true;
            return null;
        }
    }
}