/*
* -----------------------------------------------------------------------------
* Controller for MyDownloads.component
* -----------------------------------------------------------------------------
*/
public without sharing class FS_MyDownloadsController {
    
    public static Id getContactId() {
        Id ContactId;
        String UserId = UserInfo.getUserId();
        List<User> lu = [SELECT Id, ContactId FROM User WHERE Id=: UserId];
        if (lu != null && !lu.isEmpty()) {
            ContactId = lu[0].ContactId;
        }
        return ContactId;
    }
    
    private static User getUser() {
        User currentUser;
        String UserId = UserInfo.getUserId();
        List<User> lu = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.ParentId FROM User WHERE Id=:UserId];
        if (lu != null && !lu.isEmpty()) {
            currentUser = lu[0];
        }
        return currentUser;
    }
    
    @AuraEnabled
    public static List<SectionWrapper> fetchSections() {
        List<SectionWrapper> Sections = new List<SectionWrapper>();
        User currentUser = getUser();
        List<OrderApi__Sales_Order_Line__c> purchasedItem = getPurchasedItems(currentUser.ContactId);
        if (!purchasedItem.isEmpty()) {
            SectionWrapper purchasedSection = new SectionWrapper();
            purchasedSection.setPurchasedSection(purchasedItem);
            purchasedSection.Items.sort();
            Sections.add(purchasedSection);
        }
        List<OrderApi__Access_Permission__c> badgeItems = getItemBadges(currentUser);
        if (!badgeItems.isEmpty()) {
            Map<Id, List<OrderApi__Access_Permission__c>> mapSectionsBadge = new Map<Id, List<OrderApi__Access_Permission__c>>();
            for (OrderApi__Access_Permission__c ap: badgeItems) {
                if (mapSectionsBadge.get(ap.OrderApi__Badge_Type__c) == NULL) {
                    mapSectionsBadge.put(ap.OrderApi__Badge_Type__c, new List<OrderApi__Access_Permission__c>{ap});
                }
                else {
                    mapSectionsBadge.get(ap.OrderApi__Badge_Type__c).add(ap);
                }
            }
            for (List<OrderApi__Access_Permission__c> lap: mapSectionsBadge.values()) {
                SectionWrapper badgeSection = new SectionWrapper();
                badgeSection.setBadgeSection(lap);
                badgeSection.Items.sort();
                Sections.add(badgeSection);
            }
            
        }
        
        Sections.sort();
        return Sections;
    }
    
    @AuraEnabled
    public static List<OrderApi__Sales_Order_Line__c> getPurchasedItems(Id customerId) {
        List<OrderApi__Sales_Order_Line__c> results = new List<OrderApi__Sales_Order_Line__c>();
        if (customerId != null) {
            results = [SELECT Id,
                       OrderApi__Item__r.Id,
                       OrderApi__Item__r.OrderApi__Download_File_Name__c,
                       OrderApi__Item__r.OrderApi__Download_File_Type__c,
                       OrderApi__Item__r.OrderApi__Download_File_Location__c,
                       OrderApi__Item__r.OrderApi__Maximum_Number_of_Downloads__c,
                       OrderApi__Item__c,
                       OrderApi__Sales_Order__r.OrderApi__Posted_Date__c,
                       OrderApi__Item__r.OrderApi__Image_Path__c,
                       OrderApi__Item__r.OrderApi__Display_Name__c
                       FROM OrderApi__Sales_Order_Line__c
                       WHERE OrderApi__Item__r.FS_Downloadable_Item__c = TRUE
                       AND OrderApi__Contact__c = : customerId
                       //AND OrderApi__Item__r.OrderApi__Is_Active__c = TRUE--for NYSBA-613
                       AND OrderApi__Item__r.FS_Is_Published__c = TRUE // added for NYSBA-613 
                       AND OrderApi__Sales_Order__r.OrderApi__Is_Posted__c = TRUE
                       AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c = 'Posted'
                       AND OrderApi__Item__r.OrderApi__Download_File_Location__c != NULL
                       AND OrderApi__Item__r.FS_Community_Site__r.LTE__Community_ID__c =: (Id)Network.getNetworkId()
                       ORDER BY OrderApi__Sales_Order__r.OrderApi__Posted_Date__c DESC];
        }
        return results;
    }
    
    @auraEnabled
    public static List<OrderApi__Access_Permission__c> getItemBadges(User currentUser) {
        List<OrderApi__Access_Permission__c> results = new List<OrderApi__Access_Permission__c>();
        if (currentUser != null) {
            Set<Id> badgeIds = new Set<Id>();
            for(OrderApi__Badge__c o : [SELECT OrderApi__Badge_Type__r.Id FROM OrderApi__Badge__c WHERE 
                                        ((OrderApi__Contact__c != null AND OrderApi__Contact__c =: currentUser.Contactid) OR
                                         (OrderApi__Account__c !=null AND OrderApi__Account__c =: currentUser.Contact.AccountId and OrderApi__Account__r.OrderApi__Disable_Badge_Flow_down__c = false AND OrderApi__Badge_Type__r.OrderApi__Enable_Badge_Flow_down__c = true) OR
                                         (OrderApi__Account__c != null AND (OrderApi__Account__c =: currentUser.Contact.Account.ParentId OR OrderApi__Account__c =: currentUser.Contact.AccountId) AND OrderApi__Badge_Type__r.OrderApi__Enable_Badge_Flow_down__c = true AND (OrderApi__Account__r.OrderApi__Disable_Badge_Flow_down__c = false AND OrderApi__Account__c =: currentUser.Contact.Account.ParentId)))
                                        AND (OrderApi__Expired_Date__c > TODAY OR OrderApi__Expired_Date__c = NULL)
                                        AND (OrderApi__Awarded_Date__c <= TODAY OR OrderApi__Awarded_Date__c = NULL)
                                        ORDER BY OrderApi__Badge_Type__c DESC Limit 100]){
                                            
                                            badgeIds.add(o.OrderApi__Badge_Type__r.Id);
                                        }
            
            results =  [SELECT Id,
                        OrderApi__Item__r.id,
                        OrderApi__Item__r.OrderApi__Download_File_Name__c,
                        OrderApi__Item__r.OrderApi__Download_File_Type__c,
                        OrderApi__Item__r.OrderApi__Download_File_Location__c,
                        OrderApi__Item__r.OrderApi__Maximum_Number_of_Downloads__c,
                        OrderApi__Item__r.OrderApi__Image_Path__c,
                        OrderApi__Item__r.OrderApi__Display_Name__c,
                        OrderApi__Item__c,
                        OrderApi__Item__r.FS_Publication_Date__c,
                        OrderApi__Badge_Type__r.Name,
                        OrderApi__Badge_Type__r.OrderApi__Image_Location__c,
                        OrderApi__Badge_Type__c
                        FROM OrderApi__Access_Permission__c
                        WHERE   OrderApi__Badge_Type__r.Id IN: badgeIds
                        AND OrderApi__Item__r.FS_Downloadable_Item__c = TRUE
                        //AND OrderApi__Item__r.OrderApi__Is_Active__c = TRUE -- for NYSBA - 613
                        AND OrderApi__Item__r.OrderApi__Enable_Access_Permissions__c = TRUE
                        AND OrderApi__Item__r.OrderApi__Download_File_Location__c != NULL
                        AND OrderApi__Badge_Type__r.OrderApi__Is_Active__c = TRUE
                        AND OrderApi__Badge_Type__r.OrderApi__Is_Published__c = TRUE
                        AND OrderApi__Item__r.FS_Publication_Date__c != NULL
                        AND OrderApi__Item__r.FS_Is_Published__c = TRUE
                        AND OrderApi__Item__r.FS_Community_Site__r.LTE__Community_ID__c =: (Id)Network.getNetworkId()
                        ORDER BY OrderApi__Badge_Type__r.Name DESC];
        }
        return results;
    }
    
    
    public class SectionWrapper implements Comparable {
         @auraEnabled public  Date lastPostedSection { get; set; }
         @auraEnabled public  Boolean isPurchasedSection { get; set; }
         @auraEnabled public  String SectionName { get; set; }
         @auraEnabled public  String anchorTag { get; set; }
         @auraEnabled public  String imageBadge { get; set; }
         @auraEnabled public  List<SectionItemWrapper> Items { get; set; }
        
        
        public void setPurchasedSection(List<OrderApi__Sales_Order_Line__c> listSOL) {
            this.isPurchasedSection = true;
            this.anchorTag = 'PIS';
            this.Items = new List<SectionItemWrapper>();
            for (OrderApi__Sales_Order_Line__c sol: listSOL) {
                SectionItemWrapper sectionItem = new SectionItemWrapper();
                if (this.lastPostedSection == NULL) {
                    this.lastPostedSection = sol.OrderApi__Sales_Order__r.OrderApi__Posted_Date__c;
                }
                else if (this.lastPostedSection < sol.OrderApi__Sales_Order__r.OrderApi__Posted_Date__c) {
                    this.lastPostedSection = sol.OrderApi__Sales_Order__r.OrderApi__Posted_Date__c;
                }
                sectionItem.postedDate = sol.OrderApi__Sales_Order__r.OrderApi__Posted_Date__c;
                sectionItem.postedDateSt = sectionItem.postedDate.format();
                sectionItem.downloadFileName = sol.OrderApi__Item__r.OrderApi__Download_File_Name__c;
                sectionItem.fileType = sol.OrderApi__Item__r.OrderApi__Download_File_Type__c.toUpperCase();
                sectionItem.downloadLocation = sol.OrderApi__Item__r.OrderApi__Download_File_Location__c;
                sectionItem.itemName = sol.OrderApi__Item__r.OrderApi__Display_Name__c;
                sectionItem.itemImage = sol.OrderApi__Item__r.OrderApi__Image_Path__c;
                Items.add(sectionItem);
            }
        }
        
        
        public  void setBadgeSection(List<OrderApi__Access_Permission__c> listAP) {
            this.isPurchasedSection = false;
            this.Items = new List<SectionItemWrapper>();
            for (OrderApi__Access_Permission__c ap: listAP) {
                SectionItemWrapper sectionItem = new SectionItemWrapper();
                if (this.lastPostedSection == NULL) {
                    this.lastPostedSection = ap.OrderApi__Item__r.FS_Publication_Date__c;
                }
                else if (this.lastPostedSection < ap.OrderApi__Item__r.FS_Publication_Date__c) {
                    this.lastPostedSection = ap.OrderApi__Item__r.FS_Publication_Date__c;
                }
                if (this.anchorTag == null) {
                    this.anchorTag = ap.OrderApi__Badge_Type__c;
                }
                if (this.SectionName == null) {
                    this.SectionName = ap.OrderApi__Badge_Type__r.Name;
                }
                if (this.imageBadge == null && !String.isBlank(ap.OrderApi__Badge_Type__r.OrderApi__Image_Location__c)) {
                    this.imageBadge = ap.OrderApi__Badge_Type__r.OrderApi__Image_Location__c;
                }
                
                
                
                sectionItem.postedDate = ap.OrderApi__Item__r.FS_Publication_Date__c;
                sectionItem.postedDateSt = sectionItem.postedDate.format();
                sectionItem.downloadFileName = ap.OrderApi__Item__r.OrderApi__Download_File_Name__c;
                sectionItem.fileType = ap.OrderApi__Item__r.OrderApi__Download_File_Type__c.toUpperCase();
                sectionItem.downloadLocation = ap.OrderApi__Item__r.OrderApi__Download_File_Location__c;
                sectionItem.itemName = ap.OrderApi__Item__r.OrderApi__Display_Name__c;
                sectionItem.itemImage = ap.OrderApi__Item__r.OrderApi__Image_Path__c;
                Items.add(sectionItem);
            }
        }
        
        public  Integer compareTo(Object compareTo) {
            SectionWrapper sectionOne = (SectionWrapper) compareTo;
            if (lastPostedSection == sectionOne.lastPostedSection) return 0;
            if (lastPostedSection < sectionOne.lastPostedSection) return 1;
            return -1;
        }
    }
    
    public class SectionItemWrapper implements Comparable {
         @auraEnabled public  Date postedDate { get; set; }
         @auraEnabled public  String postedDateSt { get; set; }
         @auraEnabled public  String downloadFileName { get; set; }
         @auraEnabled public  String fileType { get; set; }
         @auraEnabled public  String downloadLocation { get; set; }
         @auraEnabled public  String itemName { get; set; }
         @auraEnabled public  String itemImage { get; set; }
        
     
        public Integer compareTo(Object compareTo) {
            SectionItemWrapper itemOne = (SectionItemWrapper) compareTo;
            if (postedDate == itemOne.postedDate) return 0;
            if (postedDate < itemOne.postedDate) return 1;
            return -1;
        }
    }
    
    /*
        @desc added community branding styling 
    */
    @auraEnabled
    public static String communityStyle(){
        String themeColor;
        
        for( LTE__Site__c oTheme: [SELECT Id, FS_My_Downloads_Column_Color__c, FS_My_Downloads_Link_Color__c, LTE__Community_ID__c  from LTE__Site__c where LTE__Community_ID__c  =:(Id)Network.getNetworkId() ]){
            themeColor = oTheme.FS_My_Downloads_Column_Color__c + '*' + oTheme.FS_My_Downloads_Link_Color__c;break;
        }
        return themeColor ;
    }
}