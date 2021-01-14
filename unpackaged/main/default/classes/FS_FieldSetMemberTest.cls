/**
 * Created by daweima on 2019-07-11.
 */

/**
 * Created by daweima on 2019-07-11.
 */
@IsTest
public with sharing class FS_FieldSetMemberTest {

    static testMethod void testGetResults1() {
//        FS_FieldSetMember f = new FS_FieldSetMember();
        List<Schema.FieldSetMember> fields =
                Schema.SObjectType.Contact.fieldSets.getMap().get('Address_Information').getFields();
        System.debug(fields);
        Test.startTest();
        List<FS_FieldSetMember> FSList = new List<FS_FieldSetMember>();
        for (Schema.FieldSetMember f : fields) {
            FSList.add(new FS_FieldSetMember(f, 'Contact'));
        }
        System.assertEquals(FSList.size(),fields.size());
        Test.stopTest();
    }

}