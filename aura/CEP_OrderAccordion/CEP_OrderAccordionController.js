({
	expandCollapse : function(component, event, helper) {
	  let serNum = event.currentTarget.dataset.val;
	  if(serNum == component.get("v.accordIndex")){
		   component.set("v.accordIndex",'0');
	  }else{
		   component.set("v.accordIndex",serNum);
	  }
   },
   doInit : function(component, event, helper) {
	 component.set("v.index",(component.get("v.index")).toString());
   }
})