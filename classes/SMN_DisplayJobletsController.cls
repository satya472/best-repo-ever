/*
 * Author : Jens Becker
 * Description: The Class Queries the Work packages and Worklet item Objects and display the records.
                Updates the Status of the Worklet item. Add New Worklet items to the current record.
 * Related To: SMN_DisplayJobletsCmp
 * Test Class: SMN_DisplayJobletsControllerTest
 */
public class SMN_DisplayJobletsController {


    /*
     * Description : The method Queries the Worklet items related to the Current record and also Queries the WorkPackages
                     related to the Current record and its related Child object(If Selected from UI) and displays only the 
                     new Work Packages for addition when the user wants to add the work Packages as Worklet items and already
                     added Worklet Items are displayed in seperate grid on UI.
     */
    @AuraEnabled
    public static JobWrapper getListTodisplay(string recordId,string recordObject, sObject currentRecord,string fieldSetName,string fieldSetNameWorkPackage, String parentChildRelatedField, string childObjectName ){
        
        //try{
            
            JobWrapper result=new JobWrapper();
            //Creation of the worklets
            
            FieldSetDetails_Util.lightningTableWrapper result1=new FieldSetDetails_Util.lightningTableWrapper();
            List<FieldSetDetails_Util.lightningTableColumnWrapper> lstTableColumn = new list<FieldSetDetails_Util.lightningTableColumnWrapper>();
            
            //Fetch the Field Details from Fieldset (worklet)
            lstTableColumn = FieldSetDetails_Util.getFieldDetails('Worklet_Item__c',fieldSetName);

            List<String> workletItemFields = new List<String>();
            for(FieldSetDetails_Util.lightningTableColumnWrapper fieldColumn : lstTableColumn){
                 workletItemFields.add(fieldColumn.fieldName);
             }
            
            String soqlString = 'Select Work_Package_ID__c,Id, Name, Due_Date__c, Status__c,Job_Task__c FROM Worklet_Item__c WHERE Parent_Context_ID__c =\'' + recordId + '\' ORDER BY Name DESC';
            List<Worklet_Item__c> WorkletsList = new List<Worklet_Item__c>();
            WorkletsList = database.query(soqlString);            
            
            
            result1.tableRecord=WorkletsList;
            result1.tableColumn = lstTableColumn;
            
            result.workletTableWrapper=result1;    
            
            
            //creation of work Packages
            FieldSetDetails_Util.lightningTableWrapper result2=new FieldSetDetails_Util.lightningTableWrapper();
            List<FieldSetDetails_Util.lightningTableColumnWrapper> lstTableColumnWorkPackage = new list<FieldSetDetails_Util.lightningTableColumnWrapper>();
            
            //Fetch the Field Details from Fieldset (work Package)
            lstTableColumnWorkPackage = FieldSetDetails_Util.getFieldDetails('Work_Package__c',fieldSetNameWorkPackage);

            List<String> workPackageFields = new List<String>();
            for(FieldSetDetails_Util.lightningTableColumnWrapper fieldColumn : lstTableColumnWorkPackage){
                 workPackageFields.add(fieldColumn.fieldName);
             }
            
            List<string> listOfExistingWorkPackages=new List<string>();

            String soqlStringWorkPackages = 'SELECT  Id,OwnerId,Name,Sequence_Order__c,Status__c,CreatedDate,Article_Link__c,'+
                    'Auto_Enroll__c,Business_Units__c,Context_Object__c,ContextField__c,ContextValue__c,ContextChildObject__c,Context_User__c,'+
                    'Mandatory__c,Period__c,Period_Type__c,Product__c,Segments__c,Job_Link__c,'+
                    'Visibility__c,Work_Description__c,Work_Division__c,Use_workpackage_owner__c '+
                    ' FROM Work_Package__c WHERE Status__c =\'Active\' AND Context_Object__c = \''+ recordObject +'\'';

            if((WorkletsList!=null)&&(WorkletsList.size()!=0)){

                for(Worklet_Item__c worklet:  WorkletsList){
                    if(worklet.Work_Package_ID__c!=null){
                        listOfExistingWorkPackages.add('\''+worklet.Work_Package_ID__c+'\'');
                    }else{
                        listOfExistingWorkPackages.add(worklet.Work_Package_ID__c);
                    }
                    
                }

                soqlStringWorkPackages += ' AND Id NOT IN'+ listOfExistingWorkPackages +' ';
            }

            List<sObject> childRec = new List<sObject>();
            if(string.isNotBlank(childObjectName)){

                childRec = Database.query('Select Id from '+childObjectName+' Where '+parentChildRelatedField+' = \''+ recordId + '\'');

            }
             
                soqlStringWorkPackages += ' ORDER BY Sequence_Order__c ASC';

                List<Work_Package__c>  workPackagesList = new List<Work_Package__c>();
                List<Work_Package__c>  finalWorkPackagesList = new List<Work_Package__c>();
                workPackagesList = database.query(soqlStringWorkPackages);      

                for(Work_Package__c wp: workPackagesList){
                    if(string.isBlank(wp.ContextChildObject__c) && string.isNotBlank(wp.ContextField__c) && string.valueOf(currentRecord.get(wp.ContextField__c)) == wp.ContextValue__c){
                        finalWorkPackagesList.add(wp);
                    }else if(!childRec.isEmpty() && string.isNotBlank(wp.ContextChildObject__c) && string.isNotBlank(childObjectName) && wp.ContextChildObject__c == childObjectName){
                        finalWorkPackagesList.add(wp);
                    } 
                   
                }   
                
                result2.tableRecord = finalWorkPackagesList;
                result2.tableColumn = lstTableColumnWorkPackage;  
                
                result.workPackageTableWrapper=result2;           
            
            return result;
            
    }
    
    @AuraEnabled
    public static void updateWorkletStatus(string workletId,string newStatus){
        try{
            List<Worklet_Item__c> worklet=[
                SELECT Id, Name,Status__c
                FROM Worklet_Item__c
                WHERE Id=:workletId
                Limit 1
            ];
            
            if((worklet!=null)&&(worklet.size()!=0)){
                worklet[0].Status__c = newStatus;
                update worklet;
            }
            
        }catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());    
        }
        
    }
    
    @AuraEnabled
    public static void createWorklets(string selectedWorkPackages_str,string recordId,sObject currentRecord){
        
        try{
            //get list of work package selected 
            List<Work_Package__c> selectedWorkPackages=new List<Work_Package__c>();
            selectedWorkPackages = (List<Work_Package__c>)System.JSON.deserialize(selectedWorkPackages_str, List<Work_Package__c>.class);
            
            //Work package to --> Worklet mapping
            List <Worklet_Item__c> workletsToCreate=new List<Worklet_Item__c>();
            for(Work_Package__c workPackage:selectedWorkPackages){
                Worklet_Item__c worklet=new  Worklet_Item__c ();
                worklet.Work_Package_ID__c=workPackage.Id;
                worklet.Sequence__c=workPackage.Sequence_Order__c;
                worklet.Parent_Context_ID__c=recordId;
                worklet.Job_Task__c=workPackage.Work_Description__c;
                
                decimal period=workPackage.Period__c;
                Date finalDate;
                DateTime dueDate;
                DateTime now = datetime.now();
                
               if(period != null && period > 0){   
                if(workPackage.Period_Type__c=='Hours'){
                    dueDate=now.addHours(period.intValue());
                }
                if(workPackage.Period_Type__c=='Days'){
                    dueDate=now.addDays(period.intValue());
                }
                if(workPackage.Period_Type__c=='Weeks'){
                    dueDate=now.addDays((period.intValue())*7);
                }
                
                 finalDate = date.newinstance(dueDate.year(), dueDate.month(), dueDate.day());
               }else{
                   finalDate = date.newinstance(now.year(), now.month(), now.day());
               }
                
                worklet.Due_Date__c = finalDate;

                /* resolving the responsible owner
                1. Default to '' in order to have the creator of the worklet being assigned
                2. Check if we have a named workpackage owner to be used "Use_workpackage_owner__c = false"
                 */

                String workletOwnerId ='';

                if(workpackage.Use_workpackage_owner__c){
                    workletOwnerId = (String) workpackage.OwnerId;

                }else{
                    string contextUser=workpackage.Context_User__c;

                    if(!String.isEmpty(contextUser))
                    {
                        workletOwnerId= (String) currentRecord.get(contextUser);
                    }
                }
                
                if(workletOwnerId != null && workletOwnerId != '' )
                {
                	worklet.OwnerId= workletOwnerId;
                }

                worklet.Status__c='Open';
                worklet.Name=workPackage.Name;
                workletsToCreate.add(worklet);
                
            }
            if(!workletsToCreate.isEmpty())
            {
            	insert workletsToCreate;
            }
        }catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());    
        }
        
    }
    
    
     /*
     * ClassName: JobWrapper
     * description : Wrapper class for storing the records for worklets + work Packages lists to display
     */
    public class JobWrapper{
        
        @AuraEnabled
        public FieldSetDetails_Util.lightningTableWrapper workletTableWrapper{get;Set;}
        
        @AuraEnabled
        public FieldSetDetails_Util.lightningTableWrapper workPackageTableWrapper{get;set;}
        
    }
     
}