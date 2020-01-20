public class cep_mycontractView {
    public cep_mycontractView() {

    }
    @AuraEnabled(cacheable=true)
    public static List<ContractAsset__c> getMyContractList() {
        return [SELECT Id, 	Account__c, AssetId__c,AssetId__r.name, ContractId__c ,ContractId__r.name, startDate__c,endDate__c, SubscriptionStatus__c FROM ContractAsset__c ];
    }
}