({
	scriptsLoaded : function(component, event, helper) {
        //console.log('Script loaded..');
        var action = component.get('c.getCases');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cases = response.getReturnValue();
                var caseList = [];
                //console.log("...........cases...........");
                //console.log(cases);
                for (var key in cases) {
                    //console.log(key, cases[key]);
                    caseList.push({
                        'mrid': cases[key].mrid,
                       	'e__uid': cases[key].e__uid,
                        'plant_part': cases[key].plant_part,
                        'mrtitle': cases[key].mrtitle,
                        'product__blevel__b1': cases[key].product__blevel__b1,
                      	'product__blevel__b2': cases[key].product__blevel__b2,
                        'contract': cases[key].contract,
                        'submitted__bat': cases[key].submitted__bat,
                        'mrstatus': cases[key].mrstatus,
                    });
                }
                //console.log(caseList);
                //
                component.set('v.caseListArr', caseList);
                // when response successfully return from server then apply jQuery dataTable after 500 milisecond
                setTimeout(function(){ 
                    //jQuery('#hotline-list').DataTable();
                    jQuery('#hotline-list').DataTable({ responsive: true });
                    // add lightning class to search filter field with some bottom margin..  
                    $('div.dataTables_filter input').addClass('slds-input');
                    $('div.dataTables_filter input').css("marginBottom", "10px");
                }, 500);          
            }
        });
        $A.enqueueAction(action); 
    },
    editCaseDetail: function(component, event, helper) {
        event.preventDefault();
        console.log("inside editCaseDetail");
        component.set('v.showEdit', false);
        var id = event.currentTarget.dataset.id;
        console.log(id);
        component.set('v.recordId', id);
        component.set('v.showEdit', true);
    },
    getCaseDetail: function(component, event, helper) {
        event.preventDefault();
        console.log("inside getCaseDetail");
        component.set('v.showDetail', false);
        var id = event.currentTarget.dataset.id;
        console.log(id);
        component.set('v.recordId', id);
        component.set('v.showDetail', true);
    }
})