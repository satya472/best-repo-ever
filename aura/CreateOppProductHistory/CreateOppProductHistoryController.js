({
	init : function(component, event, helper)
        {
            helper.getHistoryTableData(component);
        },
        editRecord : function(component, event) 
        {
            var selectedRows = event.getParam('selectedRows');
            
            if(selectedRows.length != 0)
            {
                component.set("v.selectedLst",selectedRows);
            }
        },
        multiSelectValues : function(component, event, helper)
        {
            $A.util.toggleClass(component.find("relatedSpinner"), "slds-hide"); 
            //let dataRec = component.get("v.nonExistingList");
            var selectedOptionValue = event.getParam("value");
            var multiString ;
            selectedOptionValue.forEach(function(rec,index){
                var split = rec.split(",");
                if(!multiString)
                {
                    multiString = split + ';';
                }
                else{
                    
                    multiString = multiString +split + ';';
                    
                    
                }
            });
            multiString = multiString.slice(0, multiString.length-1);
            component.set("v.wonLossFilter",multiString);
             
            $A.util.toggleClass(component.find("relatedSpinner"), "slds-hide"); 
        },
        stageValue : function(component, event, helper)
        {
            $A.util.toggleClass(component.find("relatedSpinner"), "slds-hide");
            var splitFilters = component.get("v.compFilters").split(","); 
            let elementVal = document.getElementById(splitFilters[0]).value;
            component.set("v.statusFilter",elementVal);
            $A.util.toggleClass(component.find("relatedSpinner"), "slds-hide"); 
        },
        handleClick : function(component, event,helper) {
            component.set("v.recCreateSpinner",true);
            var selectedRows = component.get("v.selectedLst");
            if(selectedRows.length != 0)
            {
                helper.updateOppProdHistoryRecords(component);
            }
        }
        
})