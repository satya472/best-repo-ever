({
	inlineEditPrice : function(component,event,helper){   
        // show the name edit field popup 
        component.set("v.priceEditMode", true); 
        // after the 100 millisecond set focus to input field   
        setTimeout(function(){ 
            component.find("inputId").focus();
        }, 100);
    },
    onPriceChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value").trim() != ''){ 
            component.set("v.showSaveCancelBtn",true);
        }
    },
    closePriceBox : function (component, event, helper) {
      // on focus out, close the input section by setting the 'nameEditMode' att. as false   
        component.set("v.priceEditMode", false); 
    }
})