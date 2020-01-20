({
    doInit: function(component, event, helper) {
        // this function call on the component load first time     
        // call the helper function   
        helper.getSimilarOpportunities(component);        
    },
    editRecord : function(component, event) 
    {
        
        var selectedRows = event.getParam('selectedRows');
        if(component.get("v.pagenated")){
            component.set("v.pagenated",false)
            return;
        }
       
        component.get("v.SelectedOpps")[component.get("v.currentPage")] = selectedRows; 
        var mapValues = component.get("v.SelectedOpps");
        component.set("v.SelectedOpps",mapValues);
        let displaySelected = 0;
        
        Object.keys(mapValues).forEach(function(key,index) 
		{ 
            displaySelected = displaySelected+mapValues[key].length;
        });
        component.set("v.showSelected",displaySelected);
        
    },
    handleClick : function(component, event,helper) 
    {
        var mapValues = component.get("v.SelectedOpps");
        let selectedRows = [];
        Object.keys(mapValues).forEach(function(key,index)
        { 
            mapValues[key].forEach((key2,index2)=>{
                selectedRows.push(key2);
            });
                
        });
                
        if(selectedRows.length != 0)
        {
         	component.set("v.selectedLst",selectedRows);
            helper.createSimilarOpportunities(component);
        }
    },  
    next : function(component, event, helper) 
    {
        
        let current = component.get("v.currentPage");  
        if(!$A.util.isEmpty(component.get("v.SelectedOpps")[current])){
            component.set("v.pagenated",true);
        }else{
            component.set("v.pagenated",false);
        }
        var pgName = current;
        current = current +1;
        pgName = current;
        
        var nextPageSelectedRows = component.get("v.SelectedOpps")[pgName];
        
        component.set("v.currentPage",current);
        
        var oppList = component.get("v.opportunitiesList");
        var disButton = false;
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var totalRecs =component.get("v.total");
        var paginationList = [];
        
        if(oppList.length > end)
        {
            var pageNum = component.get("v.page");
            pageNum = pageNum + 1;   
            component.set("v.page",pageNum);
        }
        var counter = 0;
        for(var i=end; i<end+pageSize; i++)
        {
            if(oppList.length > end)
            {
                if(oppList[i] != null)
                {
                    paginationList.push(oppList[i]);
                    counter ++ ;
                }
                else{counter ++ ;}
            }
        }
        start = start + counter;
        end = end + counter;
        if(end>=totalRecs)
        {
            disButton = true ;
            component.set("v.disableButton",disButton);
        }
     
        component.set("v.start",start);
        component.set("v.end",end);
        component.set('v.paginationList', paginationList);
  
        if (!$A.util.isEmpty(nextPageSelectedRows )) 
        {
            var selectedRowsIds = [];
            for(var i=0;i<nextPageSelectedRows.length;i++)
            {
                selectedRowsIds.push(nextPageSelectedRows[i].Id);  
            }         
            component.find("similarOppTable").set("v.selectedRows", selectedRowsIds); 
        }
    },
    previous : function(component, event, helper) 
    {
        //To persist page record selections
        var current = component.get("v.currentPage");
        if(!$A.util.isEmpty(component.get("v.SelectedOpps")[current])){
            component.set("v.pagenated",true);
        }else{
            component.set("v.pagenated",false);
        }
        var pgName = current;
        current = current - 1; 
        pgName = current;
        var selRow = component.get("v.SelectedOpps")[pgName];
        
        component.set("v.currentPage",current);
        
        var oppList = component.get("v.opportunitiesList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var totalRecs =component.get("v.total");
        var paginationList = [];
        
        var pageNum = component.get("v.page");
        if(pageNum > 1)
        {    
            pageNum = pageNum - 1;
            component.set("v.page",pageNum);
        }

        var counter = 0;
        for(var i= start-pageSize; i < start ; i++)
        {
            if(i > -1)
            {
                paginationList.push(oppList[i]);
                counter ++;
            }
            else
            {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        //to enable next button
        if(end<totalRecs)
        {
            component.set("v.disableButton",false);
        }
        component.set("v.start",start);
        component.set("v.end",end);
        component.set('v.paginationList', paginationList);
        
        if (!$A.util.isEmpty(selRow )) 
        {
            var selectedRowsIds = [];
            for(var i=0;i<selRow.length;i++)
            {
                selectedRowsIds.push(selRow[i].Id);  
            }         
            component.find("similarOppTable").set("v.selectedRows", selectedRowsIds);
        }
     },
                
})