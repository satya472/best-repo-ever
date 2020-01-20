import { LightningElement, track, api } from 'lwc';
import getCases from '@salesforce/apex/CEPCaseCont.getCases';	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Cep_caseListDT extends LightningElement {

	@track casedata = [];
	@track filteredData = [];
    @api columns = [];
    @track rowOffset = 0;
    @track tableLoadingState = true;
    @api sortedBy = 'case_number';
    @api sortedDirection = 'asc';
    @track queryTerm;
    @track recordId = 0;

    @track toastTitle = 'Error';
    @track toastMessage;
    @track toastVariant = 'error';

    @track value;
    @track plantPart = {};
    @track system = {};
    @track product = {};
    @track status = {};

    showNotification() {
        const evt = new ShowToastEvent({
            title: this.toastTitle,
            message: this.toastMessage,
            variant: this.toastVariant,
        });
        this.dispatchEvent(evt);
    }

    /*
    * Helper : Takes in a Array , returns an object with the same value and two keys : label and value
    */
    returnObject(sourceArray) {
        let returnArr = [];
        for (let i = sourceArray.length - 1; i >= 0; i--) {
            if (sourceArray[i]) {
                returnArr.push({label:sourceArray[i],value:sourceArray[i]});
            }
        }
        return returnArr;
    }

    constructor() {
        super();
        this.columns = [
            { label: 'Case#', fieldName: 'case_number',type: 'text',sortable: true },
		    { label: 'Plant part', fieldName: 'plant_part', type: 'text',sortable: true },
		    { label: 'Ticket Priority', fieldName: 'ticket_priority', type: 'text',sortable: true },
		    { label: 'Title', fieldName: 'title', type: 'text',sortable: true },
		    { label: 'System', fieldName: 'system', type: 'text',sortable: true },
		    { label: 'Product', fieldName: 'product', type: 'text',sortable: true },
		    { label: 'Contract', fieldName: 'contract', type: 'text',sortable: true },
		    { label: 'Opened Date', fieldName: 'opened_date', type: 'text',sortable: true },
		    { label: 'Status', fieldName: 'status', type: 'text',sortable: true },
            { type: 'action', typeAttributes: { rowActions: this.getRowActions } },
        ]
    }

    /*
    * Function to filter records based on filter selected
    */
    handleDropdownChange(event){
        this.clearStartDate();
        this.clearEndDate();
        let name = event.currentTarget.name;
        this.value = event.detail.value;
        let tableData = this.casedata;
        let results = tableData.filter(m => {
            if ( this.value == m[name]) {
                return m;
            }
        });
        this.filteredData = results;
    }

    /**
    * Function to return row actions in the table
    */
    getRowActions(row, doneCallback) {
        const actions = [];
    	actions.push({
                'label': 'Show details',
                'name': 'show_details'
        });
        if (row['status'] != 'Closed') {
            actions.push({
                'label': 'Edit',
                'name': 'edit'
            });
        } 
        doneCallback(actions);
    }


    /**
    * Function to handle actions in the table
    */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'edit':
                this.editRecord(row);
                break;
            case 'show_details':
                this.displayRecord(row);
                break;
            default:
                console.log("invalid action selected");
        }
    }

    async connectedCallback() {
    	let caseArr = [];
        let plantPartArr = [];
        let systemArr = [];
        let productArr = [];
        let statusArr = [];
    	getCases().then(result => {
              Object.entries(result).forEach(([key,map2]) =>{
              	  let openedDate = new Date(map2.submitted__bat);
              	  let dd = (openedDate != 'Invalid Date') ? openedDate.getDate() : '';
              	  let mm = (openedDate != 'Invalid Date') ? openedDate.getMonth()+1 : '';
              	  let yyyy = (openedDate != 'Invalid Date') ? openedDate.getFullYear() : '';
                  plantPartArr.push(map2.plant_part);
                  systemArr.push(map2.product__blevel__b1);
                  productArr.push(map2.product__blevel__b2);
                  statusArr.push(map2.mrstatus);
                  caseArr.push({
                      'case_number': map2.e__uid,
                      'opened_date': `${dd}-${mm}-${yyyy}`,
                      'title': map2.mrtitle,
                      'status': map2.mrstatus,
                      'system': map2.product__blevel__b1,
                      'product': map2.product__blevel__b2,
                      'mrid': map2.mrid,
                      'submitted__bat': map2.submitted__bat,
                      'contract': map2.contract,
                      'plant_part': map2.plant_part,
                      'ticket_priority':map2.ticket_priority,
                  });
              });
        }).then(()=>{
	        this.casedata = caseArr;
	        this.filteredData = caseArr;
	        this.tableLoadingState = false;

            plantPartArr = [...new Set(plantPartArr)]; //Return all unique values from the array
            this.plantPart = this.returnObject(plantPartArr.sort().reverse());

            systemArr = [...new Set(systemArr)];
            this.system = this.returnObject(systemArr.sort().reverse());

            productArr = [...new Set(productArr)];
            this.product = this.returnObject(productArr.sort().reverse());

            statusArr = [...new Set(statusArr)];
            this.status = this.returnObject(statusArr.sort().reverse());

        })
        
    }

    clearEndDate(){
        this.template.querySelector(".ed").value = '';
    }

    clearStartDate(){
        this.template.querySelector(".sd").value = '';
    }

    clearValue(){
        this.value = '';
    }

    /**
    * Function to handle search cases by date
    */
    filterByDate(event) {
        this.clearValue();
        let sd = this.template.querySelector(".sd").value;
        let ed = this.template.querySelector(".ed").value;
        let startDate = new Date(sd);
        let endDate = new Date(ed);

        if (!sd) {
            this.toastMessage = 'Please enter start date';
            this.showNotification();
            this.filteredData = this.casedata;
        } else if (!ed) {
        	this.toastMessage = 'Please enter end date';
            this.showNotification();
            this.filteredData = this.casedata;
        } else if (startDate > endDate)  {
            this.toastMessage = 'Start date is greater than end date';
            this.showNotification();
            this.filteredData = this.casedata;
        } else {
        	let tableData = this.casedata;
        	let results = tableData.filter(m => {
	    		let currentRecordDate = new Date(m.submitted__bat);
	    		currentRecordDate.setHours(0,0,0,0);
	    		startDate.setHours(0,0,0,0);
	    		endDate.setHours(0,0,0,0);
				if ( currentRecordDate >= startDate && currentRecordDate <= endDate) {
					return m;
				} 
		    });
        	this.filteredData = results;
        }
    }


    /**
    * Function to handle search
    */
    handleKeyUp(evt) {
    	this.clearStartDate();
        this.clearEndDate();
        this.clearValue();

    	this.queryTerm = evt.target.value;
    	let tableData = this.casedata,
            term = this.queryTerm,
            results = tableData, regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = tableData.filter(
            	row => 
	            	regex.test(row.title) ||
	            	regex.test(row.case_number.toString()) ||
	            	regex.test(row.opened_date.toString()) ||
	            	regex.test(row.status) ||
	            	regex.test(row.system) ||
	            	regex.test(row.product) ||
	            	regex.test(row.contract) ||
	            	regex.test(row.ticket_priority) ||
	            	regex.test(row.plant_part)
            );
        } catch(e) {
        	console.error("error while searching");
            console.log(e);
        }
        this.filteredData = results;
    }

    

    /**
    * Function to handle edit case , opens a new component
    */
    editRecord(row) {
        this.recordId = row.mrid; 
        this.template.querySelector('c-cep_case-update').openModalBox();
    }

    /**
    * Function to handle get case , opens a new component
    */
    displayRecord(row) {
    	this.recordId = row.mrid;
		this.template.querySelector('c-cep_case-detail').openModalBox();   	
    }

    /**
    * Function to handle sorting
    */
    updateColumnSorting(event) {
            let fieldName = event.detail.fieldName;
            let sortDirection = event.detail.sortDirection;
            // assign the latest attribute with the sorted column fieldName and sorted direction
            this.sortedBy = fieldName;
            this.sortedDirection = sortDirection;
            this.filteredData = this.sortData(fieldName, sortDirection);
            this.filteredData=JSON.parse(JSON.stringify(this.filteredData));
    }

    /**
    * Function to sort data , called in updateColumnSorting
    */
    sortData(fieldName, sortDirection) {
        let sortedData = this.filteredData;
        let reverse = sortDirection !== 'asc';
        sortedData.sort(this.sortBy(fieldName, reverse));
        return sortedData;
    }

    /**
    * Function to sort data by field name, called in sortData
    */
    sortBy(field, reverse, primer) {
        let key = primer ?
            function(x) {return primer(x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'zzz')} :
            function(x) {return x.hasOwnProperty(field) ? (typeof x[field] === 'string' ? x[field].toLowerCase() : x[field]) : 'zzz'};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }

}