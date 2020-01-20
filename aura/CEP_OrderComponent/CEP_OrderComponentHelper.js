({
	fetchOrders : function(component,event,helper) {

		component.set("v.spinner",true);

		let action= component.get("c.getTrackAndTraceOrders");

		action.setParams({
             'encodedParam': $A.util.isEmpty(component.get('v.ifaNumber'))?'':decodeURIComponent(component.get('v.ifaNumber'))
		});

		action.setCallback(this,function(response){

			 let state = response.getState();
			 
			 if(state === 'SUCCESS'){

				component.set('v.orderList',response.getReturnValue());
				component.set('v.filteredList',response.getReturnValue());

			 }else if(state === 'ERROR'){

				 let error = response.getError();
				 if(error){
            if(error[0] && error[0].message){
						  this.showToast("Error in Fetching Details: "+error[0].message,'error','ERROR!');     
					  }
					}else{
						alert('Inside error 4');
								this.showToast("Error in Fetching Details: Unknown Error",'error','ERROR!');
					}

			 }else{
            this.showToast("Something went wrong, Please check with your admin",'error','ERROR!');
			 }
			 component.set("v.spinner",false);

		});

		$A.enqueueAction(action);
	},
	showToast: function(message,type,title){

		let toastEvent = $A.get("e.force:showToast");

		toastEvent.setParams({
		     "title": title,
			 "type":  type,
			 "message": message
		});

		toastEvent.fire();
	},
	sortData :function (component, fieldName, sortDirection) {
		let data = component.get("v.data");
		let reverse = sortDirection !== 'asc';
		let sortedData = data.sort(this.sortBy(fieldName, reverse));
		component.set("v.data", sortedData);
	},
	sortBy: function (field,reverse , primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
			return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
		}
	},
		
	fetchChildOrders: function(component,helper,rec){

		component.set("v.spinner",true);

		let action= component.get("c.getTrackAndTraceChildOrderRecords");

		action.setParams({
						 'poNumber': $A.util.isEmpty(rec)?'':rec.CustomerPONumber__c,
						 'fieldSetName': 'FieldSetForChildOrders'
		});

		action.setCallback(this,function(response){

			 let state = response.getState();
			 
			 if(state === 'SUCCESS'){

				let col = response.getReturnValue().tableColumn;

				//Updating the columns Names as per bussiness request
				col.forEach(rec =>{
					  if(rec.type == 'double' || rec.type == 'integer'){
							 rec.type='number';
							 rec['cellAttributes'] = { alignment: 'left' };
						}
						if(rec.label == 'Order Line Item No'){ rec.label = 'Item';}
						else if(rec.label == 'Part Description'){ rec.label = 'Part Desc.';}
						else if(rec.label == 'Order Quantity'){ rec.label = 'Order Qty';}
						else if(rec.label == 'Delivered Quantity'){ rec.label = 'Delivered Qty';}
						else if(rec.label == 'Item Unit'){ rec.label = 'Unit';}
						else if(rec.label == 'Customer Requested Date'){ rec.label = 'Cust. Req. Date';}
				})

				component.set('v.columns',col);

				component.set('v.data',response.getReturnValue().tableRecord);

				//Checking if there are any partially delivered Items so that we can display a note to the user.
				let itemPartiallyDelivered = false;
				response.getReturnValue().tableRecord.forEach(rec =>{
					if(rec.CurrentStatusItem__c === 'OFP_Order Fulfilled Partially' || rec.CurrentStatusItem__c === 'GIP_Goods Issued Partially'){
						itemPartiallyDelivered = true;
					}
				});

				if(itemPartiallyDelivered){
					component.set('v.partiallyDeliveredMsg','(Note: Some of this Order has been Partially Delivered.)');
				}

			 }else if(state === 'ERROR'){
				 let error = response.getError();

				 if(error){
            if(error[0] && error[0].message){
					    this.showToast("Error in Fetching Details: "+error[0].message,'error','ERROR!');     
					  }
				 }else{
					   this.showToast("Error in Fetching Details: Unknown Error",'error','ERROR!');
				 }

			 }else{
                this.showToast("Something went wrong, Please check with your admin",'error','ERROR!');
			 }
			 component.set("v.spinner",false);

		});

		$A.enqueueAction(action);

	}
})