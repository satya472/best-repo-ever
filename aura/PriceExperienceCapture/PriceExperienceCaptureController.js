/**
 * Created by jens.becker on 11.04.18.
 */
({
    init: function(cmp,  event,helper){
        //get the

        var objName = cmp.get("v.sObjectName");
        var id = cmp.get("v.recordId");
        if(objName=="Opportunity"){
            cmp.set("v.startingObjectId", id);
        }
        helper.getCompetitionRecords(cmp);
    }
})