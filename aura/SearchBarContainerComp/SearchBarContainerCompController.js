({
	filterData : function(component, event, helper) {

		//Checking for Enter Key Code
		let isEnterKey = event.keyCode === 13;

		//Checking if Enter key is pressed or not and making sure
		//the component event fires for both onclick of Search button and hitting enter button 
		// It will not work with any other key Press
        if (!isEnterKey && !$A.util.isEmpty(event.keyCode)) {
            return;
		}
		
		 let evt = component.getEvent('cepSearchEvt');

		 evt.setParams({

			 /*'startDate': component.find("start").get("v.value"),
			 'endDate': component.find("end").get("v.value"),*/
			 'viewBy': component.find("typeSelect").get("v.value"),
			 'searchText': component.find("inputTxt").get("v.value")
		 });

		 evt.fire();
	},
	
})