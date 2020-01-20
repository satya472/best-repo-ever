import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import commentRecord from '@salesforce/apex/DisplayListOfRecords.getListOfCommentRecords';
import createComment from '@salesforce/apex/DisplayListOfRecords.createCaseComment';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    refreshApex
} from '@salesforce/apex';

export default class Cep_ticketComments extends LightningElement {
    @api recordId;
    @track showCommentEntry;
    @track commentData;
    @track loadSpinner;

    @wire( commentRecord, {
        recordId: '$recordId'
    } ) commentRecordsList;

    showCommentEntrySection() {
        this.showCommentEntry = true;
    }
    hideCommentEntrySection() {
        this.showCommentEntry = false;
        this.commentData = '';
    }

    onCommentChange( event ) {
        this.commentData = event.target.value;
    }

    addComment() {
        this.loadSpinner = true;

        createComment( {
            body: this.commentData,
            parentId: this.recordId
        } ).then( () => {

            this.dispatchEvent(
                new ShowToastEvent( {
                    title: 'Success',
                    message: 'Comment Inserted Successfully!!',
                    variant: 'success',
                } ),
            );

            this.hideCommentEntrySection();
            this.loadSpinner = false;
            return refreshApex( this.commentRecordsList );

        } ).catch( ( error ) => {

            this.dispatchEvent(
                new ShowToastEvent( {
                    title: 'Error creating record',
                    message: error.body.message,
                    variant: 'error',
                } ),
            );
            this.loadSpinner = false;
        } );


    }



}