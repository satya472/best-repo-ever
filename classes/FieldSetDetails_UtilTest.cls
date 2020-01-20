/*
*Author: G.Naveen Kumar
*Date:24-Jul-18
*Description: Test class for SMN_Utils
*/
@IsTest
public class FieldSetDetails_UtilTest
{
    public static testmethod void testPositive()
    {
        test.startTest();
        List<FieldSetDetails_Util.lightningTableColumnWrapper> lstWrap2 = FieldSetDetails_Util.getFieldDetails('Worklet_Item__c','SMN_WorkletListing');
        List<SObject> sobjList = new List<SObject>();
        sobjList.add(new Contact(LastName='test con'));
        FieldSetDetails_Util.lightningTableWrapper temp = new FieldSetDetails_Util.lightningTableWrapper();
        temp.tableRecord = sobjList;
        temp.tableColumn = lstWrap2;
        test.stopTest();
        
        try
        {
            List<FieldSetDetails_Util.lightningTableColumnWrapper> lstWrap3 = FieldSetDetails_Util.getFieldDetails(null,'SMN_WorkletListing');
        }
        catch(Exception ex)
        {
            system.assertequals(ex.getMessage(),'Script-thrown exception');
        }
        
    
    }
    
}