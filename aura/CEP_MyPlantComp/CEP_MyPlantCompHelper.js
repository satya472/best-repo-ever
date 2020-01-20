({
	fetchAssetDetails : function(component,event,helper) {

		component.set("v.relatedSpinner",true);        
        let action = component.get("c.getAssetHierarchyDetailsCEP");
        //Passing parameters to the apex controller
        action.setParams({
            recordId : component.get("v.accountId")
        });

        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                this.treeStructure(component,response.getReturnValue(),'ParentId');
            }else if (state === 'ERROR'){
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
						this.showToast("Error in Fetching Details: "+errors[0].message,'error','ERROR!');
                    }
                } else {
					this.showToast("Error in Fetching Details: Unknown Error",'error','ERROR!');
				}
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            component.set("v.relatedSpinner",false);
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

	treeStructure: function(component,list,parentIdentifierField){

		let treeList = [];
		let lookup = {};

		//The below code can be updated with different attribute i.e. based on the details we would like to
		//See on the screen. In this code we are just framing the structure of attributes for all the assets fetched
		//from the SOQL
		list.forEach(function(obj) {
			lookup[obj['Id']] = {
									 'name' : obj['Id'],
									 'label': obj['Name'],
									 'expanded': false,
									 'items' : [],
									 'href':'',
									 'metatext': 'Testing Data',
									 'recordTypeName': obj['RecordType']['Name'],
									 'icon': obj['RecordType']['Name'] == 'Train'?'TrainIcon.jpg':obj['RecordType']['Name'] == 'Equipment'?'EquipmentIcon.jpg':'PlantIcon.jpg'
			                    };
		});

		//In the below code we are creating the tree structure based on the parentId Mapping
		//Which will be looped to display the details in the Tree Structure
		list.forEach(function(obj) {
			if (!$A.util.isEmpty(obj[parentIdentifierField])) {
				lookup[obj[parentIdentifierField]]['items'].push(
					lookup[obj['Id']]
				);
			} else {
				treeList.push(lookup[obj['Id']]);
			}
		});
		
		component.set("v.plantList",treeList);
	}
})