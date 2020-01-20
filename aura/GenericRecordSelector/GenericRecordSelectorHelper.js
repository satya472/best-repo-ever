({
    //Get Search Scope
    getSearchScope : function(component, event, helper) {   
        var action = component.get("c.getSearchScope");
        action.setParams({
            controllerName: component.get("v.controllerName"),
            modalName: component.get("v.modalName")
        });
        action.setCallback(this, function(response) {    
            component.set("v.searchScope", JSON.parse(response.getReturnValue()));
            component.set("v.selectedValue", JSON.parse(response.getReturnValue())[0].value); 
            helper.getTableFieldSet(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    //for table field names
    getTableFieldSet : function(component, event, helper) {
        let modalNameTemp;
        modalNameTemp = component.get("v.selectedValue");
        var action = component.get("c.getFieldSetDataJSON");
        //if($A.util.isEmpty(component.get("v.modalName"))) {
        //     modalNameTemp = component.get("v.selectedValue");
        //}else{
        //    modalNameTemp = component.get("v.modalName");
        //}
        action.setParams({
            controllerName: component.get("v.controllerName"),
            modalName: modalNameTemp
        });
        
        action.setCallback(this, function(response) {                               
            //Get the expanded field names
            var fieldSetValues = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetValues);
            
            var setfieldNames = new Set();
            for(var c=0, clang=fieldSetValues.length; c<clang; c++){  
                if(!setfieldNames.has(fieldSetValues[c].name)) {   
                    setfieldNames.add(fieldSetValues[c].name);  
                    if(fieldSetValues[c].type == 'REFERENCE') {
                        if(fieldSetValues[c].name.indexOf('__c') == -1) { 
                            setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');   
                        }else {                      
                            setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');                            
                        }               
                    }           
                }        
            }        
            let arrfieldNames = [];         
            setfieldNames.forEach(v => arrfieldNames.push(v));
            component.set("v.arrfieldNames", arrfieldNames);
            helper.getTableRows(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    //for table data
    getTableRows : function(component, event, helper){        
        var action = component.get("c.getTableRows");        
        action.setParams({
            controllerName: component.get("v.controllerName"),
            modalName: component.get("v.modalName"),
            searchScope: component.get("v.selectedValue"),
            record: component.get("v.record"),
            fieldNameJson: JSON.stringify(component.get("v.arrfieldNames"))
        });
        action.setCallback(this, function(response) {
            var rowDataList = JSON.parse(response.getReturnValue());
            helper.getAttributes(component, event, rowDataList, helper);
            
        })
        $A.enqueueAction(action);
    },
    
    //For Attributes
    getAttributes : function(component, event, rowDataList, helper) {
        var action = component.get("c.getAttributeData");
        action.setParams({
            controllerName: component.get("v.controllerName"),
            modalName: component.get("v.modalName")
        });
        
        action.setCallback(this, function(response) {
            //get the existing fields
            var fieldVals = [];
            for(var key in component.get("v.fieldSetValues")){
                fieldVals.push(component.get("v.fieldSetValues")[key]);
            }           
            component.set("v.fieldSetValues","");
            for(var key in response.getReturnValue()){
                fieldVals.push(JSON.parse(key));
            }
            //parse the response           
            var fieldData = [];
            for (var i = 0; i < rowDataList.length; i++) { 
                var row = [];
                row = rowDataList[i]; 
                for(var key in response.getReturnValue()){
                    row[JSON.parse(key).name] = response.getReturnValue()[key];                    
                }    
                row.check = false;
                fieldData.push(row);
            }      
            component.set("v.fieldSetValues", fieldVals);
            component.set("v.tableData", fieldData);            
            component.set("v.tableRecords", fieldData);
            
            //get pagination
            component.set("v.resultSize", fieldData.length)
            component.set("v.currentPageNumber",1);
            helper.renderPage(component);
            component.set("v.Spinner", false);                  
            
        })
        $A.enqueueAction(action);
    },
    
    //For Search
    getSearchTableData : function(component, event, helper) {
        var searchResultData = []
        var fieldData = [];
        var fieldVals = component.get("v.fieldSetValues");
        var searchKey = component.get("v.searchKey"),
            fieldData = component.get("v.tableData");
        var fieldName;
        for(var key in fieldData){
            for(var fieldkey in fieldVals){
                var rowData = fieldData[key];
                var field = fieldVals[fieldkey] ;   
                //check for ref field and undefined input
                if(field.type != 'REFERENCE' && rowData[field.name] != undefined){
                    var fdata = JSON.stringify(rowData[field.name]);
                    if(fdata.toLowerCase().includes(searchKey.toLowerCase())){
                        searchResultData.push(rowData);
                        break;
                    }
                }else{
                    var fieldName = field.name.substring(0, field.name.indexOf('Id'));
                    if(rowData[fieldName] != undefined && 
                       (rowData[fieldName].Name).toLowerCase().includes(searchKey.toLowerCase())){
                        searchResultData.push(rowData);
                        break;
                    }
                }
            }	
        }   
        component.set("v.tableRecords", "");
        component.set("v.tableRecords", searchResultData);
        
        //get pagination
        component.set("v.resultSize", searchResultData.length)
        component.set("v.currentPageNumber",1);
        helper.renderPage(component);
    },
    
    createNewRecordsHelper : function(component, helper){
        var action= component.get("c.createNewRecords");
        action.setParams({   
            controllerName: component.get("v.controllerName"),
            modalName: component.get("v.modalName"),
            searchScope: component.get("v.selectedValue"),
            addRecordList: JSON.stringify(component.get("v.AddRecordList")),
            recordId: component.get("v.record").Id         
        });
        action.setCallback(this, function(response){
            if(component.isValid() && response.getState() === 'SUCCESS'){
                $A.get("e.force:closeQuickAction").fire() ; 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The records have been added."
                });
                toastEvent.fire();
                component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
            }else if (response.getState() === "ERROR") {   
                let message = 'Unknown error';
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message = errors[0].message;
                    }   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type":"Error",
                        "title": "Error!",
                        "message": message
                    });
                    toastEvent.fire();
                }
                for(let i in component.get("v.tableRecords")){
                    if(component.get("v.tableRecords")[i].check){
                        
                    }
                }
            }
        });        
        $A.enqueueAction(action);  
    },
    
    //For Column Sorting
    sortBy: function(component, fieldType, fieldName) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.tableRecords");
        var field;
        if(fieldType == 'REFERENCE') {
            if(fieldName.indexOf('__c') == -1) { 
                field = fieldName.substring(0, fieldName.indexOf('Id'));   
            }else {                      
                field = (fieldName.substring(0, fieldName.indexOf('__c')) + '__r');                            
            }               
        }else{
            field = fieldName;
        }
        sortAsc = sortField != fieldName || !sortAsc;
        if(fieldType == 'REFERENCE') {
            records.sort(function(a,b){
                if(a[field] != undefined && b[field] != undefined){
                    var t1 = a[field].Name == b[field].Name,
                        t2 = (!a[field].Name && b[field].Name) || (a[field].Name < b[field].Name);
                    return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
                }else{
                    return (sortAsc?-1:1)*(t2?1:-1);
                }
            });
        }else{
            records.sort(function(a,b){
                var t1 = a[field] == b[field],
                    t2 = (!a[field] && b[field]) || (a[field] < b[field]);
                return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
            });
        }
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", fieldName);
        component.set("v.tableRecords", "");
        component.set("v.tableRecords", records);
        this.renderPage(component);
    },
    
    //For Pagiantion
    renderPage : function(component){
        let records = component.get("v.tableRecords");
        let recPerPage = component.get("v.recordsPerPage");
        component.set("v.maxPageNumber",Math.ceil(records.length/recPerPage));
        let pageNumber = component.get("v.currentPageNumber");
        let pageRecords = records.slice((pageNumber-1)*recPerPage, pageNumber*recPerPage);
        component.set("v.currentList",pageRecords);
    }
})