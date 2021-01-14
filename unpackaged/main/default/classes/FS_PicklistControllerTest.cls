/**
 * Created by dwu on 5/1/18.
 */

@IsTest
public with sharing class FS_PicklistControllerTest {
    private static final String CUSTOM_SETTING_NAME = 'TestPicklistSetting';

    @IsTest
    public static void testGetPicklistValues() {
        String result = FS_PicklistController.getPicklistValues(CUSTOM_SETTING_NAME, 'Contact', 'Salutation', JSON.serialize(''));

        System.assert(result.length() > 1);

    }
}