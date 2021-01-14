/**
 * Created by Gopi on 16-10-2019.
 */
@IsTest
private without sharing class FS_OppRoutingRuleTest {
    @TestSetup
    private static void afterUpdate(){
        List<Framework.RoutingRule> rules = new List<Framework.RoutingRule>();
        /* RoutingRule information*/
        Framework.RoutingRule routingRule= new Framework.RoutingRule();
        routingRule.apexClass = FS_OppRoutingRule.class.getName();
        routingRule.namespace = ' ';
        routingRule.isEnabled = TRUE;
        routingRule.sObjectName = 'Opportunity';
        routingRule.executionOrder = 40;
        rules.add(routingRule);
        Framework.Config.push(rules);
    }
    @IsTest
    private static void testOpp(){
        Account acc = FS_TestUtils.createAccount('Testing Account');
        insert acc;
        Contact con = FS_TestUtils.createContact('testContact','test@mail.com');
        insert con;
        Opportunity opp = new Opportunity();
        Opp.Name = 'Testing';
        Opp.CloseDate = System.Today();
        Opp.AccountId = acc.Id;
        Opp.StageName = 'Prospecting';
        insert opp;
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp);
        Id pricebookId = Test.getStandardPricebookId();
        //Create product
        Product2 prod = new Product2(
                Name = 'Product X',
                ProductCode = 'Pro-X',
                isActive = TRUE
        );
        insert prod;

        OrderApi__Item_Class__c itemclass = FS_TestUtils.createItemClass('testItemClass');
        insert itemclass;
        OrderApi__Item__c item = FS_TestUtils.createItem('testItem',itemclass.Id);
        item.FS_Linked_Product__c = prod.Id;
        insert item;
        //Create  pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
        );
        insert pbEntry;

        //create opportunity line item
        OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 5,
                PricebookEntryId = pbEntry.Id,
                TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;

        FS_OppRoutingRule RoutingRule = new FS_OppRoutingRule(oppList);
        FS_OppRoutingRule.Constructor fscc = new FS_OppRoutingRule.Constructor();
        fscc.construct(oppList);

        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id,StageName,AccountId,ContactId,
        (SELECT Id,OpportunityId,Product2Id,UnitPrice,Quantity FROM OpportunityLineItems WHERE Product2Id!=NULL),
        (SELECT Id,Contact.Name,ContactId FROM OpportunityContactRoles WHERE IsPrimary = TRUE)
        FROM Opportunity WHERE Id = :opp.Id]);

        Opp.StageName = 'Closed Won';
        update opp;

        RoutingRule.afterUpdate(oppMap);
        OrderApi__Sales_Order__c salesOrder = [SELECT Id,OrderApi__Account__c FROM OrderApi__Sales_Order__c WHERE OrderApi__Account__c =: opp.AccountId  ];
        System.assertNotEquals(salesOrder.Id,NULL);
    }
}