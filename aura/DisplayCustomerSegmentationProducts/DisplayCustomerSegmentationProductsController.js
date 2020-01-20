({
	doInit : function(component, event, helper) {
		helper.loadProductData(component);
	},
   showBlacklisted : function(component, event, helper){
       
       helper.filterData(component,component.get("v.dataWrapper"));
   },
   filterAssetsOutages : function(component, event, helper){
       helper.filterData(component,component.get("v.dataWrapper"));
   },
   getSelectedRow : function(component, event, helper){
          component.set("v.selectedRowList",event.getParam('selectedRows'));
   },
   handleSave : function(component, event, helper){
        component.set("v.errorMsg",'');
        if($A.util.isEmpty(component.get("v.selectedRowList"))){
            component.set("v.errorMsg",$A.get("$Label.c.SegmentationOpportunityError1"));
            return;
        }
        component.set("v.createOpportunityPopup",true);
   },
   handleRowAction : function(component, event, helper){
        component.set("v.errorMsg",'');
        let action = event.getParam('action');
        let row = event.getParam('row');
        let rows = component.get("v.dataWrapper").recordsWrapper;
        if(action.name == 'Undo'){
            helper.prodBlackListing(component,JSON.stringify(row),false,'');
        }else{
             component.set("v.blackListedRow",row);
             component.set("v.reasonPopup",true);
        }
   },
   rowBlackList : function(component, event, helper){
       helper.prodBlackListing(component,JSON.stringify( component.get("v.blackListedRow")),true,component.find("blackListReason").get("v.value"));
   },
   closePopup : function(component, event, helper){
       component.set("v.blackListedRow",{});
        component.set("v.reasonPopup",false);
        component.set("v.createOpportunityPopup",false);
   },
   error : function(component, event, helper) {
    component.set("v.recCreateSpinner",false);
   },
   submit : function(component, event, helper) {
    event.preventDefault();
    component.set("v.recCreateSpinner",true);   
    let fieldsData = event.getParam("fields");
    fieldsData['recordTypeId'] = component.get("v.opportunityRecordTypeId");
    helper.saveData(component,JSON.stringify(component.get("v.selectedRowList")),JSON.stringify(fieldsData));
   }
           
})