({
	doInit : function(component, event, helper) {
		let accId='0010E00000JzNIMQA3';
        component.set("v.accountId",accId);
        if(!$A.util.isEmpty(component.get("v.accountId"))){
            helper.getAccountDetailsHelper(component, event);
        }
	}
})