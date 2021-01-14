/**
 * Created by dfitzgerald on 10/24/19.
 * Updated by cubiascaceres on 03/24/20: Adding named credential
 */

public without sharing class FS_GetCountyFromSS implements Queueable, Database.AllowsCallouts {

    SObject obj;
    private static final String ENDPOINT = 'street-address';
    private static final String SMARTY_STREET_API_URL, AUTH_ID, AUTH_TOKEN;

    static {
        SMARTY_STREET_API_URL = [SELECT FS_Value__c FROM FS_Smarty_Street_API_Auth_Param__mdt WHERE FS_Endpoint__c = :ENDPOINT AND DeveloperName = 'URL'][0].FS_Value__c;
        AUTH_ID = [SELECT FS_Value__c FROM FS_Smarty_Street_API_Auth_Param__mdt WHERE FS_Endpoint__c = :ENDPOINT AND DeveloperName = 'AUTH_ID'][0].FS_Value__c;
        AUTH_TOKEN = [SELECT FS_Value__c FROM FS_Smarty_Street_API_Auth_Param__mdt WHERE FS_Endpoint__c = :ENDPOINT AND DeveloperName = 'AUTH_TOKEN'][0].FS_Value__c;
    }

    //constructor
    public FS_GetCountyFromSS(SObject obj) {
        this.obj = obj;
    }

    public void execute(QueueableContext context) {
        if (obj instanceof Contact) {

        } else if (obj instanceof Account) {

        } else if (obj instanceof OrderApi__Known_Address__c) {
            String county = null;
            //get known address record
            OrderApi__Known_Address__c knownAddress = [
                    SELECT Id, OrderApi__Country__c, OrderApi__Street__c, OrderApi__City__c, OrderApi__Province__c
                    FROM OrderApi__Known_Address__c
                    WHERE Id = :obj.Id
                    LIMIT 1
            ][0];
            //make callout
            if (!String.isBlank(knownAddress.OrderApi__Street__c) && !String.isBlank(knownAddress.OrderApi__City__c)
                    && !String.isBlank(knownAddress.OrderApi__Province__c)) {

                county = makeCalloutForCounty(knownAddress.OrderApi__Country__c, knownAddress.OrderApi__Street__c,
                        knownAddress.OrderApi__City__c, knownAddress.OrderApi__Province__c);

                //update fields
                knownAddress.FS_County__c = county;
                knownAddress.FS_Last_Verified__c = Datetime.now();
                if (!String.isBlank(county)) {
                    knownAddress.FS_Verified__c = true;
                    knownAddress.FS_Return_Code__c = 'Confirmed';
                } else {
                    knownAddress.FS_Verified__c = false;
                    knownAddress.FS_Return_Code__c = 'Not Confirmed';
                }
                update knownAddress;
            }

        } else if (obj instanceof OrderApi__Sales_Order__c) {
            String billingCounty = null;
            String shippingCounty = null;
            Datetime currentDatetime = null;
            Boolean needUpdate = false;

            //get sales order record
            OrderApi__Sales_Order__c salesOrder = [
                    SELECT Id, 
                        OrderApi__Billing_Country__c, OrderApi__Billing_Street__c, OrderApi__Billing_City__c, OrderApi__Billing_State__c, FS_Billing_Address_Verified__c, 
                        OrderApi__Shipping_Country__c, OrderApi__Shipping_Street__c, OrderApi__Shipping_City__c, OrderApi__Shipping_State__c, FS_Shipping_Address_Verified__c
                    FROM OrderApi__Sales_Order__c
                    WHERE Id = :obj.Id
                    LIMIT 1
            ][0];

            currentDatetime = Datetime.now();
            //make callouts
            if (!String.isBlank(salesOrder.OrderApi__Billing_Street__c) && !String.isBlank(salesOrder.OrderApi__Billing_City__c)
                    && !String.isBlank(salesOrder.OrderApi__Billing_State__c)) {
                if (salesOrder.FS_Billing_Address_Verified__c == false) {
                    billingCounty = makeCalloutForCounty(salesOrder.OrderApi__Billing_Country__c, salesOrder.OrderApi__Billing_Street__c,
                            salesOrder.OrderApi__Billing_City__c, salesOrder.OrderApi__Billing_State__c);
                }
                if (salesOrder.FS_Billing_Address_Verified__c == false && billingCounty != null) {
                    salesOrder.FS_Billing_County__c = billingCounty;
                    salesOrder.FS_Billing_Address_Last_Verified__c = currentDatetime;
                    salesOrder.FS_Billing_Address_Verified__c = true;
                    needUpdate = true;
                }
            }

            if (!String.isBlank(salesOrder.OrderApi__Shipping_Street__c) && !String.isBlank(salesOrder.OrderApi__Shipping_City__c)
                    && !String.isBlank(salesOrder.OrderApi__Shipping_State__c)) {
                if (salesOrder.FS_Shipping_Address_Verified__c == false) {
                    shippingCounty = makeCalloutForCounty(salesOrder.OrderApi__Shipping_Country__c, salesOrder.OrderApi__Shipping_Street__c,
                            salesOrder.OrderApi__Shipping_City__c, salesOrder.OrderApi__Shipping_State__c);
                }
                if (salesOrder.FS_Shipping_Address_Verified__c == false && shippingCounty != null) {
                    salesOrder.FS_Shipping_County__c = shippingCounty;
                    salesOrder.FS_Shipping_Address_Last_Verified__c = currentDatetime;
                    salesOrder.FS_Shipping_Address_Verified__c = true;
                    needUpdate = true;
                }
            }
            if (needUpdate) {
                update salesOrder;
            }

        } else if (obj instanceof OrderApi__Sales_Order_Line__c) {
            String shippingCounty = null;
            Datetime currentDatetime = null;

            //get sales order record
            List<OrderApi__Sales_Order_Line__c> salesOrderLines = [
                    SELECT Id, OrderApi__Shipping_Country__c,
                            OrderApi__Shipping_Street__c, OrderApi__Shipping_City__c,
                            OrderApi__Shipping_State__c, FS_Shipping_Address_Verified__c
                    FROM OrderApi__Sales_Order_Line__c
                    WHERE Id = :obj.Id
                    LIMIT 1
            ];

            if (salesOrderLines.size() != 0) {
                OrderApi__Sales_Order_Line__c salesOrderLine = salesOrderLines[0];
                if (!String.isBlank(salesOrderLine.OrderApi__Shipping_Street__c) && !String.isBlank(salesOrderLine.OrderApi__Shipping_City__c)
                        && !String.isBlank(salesOrderLine.OrderApi__Shipping_State__c)) {
                    if (salesOrderLine.FS_Shipping_Address_Verified__c == false) {
                        shippingCounty = makeCalloutForCounty(salesOrderLine.OrderApi__Shipping_Country__c, salesOrderLine.OrderApi__Shipping_Street__c,
                                salesOrderLine.OrderApi__Shipping_City__c, salesOrderLine.OrderApi__Shipping_State__c);
                    }
                    if (shippingCounty != null) {
                        currentDatetime = Datetime.now();

                        //update fields
                        if (salesOrderLine.FS_Shipping_Address_Verified__c == false) {
                            salesOrderLine.FS_Shipping_County__c = shippingCounty;
                            salesOrderLine.FS_Shipping_Address_Last_Verified__c = currentDatetime;
                            salesOrderLine.FS_Shipping_Address_Verified__c = true;
                        }

                        update salesOrderLine;
                    }

                }
            }
        }
    }

    private String makeCalloutForCounty(String country, String addressStreet, String addressCity, String addressState) {
        // If country not US/United States, we don't even need to call the API, due to it does not return the country field (Even if we use the international API)
        if (country != 'US' && country != 'United States') {
            return null;
        }
        //if (addressState != 'New York' && addressState != 'NY') {
        String countyName = null;

        HttpRequest req = new HttpRequest();

        String params = SMARTY_STREET_API_URL + '/' + ENDPOINT
                        + '?auth-id=' + AUTH_ID
                        + '&auth-token=' + AUTH_TOKEN 
                        + '&street=' + EncodingUtil.urlEncode(addressStreet,'UTF-8') 
                        + '&city=' + EncodingUtil.urlEncode(addressCity,'UTF-8')
                        + '&state=' + EncodingUtil.urlEncode(addressState,'UTF-8');
        req.setEndpoint(params);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse resp = http.send(req);

        //check server response code
        if (resp.getStatusCode() < 200 || resp.getStatusCode() >= 300) {
            throw new CalloutException('HTTP callout failed:'
                    + '\nendPoint=' + req.getEndpoint()
                    + '\nstatusCode=' + resp.getStatusCode()
                    + '\nstatus=' + resp.getStatus()
                    + '\nbody=' + resp.getBody()
            );
        }
        
        JSONParser parser = JSON.createParser(resp.getBody());

        while (parser.nextToken() != null) {
            //if current token is a field name
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                System.debug('fieldName: ' + fieldName);
                //move to token after the field name
                parser.nextToken();
                if (fieldName == 'county_name') {
                    countyName = parser.getText();
                }
            }
        }
        return countyName;
    }
}