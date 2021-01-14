/**
 * Created by daweima on 2019-06-26.
 */

public class FS_FieldSetMember {
    public FS_FieldSetMember(Schema.FieldSetMember f, String objApiName) {
        this.DBRequired = f.DBRequired;
        this.APIName = f.fieldPath;
        this.Label = f.label;
        this.Required = f.required;
        this.Type = String.valueOf(f.getType());
        this.objApiName = objApiName;

        Schema.DescribeFieldResult apiDescribe = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap().get(this.APIName).getDescribe();

        this.isFormula = apiDescribe.isCalculated();
        if (this.Type.toLowerCase() == 'picklist') {
            this.isDependent = apiDescribe.isDependentPicklist();
            if (this.isDependent) {
//                System.debug('field is dependent');
                this.controllingField = apiDescribe.getController().getDescribe().Name;
//                System.debug('controlling field is: ');
//                System.debug(this.controllingField);
            }
            this.setPickListValue();
        }
    }

    public FS_FieldSetMember(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }

    private void setPickListValue() {
        List<PicklistValues> pickListValuesList = new List<PicklistValues>();

        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objApiName).getDescribe().fields.getMap().get(this.APIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for( Schema.PicklistEntry pickListVal : ple){
            PicklistValues p = new PicklistValues(false,pickListVal.getLabel(),pickListVal.getValue());
            pickListValuesList.add(p);
        }
        this.pickListValues = pickListValuesList;
    }

    @AuraEnabled
    public Boolean DBRequired { get;set; }

    @AuraEnabled
    public String APIName { get;set; }

    @AuraEnabled
    public String Label { get;set; }

    @AuraEnabled
    public Boolean Required { get;set; }

    @AuraEnabled
    public String Type { get; set; }

    @AuraEnabled
    public Boolean isFormula {get;set;}

    @AuraEnabled
    public String objApiName {get;set;}

    @AuraEnabled
    public boolean isDependent {get;set;}

    @AuraEnabled
    public String controllingField {get;set;}

    @AuraEnabled
    public List<PickListValues> pickListValues {get;set;}

    public class PicklistValues {
        public PicklistValues(Boolean active, String label, String value) {
            this.active = active;
            this.label = label;
            this.value = value;
        }
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}