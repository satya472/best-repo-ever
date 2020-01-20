({
    filterRecords : function(component,event,helper) {

        let type= component.find("ticketType").get("v.value");
        let status= component.find("status").get("v.value");
        let search= component.find("searchTxt").get("v.value").toLowerCase();

        component.set("v.filteredList",'');

        let recordsAfterFilter = component.get("v.fullList").filter(rec =>{
             return $A.util.isEmpty(type)?true:rec.ticketType == type;
        }).filter(rec =>{
            return $A.util.isEmpty(status)?true:rec.status.toLowerCase() == status.toLowerCase();
       }).filter(rec =>{
            return $A.util.isEmpty(search)?true:(rec.ticketNumber.indexOf(search) != -1 || (rec.relatedUnit).toLowerCase().indexOf(search) != -1 ||
                                                 rec.createdDate.indexOf(search) != -1);
       })

       component.set("v.filteredList",recordsAfterFilter);

    },
    
})