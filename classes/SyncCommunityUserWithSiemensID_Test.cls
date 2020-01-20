/*
* Author: Yash Raikwar
* Date: 14-Feb-2019
* Apex Covering: 
* 1. SyncCommunityUserWithSiemensID_TrigAct
* 2. CreateUserInSiemensId_Queueable
*/
@isTest
global class SyncCommunityUserWithSiemensID_Test {

    //Prepare setup data
    @testSetup
    static void setupTestData() 
    {
        Account custAccount = new Account( Name='Test Account');        
        insert custAccount;

        List<Contact> contactList = new List<Contact>();
        Contact custContant = new Contact(FirstName = 'Customer',LastName = 'Test',
                                        AccountId = custAccount.Id,
                                        Email = 'test.user@test.com');
        contactList.add(custContant);

        Contact custContant2 = new Contact(FirstName = 'Customer',LastName = 'Test2',
                                        AccountId = custAccount.Id,
                                        Email = 'test2.user@test.com');
        contactList.add(custContant2);

        insert contactList;
    }

    //Test Method to test community user inserted in salesforce and siemens id
    static testMethod void testNewCommunityUserPositive()
    {
        //Get community profile details to set it for new user
        List<Id> profileIdList = new List<Id>();
        profileIdList = CEPUserAccess_Util.getProfileIdByCommunityName(System.Label.CustomerCommunityName);
        Profile communityprofile = new Profile();
        communityprofile = [SELECT Id,Name,UserLicenseId,UserLicense.Name 
                            FROM Profile 
                            WHERE Id IN :profileIdList
                            AND UserLicense.Name != 'Salesforce' 
                            LIMIT 1];

        Account custAccount = new Account();
        custAccount = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Contact custContact = new Contact();
        custContact = [SELECT Id,AccountId,FirstName,LastName,Email FROM Contact WHERE Email = 'test.user@test.com' LIMIT 1];

        system.assertEquals(custAccount.Id, custContact.AccountId);

        Test.startTest();
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSiemensId_Test('new_user'));

        //Generate unique user name
        String uniqueEmail = String.valueOf(Math.round(Math.random()*1000)) +
                            string.valueOf(System.now().format('ddMMYYYhhmmss')) +
                            '@' + URL.getSalesforceBaseUrl().getHost();

        User custUser = new User( email=custContact.Email,
                                profileid = communityprofile.Id, 
                                UserName=uniqueEmail,
                                Alias = 'test123u',
                                TimeZoneSidKey='America/New_York',
                                EmailEncodingKey='ISO-8859-1',
                                LocaleSidKey='en_US', 
                                LanguageLocaleKey='en_US',
                                ContactId = custContact.Id,
                                PortalRole = 'Manager',
                                FirstName = custContact.FirstName,
                                LastName = custContact.LastName);
        insert custUser;
        
        Test.stopTest();

        User newUser = [SELECT Id,UserName,ContactId,Email
                        FROM User
                        WHERE Email = :custContact.Email
                        LIMIT 1];
        //Check if the user is created in Siemens ID by verifying the email id of the user
        system.assertEquals(custContact.Email, newUser.Email);
        system.assertEquals(custContact.Id, newUser.ContactId);
    }

    //Test Method to test non-community user inserted in salesforce
    static testMethod void testNewCommunityUserNegative()
    {
        //Get community profile details to set it for new user
        Profile communityprofile = new Profile();
        communityprofile = [SELECT Id,Name,UserLicenseId,UserLicense.Name 
                            FROM Profile 
                            WHERE Name = 'Standard User'
                            AND UserLicense.Name = 'Salesforce' 
                            LIMIT 1];

        Test.startTest();
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSiemensId_Test('password_change'));

        //Generate unique user name
        String uniqueEmail = String.valueOf(Math.round(Math.random()*1000)) +
                            string.valueOf(System.now().format('ddMMYYYhhmmss')) +
                            '@' + URL.getSalesforceBaseUrl().getHost();

        User custUser = new User( email='admin@test.com',
                                profileid = communityprofile.Id, 
                                UserName=uniqueEmail,
                                Alias = 'test123u',
                                TimeZoneSidKey='America/New_York',
                                EmailEncodingKey='ISO-8859-1',
                                LocaleSidKey='en_US', 
                                LanguageLocaleKey='en_US',
                                PortalRole = 'Manager',
                                FirstName = 'Admin',
                                LastName = 'User');
        insert custUser;
        
        Test.stopTest();

        User newUser = [SELECT Id,UserName,ContactId,Email,ProfileId
                        FROM User
                        WHERE Email = 'admin@test.com'
                        LIMIT 1];
        //Check if the user is created in Siemens ID by verifying the email id of the user
        system.assertEquals(communityprofile.Id, newUser.ProfileId);
    }

    //Test Method to test existing community user transfered to siemens id
    static testMethod void testCommunityUserTransferBulk()
    {
        //Get community profile details to set it for new user
        List<Id> profileIdList = new List<Id>();
        profileIdList = CEPUserAccess_Util.getProfileIdByCommunityName(System.Label.CustomerCommunityName);
        Profile communityprofile = new Profile();
        communityprofile = [SELECT Id,Name,UserLicenseId,UserLicense.Name 
                            FROM Profile 
                            WHERE Id IN :profileIdList
                            AND UserLicense.Name != 'Salesforce' 
                            LIMIT 1];

        Account custAccount = new Account();
        custAccount = [SELECT Id,Name FROM Account WHERE Name = 'Test Account' LIMIT 1];

        List<Contact> custContactList = new List<Contact>();
        custContactList = [SELECT Id,AccountId,FirstName,LastName,Email FROM Contact];

        system.assertEquals(custContactList.size(), 2);

        //Generate unique user name
        String uniqueEmail = String.valueOf(Math.round(Math.random()*1000)) +
                            string.valueOf(System.now().format('ddMMYYYhhmmss')) +
                            '@' + URL.getSalesforceBaseUrl().getHost();

        Test.startTest();
        
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSiemensId_Test('existing_user'));

        User custUser1 = new User( email=custContactList[0].Email,
                                profileid = communityprofile.Id, 
                                UserName='a'+uniqueEmail,
                                Alias = 'test123u',
                                TimeZoneSidKey='America/New_York',
                                EmailEncodingKey='ISO-8859-1',
                                LocaleSidKey='en_US', 
                                LanguageLocaleKey='en_US',
                                ContactId = custContactList[0].Id,
                                PortalRole = 'Manager',
                                FirstName = custContactList[0].FirstName,
                                LastName = custContactList[0].LastName);
        
        User custUser2 = new User( email=custContactList[1].Email,
                                profileid = profileIdList[0], 
                                UserName='b'+uniqueEmail,
                                Alias = 'test123u',
                                TimeZoneSidKey='America/New_York',
                                EmailEncodingKey='ISO-8859-1',
                                LocaleSidKey='en_US', 
                                LanguageLocaleKey='en_US',
                                ContactId = custContactList[1].Id,
                                PortalRole = 'Manager',
                                FirstName = custContactList[1].FirstName,
                                LastName = custContactList[1].LastName);
        List<User> userList = new List<User>();
        userList.add(custUser1);
        userList.add(custUser2);
        insert userList;

        CreateUserInSiemensId_Queueable createUsers = new CreateUserInSiemensId_Queueable(userList,0,false);
        createUsers.execute(null);
        createUsers.updateUserIdAfterInsertSync(userList[0],'1234Test4321');
        Test.stopTest();
    }
}