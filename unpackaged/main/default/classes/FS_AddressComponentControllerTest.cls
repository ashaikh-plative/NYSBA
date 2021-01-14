/**
 * Created by daweima on 2019-10-30.
 */

@isTest
public with sharing class FS_AddressComponentControllerTest {
    public static testMethod void dotest()
    {
        FS_AddressComponentController.getJSONCountriesAndStatesWithNone();
        FS_AddressComponentController.MyPickListInfo a = new FS_AddressComponentController.MyPickListInfo();
    }
}