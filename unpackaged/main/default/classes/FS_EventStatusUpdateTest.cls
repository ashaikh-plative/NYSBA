/**
 * Created by daweima on 4/14/20.
 */

@IsTest
public class FS_EventStatusUpdateTest {
    @TestSetup
    private static void install() {

        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();

        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule eventStatusUpdate = new Framework.RoutingRule();
        eventStatusUpdate.apexClass = FS_EventStatusUpdateRule.class.getName();
        eventStatusUpdate.namespace = '';
        eventStatusUpdate.isEnabled = true;
        eventStatusUpdate.sObjectName = 'EventApi__Event_Status__c';
        eventStatusUpdate.executionOrder = 30;
        rules.add(eventStatusUpdate);
        Framework.Config.push(rules);
    }

    @IsTest
    private static void test(){
        PagesApi__Theme__c theme1 = new PagesApi__Theme__c();
        theme1.Name = 'Test Theme 1';
        theme1.PagesApi__Logo_URL__c = 'test1@test.com';
        theme1.PagesApi__Supernav_HTML_Position_1__c = '<a href="https://test1.com">Test</a>';
        theme1.PagesApi__Supernav_HTML_Position_2__c = '<a href="https://test1.com">Test</a>';
        theme1.PagesApi__Supernav_HTML_Position_3__c = '<a href="https://test1.com">Test</a>';
        insert theme1;

        PagesApi__Site__c site1 = new PagesApi__Site__c();
        site1.Name = 'Test Site 1';
        site1.PagesApi__Theme__c = theme1.Id;
        site1.PagesApi__Site_URL__c = 'https://TEST-usacpart-usacricket.cs15.force.com';
        site1.PagesApi__Profile_Page_URL__c = 'https://TEST-usacpart-usacricket.cs15.force.com/CPBase__profile?site=a0de000000CXEDZAA5';
        site1.PagesApi__User_Reset_Password_URL__c = 'https://TEST-usacpart-usacricket.cs15.force.com/CPBase__reset_password?site=a0de000000CXEDZAA5';
        site1.PagesApi__User_Self_Registration_URL__c = 'https://TEST-usacpart-usacricket.cs15.force.com/CommunitiesSelfReg?site=a0de000000CXEDZAA5';
        site1.PagesApi__User_Login_URL__c = 'https://TEST-usacpart-usacricket.cs15.force.com/CPBase__custom_login?site=a0de000000CXEDZAA5';
        site1.PagesApi__Login_Redirect_URL__c = 'https://TEST-usacpart-usacricket.cs15.force.com/CPBase__profile?site=a0de000000CXEDZAA5';
        insert site1;

        EventApi__Event__c e = new EventApi__Event__c();
        e.EventApi__Status__c = 'Planned';
        e.FS_Accounting_Approval__c = 'Request Approval';
        e.Name = 'test event';
        e.EventApi__Event_Key__c = generateRandomString(15);
        e.EventApi__Start_Time__c = '08:00 AM';
        e.EventApi__End_Time__c = '08:00 PM';
        insert e;

        EventApi__Event_Status__c active = new EventApi__Event_Status__c();
        active.EventApi__Event__c = e.Id;
        active.Name = 'Active';
        active.EventApi__Order__c = 2;
        insert active;

        EventApi__Event_Status__c planned = new EventApi__Event_Status__c();
        planned.EventApi__Event__c = e.Id;
        planned.Name = 'Planned';
        planned.EventApi__Order__c = 1;
        planned.EventApi__Is_Current_Status_for_Event__c = true;
        insert planned;

        active.EventApi__Is_Current_Status_for_Event__c = true;
        update active;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
}