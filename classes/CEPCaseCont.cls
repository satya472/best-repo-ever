/*
 * Created By: Phaniram Upalapati
 * Description: This is a controller Class for CEPCase LWC Which inturn invokes
                CEPFootPrintSoapCont Which fetches the Contracts/Plants/products
                details from FootPrint Environment.
 */
public with sharing class CEPCaseCont {

    @AuraEnabled
    public static Map<string, Map<String,String>> getContracts(String plantId){
       
      try{ 
         Map<string, Map<String,String>> contractMap = CEPFootPrintSoapCont.fetchingContracts(plantId);
         return contractMap;
      }catch(Exception ex){
          AuraHandledException e = new AuraHandledException(ex.getMessage());
          e.setMessage(ex.getMessage());
    	  throw e;
      }
      
    }

    @AuraEnabled
    public static string insertCase(String data){
      try{ 
        String caseNumber = CEPFootPrintSoapCont.createCase(data);
        return caseNumber;
      }catch(Exception ex){
          throw new AuraHandledException(ex.getMessage());
      }
      
    }
    

    @AuraEnabled
    public static Map<string, Map<String,String>> getCases(){
       
      try{ 
         Map<string, Map<String,String>> casesMap = CEPFootPrintSoapCont.fetchingCases();
         return casesMap;
      }catch(Exception ex){
          throw new AuraHandledException(ex.getMessage());
      }
      
    }
    
    @AuraEnabled
    public static Map<String, Map<String,String>> getCaseDetail(String data){
       
      try{ 
         Map<String, Map<String,String>> caseDetailMap = CEPFootPrintSoapCont.getCaseDetail(data);
         return caseDetailMap;
      }catch(Exception ex){
          throw new AuraHandledException(ex.getMessage());
      } 
    }

    @AuraEnabled
    public static string updateCase(String data){
      try { 
        String caseNumber = CEPFootPrintSoapCont.updateCase(data);
        return caseNumber;
      } catch(Exception ex) {
          throw new AuraHandledException(ex.getMessage());
      }
    }
}