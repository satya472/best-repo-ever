({
	doInit : function(component, event, helper) {
		
		helper.fetchOrders(component,event,helper);
		
	},
	filterRecords : function(component, event, helper) {
      //Based on the Search Criteria records are filtered
	  component.set("v.spinner",true);

	  let paramData = event.getParams();
	  let searchTxt = paramData['searchText'].toLowerCase();
	 // let startDate = paramData['startDate'];
	 // let endDate = paramData['endDate'];
	  let viewBy = paramData['viewBy'];

	  let finalLst =   component.get("v.orderList").filter(rec =>{
							return $A.util.isEmpty(viewBy)?true:rec.Type__c == viewBy;
						}).filter(rec => {
							return $A.util.isEmpty(searchTxt)?true:(((rec.CustomerPONumber__c).toLowerCase() ==  searchTxt) || ((rec.SalesOrderNumber__c).toLowerCase() == searchTxt));
						});			
					
		component.set("v.filteredList",finalLst);		
		component.set("v.spinner",false);

	},
   showDetails: function(component, event, helper) {

	   let rec = component.get('v.orderList').find(element =>{
				return element.CustomerPONumber__c === event.currentTarget.dataset.details;
     });

       component.set("v.order",rec);

		component.set("v.showDetails",true);
		
		if(rec.Type__c == 'Spare Parts'){
			helper.fetchChildOrders(component,helper,rec);
		}

   },
   goBack : function(component, event, helper) {
		component.set("v.showDetails",false);
		component.set("v.order",'');
	 },
	 columnSorting : function(component, event, helper) {

	  let fieldName = event.getParam('fieldName');
      let sortDirection = event.getParam('sortDirection');
      component.set("v.sortedBy", fieldName);
      component.set("v.sortedDirection", sortDirection);
      helper.sortData(component, fieldName, sortDirection);

	 }
})