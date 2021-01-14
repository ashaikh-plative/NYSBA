/**
 * Created by daweima on 2019-10-30.
 */

public class FS_AddressComponentController {

    public class MyPickListInfo {
        public String validFor;
    }

    @AuraEnabled
    public static Map<String, Object> getJSONCountriesAndStatesWithNone() {
        Map<String, List<Map<String, String>>> controllingInfo = new Map<String, List<Map<String, String>>>();
        List<Map<String, String>> countriesInfo = new List<Map<String, String>>();

        countriesInfo.add(new Map<String, String>{'value' => 'US', 'label' => 'United States'});
        countriesInfo.add(new Map<String, String>{'value' => 'CA', 'label' => 'Canada'});

        Schema.DescribeFieldResult controllingFieldInfo = User.countrycode.getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = User.statecode.getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            controllingInfo.put(currControllingValue.getValue(), new List<Map<String, String>>());
            if (!currControllingValue.getValue().equals('US') && !currControllingValue.getValue().equals('CA')) {
                countriesInfo.add(new Map<String, String>{'value' => currControllingValue.getValue(), 'label' => currControllingValue.getLabel()});
            }
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;

            Map<String, String> temp = new Map<String, String>();
            temp.put('label', currDependentValue.getLabel());
            temp.put('value', currDependentValue.getValue());

            for (Integer curr : hexString.getChars()) {
                Integer val = 0;
                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }

                if ((val & 8) == 8) {
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(temp);
                }
                if ((val & 4) == 4) {
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(temp);
                }
                if ((val & 2) == 2) {
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(temp);
                }
                if ((val & 1) == 1) {
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(temp);
                }
                baseCount += 4;
            }
        }
        for (String key : controllingInfo.keySet()) { 
            if (controllingInfo.get(key).size() == 0) {
                controllingInfo.get(key).add(new Map<String, String>{'value' => 'none', 'label' => '--None--'});
            }
        }
        Map<String, Object> result = new Map<String, Object>();
        result.put('countriesInfo', countriesInfo);
        result.put('statesInfo', controllingInfo);
        return result;
    }
}