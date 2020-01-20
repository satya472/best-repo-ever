global class MyPageSecurityPlugin implements SBQQ.PageSecurityPlugin2 {
    public Boolean isFieldEditable(String pageName, Schema.SObjectField field) {
        return null;
    }
    
    public Boolean isFieldEditable(String pageName, Schema.SObjectField field, SObject record) {
        return null;
    }
    
    public Boolean isFieldVisible(String pageName, Schema.SObjectField field) {
        return null;
    }
    
    public Boolean isFieldVisible(String pageName, Schema.SObjectField field, SObject record) {
        if ((pageName == 'EditLines') && (record instanceof SBQQ__QuoteLine__c)) {
            SBQQ__QuoteLine__c line = (SBQQ__QuoteLine__c)record;
            if ((line.SBQQ__Bundle__c == true) && (field == SBQQ__QuoteLine__c.SBQQ__ListPrice__c)) {
                return false;
            }
        }
        return null;
    }
}