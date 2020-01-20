@isTest(seeAllData=false)
private class CEP_SiemensIdAuthLoginContTest {
    static testMethod void testCreateAndUpdateUser() {
        
        CEP_SiemensIdAuthLoginCont handler = new CEP_SiemensIdAuthLoginCont();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuse8888r@example.org', null, 'testuserlong', 'en_US', '0SOe00000004CKk',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        
        Profile profile =[SELECT Id FROM Profile WHERE Profile.Name LIKE 'Cube Community User' LIMIT 1];
        
        Account TSTAccount= new Account (Name='TSTAccount', shippingCountry='United States', BillingCountry='United States');
        insert TSTAccount;
        
        String randomStr = System.now().getTime()+'-'+String.valueOf(Math.round(Math.random() * 100));
        Contact TSTContact = new Contact(AccountId=TSTAccount.Id, FirstName='testFirst', LastName='testLast',Email=randomStr+'testuse8888r@test.com');
        insert TSTContact;
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Profile.Name LIKE 'System%Admin%' LIMIT 1];
        User adminUser = [SELECT Id,Name FROM User WHERE Profile.Id=:adminProfile.Id AND IsActive=true LIMIT 1];
        User commUser = new User(Alias = 'newUser', Email=randomStr+'testuse8888r@test.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = profile.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName=randomStr+'testuse8888r@test.com');

        
        System.runAs(adminUser){
            
            commUser.ContactId=TSTContact.Id;
            commUser.IsActive=true;
            insert commUser;
        }
        
        User usr=new User();
        try{
            usr=handler.createUser('0SOe00000004CKk',sampleData);
        }catch(Exception ex){
            System.assertEquals('No matching user found', ex.getMessage());
        }
        
        String uid = commUser.id;
        
        sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                       'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', '0SOe00000004CKk',
                                       null, new Map<String, String>{});
        try{
            handler.updateUser(uId, '0SOe00000004CKk', sampleData);
        }catch(Exception ex){
            System.assertEquals('No matching user found', ex.getMessage());
        }
    }
}