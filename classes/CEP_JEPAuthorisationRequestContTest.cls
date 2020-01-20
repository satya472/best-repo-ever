@isTest(seeAllData=false)
private class CEP_JEPAuthorisationRequestContTest {
    private testMethod static void testCEP_JEPAuthorisationRequestCont(){
        String uniqueVal = String.valueOf(Math.random()*10);
        CEP_JEPAuthorisationRequestCont.sendMailMethod(uniqueVal+'@testOrg.com', 'Test FirstName', 'Test LastName', 'Test Account', 'Test Plant', 'Test Equipment');
    }
}