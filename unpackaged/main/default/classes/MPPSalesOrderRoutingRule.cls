/**
 * Created by Jason Cookman on 2/26/20.
 *
 * /*************************************************************************
 *
 * fusionSpan CONFIDENTIAL
 * __________________
 *
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of fusionSpan LLC,
 * The intellectual and technical concepts contained
 * herein are proprietary to fusionSpan
 * and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from fusionSpan.
 */

global without sharing class MPPSalesOrderRoutingRule extends Framework.Domain {
    public MPPSalesOrderRoutingRule(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }

    private final Integer MAX_LENGTH = 10;
    private Integer simpleIDLength = 4;

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new MPPSalesOrderRoutingRule(sObjectList);
        }
    }

    public override void beforeDelete() {
        Framework.Log.push(MPPSalesOrderRoutingRule.class.getName(), 'Before delete');
        if(Schema.SObjectType.FSP_FonMPP__Agreement__c.isDeletable()) {
            deleteAgreements(records);
        }
        Framework.Log.pop();
    }

    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(MPPSalesOrderRoutingRule.class.getName(), 'Before Update');

        if (Schema.SObjectType.OrderApi__Sales_Order__c.isUpdateable()){
            updateSalesOrderBefore(records);
        }
        Framework.Log.pop();
    }


    public void deleteAgreements(List<OrderApi__Sales_Order__c> records) {

        Set<Id> orderIds = new Set<Id>();
        Set<Id> agreementIds = new Set<Id>();

        for (SObject record : records) {
            orderIds.add(record.Id);
        }

        List<OrderApi__Sales_Order_Line__c> orderLines = [
                SELECT Id, FSP_FonMPP__Agreement__c
                FROM OrderApi__Sales_Order_Line__c
                WHERE OrderApi__Sales_Order__c IN :orderIds
        ];

        for (OrderApi__Sales_Order_Line__c orderLine : orderLines) {

            if (orderLine.FSP_FonMPP__Agreement__c != null) {
                agreementIds.add(orderLine.FSP_FonMPP__Agreement__c);
            }
        }

        List<FSP_FonMPP__Agreement__c> agreementsToDelete = [SELECT Id FROM FSP_FonMPP__Agreement__c WHERE Id IN :agreementIds];
        delete agreementsToDelete;
    }


    public void updateSalesOrderBefore(List<OrderApi__Sales_Order__c> salesOrders) {

        List<OrderApi__Sales_Order__c> salesToAdd = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Sales_Order__c> salesToRemove = new List<OrderApi__Sales_Order__c>();

        for (OrderApi__Sales_Order__c currentSalesOrder : salesOrders) {
            if (currentSalesOrder.OrderApi__Posting_Entity__c == 'Receipt' &&
                    currentSalesOrder.OrderApi__Status__c == 'Closed' &&
                    currentSalesOrder.OrderApi__Posting_Status__c == 'Pending' &&
                    currentSalesOrder.FS_Simple_Id__c == null &&
                    currentSalesOrder.OrderApi__Contact__c != null) {
                salesToAdd.add(currentSalesOrder);
            } else if(currentSalesOrder.OrderApi__Status__c == 'Closed'
                    && currentSalesOrder.OrderApi__Posting_Status__c == 'Posted'
                    && currentSalesOrder.FS_Simple_Id__c != null){
                salesToRemove.add(currentSalesOrder);
            }
        }
        removeClosedPosted(salesToRemove);
        updateClosedPending(salesToAdd);

    }

    private void removeClosedPosted(List<OrderApi__Sales_Order__c> salesOrders) {
        for (OrderApi__Sales_Order__c currentSalesOrder : salesOrders) {
            currentSalesOrder.FS_Simple_Id__c = '';
            currentSalesOrder.FSP_FonMPP__Short_URL__c = '';
            currentSalesOrder.FSP_FonMPP__Long_URL__c = '';
            currentSalesOrder.FSP_FonMPP__Long_URL_Lightning__c = '';
        }
    }

    private void updateClosedPending(List<OrderApi__Sales_Order__c> salesOrders) {
        List<String> simpleIDs = generateRandomIdList(simpleIDLength, salesOrders.size());
        for (OrderApi__Sales_Order__c currentOrder : salesOrders) {
            currentOrder.FS_Simple_Id__c = simpleIDs.remove(0);
        }
        updateUrls(salesOrders);
    }

    public void updateUrls(List<OrderApi__Sales_Order__c> salesOrderList) {

        String salesOrderURL = '/OrderApi__checkout?salesOrder=';
        String siteRedirect = '&authreq=false&signedInAsGuest=true&site=';

        List<PagesApi__Site__c> sites = [SELECT Id, OrderApi__Business_Group__c, PagesApi__Site_URL__c FROM PagesApi__Site__c LIMIT 1000];
        Map<String, PagesApi__Site__c> sitesMap = new Map<String, PagesApi__Site__c>();
        for (PagesApi__Site__c currSite : sites) {
            sitesMap.put(currSite.OrderApi__Business_Group__c, currSite);
        }

        List<PagesApi__Site__c> defaultSites = [
                SELECT Id, OrderApi__Business_Group__c, PagesApi__Site_URL__c
                FROM PagesApi__Site__c
                WHERE PagesApi__Is_Default__c = TRUE
        ];

        PagesApi__Site__c defaultSite;
        if (defaultSites.size() > 0) {
            defaultSite = defaultSites[0];
        } else {
            // On the issue of no default site, this exception is thrown. Noticed that Fonteva is catching and doing a partial save
            throw new SalesOrderRoutingRuleException('No Default Site');
        }

        //List<LTE__Site__c> lightningSites = [SELECT Id, LTE__Site_URL__c FROM LTE__Site__c WHERE LTE__Is_Default__c = TRUE];

        //Using this workaround to preserve backwards compatability with prior version of Fonteva that don't have LTE__Site__c
        List<FSP_FonMPP__Membership_Power_Pack__mdt> lightningSites = [
                SELECT FSP_FonMPP__Lightning_Site_URL__c
                FROM FSP_FonMPP__Membership_Power_Pack__mdt
                WHERE DeveloperName = 'Membership_Power_Pack_Settings' AND FSP_FonMPP__Lightning_Site_URL__c != ''
        ];

        for (OrderApi__Sales_Order__c currSalesOrder : salesOrderList) {

            PagesApi__Site__c currSite = sitesMap.get(currSalesOrder.OrderApi__Business_Group__c);
            if (currSite == null) {
                currSite = defaultSite;
            }

            currSalesOrder.FSP_FonMPP__Long_URL__c = salesOrderURL + currSalesOrder.Id + siteRedirect + currSite.Id;

            if (lightningSites.size() > 0) {
                currSalesOrder.FSP_FonMPP__Long_URL_Lightning__c = lightningSites[0].FSP_FonMPP__Lightning_Site_URL__c + '/store#/store/checkout/' + currSalesOrder.Id;
                currSalesOrder.FSP_FonMPP__Short_URL__c = lightningSites[0].FSP_FonMPP__Lightning_Site_URL__c.removeEnd('/s') + '/pfr?sid=' + currSalesOrder.FS_Simple_Id__c;
            } else {
                currSalesOrder.FSP_FonMPP__Short_URL__c = currSite.PagesApi__Site_URL__c + '/pfr?sid=' + currSalesOrder.FS_Simple_Id__c;
            }
        }
    }



    @TestVisible
    private List<String> generateRandomIdList(Integer stringLength, Integer setSize) {

        if (stringLength > MAX_LENGTH) {
            throw new SalesOrderRoutingRuleException('Cannot set Simple Id. Please ensure there are not too many ProForma Invoices with Simple Id\'s');
        }

        Set<String> idSet = new Set<String>();


        while (idSet.size() < setSize) {
            String tempId = generateRandomId(stringLength);
            idSet.add(tempId);
        }

        List<OrderApi__Sales_Order__c> matchingSalesOrders = [
                SELECT FS_Simple_Id__c
                FROM OrderApi__Sales_Order__c
                WHERE FS_Simple_Id__c IN :idSet
        ];

        if (matchingSalesOrders.size() > 0) {
            for (OrderApi__Sales_Order__c currSO : matchingSalesOrders) {
                idSet.remove(currSO.FS_Simple_Id__c);
            }

            idSet.addAll(generateRandomIdList(stringLength + 1, matchingSalesOrders.size()));
        }
        return new List<String>(idSet);
    }

    @TestVisible
    private String generateRandomId(Integer len) {

        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }


    class SalesOrderRoutingRuleException extends Exception{}
}