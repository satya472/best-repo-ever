({
    getSimilarOpportunities: function(component) {
        // create a server side action. 
        var action = component.get("c.fetchSimilarOpportunities");
        var pageSize = component.get("v.pageSize");//return default size
        // set the parameters to method 
        action.setParams({
            recId:component.get("v.recordId"),
            objectName:component.get("v.sObjectName")
        });
        // set a call back   
        action.setCallback(this, function(a) {
            // store the response return value (wrapper class insatance)  
            var rtnValue = a.getReturnValue();
            let state = a.getState();
            // set the component attributes value with wrapper class properties.   
            if(state == 'SUCCESS'){
                //Setting up the Id field with Url formatting and removing the name from the list 
                //So that link to the record will be displayed
                let columnId = {
                    'label' : 'Id',
                    'fieldName' : 'Id',
                    'type' : 'url',
                    'typeAttributes' : { label: { fieldName: 'Name' } ,target: '_top'},
                    'sortable' : true
                };
                
                let fields=[];                
                let nameExists = false;
                rtnValue.tableColumn.forEach(function(row){
                    if(row.fieldName == 'Name'){
                        nameExists = true;
                    }
                    fields.push(row.fieldName);
                });

                //Adding Id column only when Name field is present in the fieldSet
                if(nameExists){
                    rtnValue.tableColumn.unshift(columnId);
                }
                let nameIndex = 0;
                rtnValue.tableColumn.forEach(function(rec,index){
                    if(rec.fieldName == 'Name'){
                        rtnValue.tableColumn[0].label = rec.label;
                        nameIndex = index;
                    }
                    if(rec.type == 'reference'){
                        rec['type'] = 'url';
                        rec.typeAttributes = { label: { fieldName: rtnValue.referenceValMap[rec.fieldName]  } ,target: '_top' };
                    }
                    else if(rec.type == 'currency'){
                        rec.cellAttributes = {alignment: 'left'};
                    }
                });
                
                //We don't need the name field as it is displayed as url Name
                //so we are removing it from the list
                if(nameExists)
                {
                  rtnValue.tableColumn.splice(nameIndex,1);
                }
                    
                rtnValue.tableRecord.forEach(function(rec,index){
                    rec.editId = rec.Id;
                    rec.Id = $A.get('$Label.c.Util_LtngURLFormat1')+rec.Id+$A.get('$Label.c.Util_LtngURLFormat2');    
                    if(!$A.util.isEmpty(rtnValue.referenceValMap))
                    {
                    //Looping through the referenceMap to update the values properly as required
                    Object.keys(rtnValue.referenceValMap).forEach(function(key,index) {
                        // key: the name of the object key
                        //Going inside the loop only if the reference has some value
                        if(!$A.util.isEmpty(rec[key])){
                            rec[key] = $A.get('$Label.c.Util_LtngURLFormat1')+rec[key]+$A.get('$Label.c.Util_LtngURLFormat2');
                            let data = rtnValue.referenceValMap[key].split('.');
                            rec[data[0]+'.'+data[1]] = rec[data[0]][data[1]];
                        }
                        
                    });
                    }    
                });
                component.set("v.oppColumn",rtnValue.tableColumn);
                component.set("v.opportunitiesList",rtnValue.tableRecord);     
                component.set("v.total", rtnValue.total);
                var totalRec =  rtnValue.total;
                if(totalRec == 0)
                {
                    component.set("v.disableButton", true);
                    component.set("v.pages", 0);
                    component.set("v.page", 0);
                }
                if(pageSize >= totalRec && totalRec != 0)
                {
                    component.set("v.pageSize", totalRec);
                    component.set("v.disableButton", true);
                    component.set("v.pages", 1);
                    component.set("v.page", 1);
                    pageSize = totalRec;
                } 
                else if( totalRec > pageSize )
                {
                	component.set("v.pages", Math.ceil(totalRec/ pageSize));
                    component.set("v.page", 1);
                	component.set("v.end",pageSize);
                }
                //Set the current Page as 0
                component.set("v.currentPage",0);
                component.set("v.start",0);
                var pList = [];
                if(totalRec > 0){
                for(var i=0; i< pageSize; i++)
                {
                 	pList.push(component.get("v.opportunitiesList")[i]);    
    			}
                
                component.set("v.paginationList", []);
                component.set("v.paginationList", pList);  
                }
            }
            else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        // enqueue the action 
        $A.enqueueAction(action);
    },
    
    createSimilarOpportunities: function(component)
    {
        let recId = component.get("v.recordId");
        let successMessage = component.get("v.SuccessMessage");
        let action = component.get("c.createSimilarOpportunities");
        //Passing parameters to the apex controller
        action.setParams({
            sourceRecordList : JSON.stringify(component.get("v.selectedLst")),
            recId:recId,
            objName:component.get("v.sObjectName")
        });
        
        //Fetching columns and its related data for the fields mentioned in fieldset
        action.setCallback(this,function(response){
        let state = response.getState();
        if(state == 'SUCCESS')
        {
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                                "title": "SUCCESS",
                				"type":"Success",
                                "message": " Similar Opportunity Inserted Successfully"
                        });	
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire() ;
            component.set("v.selectedLst",'');
            this.getSimilarOpportunities(component);
            //this.getLightningTableData(component);   
        }else if (state === 'ERROR')
        {
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) 
                {
                    if (errors[0] && errors[0].message) 
                    {
                       toastEvent.setParams({
                                "title": "Error!",
                                "message": "Error Insertion of Records: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else 
                {
                   toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error Insertion of Records: Unknown Error"
                   });
                   toastEvent.fire();
                }
            }else
            {
                console.log('Something went wrong, Please check with your admin');
            }
       });
         $A.enqueueAction(action);
    },
  
})