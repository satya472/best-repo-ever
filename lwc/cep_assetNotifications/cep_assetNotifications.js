import { LightningElement, wire, track, api } from 'lwc';
import getNotificationDetails from '@salesforce/apex/CEPAssetPlantToolsCont.getNotificationDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import Contact_NAME_FIELD from '@salesforce/schema/User.ContactId';
import { getRecord } from 'lightning/uiRecordApi';
import usrId from '@salesforce/user/Id';

export default class Cep_assetNotifications extends LightningElement {

    notificationsList;
    @api selectedId;
    @track sortedNotificationList;
    @track sortField;
    @track sortDirection;
    @track contactId;

     /** Wired Apex result so it can be refreshed programmatically */
     wiredNotificationResult;

     @wire(getRecord, {recordId: usrId,fields:[Contact_NAME_FIELD]})
     userDetails(result){
         if(result.data){
            this.contactId = result.data.fields.ContactId.value;
         }
     }

    /* Fetching Notification Records from the system */
    @wire(getNotificationDetails)
    notificationInfo(result){
        this.wiredNotificationResult = result;
       if(result.data){
           // Adding the fetched records to notificationList and SortedNotificationList to display onto screen
           //The records fetched in this manner are read-only
           //We are parsing them to form new array and update them with new fields which we would like to display on UI i.e. acknowledged Date
            let finalData = JSON.parse(JSON.stringify(result.data));
            finalData.forEach(ele =>{

                if(ele.Notified_Contacts__r){
                    if(ele.Notified_Contacts__r[0].AcknowledgedDate__c){
                        let date = new Date(ele.Notified_Contacts__r[0].AcknowledgedDate__c);
                        let d = date.getDate();
                        let m = date.getMonth() + 1;
                        let y = date.getFullYear();
                        
                        ele.acknowledgedDate  = y + '-' + (m <= 9 ? '0' + m : m) + '-' + (d <= 9 ? '0' + d : d);
                    }
                    
                    ele.read = true;
                    ele.notifiedRecordId = ele.Notified_Contacts__r[0].Id;
                }else{
                    ele.acknowledgedDate = null;
                    ele.read = false;
                    ele.notifiedRecordId = null;
                }

            });
            this.notificationsList = Object.keys(result.data).length === 0?undefined:finalData;
            this.sortedNotificationList = Object.keys(result.data).length === 0?undefined:finalData;
            
        }else if(result.error){
            this.sortedNotificationList  = undefined;
            this.notificationsList = undefined;
            this.displayError(result.error)
        }
    }

    handleSearch(event){
        //The method is invoked when the user starts typing input into the Search text box
       let val = event.currentTarget.value.toLowerCase();
       this.sortedNotificationList = undefined;

       if(val !== ''){
           //Filtering the records
            let filteredRec = this.notificationsList.filter(ele =>{
                return (ele.Name.toLowerCase()).includes(val) || (ele.User__c?(ele.User__r.Name.toLowerCase()).includes(val):false) ||
                (ele.acknowledgedDate?ele.acknowledgedDate.toString().includes(val):false) ||
                (ele.Description__c?ele.Description__c.includes(val):false);
            });

            this.sortedNotificationList = filteredRec.length > 0?filteredRec:undefined;
       }else{
           this.sortedNotificationList = this.notificationsList;
       }
       
    }

    sortRecords(event){
        //This method is invoked when the user clicks on the Headers for Sorting the records
        let field = event.currentTarget.dataset.name;

        this.sortDirection = (this.sortField === '' || this.sortField !== field)?'asc': (this.sortDirection === 'asc')?'desc':'asc';
        this.sortData(field,this.sortDirection);

        //The below code is used to update the arrow direction based on the sort order and the header clicked
        this.template.querySelectorAll('lightning-icon').forEach(ele=>{

            if(ele.alternativeText === field){
                ele.iconName = this.sortDirection === 'asc'?'utility:chevrondown':'utility:chevronup';
            }else{
                ele.iconName = 'utility:chevrondown';
            }

        });
    }

    sortData(fieldName, sortDirection) {

        let data = JSON.parse(JSON.stringify(this.notificationsList));
        
        this.sortedNotificationList = [];
        let reverse = sortDirection !== 'asc';

        data.sort(this.sortBy(fieldName, reverse));

        this.sortedNotificationList = data;
        this.sortField = fieldName;
        
    }
    sortBy(field, reverse, primer) {
            var key = primer ?
                function(x) {return primer(x[field])} :
                function(x) {return x[field]};
            reverse = !reverse ? 1 : -1;
            return function (a, b) {
                return a = key(a)?key(a):'', b = key(b)?key(b):'', reverse * ((a > b) - (b > a));
            }
    }

    refreshData(){
        this.notificationsList = undefined;
        this.sortedNotificationList =  undefined;
        return refreshApex(this.wiredNotificationResult);
    }

    displayError(error){
        //Method for displaying the error
        let message = 'Unknown error';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            message = error.body.message;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error',
            }),
        );

    }


}