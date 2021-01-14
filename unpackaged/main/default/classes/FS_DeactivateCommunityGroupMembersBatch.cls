/**
 * Created by David Ma on 4/6/2020.
 */

global without sharing class FS_DeactivateCommunityGroupMembersBatch implements Database.Batchable<SObject>, Schedulable{
    private Boolean firstRun = true;
    private static final String ACTIVE_STATUS = 'Active';
    private static final String DEACTIVATED_STATUS = 'Deactivated';
    private static final Integer BATCH_SIZE = 50;

    private static final String ACTIVE_CGM_QUERY = 'SELECT Id, ' +
            '(SELECT Id, FS_Is_Active__c, FS_Deactivated_Manually__c, ' +
            'FS_Term_Start_Date__c, FS_Term_End_Date__c, FS_Term_Grace_Period_End_Date__c ' +
            'FROM Community_Group_Member_Terms__r WHERE FS_Deactivated_Manually__c = FALSE) ' +
            'FROM PagesApi__Community_Group_Member__c WHERE PagesApi__Status__c = \'Active\'';


    private static final String DEACTIVATED_CGMT_QUERY = 'SELECT Id, FS_Community_Group_Member__r.PagesApi__Status__c, '+
            'FS_Term_Start_Date__c, FS_Term_End_Date__c, FS_Term_Grace_Period_End_Date__c ' +
           ' FROM FS_Community_Group_Member_Term__c ' +
            'WHERE FS_Is_Active__c = TRUE AND FS_Community_Group_Member__r.PagesApi__Status__c = \'Deactivated\'';

    global FS_DeactivateCommunityGroupMembersBatch(Boolean firstRun) {
        if(firstRun == null) {
            firstRun = true;
        }
        this.firstRun = firstRun;
    }

    global FS_DeactivateCommunityGroupMembersBatch() {
        if(this.firstRun == null) {
            this.firstRun = true;
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = firstRun ? ACTIVE_CGM_QUERY : DEACTIVATED_CGMT_QUERY;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (firstRun) {
            this.findDeactivateCGMWithActiveTerm(scope);
        } else {
            this.findActiveTermWithDeactivatedCGM(scope);
        }
    }

    global void finish(Database.BatchableContext bc) {
        if(firstRun) {
            Database.executeBatch(new FS_DeactivateCommunityGroupMembersBatch(false), BATCH_SIZE);
        }

    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new FS_DeactivateCommunityGroupMembersBatch(true), BATCH_SIZE);
    }

    private void findActiveTermWithDeactivatedCGM(List<FS_Community_Group_Member_Term__c> scope) {
        List<Id> CGMIds = new List<Id>();
        List<PagesApi__Community_Group_Member__c> CGMList = new List<PagesApi__Community_Group_Member__c>();
        // date array: [StartDate,EndDate,GraceEndDate]
        Map<Id, Date[]> CGMIdToDateArray = new Map<Id, Date[]>();
        if (scope.size() > 0) {
            for (FS_Community_Group_Member_Term__c currTerm : scope) {
                CGMIds.add(currTerm.FS_Community_Group_Member__r.Id);
                if (currTerm.FS_Term_Start_Date__c <= System.today() &&
                        currTerm.FS_Term_End_Date__c > System.today() && (
                        currTerm.FS_Term_Grace_Period_End_Date__c == null ||
                        currTerm.FS_Term_Grace_Period_End_Date__c > System.today())) {
                    Date[] dateArray = new List<Date>();
                    dateArray.add(currTerm.FS_Term_Start_Date__c);
                    dateArray.add(currTerm.FS_Term_End_Date__c);
                    dateArray.add(currTerm.FS_Term_Grace_Period_End_Date__c);
                    CGMIdToDateArray.put(currTerm.FS_Community_Group_Member__r.Id, dateArray);
                }
            }

            CGMList = [SELECT Id, PagesApi__Status__c FROM PagesApi__Community_Group_Member__c WHERE Id IN :CGMIds];
            for (PagesApi__Community_Group_Member__c cgm : CGMList) {
                Date[] dateArray = CGMIdToDateArray.get(cgm.Id);
                cgm.PagesApi__Status__c = ACTIVE_STATUS;
                if (dateArray != null) {
                    cgm.FS_Term_Start_Date__c = dateArray[0];
                    cgm.FS_Term_End_Date__c = dateArray[1];
                    cgm.FS_Grace_Period_End_Date__c = dateArray[2];
                }
            }

            update CGMList;
        }
    }

    private void findDeactivateCGMWithActiveTerm(List<PagesApi__Community_Group_Member__c> scope) {
        List<PagesApi__Community_Group_Member__c> CGMList = new List<PagesApi__Community_Group_Member__c>();
        for (PagesApi__Community_Group_Member__c cgm : scope) {
            Boolean hasActive = false, updateDate = false;
            for (FS_Community_Group_Member_Term__c term : cgm.Community_Group_Member_Terms__r) {
                if (term.FS_Is_Active__c) {
                    hasActive = true;
                    if ((term.FS_Term_Start_Date__c == null || term.FS_Term_Start_Date__c >= System.today())  && (term.FS_Term_End_Date__c == null || term.FS_Term_End_Date__c < System.today()) && (
                            term.FS_Term_Grace_Period_End_Date__c== null || term.FS_Term_Grace_Period_End_Date__c < System.today())) {
                        cgm.FS_Term_Start_Date__c = term.FS_Term_Start_Date__c;
                        cgm.FS_Term_End_Date__c = term.FS_Term_End_Date__c;
                        cgm.FS_Grace_Period_End_Date__c = term.FS_Term_Grace_Period_End_Date__c;
                        updateDate = true;
                    }
                }
            }

            if (!hasActive || updateDate) {
                if (!hasActive) {
                    cgm.PagesApi__Status__c = DEACTIVATED_STATUS;
                }
                CGMList.add(cgm);
            }
        }
        update CGMList;
    }
}