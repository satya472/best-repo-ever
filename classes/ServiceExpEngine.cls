/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 21-June-18
* Description: Controller for ServiceExpEngine component
* 
*/
public class ServiceExpEngine 
{    
    public class PriceExperienceWrapper 
    {
        @AuraEnabled
        public Integer RowID {get;set;}
        
        @AuraEnabled
        public String PriceExpId {get;set;}
        
        @AuraEnabled
        public String CompetitorName {get;set;}
        
        @AuraEnabled
        public Price_Experience__c NewPriceExp {get;set;}
        
        @AuraEnabled
        public List<PriceExplineWrapper> NewExpLineWrapper {get;set;}
        
        //Existing PriceExperienceLine records which are not being processed for DML
        //Just for display
        @AuraEnabled
        public List<PriceExperienceLine__c> RelatedPriceExpLines {get;set;}
        
        @AuraEnabled
        public Integer RelatedSerLineCount {get{  If(!RelatedPriceExpLines.isEmpty()){return RelatedPriceExpLines.size();}
                                                  else return 0;
            
        }}
        
        @AuraEnabled
        public Set<String> ProductNames {get;set;}
    }
    
    @AuraEnabled
    public static List<PriceExperienceWrapper> UpsertPriceExperience(String priceExpWrapperJason)
    {
        system.debug('priceExpWrapperJason>>'+priceExpWrapperJason);
        List<PriceExperienceWrapper> priceExperienceList = (List<PriceExperienceWrapper>) JSON.deserialize(priceExpWrapperJason, List<PriceExperienceWrapper>.class);
        List<PriceExperienceWrapper> oppCompList = new  List<PriceExperienceWrapper>();
        try
        {
            List<Price_Experience__c> upsertPriceExpRecs = new List<Price_Experience__c>();
            List<PriceExperienceLine__c> upsertPriceExpLineRecs = new List<PriceExperienceLine__c>();            
            
            Map<String,List<PriceExperienceLine__c>> priceExperienceLineMap = new  Map<String,List<PriceExperienceLine__c>>();
            List<PriceExperienceLine__c> expList;
            for(PriceExperienceWrapper priceExpWrapper : priceExperienceList)
            {
                //needed to update later with newly upserted records of priceexp & priceexplines
                
                expList = new List<PriceExperienceLine__c>();
                for(PriceExplineWrapper prodLineWrapper :priceExpWrapper.NewExpLineWrapper)
                {
                    expList.add(prodLineWrapper.NewProductLine);
                }
                //needed to fetch related priceexplines for priceExp upserted
                //priceExperienceLineMap.put(priceExpWrapper.NewPriceExp.Competitor_Account__c,priceExpWrapper.NewExpLine);PriceExplineWrapper
                priceExperienceLineMap.put(priceExpWrapper.NewPriceExp.Competitor_Account__c,expList);
                
                //needed to upsert price experience records
                upsertPriceExpRecs.add(priceExpWrapper.NewPriceExp);
            }
            
            upsert upsertPriceExpRecs;
            List<PriceExperienceLine__c> expLinesList;
            for(Price_Experience__c expRec : upsertPriceExpRecs)
            {
                expLinesList = new List<PriceExperienceLine__c>();
                //populate the Id in the Serice line from upserted Price Exp
                for(PriceExperienceLine__c recLine :priceExperienceLineMap.get(expRec.Competitor_Account__c) )
                {
                    if(!String.isBlank(recLine.ProductPrice__c) && recLine.ProductPrice__c != '0')
                    {
                        expLinesList.add(new PriceExperienceLine__c(PriceExperienceId__c = expRec.Id,
                                                                    ProductName__c = recLine.ProductName__c,
                                                                    ProductPrice__c = recLine.ProductPrice__c,
                                                                    Id=recLine.Id));
                    }
                }
                if(!expLinesList.isEmpty())
                    upsertPriceExpLineRecs.addall(expLinesList);
            }
            
            //upsert the Price Experience Line records
            upsert upsertPriceExpLineRecs;
            
            oppCompList = getCompData(priceExperienceList[0].priceExpId);
        }
        catch(exception ex)
        {
            system.debug('Error occurred'+ex.getMessage());
        }
        return oppCompList;
    }
    
    
    @AuraEnabled
    public static List<PriceExperienceWrapper> getCompData(Id priceExpId)
    {
        List<PriceExperienceWrapper> oppCompList = new  List<PriceExperienceWrapper>();
        //1. fetch current PriceExperience record
        List<Price_Experience__c> priceExpList = [SELECT Opportunity__c
                                                  FROM Price_Experience__c where Id = : priceExpId];   
        
        //2.Fetch all OpportunityCopetition record for this opportunity
        if(!priceExpList.isEmpty())
        {
            List<OpportunityCompetition__c> oppCompetitionList = [Select id,Name 
                                                                  FROM OpportunityCompetition__c 
                                                                  where Opportunity__c =:priceExpList[0].Opportunity__c ];
        }
        
        //3. Fetch the PriceExperienceLine records related to current Price Experience in 1.
        Map<String,PriceExperienceLine__c> priceExpLinesExistingMap = new Map<String,PriceExperienceLine__c>();
        List<PriceExperienceLine__c> priceExpExistingLineList = [SELECT Id,PriceExperienceId__c,ProductName__c,
                                                                 ProductPrice__c 
                                                                 FROM PriceExperienceLine__c
                                                                 where PriceExperienceId__c = : priceExpId order by ProductName__c];
        for(PriceExperienceLine__c lineExp : priceExpExistingLineList )
        {
            priceExpLinesExistingMap.put(lineExp.ProductName__c,lineExp);
            system.debug(' ln115 priceExpLinesExistingMap -- '+priceExpLinesExistingMap);
        }
        
        Set<Id> compPriceExpRecords = new Set<Id>();
        if(!priceExpList.isEmpty())
        {
            //retrieve the existing record of Exp lines for competitors
            Map<String,Price_Experience__c> existingPriceExp = new  Map<String,Price_Experience__c>();
            
            //3.Fetch the existing child Price experience records for current Price Experience record
            for(Price_Experience__c existPriceExpRec : [Select Siemens_Price_Experience__c,Competitor_Account__c,Competitor_Account__r.Name,
                                                        Opportunity__c,CompetitorPricingSource__c,ConfidenceLevel__c
                                                        from Price_Experience__c 
                                                        where Siemens_Price_Experience__c = : priceExpId])
            {
                if(!existingPriceExp.containsKey(existPriceExpRec.Competitor_Account__c))
                {
                    existingPriceExp.put(existPriceExpRec.Competitor_Account__c,existPriceExpRec);
                }
                compPriceExpRecords.add(existPriceExpRec.Id);
            }
            //retrieve existing PriceExpLines related to PriceExp for competitors
            List<PriceExperienceLine__c> tempListLines;
            Map<Id,List<PriceExperienceLine__c>> priceExpwithPriExplineMap = new Map<Id,List<PriceExperienceLine__c>>();
            for(PriceExperienceLine__c expLine : [SELECT PriceExperienceId__c,ProductName__c,ProductPrice__c 
                                                  FROM PriceExperienceLine__c
                                                  where PriceExperienceId__c in : compPriceExpRecords order by ProductName__c])
            {
                tempListLines = new List<PriceExperienceLine__c>();
                if(priceExpwithPriExplineMap.containsKey(expLine.PriceExperienceId__c))
                {
                    tempListLines = priceExpwithPriExplineMap.get(expLine.PriceExperienceId__c);
                }
                tempListLines.add(expLine);
                priceExpwithPriExplineMap.put(expLine.PriceExperienceId__c,tempListLines);
            }
            
            Price_Experience__c priceExpRec;
            PriceExperienceWrapper priceExpTemp;  
            PriceExperienceLine__c priceExpLine;
            PriceExplineWrapper priceExpLineWrapper;
            
            //for existing Price Experience and Price Experienceline recods
            Set<String> tempProducts;
            List<PriceExplineWrapper> tempProductLinesWrapper;
            if(existingPriceExp !=null && !existingPriceExp.isEmpty())
            {
                for(Price_Experience__c priceExp : existingPriceExp.values())
                {
                    //In case of existing Price Experience Records simply create a wrapper instance
                    tempProductLinesWrapper = new List<PriceExplineWrapper>();
                    priceExpTemp = new PriceExperienceWrapper();
                    priceExpTemp.CompetitorName =  priceExp.Competitor_Account__r.Name;
                    priceExpTemp.NewPriceExp = priceExp;
                    priceExpTemp.RelatedPriceExpLines = priceExpExistingLineList;
                    priceExpTemp.PriceExpId = priceExpId;
                    
                    if(priceExpwithPriExplineMap.containskey(priceExp.Id))
                    {
                        tempProducts = new Set<String>();                       
                        //we need to check which products are missing and create a dummy 
                        //record so the row is displayed on the vf page in the table
                        for(PriceExperienceLine__c priceExpln : priceExpwithPriExplineMap.get(priceExp.Id))
                        {                           
                            tempProductLinesWrapper.add(new priceExpLineWrapper(priceExpln,priceExpLinesExistingMap.get(priceExpln.ProductName__c).ProductPrice__c));
                            tempProducts.add(priceExpln.ProductName__c);
                        }
                        
                        //check which product is missing and assign the dummy instance for that in service line
                        for(String strProd : priceExpLinesExistingMap.keyset())
                        {
                            if(!tempProducts.contains(strProd))
                            {
                                priceExpLine = new PriceExperienceLine__c();
                                priceExpLine.PriceExperienceId__c = priceExp.Id;
                                priceExpLine.ProductPrice__c = '0';
                                priceExpLine.ProductName__c = strProd;
                                tempProductLinesWrapper.add(new priceExpLineWrapper(priceExpLine,priceExpLinesExistingMap.get(strProd).ProductPrice__c));
                            }
                        }
                    }
                    else
                    {
                        //means Service record exist but no Service Line record exist for the COmpetitor
                        //so add dummy record to bind
                        for(PriceExperienceLine__c expProductLine : priceExpExistingLineList)
                        {                            
                            priceExpLine = new PriceExperienceLine__c();
                            priceExpLine.PriceExperienceId__c = priceExp.Id;
                            priceExpLine.ProductPrice__c = '0';
                            priceExpLine.ProductName__c = expProductLine.ProductName__c;
                            tempProductLinesWrapper.add(new priceExpLineWrapper(priceExpLine,priceExpLinesExistingMap.get(expProductLine.ProductName__c).ProductPrice__c));
                            
                        }
                    }
                    tempProductLinesWrapper.sort();
                    priceExpTemp.PriceExpId = priceExpId;                    
                    priceExpTemp.NewExpLineWrapper = tempProductLinesWrapper;
                    priceExpTemp.ProductNames = priceExpLinesExistingMap.keyset();
                    oppCompList.add(priceExpTemp);
                }
            }
            
            List<PriceExperienceLine__c> productList = new List<PriceExperienceLine__c>();
            //4. fetch the Opportunity competition records related to current Price experience
            
            for(OpportunityCompetition__c temp : [SELECT AccountName__c,CompetitorAccount__c,CompetitorAccount__r.Name,
                                                  Opportunity__c FROM OpportunityCompetition__c
                                                  where Opportunity__c = :priceExpList[0].Opportunity__c])
            {
                if(!existingPriceExp.containsKey(temp.CompetitorAccount__c))
                {
                    priceExpRec = new Price_Experience__c();
                    priceExpRec.Siemens_Price_Experience__c = priceExpList[0].Id;
                    priceExpRec.Competitor_Account__c = temp.CompetitorAccount__c;
                    priceExpRec.Opportunity__c = temp.Opportunity__c;
                    tempProductLinesWrapper = new List<PriceExplineWrapper>();
                    //New changes start
                    for(PriceExperienceLine__c expProductLine : priceExpExistingLineList)
                    {                           
                        priceExpLine = new PriceExperienceLine__c();
                        priceExpLine.ProductPrice__c = '0';
                        priceExpLine.ProductName__c = expProductLine.ProductName__c;
                        tempProductLinesWrapper.add(new priceExpLineWrapper(priceExpLine,priceExpLinesExistingMap.get(expProductLine.ProductName__c).ProductPrice__c));
                    }
                    tempProductLinesWrapper.sort();
                    //New changes end
                    priceExpTemp = new PriceExperienceWrapper();
                    priceExpTemp.NewPriceExp = priceExpRec;
                    priceExpTemp.CompetitorName =  temp.CompetitorAccount__r.Name;
                    priceExpTemp.RelatedPriceExpLines = priceExpExistingLineList;
                    priceExpTemp.ProductNames = priceExpLinesExistingMap.keyset();
                    priceExpTemp.PriceExpId = priceExpId;     
                    priceExpTemp.NewExpLineWrapper = tempProductLinesWrapper;
                    oppCompList.add(priceExpTemp);                    
                }                
            }
        }
        return oppCompList;
    }
    
    @AuraEnabled
    public static List < PicklistOption > getPicklistOptions(String objectName, String fieldName ) 
    {
        List<PicklistOption> options = new List<PicklistOption>();
        
        for( Schema.PicklistEntry f : Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap().get( fieldName ).getDescribe().getPicklistValues() )
        {
            options.add(new PicklistOption(f.getLabel(),f.getValue()));
        }
        return options;
    } 
    
    /* *
* The system class PicklistEntry is not aura enabled so cannot be returned from @AuraEnabled method.
* Workaround is to define our own class with aura enabled properties.
*/
    public class PicklistOption {
        
        @AuraEnabled
        public String label { get; set; }
        
        @AuraEnabled
        public String value { get; set; }
        
        public PicklistOption( String label, String value ) {
            this.label = label;
            this.value = value;
        }
        
    } 
}