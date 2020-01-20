({
	doInit: function (component, event, helper) {

		let orderList = ['Order Entry', 'Order Confirmed', 'With Warehouse', 'Ready to Ship', 'Goods Issued','With Forwarder', 'Delivered'];
		
		let status = component.get("v.currentStatus") == 'Initiation of Delivery'?'With Warehouse':component.get("v.currentStatus") == 'Receipt by shipping agent/carrier'?'With Forwarder':component.get("v.currentStatus");

		component.set("v.orderStatusList", orderList);
		component.set("v.currentIndex", orderList.indexOf(status));

	}
})