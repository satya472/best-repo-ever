({
	toggle: function(component, event, helper) {
		event.stopPropagation();
		component.set("v.expanded", !component.get("v.expanded"));
	},
	itemSelect : function(component, event, helper) {
		let selectedItem = event.currentTarget.dataset.item;
		component.set("v.selectedItem",selectedItem);
	}
})