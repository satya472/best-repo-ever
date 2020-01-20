({    
    doInit: function(component, event, helper) {
      //populating the pricing source picklist
        helper.callAction( component, 'c.getPicklistOptions', {
            	'objectName' : component.get('v.objectName'),
            	'fieldName'  : component.get('v.PricingSource')
        	}, function( data ) {
            component.set('v.PricingListOptions', data);
        });
        //populating the confidence level picklist
        helper.callAction( component, 'c.getPicklistOptions', {
            	'objectName' : component.get('v.objectName'),
            	'fieldName'  : component.get('v.ConfidenceLevel')
        	}, function( response ) {
            component.set('v.ConfidenceListOptions', response);
        });
    },
    inlineEditSource : function(component,event,helper){   
        // show the source edit field popup 
        component.set("v.sourceEditMode", true); 
        // after set sourceEditMode true, set picklist options to picklist field 
        component.find("priceSource").set("v.options" , component.get("v.PricingListOptions"));
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("priceSource").focus();
        }, 100);
    },
 
    onSourceChange : function(component,event,helper){ 
        // if picklist value change,
        // then show save and cancel button by set attribute to true
        component.set("v.showSaveCancelBtn",true);
    },  
    
    closeSourceBox : function (component, event, helper) {
       // on focus out, close the input section by setting the 'ratingEditMode' att. as false
        component.set("v.sourceEditMode", false); 
    },
    
    
    inlineEditConfidence : function(component,event,helper){   
        // show the rating edit field popup 
        component.set("v.confidenceEditMode", true); 
        // after set ratingEditMode true, set picklist options to picklist field 
        component.find("priceConfidence").set("v.options" , component.get("v.ConfidenceListOptions"));
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("priceConfidence").focus();
        }, 100);
    },
 
    onConfidenceChange : function(component,event,helper){ 
        // if picklist value change,
        // then show save and cancel button by set attribute to true
        component.set("v.showSaveCancelBtn",true);
    },  
    
    closeConfidenceBox : function (component, event, helper) {
       // on focus out, close the input section by setting the 'ratingEditMode' att. as false
        component.set("v.confidenceEditMode", false); 
    }
  
})