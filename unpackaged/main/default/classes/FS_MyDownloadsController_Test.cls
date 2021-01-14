@isTest
private class FS_MyDownloadsController_Test {
    static Boolean isInstalled = false;
    private static void install() {  
        if (!isInstalled) {
            Framework.Installer.install();
            PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            isInstalled = true;
        }
    } 
    
    static testmethod void MyDownloads_ControllerTest(){
        install();
        
        FS_TestHelper.CommunityUserHelper userInit = new FS_TestHelper.CommunityUserHelper();
        
        FS_TestHelper.ItemHelper itemClassInit = new FS_TestHelper.ItemHelper(false, true, false, true, true);
        itemClassInit.addItem(true, true, true, true);
        itemClassInit.addItem(true, true, true, true);
        
        FS_TestHelper.BadgeHelper badge1 = new FS_TestHelper.BadgeHelper('Test Badge1', true, true);
        badge1.assigneeItem(itemClassInit.itemsId);
        badge1.assigneeUser(new List<Id>{userInit.testContact.Id}, true, Date.today().addDays(-5), Date.today().addDays(5));
        
        FS_TestHelper.BadgeHelper badge2 = new FS_TestHelper.BadgeHelper('Test Badge2', true, true);
        badge2.assigneeUser(new List<Id>{userInit.testContact.Id}, true, Date.today().addDays(-10), Date.today().addDays(5));
        badge2.assigneeItem(itemClassInit.itemsId);
        
        FS_TestHelper.SalesOrderHelper salesOrder = new FS_TestHelper.SalesOrderHelper(userInit.testContact.Id, true, 'Closed', 'Posted', System.today()-5);
        salesOrder.addLines(itemClassInit.itemsId, userInit.testContact.Id);
        Test.startTest();
        System.runAs(userInit.testUser) {
            List<FS_MyDownloadsController.SectionWrapper> sections = FS_MyDownloadsController.fetchSections();
            System.assert(sections.size() > 0);
            
        }
        Test.stopTest();
    }
    
    static testmethod void MyDownloads_ControllerEmptyTest(){
        install();
        FS_TestHelper.CommunityUserHelper userInit = new FS_TestHelper.CommunityUserHelper();
        Test.startTest();
        System.runAs(userInit.testUser) {
            List<FS_MyDownloadsController.SectionWrapper> sections = FS_MyDownloadsController.fetchSections();
            System.assert(sections.size() == 0);
            
        }
        Test.stopTest();
    }
    

    @isTest static void communityStyleTest(){
        install();
        
        LTE__Site__c site = new LTE__Site__c();
        site.Name = 'test site';
        site.FS_My_Downloads_Column_Color__c = '#6666ff';
        site.FS_My_Downloads_Link_Color__c = '#00cc66';
        insert site;
        
        LTE__Site__c site1=[select Id,FS_My_Downloads_Column_Color__c,FS_My_Downloads_Link_Color__c FROM LTE__Site__c WHERE ID =:Site.Id];
        String themeColour=site1.FS_My_Downloads_Column_Color__c+' '+site1.FS_My_Downloads_Link_Color__c;
        System.assertNotEquals((FS_MyDownloadsController.communityStyle()),themeColour);
        Id ConId=FS_MyDownloadsController.getContactId();
        System.assertEquals(Null, conId);
        FS_MyDownloadsController.fetchSections();
       
		
    }
}