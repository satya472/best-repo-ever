({
	doInit : function(component, event, helper) {
 
		// Fetching the radio button values from the Custom labels and 
		// adding them to the list so that multiple values can be displayed
		let expLst = $A.get('$Label.c.ExperienceList').split(';');
		let dataLst = [];
		expLst.forEach(element => {
			dataLst.push({
				'label':element,
				'value':element
			});
		});
		component.set("v.captureDetails",dataLst);

		expLst = $A.get('$Label.c.ApplyExperienceList').split(';');
	    dataLst = [];
		expLst.forEach(element => {
			dataLst.push({
				'label':element,
				'value':element
			});
		});

		component.set("v.applyDetails",dataLst);
		
		// calling helper function to autopopulate the record with the necessary values during record creation
		if(component.get("v.sObjectName") == 'Opportunity'){
			helper.autoPopulateHelper(component);
		}
	},
	navigateToSObject : function(component,event,helper){

		//On click of Cancel button in Mobile 
		let pageReference = {
            type: 'standard__recordPage',
            attributes: {
				recordId: component.get("v.recordId"),
                objectApiName: component.get("v.sObjectName"),
                actionName: 'view'
			}
		};

		let navService = component.find("navService");
        navService.navigate(pageReference);
	},
	radioValuChange : function(component,event,helper){
		component.set("v.value",event.getSource().get("v.value"));
	},
	handleRecordUpdated : function(component,event,helper){
		//method is invoked when the component is invoked from Experience report record
		let eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
			helper.autoPopulateHelper(component);
		}

	},
	next : function(component,event,helper){

		//After selecting the option and user clicks on next button 
		//based on the selected radio option we will fetch the Quote Line items
		// Which are needed when Price Intelligence Type is selected during record Creation
        if(component.get("v.value") == 'Create new Intelligence'){
            helper.fetchQuoteLineItems(component,helper);
		}
      
		component.set("v.hideNxtScreen",false);
		component.set("v.header",component.get("v.value"));
	},
	closePopup:  function(component,event,helper){

		//If there is a Selected Quote Line then we need to updated the Intelligence Record
		// With the Selected QuoteLine Id.
		if(event.getSource().get('v.name') == 'priceNext'){
			if(!$A.util.isEmpty(component.get("v.selectedQuoteLine"))){
				helper.updateIntelligenceRecord(component,helper);
			}else{
				component.set("v.afterPrice",true);
			}
            
		}else{
            $A.get("e.force:closeQuickAction").fire();
		}
	},
	onSelectQuote : function(component,event,helper){
		let selectedVal = component.get("v.selectedQuoteLine");
		let currentSelectedVal = event.getSource().get("v.value");

		//If both the current Selected and Already Select record are same then we are deselecting the same.
		if(selectedVal == currentSelectedVal){
			component.set("v.selectedQuoteLine",'');
		}else{
			component.set("v.selectedQuoteLine",event.getSource().get("v.value"));
		}
         
	},
	
})