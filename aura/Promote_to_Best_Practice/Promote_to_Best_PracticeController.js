/**
 * Created by jens.becker on 20.03.18.
 * Updated by Ankur on 04.03.18
 */
({
    init : function (cmp) {
        var flow = cmp.find("flowData");
        var recId= cmp.get("v.recordId");
        try{
        	flow.startFlow("Promote_to_Best_Practice");   
        }catch(e){
            console.log('error '+ e);
        }
        
    },
    handleStatusChange : function (component, event,helper) {
        if(event.getParam("status") === "FINISHED_SCREEN") {
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                console.log(outputVar);
                if(outputVar.name === "clonedRecordId"){                    
                    var urlEvent = $A.get("e.force:editRecord");                    
                    urlEvent.setParams({
                        "recordId": outputVar.value,
                        "isredirect": "false"
                    });
                    urlEvent.fire();
                }
            }
        }else{
            var outputVariables = event.getParam("inputVariables");
        }
    }
})