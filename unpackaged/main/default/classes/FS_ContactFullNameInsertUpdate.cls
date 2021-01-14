global class FS_ContactFullNameInsertUpdate extends Framework.Domain {
    public FS_ContactFullNameInsertUpdate(List<Contact> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<Contact> sObjectList) {
            return new FS_ContactFullNameInsertUpdate(sObjectList);
        }
    }
    
    public override void beforeInsert() {
        Framework.Log.push(FS_ContactFullNameInsertUpdate.class.getName(),'Before Insert');
        updatingFullName((Contact[]) records);
        Framework.Log.pop();
    }
    
    public override void beforeUpdate(Map<Id, SObject> oldMap) {
        Framework.Log.push(FS_ContactFullNameInsertUpdate.class.getName(),'Before update');
        List<Contact> contactList = (List<Contact>) records;
        List<Contact> conList = new List<Contact>();
        for (Contact con : contactList) {
            Contact oldCon = (Contact)oldMap.get(con.Id);
            if(con.FirstName != oldCon.FirstName ||con.MiddleName != oldCon.MiddleName ||con.LastName != oldCon.LastName  
               || con.DonorApi__Suffix__c != oldCon.DonorApi__Suffix__c ||con.FS_Designation__c != oldCon.FS_Designation__c
               || con.FS_Other_Designation__c != oldCon.FS_Other_Designation__c || con.Salutation != oldCon.Salutation || 
               con.FS_Other_Salutation__c !=oldCon.FS_Other_Salutation__c || con.MiddleName != oldCon.MiddleName){
                   conList.add(con);
               }
            
        }
        updatingFullName(conList);
        Framework.Log.pop();
    }
    private static void updatingFullName(List<Contact> records){
        for(Contact con : records){
            if(con.LastName != null){	
                String fullName = '';  
                if(String.isNotBlank(con.FS_Designation__c) || String.isNotBlank(con.FS_Other_Designation__c)){
                    String designation = '';
                    if(String.isNotBlank(con.FS_Designation__c)){
                        if(con.FS_Designation__c.indexOf(';') >= 0){
                            designation = con.FS_Designation__c.replaceAll(';',', ');
                        }else{
                            designation = con.FS_Designation__c;
                        }   
                    }else if(String.isNotBlank(con.FS_Other_Designation__c)){
                        designation = con.FS_Other_Designation__c;
                    }
                    fullName = (String.isNotBlank(con.FirstName) ? con.FirstName +' ' : '') + (String.isNotBlank(con.MiddleName) ? con.MiddleName +' ' : '') + con.LastName +', ' +
                    (String.isNotBlank(con.DonorApi__Suffix__c) ? con.DonorApi__Suffix__c +', ' : '') + designation;
                }else{
                    fullName = (String.isNotBlank(con.Salutation) ? con.Salutation +' ' : (String.isNotBlank(con.FS_Other_Salutation__c) ? con.FS_Other_Salutation__c +' ' : '')) +
                        (String.isNotBlank(con.FirstName) ? con.FirstName +' ' : '') + (String.isNotBlank(con.MiddleName) ? con.MiddleName +' ' : '') + con.LastName  + 
                        (String.isNotBlank(con.DonorApi__Suffix__c) ? ', '+con.DonorApi__Suffix__c +' ' : '') + '';
                }
                con.FS_Full_Name__c = fullName;
            }
        }
    }
}