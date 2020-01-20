import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import getfilesInfo from '@salesforce/apex/CEPAssetPlantToolsCont.getfilesInfo';
import LOCALE from '@salesforce/i18n/locale';

export default class Cep_notificationItem extends LightningElement {

    @track notificationRecord;

    @api contactId;

    @api 
    get record(){
        return this.notificationRecord;
    }

    set record(value){

        this.notificationRecord = Object.assign({},value);

    }

    @api selectedNotificationId;
    layoutFields = ['Name','NotificationDate__c','Description__c','Asset__c','AssetType__c','AffectedComponent__c','Recommendation__c','Contact__c'];

    @track icon='utility:chevronright';
    @track cssClass = 'slds-section';
    @track headerCss = 'slds-section__title slds-section__title-action';
    @track contentCss = 'slds-section__content hideContent';
    @track showAckBtn;
    @track showSpinner;
    @track filesList;
    @track types;
    @track assetName;
    @track notificationStatusCss;
    @track date;
    @track month;
    @track year;
    
    connectedCallback(){
      this.showAckBtn = this.notificationRecord.acknowledgedDate?false:true;
      this.types = this.notificationRecord.AssetType__c?this.notificationRecord.AssetType__c.split(';'):[];
      this.assetName = this.notificationRecord.Asset__c?this.notificationRecord.Asset__r.Name:'N/A';


      /* Deciding the Color that needs to be marked on UI based on the notification acknowledged or not */
      if(!this.showAckBtn){
        this.cssClass = this.cssClass+' acknowledged';
      }else{
        this.notificationStatusCss = !this.notificationRecord.acknowledgedDate?(this.notificationRecord.NotificationImportance__c === 'Urgent'?'urgent':'other'):'';
        this.cssClass = this.cssClass+' '+this.notificationStatusCss;
      }

      /*Splitting and displaying the date on the UI */
      if(this.notificationRecord.NotificationDate__c){
        let formatDate = new Date(this.notificationRecord.NotificationDate__c);
        this.date = formatDate.getDate();
        this.month = formatDate.toLocaleString(LOCALE, { month: 'long' });
        this.year = formatDate.getFullYear();
      }

      /* If there is a notificationId passed as parameter in Url and matches the current Notification record then we will expand the notification automatically*/
      if(this.selectedNotificationId === this.notificationRecord.Id){
        this.handleClick();
      }
      
    }

    /* Method for updating the CSS inorder to expand the notification div to display the details */
    expandAccordion(){

        this.cssClass = (this.cssClass.indexOf('slds-is-open') !== -1 ?'slds-section':'slds-section slds-is-open') +' '+(!this.showAckBtn?'acknowledged':this.notificationStatusCss);
        this.icon = this.cssClass.indexOf('slds-is-open') === -1 ? 'utility:chevronright':'utility:chevrondown';
        this.contentCss = 'slds-section__content slds-p-around_small'+(this.cssClass.indexOf('slds-is-open') === -1?' hideContent':'');

    }

    /* Handling the click on div which expands and Collapse the notification details*/
    handleClick(){

        this.expandAccordion();
        
        /* Fetching the Files attached to the Notification and displaying them */
        getfilesInfo({recordId: this.notificationRecord.Id})
        .then((result) =>{

            this.filesList = result;
            this.filesList = this.filesList.length > 0? this.filesList: undefined;

        }).catch(error=>{

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );

        });

        /* If the notification is not read then we will insert a record in NotifiedContact__c with notificationStatus as Read*/
        if(!this.notificationRecord.read){

            let fields = {
                AssetNotification__c : this.notificationRecord.Id,
                Contact__c : this.contactId,
                NotificationStatus__c : 'Read'
              };

              let recordInput = {apiName:'NotifiedContact__c', fields}
              this.showSpinner = true;

          createRecord(recordInput)
                    .then((result) => {
                        this.notificationRecord.notifiedRecordId = result.id;
                        this.notificationRecord.read = true;
                        this.showSpinner = false;                      
                    })
                    .catch(error => {

                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error Updating record',
                                message: error.body.message,
                                variant: 'error'
                            })
                        );
                        this.showSpinner = false;
                    });

        }

    }

    /* When user clicks on Acknowledge button the method is invoked which creates or Updates record in the NotifiedContact__c object */
    acknowledgeClick(event){

      event.stopPropagation();

      let fields = {
        NotificationStatus__c : 'Acknowledged',
        AcknowledgedDate__c : new Date()
      };

      /* If the notification has read property marked to true i.e. already record available in NotifiedContact__c for this Notification */
      if(this.notificationRecord.read){
          this.showSpinner = true;

          fields.Id = this.notificationRecord.notifiedRecordId;
          
          let recordInput = {fields}

          updateRecord(recordInput)
          .then(() => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'Notification Acknowledged',
                      variant: 'success'
                  })
              );
              this.showSpinner = false;
              this.showAckBtn = false;
              
              this.dispatchEvent(new CustomEvent('recordupdated'));
          })
          .catch(error => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error Updating record',
                      message: error.body.message,
                      variant: 'error'
                  })
              );
              this.showSpinner = false;
          });
      }else{

        /* As no Notification record is available in NotifiedContact__c we will insert new record*/

        this.showSpinner = true;

        fields.AssetNotification__c = this.notificationRecord.Id;
        fields.Contact__c = this.contactId;

        let recordInput= {apiName:'NotifiedContact__c', fields};

        createRecord(recordInput)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Notification Acknowledged',
                    variant: 'success'
                })
            );
            this.showSpinner = false;
            this.showAckBtn = false;
            
            this.dispatchEvent(new CustomEvent('recordupdated'));
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.showSpinner = false;
        });
      }

    }

}