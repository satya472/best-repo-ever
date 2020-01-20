(
    { 
        init : function(component, event, helper)
        {
            helper.getLightningTableData(component);
        },
        
        editRecord : function(component, event) 
        {
            var selectedRows = event.getParam('selectedRows');
            
            if(selectedRows.length != 0)
            {
                component.set("v.selectedLst",selectedRows);
            }
        },
        filterRecords : function(component, event, helper)
        {
            $A.util.toggleClass(component.find("relatedSpinner"), "slds-hide"); 
            let dataRec = component.get("v.nonExistingList");
            var splitFilters = component.get("v.filterBy").split(",");  
            var filters = [];
            for (var i in splitFilters) {  
                let elementVal = document.getElementById(splitFilters[i]).value;
                if(elementVal == 'All'){
                    continue;
                }
                filters[filters.length] = splitFilters[i]+','+elementVal; 
            } 
            let filterLst = [];
            if($A.util.isEmpty(filters)){
                filterLst = dataRec;
            }else{
                
                filterLst = dataRec.filter(function(rec){
                    let filterSatisfied = false;
                    filters.every(function(fList){
                        let fSplit = fList.split(',')
                        if(rec[fSplit[0]] == fSplit[1]){
                            filterSatisfied = true;
                            return true;
                        }else{
                            filterSatisfied = false;
                            return false;
                        }
                        
                    });
                    return filterSatisfied;
                });
            }
            component.set("v.mydata",filterLst);
            $A.util.toggleClass(component.find("relatedSpinner"), "slds-hide"); 
        },
        
        handleClick : function(component, event,helper) {
            var selectedRows = component.get("v.selectedLst");
            component.set("v.recCreateSpinner",true);
            if(selectedRows.length != 0)
            {
                helper.createTargetRecords(component);
            }
        }
        
    })