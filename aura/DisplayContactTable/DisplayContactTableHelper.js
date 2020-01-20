({   
    getTableFieldSet : function(component, event, helper) {
        var action = component.get("c.getFieldSetData");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSetName: component.get("v.fieldSetName")
        });
        
        action.setCallback(this, function(response) {                   
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            
            //Get the expanded field names
            var fieldSetValues = component.get("v.fieldSetValues");
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
            
            //Call helper method to fetch the records
            if( component.get("v.addMemberType") === "BCM"){
                helper.getTableRows(component, event, helper, arrfieldNames);
            }else{
                helper.getSCMTableRows(component, event, helper, arrfieldNames);
            }
        });
        $A.enqueueAction(action);
    },
    
    getTableRows : function(component, event, helper, arrfieldNames){        
        if(component.get("v.BCMContactSearchValue") === "allContacts"){
            component.set("v.parentRecordId","");
            component.set("v.tempParentFieldName","");
        }else if(component.get("v.BCMContactSearchValue") === "accountContacts"){
            component.set("v.tempParentFieldName",component.get("v.parentFieldName"));
        }
        
        var action = component.get("c.getRecordsBCM");        
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            parentFieldName: component.get("v.tempParentFieldName"),
            parentRecordId: component.get("v.parentRecordId"),
            searchKey: "",
            recordId:component.get("v.primaryRecordId"), 
            fieldNameJson: JSON.stringify(arrfieldNames)
        });
        action.setCallback(this, function(response) {
            var rowDataList = JSON.parse(response.getReturnValue());
            helper.getBCMAttributes(component, event, rowDataList, helper);
        })
        $A.enqueueAction(action);
    },
    
    getSCMTableRows : function(component, event, helper, arrfieldNames){
        if(component.get("v.SCMContactSearchValue") === "allSFUsers" ||
           component.get("v.SCMContactSearchValue") === "allContacts"){
            component.set("v.tempParentFieldName","");
        }else{
            component.set("v.tempParentFieldName",component.get("v.parentFieldName"));
        }
        var action = component.get("c.getRecordsSCM");        
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            parentFieldName: component.get("v.tempParentFieldName"),
            fieldNameJson: JSON.stringify(arrfieldNames),
            searchKey: "",
            recordId:component.get("v.primaryRecordId")  
        });
        action.setCallback(this, function(response) {
            var rowDataList = JSON.parse(response.getReturnValue());
            helper.getBCMAttributes(component, event, rowDataList, helper);
        })
        $A.enqueueAction(action);
    },
    
    getBCMAttributes : function(component, event, rowDataList, helper) {
        var action = component.get("c.getAttributeData");
        action.setParams({
            sObjectName: "Buying_Center_Member__c",
            fieldSetName: "BuyingCenterMemberAttributes"
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
        component.set("v.resultSize", searchResultData.length)
        
        //get pagination
        component.set("v.currentPageNumber",1);
        helper.renderPage(component);
    },
    
    renderPage : function(component){
        let records = component.get("v.tableRecords");
        let recPerPage = component.get("v.recordsPerPage");
        component.set("v.maxPageNumber",Math.ceil(records.length/recPerPage));
        let pageNumber = component.get("v.currentPageNumber");
        let pageRecords = records.slice((pageNumber-1)*recPerPage, pageNumber*recPerPage);
        component.set("v.currentList",pageRecords);
    }    
})