/**
 * Created by Nikhil on 05-07-2019.
 */
@istest
public with sharing class FS_FieldSetComponentControllerTest {

    @istest
    public static void TestgetProfilePageCSV(){

        //User ComUser = [SELECT Id from User];
        //System.runAs(new user(Id = userInfo.getUserId()));
        //System.runAs(ComUser){

        //Profile p = [select id, name from profile where name = 'Fonteva Customer Community Login User' limit 1];

            Contact c=new Contact(
                    FirstName='fname',
                    LastName = 'lname',
                    Email = 'email@gmail.com');
            insert c;

        PagesApi__Site__c ps = new PagesApi__Site__c();
                ps.Name = 'FON - Lightning Member Portal';
                ps.PagesApi__Community_Network_ID__c = '0DB4P000000kz6oWAA';
                ps.PagesApi__Community_Network_Name__c = 'Lightning Member Portal';

            insert ps;

        Network ntw = [select id, name from Network where urlPathPrefix = 'LightningMemberPortal'];
        LTE__Site__c ltes = new LTE__Site__c();
        ltes.Name = 'FON - Lightning Member Community';
        ltes.LTE__Profile_Contact_Fieldset_CSV__c = 'Address_Information, LTE__Demo_Field_Set, Contact_Information';
        ltes.LTE__Community_ID__c = ntw.Id;
        insert ltes;

        PagesApi__Site__c testsite = [SELECT PagesApi__Community_Network_ID__c, PagesApi__Community_Network_Name__c  from PagesApi__Site__c where id=:ps.id];
            string urlPathPrefix = 'LightningMemberPortal';

            FS_FieldSetComponentController newfs = new FS_FieldSetComponentController();
            FS_FieldSetComponentController.getProfilePageCSV(urlPathPrefix);
            FS_FieldSetComponentController.getLoggedInContactId();

        }


}