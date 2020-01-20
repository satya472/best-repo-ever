import { LightningElement,api,track } from 'lwc';

export default class Cep_notificationToast extends LightningElement {
    @api notification;
    @track hideNotification=false;

    showNotification(event){
        window.open('/JEP/s/notifications?notificationId='+event.currentTarget.dataset.id,'_self');
    }

    hideNotificationClick(){
        this.hideNotification = true;
    }
}