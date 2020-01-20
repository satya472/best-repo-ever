import { LightningElement, track, wire } from 'lwc';
import getNotificationDetails from '@salesforce/apex/CEPAssetPlantToolsCont.getNotificationDetails';
import { refreshApex } from '@salesforce/apex';
import IMAGES from '@salesforce/resourceUrl/images';

export default class Cep_notificationToastList extends LightningElement {
    @track notificationList;
    @track notificationResult;
    @track showToastMsgs;
    @track warningIcon = IMAGES + '/warning-icon.png';
    @track toastNotification = [];

    @wire(getNotificationDetails) notificationListDetails(result) {
        this.notificationResult = result;
        if (result.data) {
            this.notificationList=[];
            result.data.forEach(ele =>{
                if(!ele.Notified_Contacts__r && ele.NotificationImportance__c === 'Urgent'){ 
                    this.notificationList.push(ele);
                }
            });
            this.toastNotification.push(this.notificationList[0]);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.notificationList = undefined;
        }
    }

    displayHideNotificationList(){
        this.showToastMsgs = !this.showToastMsgs;
    }
    hideNotificationClick(){
        this.notificationList = undefined;
    }

    fetchNewNotifications(){
       setTimeout(()=>{
            refreshApex(this.notificationResult);
            this.fetchNewNotifications();
        },40000);
    }

}