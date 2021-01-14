@IsTest
public class FS_ContactFullNameInsertUpdateTest {
    @TestSetup
    private static void install() {
        
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        ROEApi.PackageScripts.install();
        CPBase.PackageScripts.install();
        LTE.PackageScripts.install();
        FDService.BUPackageScripts.install();
        DonorApi.PackageScripts.install();
        JoinApi.PackageScripts.install();
        ProgramApi.PackageScripts.install();
        PriceApi.PackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule accountJoinDateUpdate = new Framework.RoutingRule();
        accountJoinDateUpdate.apexClass = FS_ContactFullNameInsertUpdate.class.getName();
        accountJoinDateUpdate.namespace = '';
        accountJoinDateUpdate.isEnabled = true;
        accountJoinDateUpdate.sObjectName = 'Contact';
        accountJoinDateUpdate.executionOrder = 36;
        rules.add(accountJoinDateUpdate);
        Framework.Config.push(rules);
        
        List<Contact> contactList=new List<Contact>();
        
        Contact contact= new Contact(FirstName='Test',MiddleName='Check',LastName='mail',DonorApi__Suffix__c='Sr.',
                                 FS_Designation__c='Esq.',FS_Other_Designation__c='Doctor');
    
        Contact contact1= new Contact(FirstName='Test',MiddleName='Check',LastName='mailOne',DonorApi__Suffix__c='Sr.',
                                 FS_Other_Designation__c='Doctor');
    
        Contact contact2= new Contact(FirstName='Test',MiddleName='Check',LastName='mailTwo',DonorApi__Suffix__c='Sr.',
                                 FS_Other_Designation__c='Doctor',Salutation='Mr.');
       
        Contact contact3= new Contact(FirstName='Test',MiddleName='Check',LastName='mailThree',DonorApi__Suffix__c='Sr.',
                                 Salutation='Mr.');
        
        Contact contact4= new Contact(FirstName='Test',MiddleName='Check',LastName='mailFour',DonorApi__Suffix__c='Sr.',
                                 Salutation='Mr.',FS_Other_Salutation__c='Ms.');   
        
         Contact contact5= new Contact(FirstName='Test',MiddleName='Check',LastName='mailFive',DonorApi__Suffix__c='Sr.',
                                 Salutation='Mr.',FS_Other_Salutation__c='Ms.');
        contactList.add(contact);
        contactList.add(contact1);
        contactList.add(contact2);
        contactList.add(contact3);
        contactList.add(contact4);
        contactList.add(contact5);
        insert contactList;   
    }
    
    
    @IsTest
   private static void testBehaviorWithAllFeilds() {
        Test.startTest();
        
        List<Contact> conlist = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mail' LIMIT 1];
        System.assertEquals('Test Check mail, Sr., Esq.', conlist[0].FS_Full_Name__c);
        conlist[0].FirstName='tesFS';
        update conlist;
        List<Contact> conlist1 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mail' LIMIT 1];
        System.assertEquals('tesFS Check mail, Sr., Esq.',conlist1[0].FS_Full_Name__c);
       Test.stopTest();
    }
    @IsTest
   private static void testBehaviorDesignationOntherDesingation(){
        Test.startTest();
      
        List<Contact> conlist = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailOne' LIMIT 1];
        System.assertEquals('Test Check mailOne, Sr., Doctor', conlist[0].FS_Full_Name__c);
        conlist[0].FS_Designation__c='Advocate';
        update conlist;
        List<Contact> conlist1 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailOne' LIMIT 1];
        System.assertEquals('Test Check mailOne, Sr., Advocate',conlist1[0].FS_Full_Name__c);
       Test.stopTest();
    }
    @IsTest
    private static void testBehaviorSalutationDesingation(){
        Test.startTest();
        List<Contact> conlist = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailTwo' LIMIT 1];
        System.assertEquals('Test Check mailTwo, Sr., Doctor', conlist[0].FS_Full_Name__c);
        conlist[0].Salutation='Ms.';
        update conlist;
        List<Contact> conlist1 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailTwo' LIMIT 1];
        System.assertEquals('Test Check mailTwo, Sr., Doctor',conlist1[0].FS_Full_Name__c);
        Test.stopTest();
    }
      @IsTest
   private static void testBehaviorNullDesingation(){
        Test.startTest();
        List<Contact> conlist = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailThree' LIMIT 1];
        System.assertEquals('Mr. Test Check mailThree, Sr.', conlist[0].FS_Full_Name__c);
        conlist[0].Salutation='Ms.';
        update conlist;
        List<Contact> conlist1 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailThree' LIMIT 1];
        System.assertEquals('Ms. Test Check mailThree, Sr.',conlist1[0].FS_Full_Name__c);
       Test.stopTest();
    }
      @IsTest
    private static void testBehaviorSalutation(){
        Test.startTest();
        List<Contact> conlist = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailFour' LIMIT 1];
        System.assertEquals('Mr. Test Check mailFour, Sr.', conlist[0].FS_Full_Name__c);
        conlist[0].FS_Other_Designation__c='Lawyer;Doctor';
        update conlist;
        List<Contact> conlist1 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailFour' LIMIT 1];
        System.assertEquals('Test Check mailFour, Sr., Lawyer;Doctor',conlist1[0].FS_Full_Name__c);
        conlist1[0].FS_Other_Designation__c = '';
        update conlist1;
        List<Contact> conlist2 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailFour' LIMIT 1];
        System.assertEquals('Mr. Test Check mailFour, Sr.',conlist2[0].FS_Full_Name__c);
        Test.stopTest();
}
      @IsTest
    private static void testBehaviorNullOtherSalutation(){
        Test.startTest();
        List<Contact> conlist = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailFive' LIMIT 1];
        System.assertEquals('Mr. Test Check mailFive, Sr.', conlist[0].FS_Full_Name__c);
        conlist[0].Salutation='';
        update conlist;
        List<Contact> conlist1 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailFive' LIMIT 1];
        System.assertEquals('Ms. Test Check mailFive, Sr.',conlist1[0].FS_Full_Name__c);
        conlist1[0].FS_Other_Designation__c='Fighter';
        update conlist1;
        List<Contact> conlist2 = [SELECT Id,FS_Full_Name__c FROM Contact WHERE LastName ='mailFive' LIMIT 1];
        System.assertEquals('Test Check mailFive, Sr., Fighter',conlist2[0].FS_Full_Name__c);
        Test.stopTest();
    }
}