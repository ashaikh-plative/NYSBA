public class FS_RollUpLeadershipRoleAndTitleService {
    public static void addOrUpdateRolesAndTitles(List<PagesApi__Community_Group_Member__c> cgmList){
        if(cgmList != null && !cgmList.isEmpty()){
            List<PagesApi__Community_Group_Member__c> updateCGMList = new List<PagesApi__Community_Group_Member__c>();
            for(PagesApi__Community_Group_Member__c cgm : cgmList){
                if(cgm.Leadership_Roles_and_Titles__r != null && !cgm.Leadership_Roles_and_Titles__r.isEmpty()){
                    List<String> updateRolesList = new List<String>();
                    List<String> updateTitlesList = new List<String>();
                    for(FS_Leadership_Role_and_Title__c roleAndTitle : cgm.Leadership_Roles_and_Titles__r){
                        updateRolesList.add(roleAndTitle.FS_Leadership_Role__c);
                        updateTitlesList.add(roleAndTitle.FS_Leadership_Title__c);
                    }
                    
                    updateCGMList.add(new PagesApi__Community_Group_Member__c(Id = cgm.Id, FS_Member_Role__c = String.join(updateRolesList,';'),
                                                                             FS_Leadership_Title__c = String.join(updateTitlesList,',')));
                }else{
                    updateCGMList.add(new PagesApi__Community_Group_Member__c(Id = cgm.Id, FS_Member_Role__c = '', FS_Leadership_Title__c = '')); 
                } 
            }
            if(!updateCGMList.isEmpty()){
                update updateCGMList;
            }
        }
    }
}