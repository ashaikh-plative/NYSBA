public with sharing class FS_TestHelper {
    
    public class CommunityUserHelper {
        public User testUser;
        public Contact testContact;
        public Account testAccount;
        public CommunityUserHelper () {
            testAccount = new Account();
          testAccount.Name = 'test';
          insert testAccount;
        
            testContact = new Contact();
            testContact.email = 'Test7347826838878@Test.com';
            testContact.lastname = 'Test7347826838878';
            testContact.accountid = testAccount.id;
            insert testContact;  
            
            testAccount.OrderApi__Primary_Contact__c = testContact.Id;
            update testAccount;
            testUser = new User();
          testUser.profileid = [select id from profile where userLicense.Name like '%Community%' limit 1].id; 
            testUser.Contactid = testContact.id;
            testUser.Username = testContact.Email;
            testUser.LastName = testContact.LastName;
            testUser.Email = testContact.Email;
            testUser.Alias = 'MNU'+String.ValueOf(testContact.id).right(5);
            testUser.CommunityNickname = testContact.Email;
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.languagelocalekey = 'en_US';
            testUser.timezonesidkey = 'America/Los_Angeles';
            testUser.localesidkey = 'en_US';
            testUser.IsActive = true;
            Insert testUser;
        }
    }
    
    public class ItemHelper {
        public OrderApi__Item_Class__c itemClass;
        public List<OrderApi__Item__c> items;
        public List<Id> itemsId;
        public OrderApi__Business_group__c businessGroup;
        public ItemHelper(Boolean IsEvent, Boolean IsDownloadable, Boolean IsActive, Boolean IsPublication, Boolean EnableAssignments) {
            itemClass = new OrderApi__Item_Class__c();
            itemClass.Name = 'Test item Class';
            itemClass.OrderApi__Is_Event__c = IsEvent;
            itemClass.OrderApi__Is_Downloadable__c = IsDownloadable;
            itemClass.OrderApi__Is_Active__c = IsActive;
            itemClass.OrderApi__Is_Publication__c = IsPublication;
            itemClass.OrderApi__Enable_Assignments__c = EnableAssignments;
            if (EnableAssignments) {
                itemClass.OrderApi__Assignment_SObject__c = 'Test';
            }
            this.items = new List<OrderApi__Item__c>();
            this.itemsId = new List<Id>();
            businessGroup = new OrderApi__Business_group__c();
            businessGroup.name = 'BG Test';
            insert businessGroup;
            insert itemClass;
        }
        
        public void addItem(Boolean IsActive, Boolean IsDownloadable, Boolean IsPublication, Boolean EnableAccessPermissions) {
            OrderApi__Item__c item = new OrderApi__Item__c();
            item.OrderApi__Item_Class__c = this.itemClass.Id;
            item.OrderApi__Is_Active__c = IsActive;
            item.FS_Downloadable_Item__c = IsDownloadable;
            item.OrderApi__Enable_Access_Permissions__c = EnableAccessPermissions;
            item.FS_Is_Published__c = IsPublication;
            item.OrderApi__Is_Active__c = IsActive;
            item.OrderApi__Download_File_Location__c = 'http://google.com';
            item.OrderApi__Download_File_Name__c = 'West West';
            item.OrderApi__Download_File_Type__c = 'jpg';
            item.OrderApi__Business_Group__c = this.businessGroup.Id;
            item.FS_Publication_Date__c=system.today();
            insert item;
            
            this.items.add(item);
            this.itemsId.add(item.Id);
        }
    }
    
    public class BadgeHelper {
        public OrderApi__Badge_Type__c badgeType;
        public List<OrderApi__Badge__c> badges;
        public List<OrderApi__Access_Permission__c> accessPermissions;
        public BadgeHelper(String Name, Boolean IsActive, Boolean IsPublished) {
            badgeType = new OrderApi__Badge_Type__c();
            badgeType.Name = Name;
            badgeType.OrderApi__Is_Active__c = IsActive;
            badgeType.OrderApi__Is_Published__c = IsPublished;
            badgeType.OrderApi__Image_Location__c = 'http://google.com';
            this.badges = new List<OrderApi__Badge__c>();
            this.accessPermissions = new List<OrderApi__Access_Permission__c>();
            insert badgeType;
        }
        
        public void assigneeUser(List<Id> contactsId, Boolean IsActive, Date AwardedDate, Date ExpiredDate) {
            List<OrderApi__Badge__c> lb = new List<OrderApi__Badge__c>();
            if (contactsId != null && !contactsId.isEmpty()) {
                for (Id ic: contactsId) {
                    OrderApi__Badge__c badge = new OrderApi__Badge__c();
                    badge.OrderApi__Contact__c = ic;
                    badge.OrderApi__Badge_Type__c = this.badgeType.Id;
                    badge.OrderApi__Is_Active__c = IsActive;
                    badge.OrderApi__Awarded_Date__c = AwardedDate;
                    badge.OrderApi__Expired_Date__c = ExpiredDate;
                    lb.add(badge);
                }
                insert lb;
                this.badges.addAll(lb);
            }
        }
        
        public void assigneeItem(List<Id> itemsId) {
            List<OrderApi__Access_Permission__c> apl = new List<OrderApi__Access_Permission__c>();
            if (itemsId != null && !itemsId.isEmpty()) {
                for (Id ic: itemsId) {
                    OrderApi__Access_Permission__c acess = new OrderApi__Access_Permission__c();
                    acess.OrderApi__Item__c = ic;
                    acess.OrderApi__Badge_Type__c = this.badgeType.Id;
                    apl.add(acess);
                }
                insert apl;
                system.debug('venu test'+apl);
                this.accessPermissions.addAll(apl);
            }
        }
    }
    
    public class SalesOrderHelper {
        public OrderApi__Sales_Order__c salesOrder;
        public List<OrderApi__Sales_Order_Line__c> linesSO;
        public SalesOrderHelper(Id ContactId, Boolean IsPosted, String Status, String PostingStatus, Date PostedDate) {
            salesOrder = new OrderApi__Sales_Order__c();
            salesOrder.OrderApi__Contact__c = ContactId;
            salesOrder.OrderApi__Status__c = 'Open';
            salesOrder.OrderApi__Posted_Date__c = System.today();
            insert salesOrder;
            
            salesOrder.OrderApi__Status__c = Status;
            salesOrder.OrderApi__Is_Posted__c = IsPosted;
            salesOrder.OrderApi__Posting_Status__c = PostingStatus;
            salesOrder.OrderApi__Posted_Date__c = PostedDate;
            update salesOrder;
            this.linesSO = new List<OrderApi__Sales_Order_Line__c>();
        }
        public void addLines(List<Id> ItemsId, Id ContactId) {
            if (ItemsId != null && !ItemsId.isEmpty()) {
                List<OrderApi__Sales_Order_Line__c> listLine = new List<OrderApi__Sales_Order_Line__c>();
                for (Id idi: ItemsId) {
                    OrderApi__Sales_Order_Line__c line = new OrderApi__Sales_Order_Line__c();
                    line.OrderApi__Sales_Order__c = this.salesOrder.Id;
                    line.OrderApi__Item__c = idi;
                    line.OrderApi__Contact__c =  ContactId;
                    listLine.add(line);
                }
                insert listLine;
              this.linesSO.addAll(listLine);
            }
            
        }
        
        
    }
    
}