({
    getLightningTableData : function(component) {
        
        component.set("v.relatedSpinner",true);
        let sColumn = component.get("v.fieldSetName");
        let metadataName= component.get("v.hyperlinkFieldsName");
        let sObject = component.get("v.object");
        let recordType = component.get("v.RecordType");
        let iconName = component.get("v.iconName");
        //passing CurrentRecordId or Parent of Current Record as filter based on user inputs
        let filterParent = $A.util.isEmpty(component.get("v.ParentObjectId"))?component.get("v.recordId"):component.get("v.ParentObjectId");
        let parentRelationName = component.get("v.ParentObjectRelation");
        let additionalFilter = component.get("v.AdditionalFilter");
        let action = component.get("c.getsObjectRecords");
        
        //Passing parameters to the apex controller
        action.setParams({
            ObjectName : sObject,
            fieldSetName : sColumn,
            metadataValueStr : metadataName,           
            parentRecId : filterParent,
            ParentRelationName : parentRelationName,
            AdditionalFilter : additionalFilter,
            RecordType :recordType,
            iconName :iconName,
            filterByField : component.get("v.filterBy")
        });
        
        //Fetching columns and its related data for the fields mentioned in fieldset
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
                let rtnValue = response.getReturnValue();
                //Fetches the Record type id based on recordType.DeveloperName
                component.set("v.recordTypeLst",rtnValue.recordTypeWrapper);
                component.set("v.iconName",rtnValue.tableIconName);
                
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
                var columnShowList = [];
                var hyperlinkId= [];
                let nameExists = false;
                rtnValue.tableColumn.forEach(function(row){
                    if(row.fieldName == 'Name'){
                        nameExists = true;
                    }
                    fields.push(row.fieldName);
                    if(metadataName !=''){
                        if(row.fieldName.includes(":")){                        
                            var splitString= row.fieldName.split(":");
                            let fieldId= splitString[0];   
                            hyperlinkId.push(fieldId);                            
                            let fieldValue= splitString[1];
                            let columnIdStr = {
                                'label' : row.label,
                                'fieldName' : fieldId,
                                'type' : 'url',
                                'typeAttributes' : { label: { fieldName: fieldValue  } ,target: '_top' },
                                'sortable' : true
                            };
                            columnShowList.unshift(columnIdStr); 
                        }else{
                            if(row.fieldName != 'Name'){
                                columnShowList.push(row); 
                            }    
                        }
                    }
                });
                
                //Adding Id column only when Name field is present in the fieldSet
                if(nameExists){
                    rtnValue.tableColumn.unshift(columnId);
                    //Adding to column List So that when CustomMetadata is provided Id column is considered
                    columnShowList.unshift(columnId);
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
                    }else if(rec.type == 'double' || rec.type == 'integer'){
                        rec.type = 'number';
                        rec['cellAttributes'] = { alignment: 'left' };
                    }
                });
                
                //We don't need the name field as it is displayed as url Name
                //so we are removing it from the list
                if(nameExists){
                    rtnValue.tableColumn.splice(nameIndex,1);
                }
                
                rtnValue.tableRecord.forEach(function(rec,index){
                    
                    if(metadataName !=''){     
                        hyperlinkId.forEach(function(idStr){                             
                            //console.log(' Accessing lookup  '+ rec['Opportunity__r']['AccountId']);
                            if(idStr.includes('.')){
                                let splitStr= [];
                                splitStr= idStr.split('.');
                                rec[splitStr[0]][splitStr[1]]= $A.get('$Label.c.Util_LtngURLFormat1')+ rec[splitStr[0]][splitStr[1]] + $A.get('$Label.c.Util_LtngURLFormat2'); 
                            }else{
                                rec[idStr] = $A.get('$Label.c.Util_LtngURLFormat1') +rec[idStr]+ $A.get('$Label.c.Util_LtngURLFormat2');     
                            }                                                                                 
                        });
                        
                    }
                    rec.editId = rec.Id;
                    rec.Id = $A.get('$Label.c.Util_LtngURLFormat1')+rec.Id+$A.get('$Label.c.Util_LtngURLFormat2');    
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
                    
                });
                
                if(metadataName !=''){
                    var flattenedObject= [];
                    flattenedObject= this.flattenQueryResult(rtnValue.tableRecord);  
                    component.set("v.mycolumn",columnShowList);
                    component.set("v.fullListData",flattenedObject);
                    component.set("v.mydata",flattenedObject);
                }else{
                    component.set("v.mycolumn",rtnValue.tableColumn);
                    component.set("v.fullListData",rtnValue.tableRecord);    
                    component.set("v.mydata",rtnValue.tableRecord);    
                }
                
                component.set("v.optionsLst",rtnValue.filterFieldPickList);
                this.limitingRecordsDisplay(component,rtnValue.tableRecord);
                this.sortData(component,component.get("v.sortedBy"),component.get("v.sortedDirection"));
                component.set("v.fieldsLst",fields);
                
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Related List Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in Fetching Related List Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            
            component.set("v.relatedSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    getQueryFromId : function(component) {
        
        component.set("v.relatedSpinner",true);
        //For fetching the details of parent record from the Current displayed record
        let FieldName = component.get("v.ParentObjectIdField");
        let DetailId = component.get("v.recordId");
        let sObjectName = component.get("v.sObjectName");
        
        let action = component.get("c.getParentInformationFromRecord");
        action.setParams({
            sObjectName : sObjectName,
            fieldName : FieldName,
            detailId : DetailId
        });
        let self = this;
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let retrnValue = response.getReturnValue();
                component.set("v.ParentObjectId", retrnValue);
                self.getLightningTableData(component);
            }else if (state === 'ERROR'){
                let errors = response.getError();
                let toastEvent = $A.get("e.force:showToast");
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Error in Fetching Parent Details: "+errors[0].message
                        });
                        toastEvent.fire();
                    }
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Error in Fetching Parent Details: Unknown Error"
                    });
                    toastEvent.fire();
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
            
            component.set("v.relatedSpinner",false);
        });
        
        $A.enqueueAction(action);
    },
    limitingRecordsDisplay : function(component,records){
        let recLimit = component.get("v.recordDisplayLimit");
        if(records.length <= recLimit){
            component.set("v.mydata",records);
        }else{
            let dataLst = [];
            for(let i = 0;i<recLimit;i++){
                dataLst.push(records[i]);
            }
            component.set("v.mydata",dataLst);
        }
    }, 
    sortData: function (cmp, fieldName, sortDirection) {
        let data = cmp.get("v.mydata");
        let reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.mydata", data);
    },
    sortBy: function (field, reverse, primer) {
        let key = primer ?function(x) {return primer(x[field])} :function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
            
        }
    },
    showPopup : function(component){
        component.set("v.showPopup",true);
    },
    cancel : function(component){
        this.getLightningTableData(component)
        component.set("v.showPopup",false);
    },
    
    flattenQueryResult : function(listOfObjects) {       
        for(var i = 0; i < listOfObjects.length; i++){
            var obj = listOfObjects[i];	
            for(var prop in obj){      
                if(!obj.hasOwnProperty(prop)) 
                    continue;
                if(typeof obj[prop] == 'object' && typeof obj[prop] != 'Array'){
                    obj = Object.assign(obj, this.flattenObject(prop,obj[prop]));
                }
                else if(typeof obj[prop] == 'Array'){
                    for(var j = 0; j < obj[prop].length; j++){
                        obj[prop+'.'+j] = Object.assign(obj,this.flattenObject(prop,obj[prop]));
                    }
                }
            }
        }
        return listOfObjects;
    },    
    
    flattenObject : function(propName, obj){
        var flatObject = [];
        
        for(var prop in obj){
            //if this property is an object, we need to flatten again
            var propIsNumber = isNaN(propName);
            var preAppend = propIsNumber ? propName+'.' : '';
            if(typeof obj[prop] == 'object'){
                flatObject[preAppend+prop] = Object.assign(flatObject, this.flattenObject(preAppend+prop,obj[prop]) );                
            }    
            else{
                flatObject[preAppend+prop] = obj[prop];
            }
        }
        return flatObject;
    },
    newRecord :function(component,recTypeId){

        let createRecordEvent = $A.get("e.force:createRecord");

        createRecordEvent.setParams({
            "entityApiName": component.get("v.object")        
        });

        if(!$A.util.isEmpty(recTypeId)){
            createRecordEvent.setParams({
                "recordTypeId": recTypeId         
            }); 
        }
        createRecordEvent.fire();

    },
})