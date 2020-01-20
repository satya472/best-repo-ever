/*
* Author : Phaniram Upalapati
* Description : Controller for fetching details of Customer Segmentation Details i.e. 
*               SegmentationAttributeValue records based on the Category selected.
* Associated To : CustomerSegmentation and DisplayCustomerSegmentationProducts component
* Test Class : CustomerSegmentation_ContTest
*/
global class CustomerSegmentation_Cont extends VisualEditor.DynamicPickList{
    
    
    /*
    * Description: Method to fetch the default value for the Design attribute Picklist field.
    */ 
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None','None');
        
        return defaultValue;
    }
    
    /*
    * Description: Method to fetch the picklist values to display as part of Design Attributes
    *              Where user selects the values
    */ 
    global override VisualEditor.DynamicPickListRows getValues(){
        
        VisualEditor.DataRow defaultValue = getDefaultValue();
        List<SegmentationCategory__mdt> categoryRows = [Select Id,MasterLabel,DeveloperName from SegmentationCategory__mdt];
        
        VisualEditor.DynamicPickListRows categoryDetails = new VisualEditor.DynamicPickListRows();
        
        for(SegmentationCategory__mdt category: categoryRows){
            categoryDetails.addRow(new VisualEditor.DataRow(category.MasterLabel,String.valueOf(category.DeveloperName)));
        }
        
        return categoryDetails;
    }
    
    /*
    * Description: Method fetches the details of the SegmentationAttributes based on the category and current record id values
    * Input Param: Id - Id of the selected category record
    *              Id - Id of the current record based on which records are filtered
    * Return Type: List<SegmentationWrapper> - Wrapper List Containing records of SegmentationAttributes custom metadata
    *              Which are mapped to SegmentationAttributeValues.
    */ 
    
    @AuraEnabled
    public static List<SegmentationWrapper> getSegmentationAttributes(String categoryDevName,Id recordId){
        
        List<SegmentationCategory__mdt> segCategory = [Select Id,MasterLabel,DeveloperName from SegmentationCategory__mdt Where DeveloperName = :categoryDevName LIMIT 1];
        
        Id categoryId = segCategory[0].Id;
        
        List<PermissionSetAssignment> assignment = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.Name = :Label.ProductSegmentationPermissionSet];

        Boolean editEnabled = assignment.size() > 0?true:false;
        
        //fetching the SegmentationAttributeValue__c records if there are any for the current record
        List<SegmentationAttributeValue__c> segAttrVal = getSegmentationDetails(categoryId,recordId);
        
        //If the method returns null that means the recordId passed does not belong to Account,Contact or Product2
        if(segAttrVal == null){
            throw new AuraHandledException(Label.SegmentationRecordIdError);
        }
        
        //SegmentationAttribute custom metadata records
        Map<Id,SegmentationAttribute__mdt> segAttrMap = new Map<Id,SegmentationAttribute__mdt>([Select Id,MasterLabel,SegmentationCategory__c,SegmentationCategory__r.MasterLabel,Type__c,Values__c from SegmentationAttribute__mdt Where SegmentationCategory__c=:categoryId ORDER BY MasterLabel ASC]);
        
        List<SegmentationWrapper> segWrapperList = new List<SegmentationWrapper>();
        
        //Checking of any record already Exists in SegmnentationAttributeValue object with same Category and attribute as
        //SegementationAttribute custom metada record. If there is a map found then we are preparing the wrapper record with
        //the details.
        Boolean matchFound = false;
        for(SegmentationAttribute__mdt seg: segAttrMap.values()){
            matchFound = false;
            for(SegmentationAttributeValue__c val: segAttrVal){
                if(val.Category__c.equalsIgnoreCase(seg.SegmentationCategory__r.MasterLabel) 
                   && val.Attribute__c.equalsIgnoreCase(seg.MasterLabel)){
                       segWrapperList.add(new SegmentationWrapper(val.SegmentationHeaderId__c,val.Id,val.Value__c,seg,editEnabled));
                       matchFound = true;
                   }
            }
            //If there is no match found we are just adding the SegementationAttribute custom metadata record
            if(!matchFound){
                segWrapperList.add(new SegmentationWrapper('','','',seg,editEnabled));
            }
        }
        
        return segWrapperList;
    }
    
    /*
    * Description: Method Saves the details of the SegmentationAttributes records
    * Input Param: recordList - Json String containing details of List of SegmentationWrapper records
    *              Id - Id of the current record
    * Return Type: String - returning success string if all goes well.
    */ 
    
    @AuraEnabled
    public static String saveSegmentationAttributes(String recordList,Id recordId){
        
        List<SegmentationWrapper> wrapperRecords = (List<SegmentationWrapper>)JSON.deserialize(recordList,List<SegmentationWrapper>.class);
        
        List<Id> recordLst = new List<Id>();
        recordLst.add(recordId);
        
        //Finding out if there is a SegmentationHeader Exists with the current Record Id or not
        List<SegmentationHeader__c>  segHeaderLst = getSegmentationHeaderDetail(recordLst);
        Id segHeaderId;
        //If there is no record first we need to created one before inserting SegmentationAttributeValue record
        if(segHeaderLst.isEmpty()){
            String objName = recordId.getSObjectType().getDescribe().getName();
            SegmentationHeader__c segHeader = new SegmentationHeader__c();
            if(objName.equalsIgnoreCase('Account')){
                segHeader.AccountId__c = recordId;
            }else if(objName.equalsIgnoreCase('Asset')){
                segHeader.AssetId__c = recordId;
            }else{
                segHeader.Product2Id__c = recordId;
            }
            
            try{
                insert segHeader;
                segHeaderId = segHeader.Id;
            }catch(Exception e){
                throw new AuraHandledException(Label.SegmentationHeaderInsertionError+e.getMessage());
            }
        }else{
            segHeaderId = segHeaderLst[0].Id;
        }
        
        //Creating SegmentationAttributeValue__c records and Upserting the same so that if the record
        //already Exists updation will happen otherwise Insertion will happen.
        List<SegmentationAttributeValue__c> segAttrList = new List<SegmentationAttributeValue__c>();
        SegmentationAttributeValue__c segAttr;
        for(SegmentationWrapper segWrap: wrapperRecords){
            segAttr = new SegmentationAttributeValue__c();
            
            if(!string.isBlank(segWrap.segAttrValId)){
                segAttr.Id = segWrap.segAttrValId;
            }
            segAttr.SegmentationHeaderId__c = segHeaderId;
            segAttr.Category__c = segWrap.segAtt.SegmentationCategory__r.MasterLabel;
            segAttr.Attribute__c = segWrap.segAtt.MasterLabel;
            segAttr.Value__c = segWrap.currentValue;
            
            segAttrList.add(segAttr);
        }
        
        try{
            Upsert segAttrList;
        }catch(Exception ex){
            throw new AuraHandledException(Label.SegmentationAttributeUpdationError+ex.getMessage());
        }
        return 'success';
    }
    
    
    /*
    * Description: Method fetched the details of the SegmentationAttributes records if already available in the
    *              system which satisfies the criteria.
    * Input Param: Id - Id of the selected category record
    *              Id - Id of the current record based on which records are filtered
    * Return Type: List<SegmentationAttributeValue__c> - returning list of SegmentationAttributeValue__c records.
    */ 
    private static List<SegmentationAttributeValue__c> getSegmentationDetails(Id categoryId,Id recordId){
        
        List<Id> recordLst = new List<Id>();
        recordLst.add(recordId);
        
        List<SegmentationHeader__c>  segHeaderLst = getSegmentationHeaderDetail(recordLst);
        //If null is returned that means the recordId is not matching the required Object Name
        if(segHeaderLst == null){
            return null;
        }
        
        List<SegmentationCategory__mdt> segCategory = [Select Id,MasterLabel,DeveloperName from SegmentationCategory__mdt Where Id = :categoryId LIMIT 1];
        
        return [Select Id,Name,SegmentationHeaderId__c,Category__c,Attribute__c,Value__c from SegmentationAttributeValue__c 
                where SegmentationHeaderId__c in :segHeaderLst AND Category__c = :segCategory[0].MasterLabel ORDER By Attribute__c ASC];
    }
    
    
    /*
    * Description: Method fetched the details of the SegmentationHeader__c records if already available in the
    *              system which satisfies the criteria.
    * Input Param: List<Id> - List of recordIds to support different Functions i.e. Products fetching
    * Return Type: List<SegmentationHeader__c> - returning list of SegmentationHeader__c records.
    */ 
    private static  List<SegmentationHeader__c> getSegmentationHeaderDetail(List<Id> recordIdList){
        
        if(recordIdList.isEmpty()){
            return null;
        }
        String objName = recordIdList[0].getSObjectType().getDescribe().getName();
        
        String queryString = 'Select Id,Name,AccountId__c,AssetId__c,Product2Id__c from SegmentationHeader__c Where ';
        
        if(objName.equalsIgnoreCase('Account')){
            queryString = queryString + 'AccountId__c IN :recordIdList';
        }else if(objName.equalsIgnoreCase('Asset')){
            queryString = queryString + 'AssetId__c IN :recordIdList';
        }else if(objName.equalsIgnoreCase('Product2')){
            queryString = queryString + 'Product2Id__c IN :recordIdList';
        }else{
            return null;
        }
        
        List<SegmentationHeader__c>  headerList = Database.query(queryString);
        
        return headerList;
        
    }
    
    /*
    * Description: Method fetches the details of the Products records Which are having segmentationsAttribute records and a priceBook entry
    *              with currency as Accounts Currency.
    *              On Account record - Fetches all the Products from the pricebook entry with currency as account Currency and checks for Segmentation availability.
    *                                  It will fetch all the Assets(Trains) Which are having segmentations and otherwise fetched the Segmentation of its parent
    *                                  asset(Plant) and compares all the products with the each Asset Segmentation and displays them on to the screen.
    *                                  Ex: 10 products, 1 Plant, 2 Trains - total 20 records will be displayed onto screen i.e 10 products Segmentation is
    *                                      Compared to the 2 Trains Segmentation and relevance is calculated.  
    *              On Asset - Behaves same as mentioned for account record. If it is on train only the Segmentation of the train is compared. If it is on Plant
    *                         all the trains under that plant are used for relevance calculation and details are displayed onto screen.
    *              If there are no Trains associated to the Plants in both scenarios i.e. on Account or on Asset(Plant) error will be thrown on to screen.
    * Input Param: Id - Id of the selected category record
    *              Id - Id of the current record based on which records are filtered
    * Return Type: DetailsWrapper - Contains details of List of productWrappers and Assets(Train) Picklist to filter the data.
    */ 
    @AuraEnabled
    public static DetailsWrapper getProducts(String categoryDevName,Id recordId){

            List<SegmentationCategory__mdt> segCategory = [Select Id,MasterLabel,DeveloperName from SegmentationCategory__mdt Where DeveloperName = :categoryDevName LIMIT 1];
            
            Id categoryId = segCategory[0].Id;
            
            String objName = recordId.getSObjectType().getDescribe().getName();
            
            Id accountId;
            String priceBookId;
            String currencyCode;
            String oppRecordTypeId;
            List<Asset> assetRecLst = new List<Asset>();
            List<Asset> trainLst = new List<Asset>();
            Asset assetRec;

            //Opportunity RecordTypeId(Complex Bid)
            oppRecordTypeId = [Select Id from RecordType Where SObjectType='Opportunity' AND DeveloperName = 'ComplexBid' LIMIT 1].Id;

            //Preparing the fields from fieldSet
            List<String> oppFields= new List<String>();
            for(Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.ProductSegmentationFieldSet.getFields()) {
                oppFields.add(f.getFieldPath());
            }

            //Fetching the SegmentationHeader Details of the products inorder to reduce the Count of Products Displayed onto Screen.                 
            Map<Id,SegmentationHeader__c>  headerList = new Map<Id,SegmentationHeader__c>([Select Id,Name,AccountId__c,AssetId__c,Product2Id__c from SegmentationHeader__c Where Product2Id__c != '']);
             if(headerList == null || headerList.isEmpty()){
                throw new AuraHandledException(Label.SegmentationProductsErrorMsg);
            }

            Map<Id,SegmentationHeader__c> prodWithSegHeader = new Map<Id,SegmentationHeader__c>();
            List<Id> productIds = new List<Id>();

            for(SegmentationHeader__c seg : headerList.values()){

                prodWithSegHeader.put(seg.Product2Id__c,seg);
                productIds.add(seg.Product2Id__c);

            }

            
            //based on the recordId identifying the Object and fetching its account details to proceed further
            if(objName.equalsIgnoreCase('Asset')){
                assetRec = [Select Id,Name,AccountId,Account.CurrencyIsoCode,Account.Price_Book__c,ParentId,RecordType.DeveloperName from Asset Where Id = :recordId LIMIT 1];
                accountId = assetRec.AccountId;
                priceBookId = assetRec.Account.Price_Book__c;
                currencyCode = assetRec.Account.CurrencyIsoCode;
                assetRecLst.add(assetRec);
                if(assetRec.RecordType.DeveloperName.equalsIgnoreCase('Plant')){
                    string recId = ((String)recordId).substring(0,15);
                    List<Asset> assetLst = [Select Id,Name,AccountId,Account.CurrencyIsoCode,Account.Price_Book__c,ParentId,RecordType.DeveloperName from Asset Where RootAssetId = :recId AND RecordType.DeveloperName = 'Train'];
                    assetRecLst.addAll(assetLst);
                    trainLst.addAll(assetLst);
                }else{
                    //If it is from Train level then add the parent Plant record to use if there is no segmentation on Train level
                    List<Asset> parentAssetRec = [Select Id,Name,AccountId,Account.CurrencyIsoCode,Account.Price_Book__c,ParentId,RecordType.DeveloperName from Asset Where Id = :assetRec.ParentId AND RecordType.DeveloperName = 'Plant' LIMIT 1];
                    if(!parentAssetRec.isEmpty()){
                        assetRecLst.add(parentAssetRec[0]);
                    }
                    trainLst.add(assetRec);
                    
                }
            }else{
                Account accRec = [Select Id,CurrencyIsoCode,Price_Book__c from Account Where Id = :recordId LIMIT 1];
                accountId = accRec.Id;
                priceBookId = accRec.Price_Book__c;
                currencyCode = accRec.CurrencyIsoCode;
                
                //Fetching assets related to the Account
                assetRecLst = [Select Id,Name,ParentId,RecordType.DeveloperName from Asset Where AccountId = :accountId AND RecordType.DeveloperName IN ('Plant','Train')];  
                
                for(Asset assetRecord: assetRecLst){
                    if(assetRecord.RecordType.DeveloperName.equalsIgnoreCase('Train')){
                        trainLst.add(assetRecord);
                    }
                }
            }
        
            if(trainLst.isEmpty()){
                    throw new AuraHandledException('No Assets(Train) are associated to the '+objName);
            }
          
            //PriceBook Details
                List<PriceBook2> priceBook;
                if(string.isNotBlank(priceBookId)){
                   priceBook = [Select Id,Name from PriceBook2 Where Id = :priceBookId AND IsActive = true LIMIT 1];
                }else{
                   priceBook = [Select Id,Name from PriceBook2 Where Name= 'Standard Price Book' AND IsActive = true LIMIT 1];
                }
                   
                if(priceBook.isEmpty()){
                    throw new AuraHandledException('PriceBook is Inactive. Please make sure Price Book is Active');
                }
                priceBookId = priceBook[0].Id;

            //Get all pricebook entries
            List<PricebookEntry> pbe = [SELECT Id,Name,Pricebook2Id,Product2Id,UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :priceBookId AND currencyIsoCode = :currencyCode AND IsActive = true AND Product2Id IN :productIds];
           
            //Create a map to relate pricebook products
            Map<Id, PricebookEntry> prodPricemap = new Map <Id, PricebookEntry>();
            
            //Iterate pbe and write map
            for (Integer i = 0; i < pbe.size(); i++) {
                prodPricemap.put(pbe.get(i).Product2Id, pbe.get(i));
            }
        
            //Fetching Product Details
            Map<Id,Product2> productMap = new Map<Id,Product2>([Select Id,Name,ProductCode,Asset__c,status__c,Outage_Type__c from Product2 Where Id in :prodPricemap.keySet() AND IsActive = true]);

            if(productMap == null || productMap.isEmpty() || pbe == null){
                throw new AuraHandledException(Label.SegmentationProductsError);
            }
            
        
            //Holding SegmentationHeader Details of proudcts Which are having PriceBookEntries only
            List<SegmentationHeader__c>  segHeaderLst = new List<SegmentationHeader__c>();

            //Preparing PickListWrapper of Outage type in product object
            List<PickListWrapper> outageWrapper = new List<PickListWrapper>();
           
            Map<Id,SegmentationHeader__c> productsWithSegmentation = new Map<Id,SegmentationHeader__c>();
            set<string> outageTypeSet = new Set<string>();
            for(Id prodId : productMap.keySet()){
                if(prodWithSegHeader.containsKey(prodId)){
                   productsWithSegmentation.put(prodId,prodWithSegHeader.get(prodId));
                   segHeaderLst.add(prodWithSegHeader.get(prodId));
                   if(string.isNotBlank(productMap.get(prodId).Outage_Type__c) && outageTypeSet.add(productMap.get(prodId).Outage_Type__c)){
                      outageWrapper.add(new PickListWrapper(productMap.get(prodId).Outage_Type__c,productMap.get(prodId).Outage_Type__c));
                   }
                }
                
            }
            
            //Preparing PickListWrapper for the Trian Assets so that Products are filtered based on the selected value i.e. Asset Name will be used as filter
            List<PickListWrapper> assetsWrapper = new List<PickListWrapper>();
            
            for(Asset rec: trainLst){
                assetsWrapper.add(new PickListWrapper(rec.Name,rec.Name));
            }
            
            
            //Fetching the BlackListed Product Details related to the recordId passed
            List<PotentialAnalysisBlacklist__c> blackListedRecs;
            
            if(objName.equalsIgnoreCase('Asset')){
                blackListedRecs = [Select Id,Name,AccountId__c,Reason__c,AssetId__c,Product2Id__c from PotentialAnalysisBlacklist__c Where AssetId__c = :recordId];
            }else{
                blackListedRecs  = [Select Id,Name,AccountId__c,Reason__c,AssetId__c,Product2Id__c from PotentialAnalysisBlacklist__c Where AccountId__c = :recordId];
            }
            
            
            //Creating Map for ProductId and BlackListed record so that it can be used when we want pull the Product back from the blacklisted list
            Map<Id,PotentialAnalysisBlacklist__c> blackListedProdMap = new Map<Id,PotentialAnalysisBlacklist__c>();
            
            for(PotentialAnalysisBlacklist__c pb : blackListedRecs){
                blackListedProdMap.put(pb.Product2Id__c,pb);
            }
            
            List<String> productRelevance = new List<String>();

                //SegmentationHeader and SegmentationAttributeValue
                List<Id> segAvailAsset = new List<Id>();
                List<Id> assetSegFetch = new List<Id>();
             
                List<SegmentationHeader__c>  assetSegHeaderLst = [Select Id,Name,AssetId__c from SegmentationHeader__c Where AssetId__c IN :assetRecLst];
               
                if(assetSegHeaderLst == null || assetSegHeaderLst.isEmpty()){
                    throw new AurahandledException(Label.SegmentationAssetError);
                }

                 //Fetching Asset SegmentationAttributeValue records
                List<SegmentationAttributeValue__c> segAttrList = [Select Id,Name,SegmentationHeaderId__c,SegmentationHeaderId__r.AssetId__c,SegmentationHeaderId__r.AssetId__r.Name,SegmentationHeaderId__r.Product2Id__c,SegmentationHeaderId__r.Product2Id__r.Name,Weight__c,Category__c,Attribute__c,Value__c from SegmentationAttributeValue__c 
                                                                        where (SegmentationHeaderId__c In :assetSegHeaderLst OR SegmentationHeaderId__c In :segHeaderLst)AND Category__c = :segCategory[0].MasterLabel ORDER By Attribute__c ASC];
                
                
                //Preparing Map for Assetid and it is segmentaion attribute Value List i.e. grouping all the segmentation attribute value records based on ProductId
                Map<Id,List<SegmentationAttributeValue__c>> assetSegMap = new Map<Id,List<SegmentationAttributeValue__c>>();
               
                //Preparing Map for ProductId and it is segmentaion attribute Value List i.e. grouping all the segmentation attribute value records based on ProductId
                Map<Id,List<SegmentationAttributeValue__c>> prodSegMap = new Map<Id,List<SegmentationAttributeValue__c>>();


                List<SegmentationAttributeValue__c> segMapLst;
                for(SegmentationAttributeValue__c lst : segAttrList){

                   if(string.isNotBlank(lst.SegmentationHeaderId__r.AssetId__c)){
                       if(assetSegMap.containsKey(lst.SegmentationHeaderId__r.AssetId__c)){
                            segMapLst = assetSegMap.get(lst.SegmentationHeaderId__r.AssetId__c);
                            segMapLst.add(lst);
                            assetSegMap.put(lst.SegmentationHeaderId__r.AssetId__c, segMapLst);
                        }else{
                            segMapLst = new List<SegmentationAttributeValue__c>();
                            segMapLst.add(lst);
                            assetSegMap.put(lst.SegmentationHeaderId__r.AssetId__c, segMapLst);
                        }
                   }else if(string.isNotBlank(lst.SegmentationHeaderId__r.Product2Id__c)){
                          if(prodSegMap.containsKey(lst.SegmentationHeaderId__r.Product2Id__c)){
                                segMapLst = prodSegMap.get(lst.SegmentationHeaderId__r.Product2Id__c);
                                segMapLst.add(lst);
                                prodSegMap.put(lst.SegmentationHeaderId__r.Product2Id__c, segMapLst);
                          }else{
                                segMapLst = new List<SegmentationAttributeValue__c>();
                                segMapLst.add(lst);
                                prodSegMap.put(lst.SegmentationHeaderId__r.Product2Id__c, segMapLst);
                          }
                   } 
                    
                }
                              
                //Calculating Product relevance
                productRelevance = getProductRelevance(trainLst,prodSegMap,assetSegMap);

            List<ProductsWrapper> productWrapperList = new List<ProductsWrapper>();
            
            for(String prdRel : productRelevance){
                String[] data = prdRel.split(';');//(Asset Name ; Asset Id ; productId ; ProductRelevance)
                productWrapperList.add(new ProductsWrapper(data[2],
                                                           Label.Util_LtngURLFormat1+data[2]+Label.Util_LtngURLFormat2,
                                                           productMap.get(data[2]).ProductCode,
                                                           accountId,
                                                           currencyCode,
                                                           productMap.get(data[2]).Name,
                                                           Double.valueOf(data[3]),
                                                           (Double)prodPricemap.get(data[2]).Unitprice,
                                                           productMap.get(data[2]).status__c,
                                                           data[0],
                                                           Label.Util_LtngURLFormat1+data[1]+Label.Util_LtngURLFormat2,
                                                           prodPricemap.get(data[2]).Id,
                                                           blackListedProdMap.containsKey(data[2]),
                                                           blackListedProdMap.containsKey(data[2])? ((PotentialAnalysisBlacklist__c)blackListedProdMap.get(data[2])).Id:null,
                                                           blackListedProdMap.containsKey(data[2])? 'utility:check': 'utility:close',
                                                           blackListedProdMap.containsKey(data[2])? ((PotentialAnalysisBlacklist__c)blackListedProdMap.get(data[2])).Reason__c:'',
                                                           priceBookId,
                                                           productMap.get(data[2]).Outage_Type__c
                                                          ));
            }  
            
            DetailsWrapper fullWrapper = new DetailsWrapper(assetsWrapper,productWrapperList,oppRecordTypeId,oppFields,outageWrapper);
            
            return fullWrapper;
        
    }
    
    
    /*
    * Description: Method Creates Opportunity and its related Opportunity Line Item records
    * Input Param: String - Json format of the selected records from the UI
    *              String - AccountId to pass to the Opportunity Creation
    * Return Type: String -  Created Opportunity Record Id.
    */ 
    @AuraEnabled
    public static opportunity createOpportunities(String selData,String accountId,String code,String oppInput){
        //Deserializign the data
        List<ProductsWrapper> selectedRec = (List<ProductsWrapper>)JSON.deserialize(selData,List<ProductsWrapper>.class);
        //SavePoint
        Savepoint sp = Database.setSavepoint();
        
        //Opportunity record Creation 
        Opportunity oppRec = (Opportunity)JSON.deserialize(oppInput,Opportunity.class);
        try {  
            oppRec.StageName = Label.SegmentationOpportunityStageName;
            oppRec.AccountId = accountId;
            oppRec.CurrencyIsoCode = code;
            oppRec.Pricebook2Id = selectedRec[0].priceBookId;
            
            insert oppRec;
        } catch (DmlException e){
            throw new AuraHandledException('Please try again.Exception in Opportunity Record Creation: '+e.getMessage());
        }
        
        //Opportunity Line Item Creation
        OpportunityLineItem[] Products = new List<OpportunityLineItem>();
        try {
            for (Integer i = 0; i < selectedRec.size(); i++) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId=oppRec.Id;
                oli.Quantity=1;
                oli.Product2Id=selectedRec[i].productId;
                oli.UnitPrice= selectedRec[i].price;
                oli.PricebookEntryId = selectedRec[i].priceBookEntryId;
                
                Products.add(oli);
            }
            
            insert Products;
        } catch(Exception e){
            //Rolling back before Opportunity Creation.As the OpportunityLineItems Creation Failed We make sure
            //that opportunity is also rolled back so that user can insert them once again
            Database.rollback(sp);
            throw new AuraHandledException('Please try again.Exception in Insertion of Opportunity LineItems: '+e.getMessage());
        }

        return oppRec;
                
    }
    
    /*
    * Description: Method Removes or add product records to BlackListed details i.e. PotentialAnalysisBlacklist__c object
    * Input Param: String - Json format of the selected records from the UI
    *              String - AccountId to pass to the Opportunity Creation
    * Return Type: string - message to the aura component.
    */ 
    @AuraEnabled
    public static string blackListProducts(String selData, boolean addtoBlackList, Id recordId,String reason){
        
        String objName = recordId.getSObjectType().getDescribe().getName();
        
        ProductsWrapper pw = (ProductsWrapper)JSON.deserialize(selData, ProductsWrapper.class);
        try{
            //Creating new PotentialAnalysisBlacklist__c record i.e. blacklisting a product
            if(addtoBlackList && !pw.blackListed){
                PotentialAnalysisBlacklist__c newRec = new PotentialAnalysisBlacklist__c();
                newRec.Product2Id__c = pw.productId;
                newRec.Reason__c = reason;
                if(objName.equalsIgnoreCase('Asset')){
                    newRec.AssetId__c = recordId;
                }else{
                    newRec.AccountId__c = pw.accountId;
                }
                
                insert newRec;
                
                return Label.SegmentationBlacklistSuccess;
            }else{
                //Pulling back the record from Blacklisting
                PotentialAnalysisBlacklist__c rec = [Select Id,Name from PotentialAnalysisBlacklist__c Where Id = :pw.blackListRecordId LIMIT 1];
                Delete rec;
                return Label.SegmentationUndoBlacklistSuccess;
            }
        }catch(Exception e){
            throw new AuraHandledException('Please try again.Exception in BlackListing a Product: '+e.getMessage());
        }   
        
    }
    
    /*
    * Description: Method determines the relevance for Each Product so that highest relevance can be displayed first.
    *              Calculation is done based on the Number of Attributes related matches found i.e. Asset Segmentation Attribute values are
    *              Compared with Products Segmentation Attribute values and the number of Matches are divided by Total Attribute to get the
    *              Relevance.
    * Input Param:  List<Asset> - Train Records Details
    *               Map<Id,List<SegmentationAttributeValue__c>> - Products and SegmentationAttributeValues map to calculate the relevance
    *               Map<Id,List<SegmentationAttributeValue__c>> - Asset and SegmentationAttributeValues map to calculate the relevance
    * Return Type: List<String> - String containing detais about Asset, Product and the relevance.
    */ 
    private static  List<String> getProductRelevance(List<Asset> trains,Map<Id,List<SegmentationAttributeValue__c>> prodSegMap, Map<Id,List<SegmentationAttributeValue__c>> assetSegMap){

        List<String> assetProdRel = new List<String>();
        Integer matchesFound;
        List<SegmentationAttributeValue__c> assetSeg;
        List<SegmentationAttributeValue__c> prodSeg;
        
        for(Asset assetTrain : trains){
            assetSeg = assetSegMap.get(assetTrain.Id);
            if(assetSeg == null || assetSeg.isEmpty()){
                assetSeg = assetSegMap.get(assetTrain.parentId);
                if(assetSeg == null){
                    continue;
                }
            }
             for(Id prodId : prodSegMap.keySet()){
                prodSeg = prodSegMap.get(prodId);
                matchesFound = productAssetSegmentationMatch(assetSeg,prodSeg);
                Double prodRel = (Double)matchesFound/assetSeg.size();
                assetProdRel.add(assetTrain.Name+';'+assetTrain.Id+';'+prodId+';'+prodRel);
             }
            
        }
    
        return assetProdRel;
    }
    
    /*
    * Description: Method determines the matches found in Segmentations between Asset and the product
    * Input Param: List<SegmentationAttributeValue__c> - List of Asset Segmentations to compare
    *              List<SegmentationAttributeValue__c> - List of Product Segmentations to compare
    * Return Type: Integer - Number of matches found.
    */ 
    private static Integer productAssetSegmentationMatch(List<SegmentationAttributeValue__c> assetSeg,List<SegmentationAttributeValue__c> prodSeg){
                Integer matchesFound = 0;
                for(SegmentationAttributeValue__c seg: assetSeg){
                    for(SegmentationAttributeValue__c prdSeg : prodSeg){
                        if(seg.Attribute__c == prdSeg.Attribute__c){
                            if(seg.Value__c == prdSeg.Value__c){
                                  matchesFound++;
                            }
                            break;
                        }
                    }
                   
                }

        return matchesFound;
    }
    
    /*
    * Class Name: SegmentationWrapper
    * Description: Wrapper Class to maitain the details of records
    *              and Mapping between SegmentationAttribute(custommetadata) and
    *              SegmentationAttributeValue records.
    */ 
    
    public class SegmentationWrapper{
        @AuraEnabled
        public String headerId{set;get;}
        
        @AuraEnabled
        public String segAttrValId{set;get;}
        
        @AuraEnabled
        public String currentValue{set; get;}
        
        @AuraEnabled
        public SegmentationAttribute__mdt segAtt{set;get;}
        
        @AuraEnabled
        public Boolean productSegmentationEditable{set;get;}
        
        public SegmentationWrapper(String headerId, String recId,String curVal, SegmentationAttribute__mdt seg,Boolean productSegmentationEditable){
            this.headerId = headerId;
            this.segAttrValId = recId;
            this.currentValue = curVal;
            this.segAtt = seg;
            this.productSegmentationEditable =productSegmentationEditable;
        }
    }
    
    /*
    * Class Name: DetailsWrapper
    * Description: Wrapper Class to maitain the details of Outage PickList Wrapper for filtering 
    *              and List of product records to display on the UI
    */ 
    public class DetailsWrapper{
        @AuraEnabled
        public List<PickListWrapper> assetPickList{set;get;}
        @AuraEnabled
        public List<ProductsWrapper> recordsWrapper{set;get;}
        @AuraEnabled
        public String recordTypeId{set;get;}
        @AuraEnabled
        public List<String> opportunityFields{set;get;}
         @AuraEnabled
        public List<PickListWrapper> outagePickList{set;get;}
 
        public DetailsWrapper(List<PickListWrapper> assetPickList, List<ProductsWrapper> recordsWrapper, String recordTypeId,List<String> oppFields,List<PickListWrapper> outagePickList){
            this.assetPickList = assetPickList;
            this.recordsWrapper = recordsWrapper;
            this.recordTypeId = recordTypeId;
            this.opportunityFields = oppFields;
            this.outagePickList = outagePickList;
        }
        
        
    }
    
    /*
    *  Class Name: ProductsWrapper
    * Description: Wrapper Class to maitain the details of Products records
    */ 
    public class ProductsWrapper{
        
        @AuraEnabled
        public String productId{set;get;}
        @AuraEnabled
        public String productLinkId{set;get;} //For Providing link on the UI
        @AuraEnabled
        public String productCode{set;get;}
        @AuraEnabled
        public string accountId{set;get;}
        @AuraEnabled
        public String currencyCode{set;get;}
        @AuraEnabled
        public String productName{set;get;}
        @AuraEnabled
        public Double productRelevance{set;get;}
        @AuraEnabled
        public Double price{set;get;}
        @AuraEnabled
        public String implementationStatus{set;get;}
        @AuraEnabled
        public String assetName{set;get;}
        @AuraEnabled
        public String assetId{set;get;}
        @AuraEnabled
        public String priceBookEntryId{set;get;}
        @AuraEnabled
        public Boolean blackListed{set;get;}
        @AuraEnabled
        public String blackListRecordId{set;get;}
        @AuraEnabled
        public String icon{set;get;}
        @AuraEnabled
        public String blackListReason{set;get;}
        @AuraEnabled
        public String priceBookId{set;get;}
        @AuraEnabled
        public String outageType{set;get;}
        
        public ProductsWrapper(String productId,String productLinkId,String productCode,string accountId,String currencyCode,String productName,Double productRelevance,Double price,String implementationStatus,String assetName,String assetId,String priceBookEntryId,
                               boolean blackListed,String blackListRecordId,string icon,String blackListReason,String priceBookId,string outageType){
                                   this.productId = productId;
                                   this.productLinkId = productLinkId;
                                   this.productCode = productCode;
                                   this.accountId = accountId;
                                   this.currencyCode = currencyCode;
                                   this.productName =productName;
                                   this.productRelevance =productRelevance;
                                   this.price =price;
                                   this.implementationStatus = implementationStatus;
                                   this.assetName = assetName;
                                   this.assetId = assetId;
                                   this.priceBookEntryId = priceBookEntryId;
                                   this.blackListed = blackListed;
                                   this.blackListRecordId = blackListRecordId;
                                   this.icon = icon;
                                   this.blackListReason = blackListReason;
                                   this.priceBookId = priceBookId;
                                   this.outageType = outageType;
                               }
        
    }  
    
    /*
    * Class Name: PickListWrapper
    * Description: Used for preparing PickList's
    */ 
    public Class PickListWrapper{
        @AuraEnabled
        public String label{set;get;}
        
        @AuraEnabled
        public String value{set;get;}
        
        public PickListWrapper(String label, String val){
            this.label = label;
            this.value = val;
        }
    }
    
}