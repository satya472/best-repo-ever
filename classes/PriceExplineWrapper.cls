/*
* Author: Naveen Gadicherla
* Company: Accenture
* Date: 21-June-18
* Description: Controller for ServiceExpEngine component
* 
*/

public class PriceExplineWrapper implements Comparable
{
    @AuraEnabled
    public String RelatedProductPrice {get;set;}
    
    @AuraEnabled
    public PriceExperienceLine__c NewProductLine {get;set;}
    
    public PriceExplineWrapper(PriceExperienceLine__c priceLine,String price)
    {
        this.NewProductLine = priceLine;
        this.RelatedProductPrice = price;
    }
    
    public Integer compareTo(Object compareTo)
    {
        PriceExplineWrapper tempWrapper = (PriceExplineWrapper)compareTo;
        if(this.NewProductLine.ProductName__c == tempWrapper.NewProductLine.ProductName__c)
        {
            return 0;
        } 
        else if(this.NewProductLine.ProductName__c < tempWrapper.NewProductLine.ProductName__c)
        {
            return -1;
        }
        else 
        {
            return 1;
        }
    }

}