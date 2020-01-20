import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import docRecord from '@salesforce/apex/CEP_GenericFileUploader.getListOfDocuments';
import docRecordsList from '@salesforce/schema/ContentDocumentLink';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    refreshApex
} from '@salesforce/apex';

export default class cep_GenericFileUploader extends LightningElement {
    @api recordId;
    @track showDocUploader=false;
    @track commentData;
    @track attachRecordsList=true;
    @track loadSpinner;

    @wire( docRecord, {recordId: '$recordId'})docRecordsList;
    
    
    handleDocUploader() {
        this.showDocUploader = true;
    }
    handleAttachButtonDisplay() {
        this.showDocUploader = false;
    }

    get acceptedFormats() {
        return ['.pdf', '.png','.txt'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        //alert("No. of files uploaded : " + uploadedFiles.length);
        return refreshApex( this.docRecordsList );
    }

    downloadFile(event){
        event.preventDefault();
        var contentDocId=event.currentTarget.dataset;
        var downloadDocUrl='/JEP/sfc/servlet.shepherd/document/download/'+contentDocId.id+'?operationContext=S1';
        window.location.href=downloadDocUrl;
    }

}