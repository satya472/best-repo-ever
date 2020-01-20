/*
* Author : Phaniram Upalapati
* Description : Controller for fetching details of Track And Trace order
* Associated To : CEP_OrderComponent
* Test Class : CEPTrackAndTraceOrder_ContTest
*/
public with sharing class CEPTrackAndTraceOrder_Cont {
    
    /*
* Description: The Method is used to Query the Track and Trace records in the system based on the IFA numbers decoded and 
Prepare a Parent record for Spare parts records and push them to the UI.
* Params: The Methods Accepts the encoded format of the IFA Numbers as inputs
*/
    @AuraEnabled
    public static List<TrackTrace__c> getTrackAndTraceOrders(String encodedParam){
        
        try{  
            
            Blob blobVal = EncodingUtil.base64Decode(encodedParam);
            List<String> IFANumbers = (blobVal.toString()).split(';');

            List<TrackTrace__c> recordsLst = [Select Id,Name,Type__c,CustomerPONumber__c,SalesOrderNumber__c,CurrentStatusOrder__c,LastConfirmedDeliveryDate__c,OrderLineItemNo__c,
                                              PartNumber__c,PartDescription__c,ItemUnit__c,RequestedQuantity__c,IFANumber__c,CustomerRequestedDate__c,ProjectNumber__c,
                                              Client__c,ProposalNumber__c,ScopeSummary__c,ProjectManager__c,ProjectStatus__c,OrderEntryDate__c,CurrentStatusItem__c,ClientManager__c,EquipmentSN__c,ClientTagNumber__c,EquipmentModel__c,QuotedBy__c,
                                              Site__c,POReceived__c,IncotermSO__c,IncotermNamedPlace__c,ApproximateStartDate__c,EquipmentReceivedDate__c,QuotedShipDate__c,ActualShipDate__c,LatestMilestoneAchieved__c,FinalReportSubmitDate__c,OrderConfirmedDate__c,InitiationOfDelivery__c,ReadyToShip__c,GoodsIssueDate__c,ReceiptByForwarder__c,MaterialAtDestination__c
                                              from TrackTrace__c Where IFANumber__c IN :IFANumbers ORDER BY CustomerPONumber__c,SalesOrderNumber__c];
            
            Map<String,List<TrackTrace__c>> recordMap = new Map<String,List<TrackTrace__c>>();
            
            List<Tracktrace__c> parentLst = new List<TrackTrace__c>();
            
            /* Preparing the Map based on the Customer PO Numbers as they are the Unique identifiers to segregate the child records */
            for(TrackTrace__c rec: recordsLst){
                
                if(recordMap.get(rec.CustomerPONumber__c) == null){
                    recordMap.put(rec.CustomerPONumber__c, new List<TrackTrace__c>());
                }
                recordMap.get(rec.CustomerPONumber__c).add(rec);
            }
            
            /* Looping through the Customer PO Numbers and preparing the Parent Record from the Child records List*/
            for(String custPO: recordMap.keySet()){
                parentLst.add(prepareParentRecord(recordMap.get(custPO)));                
            }
            
            return parentLst;
            
        }catch(Exception ex){
            String msg = ex.getMessage();
            throw new AuraHandledException(msg);  
        }
    }
    
    /*
* Description: The Method is used to Prepare a parent record from the Spare Parts related records for each Customer PO Number otherwise return the same
Child record.(For Spare Parts We will be displaying a parent record in Allorders page and all the child record under details page
So we need to prepare the same but for Repair there is no such thing as of now.).
* Params: The Methods Accepts List of Child recordsi.e. Track and trace records as Input.
*/
    private static TrackTrace__c prepareParentRecord(List<TrackTrace__c> childRecLst){
        
        List<String> statusLst = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = TrackTrace__c.CurrentStatusOrder__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            statusLst.add(pickListVal.getLabel());
        }     
        
        /* If the child List has 1 record then we don't need to proceed further as the same record will be parent and child for Spare parts and for 
repair type there will not be any child records as of now.*/
        if(childRecLst.size() == 1){
            return childRecLst[0];
        } 
        
        TrackTrace__c parentRec = new TrackTrace__c();
        String finalStatus;
        Integer finalStatusIndex ;
        Integer currentRecStatusIndex;
        
        /* Loop for finding the least status from the child records list*/
        for(TrackTrace__c rec: childRecLst){
            
            if(string.isBlank(finalStatus)){
                finalStatus = rec.CurrentStatusOrder__c;
                finalStatusIndex = statusLst.indexOf(finalStatus);
            }else{
                
                currentRecStatusIndex = statusLst.indexOf(rec.CurrentStatusOrder__c);
                
                if(finalStatusIndex > currentRecStatusIndex){
                    finalStatusIndex = currentRecStatusIndex;
                    finalStatus = rec.CurrentStatusOrder__c;
                }
            }
            
            parentRec.CustomerPONumber__c = rec.CustomerPONumber__c;
            parentRec.SalesOrderNumber__c = rec.SalesOrderNumber__c;
            parentRec.Type__c = rec.Type__c;
            parentRec.ProjectNumber__c = rec.ProjectNumber__c;
            
        }
        
        parentRec.CurrentStatusOrder__c = finalStatus;

        Integer childCnt = 0;
        
        /* Loop for finding the Dates for different status to display on the Parent Spare parts records i.e. Latest date will be considered for display*/
        for(TrackTrace__c rec: childRecLst){
            
            /* Looping only till the finalStatus as we will not consider any status beyond this i.e. this will be the Least status that all the records are in(Except few records).
The latest date for Each Stage till the finalStatus will be considered for display based on the below Calculations.
*/ 
/* looping through each record and making sure that if there is any date misses then the parent's related date must be marked as empty even if single record missed the date for the record */
            for(Integer i=0;i<=finalStatusIndex;i++){
                switch on i{
                    when 0{
                        
                        if(childCnt > 0 && parentRec.OrderEntryDate__c != null && rec.OrderEntryDate__c != null){
                            parentRec.OrderEntryDate__c = parentRec.OrderEntryDate__c == null? rec.OrderEntryDate__c:(parentRec.OrderEntryDate__c.daysBetween(rec.OrderEntryDate__c)<0?parentRec.OrderEntryDate__c:rec.OrderEntryDate__c);
                        }else if(childCnt == 0){
                            parentRec.OrderEntryDate__c = rec.OrderEntryDate__c ;
                        }else{
                            parentRec.OrderEntryDate__c = null;
                        }
                    }
                    when 1{
                        if(childCnt > 0 && parentRec.OrderConfirmedDate__c != null && rec.OrderConfirmedDate__c != null){
                            parentRec.OrderConfirmedDate__c = parentRec.OrderConfirmedDate__c == null? rec.OrderConfirmedDate__c:(parentRec.OrderConfirmedDate__c.daysBetween(rec.OrderConfirmedDate__c)<0?parentRec.OrderConfirmedDate__c:rec.OrderConfirmedDate__c);
                        }else if(childCnt == 0){
                            parentRec.OrderConfirmedDate__c = rec.OrderConfirmedDate__c ;
                        }else{
                            parentRec.OrderConfirmedDate__c = null;
                        }
                        
                    }
                    when 2{

                        if(childCnt > 0 && parentRec.InitiationOfDelivery__c != null && rec.InitiationOfDelivery__c != null){
                            parentRec.InitiationOfDelivery__c = parentRec.InitiationOfDelivery__c == null? rec.InitiationOfDelivery__c:(parentRec.InitiationOfDelivery__c.daysBetween(rec.InitiationOfDelivery__c)<0?parentRec.InitiationOfDelivery__c:rec.InitiationOfDelivery__c);
                        }else if(childCnt == 0){
                            parentRec.InitiationOfDelivery__c = rec.InitiationOfDelivery__c ;
                        }else{
                            parentRec.InitiationOfDelivery__c = null;
                        }
                    }
                    when 3{

                        if(childCnt > 0 && parentRec.ReadyToShip__c != null && rec.ReadyToShip__c != null){
                            parentRec.ReadyToShip__c = parentRec.ReadyToShip__c == null? rec.ReadyToShip__c:(parentRec.ReadyToShip__c.daysBetween(rec.ReadyToShip__c)<0?parentRec.ReadyToShip__c:rec.ReadyToShip__c);
                        }else if(childCnt == 0){
                            parentRec.ReadyToShip__c = rec.ReadyToShip__c ;
                        }else{
                            parentRec.ReadyToShip__c = null;
                        }
                    }
                    when 4{

                        if(childCnt > 0 && parentRec.GoodsIssueDate__c != null && rec.GoodsIssueDate__c != null){
                           parentRec.GoodsIssueDate__c = parentRec.GoodsIssueDate__c == null? rec.GoodsIssueDate__c:(parentRec.GoodsIssueDate__c.daysBetween(rec.GoodsIssueDate__c)<0?parentRec.GoodsIssueDate__c:rec.GoodsIssueDate__c);
                        }else if(childCnt == 0){
                            parentRec.GoodsIssueDate__c = rec.GoodsIssueDate__c ;
                        }else{
                            parentRec.GoodsIssueDate__c = null;
                        }
                    }
                    when 5{

                        if(childCnt > 0 && parentRec.ReceiptByForwarder__c != null && rec.ReceiptByForwarder__c != null){
                           parentRec.ReceiptByForwarder__c = parentRec.ReceiptByForwarder__c == null? rec.ReceiptByForwarder__c:(parentRec.ReceiptByForwarder__c.daysBetween(rec.ReceiptByForwarder__c)<0?parentRec.ReceiptByForwarder__c:rec.ReceiptByForwarder__c);
                        }else if(childCnt == 0){
                            parentRec.ReceiptByForwarder__c = rec.ReceiptByForwarder__c ;
                        }else{
                            parentRec.ReceiptByForwarder__c = null;
                        }
                    }
                    when 6{
                        if(childCnt > 0 && parentRec.MaterialAtDestination__c != null && rec.MaterialAtDestination__c != null){
                           parentRec.MaterialAtDestination__c = parentRec.MaterialAtDestination__c == null? rec.MaterialAtDestination__c:(parentRec.MaterialAtDestination__c.daysBetween(rec.MaterialAtDestination__c)<0?parentRec.MaterialAtDestination__c:rec.MaterialAtDestination__c);
                        }else if(childCnt == 0){
                            parentRec.MaterialAtDestination__c = rec.MaterialAtDestination__c ;
                        }else{
                            parentRec.MaterialAtDestination__c = null;
                        }
                    }
                }
            }

            childCnt++;
        }
        
        return parentRec;
    }
    
    /*
    * Description: The Method is used to Query the child records based on the Customer PO Number.
    * Params: The Methods Accepts CustomerPO Number and FieldSet Name(Which Fields needs to be Queried)
    */
    @AuraEnabled(cacheable=true)
    public static FieldSetDetails_Util.lightningTableWrapper getTrackAndTraceChildOrderRecords(String poNumber,string fieldSetName){
        
        //Fetching the columns details i.e. fields from the fieldset
        List<FieldSetDetails_Util.lightningTableColumnWrapper> columnsLst = FieldSetDetails_Util.getFieldDetails('TrackTrace__c', fieldSetName);
        
        List<String> qryFields = new List<string>();
        
        for(FieldSetDetails_Util.lightningTableColumnWrapper fields: columnsLst){
            
            qryFields.add(string.valueof(fields.fieldName));
            
        }
        
        String qry = 'Select Id,CurrentStatusItem__c,'+string.escapeSingleQuotes(String.join(qryFields,','))+' from TrackTrace__c Where CustomerPONumber__c = \''+poNumber+'\' AND OrderLineItemNo__c != NULL';
        
        FieldSetDetails_Util.lightningTableWrapper tableWrapper = new FieldSetDetails_Util.lightningTableWrapper();
        tableWrapper.tableColumn = columnsLst;
        tableWrapper.tableRecord = Database.query(qry);
        
        return tableWrapper;
        
    }
}