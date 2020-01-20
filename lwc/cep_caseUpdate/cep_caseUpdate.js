import { LightningElement, track, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import BOOTSTRAP from '@salesforce/resourceUrl/bootstrap';
import getCaseDetail from '@salesforce/apex/CEPCaseCont.getCaseDetail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateCase from '@salesforce/apex/CEPCaseCont.updateCase';
import sendHotlineEmail from '@salesforce/apex/HotlineEmailCont.sendHotlineEmail';
import removeHotlineFile from '@salesforce/apex/HotlineEmailCont.removeHotlineFile';
import fetchHotlineFile from '@salesforce/apex/HotlineEmailCont.fetchHotlineFile';


export default class Cep_caseUpdate extends LightningElement {
    @track acceptedFormats = '.0,.1,.7z,.bmp,.cf,.cfg,.CN,.csv,.dat,.doc,.gif,.gz,.htm,.ini,.jar,.jpg,.lgf,.lic,.lnk,.log,.lst,.mov,.msg,.MTK,.oft,.pbp,.pdf,.pgm,.png,.ppt,.rar,.rtf,.sa,.seq,.sh,.tar,.tif,.txt,.tz,.vi,.vsd,.wmv,.xls,.xml,.Z,.zip';

    @track _recordId;
    @track counter = 0;

    @track caseDetailArr;
    @track comment;
    @track showInnerSpinner = false;
    @track ticketNo = 0;

    @track fileValues = new Array();
    @track fileData = [];
    @track emailAttachments;
    @track totalFileSize = 0;

    @track displayFileUpload = true;
    @track _showEdit;

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        this.loaded = false;
        this.eidtCase();
    }

    @api
    get showEdit() {
        return this._recordId;
    }

    set showEdit(value) {
        this._showEdit = value;
        if (value === true) {
            this.openModalBox();
            this._showEdit = false;
        }
    }

    get getKey() {
        return this.counter++;
    }


    renderedCallback() {
        this.displayFileUpload = true;
        loadScript(this, BOOTSTRAP + '/js/jquery.js');
    }

    handleChange(event) {
        this.comment = event.currentTarget.value;
    }

    scrollToTop() {
        $(this.template.querySelector('.modal-body')).scrollTop(0);
    }

    eidtCase() {
        if (this._recordId === 0) {
            return;
        }
        let dataJson = {
            'plantId': '25',
            'mrId': this._recordId
        };
        loadStyle(this, BOOTSTRAP + '/css/bootstrap.min.css')
            .then(() => {
                this.showInnerSpinner = true;

                getCaseDetail({ 'data': JSON.stringify(dataJson) })
                    .then(data => {
                        this.caseDetailArr = [];
                        Object.entries(data).forEach(([key, map2]) => {
                            this.ticketNo = map2.e__uid;
                            this.caseDetailArr.push({
                                'euid': map2.e__uid,
                                'description': map2.description,
                                'mrid': map2.mrId,
                                'mrtitle': map2.mrtitle,
                                'mrstatus': map2.mrstatus,
                                'system': map2.product__blevel__b1,
                                'product': map2.product__blevel__b2,
                                'source': map2.source,
                                'workStart': map2.work__bstarted.body,
                                'submittedbat': map2.submitted__bat,
                                'mralldescriptions': map2.mralldescriptions,
                            });
                        });
                    })
                    .then(() => {
                        this.showInnerSpinner = false;
                    })
            }).catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading data',
                        message: this.error,
                        variant: 'error'
                    })
                );
                this.showInnerSpinner = false;
            });
    }

    redirectToDashboard() {
        window.location.href = '/JEP/s/hotline';
    }

    handleFileChange(event) {

        this.emailAttachments = event.detail.files;

        try {
            Object.entries(this.emailAttachments).forEach(([key, file]) => {
                this.validateAndHandleFile(file.documentId)
            });
        } catch (e) {
            console.log(e);
        }

    }

    validateAndHandleFile(documentId) {
        fetchHotlineFile({
            'documentId': documentId
        }).then(response => {
            let result = JSON.parse(response);
            let fileSize = (result.ContentSize / 1024).toFixed(2);
            let fileName = result.Title + '.' + result.FileExtension;
            let fileValid = false;
            let tempFileDataHolder = [];
            let tempFileValueHolder = new Array();

            let message = 'File size can not be greater than 17MB.';
            fileSize = parseInt(fileSize, 10);

            //Fill existing data to temp folder
            Object.entries(this.fileData).forEach(([key, file]) => {
                tempFileDataHolder.push({
                    'fileName': file.fileName,
                    'documentId': file.documentId,
                    'fileSize': file.fileSize
                });
            });
            Object.entries(this.fileValues).forEach(([key, docId]) => {
                tempFileValueHolder[tempFileValueHolder.length] = docId;
            });


            if ((fileSize / 1024) <= 17) {
                this.totalFileSize += fileSize;
                if ((this.totalFileSize / 1024) > 17) {
                    message = 'Total file size can not be greater than 17MB.';
                    removeHotlineFile({
                        'documentId': documentId,
                    });
                    this.totalFileSize -= fileSize;
                    fileValid = false;
                } else {
                    tempFileDataHolder.push({
                        'fileName': fileName,
                        'documentId': documentId,
                        'fileSize': fileSize
                    });
                    tempFileValueHolder[tempFileValueHolder.length] = documentId;

                    fileValid = true;

                }
            } else {
                removeHotlineFile({
                    'documentId': documentId,
                });
                fileValid = false;
            }

            this.fileData = tempFileDataHolder;
            this.fileValues = tempFileValueHolder;

            if (!fileValid) {
                let title = 'File "' + fileName + '" is removed.'

                const evt = new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }

            return fileValid;
        });
    }

    saveComment() {
        this.scrollToTop();
        this.showInnerSpinner = true;

        let self = this;

        if (this.comment) {
            //Case User wants to add comment to ticket
            let caseDetailArr = this.caseDetailArr[0];
            let isoDate = new Date(new Date).toLocaleString();

            let tempComment = '\n-------' + isoDate + '-------\n';
            tempComment = tempComment + this.comment;

            caseDetailArr.description = tempComment;

            updateCase({ 'data': JSON.stringify(caseDetailArr) })
                .then(response => {
                    let title, message, variant;

                    if (response === 'error') {
                        title = 'Error';
                        message = 'There is an Error in Updating the Case';
                        variant = 'error';
                    } else {
                        self.trriggerMail(
                            self._recordId,
                            self.fileValues
                        );
                        title = 'Success';
                        message = 'Case ' + response + ' Updated Successfully';
                        variant = 'success';

                        self.comment = '';
                        self.resetFileControl();
                        self.showInnerSpinner = false;
                        self.redirectToDashboard();
                    }

                    const evt = new ShowToastEvent({
                        title: title,
                        message: message,
                        variant: variant,
                        mode: 'pester'
                    });
                    this.dispatchEvent(evt);
                    this.closeModalBox();

                }).catch(error => {
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating case',
                            message: this.error,
                            variant: 'error'
                        })
                    );
                });

        } else if (this.fileValues) {
            this.trriggerMail(
                this._recordId,
                this.fileValues
            );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucess',
                    message: 'Case ' + this._recordId + ' Updated Successfully',
                    variant: 'success'
                })
            );
            this.resetFileControl();
            self.showInnerSpinner = false;
            this.closeModalBox();

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating case',
                    message: 'Either add comment or attach a file',
                    variant: 'error'
                })
            );
            self.showInnerSpinner = false;
        }

    }

    resetFileControl() {
        this.fileData = '';
        this.fileValues = '';
        this.displayFileUpload = false;
    }

    trriggerMail(caseId, fileValues) {
        let mailBody = '<h2>Hotline Ticket Updated</h2><br/><br/>';
        mailBody += '<h4>Hotline Ticket Id - ' + caseId + '</h4>';

        let mailSubject = 'Hotline ticket updated';

        let mailText = {
            'mailSubject': mailSubject,
            'mailBody': mailBody,
        };

        sendHotlineEmail({
            'mailText': JSON.stringify(mailText),
            'fileValues': JSON.stringify(fileValues)
        });
    }

    removeFile(event) {
        let documentId = event.currentTarget.dataset.value;
        let orginalFilesHolder = this.fileData;
        let fileDataObject;
        let loopFlag = 0;

        try {
            fetchHotlineFile({
                'documentId': documentId
            }).then(response => {
                let result = JSON.parse(response);
                let fileSize = (result.ContentSize / 1024).toFixed(2);
                this.totalFileSize -= fileSize;
            });
            removeHotlineFile({
                'documentId': documentId,
            });


            Object.entries(orginalFilesHolder).forEach(([index, fileInfo]) => {
                if (loopFlag) {
                    return;
                }
                if (fileInfo.documentId === documentId) {
                    fileDataObject = Object.entries(this.fileData);
                    fileDataObject.splice(index, 1);
                    this.fileData = [];
                    this.fileValues = [];

                    fileDataObject.forEach(([key, file]) => {
                        this.fileData.push({
                            'fileName': file.fileName,
                            'documentId': file.documentId
                        });
                        this.fileValues[this.fileValues.length] = file.documentId;
                    });
                    loopFlag = 1;
                }
            });
        } catch (e) {
            console.log(e);
        }
    }

    @api
    openModalBox() {

        //open pop up box
        let modalBox = this.template.querySelector('.modal');
        modalBox.style.display = 'block';

        //Show overlay
        let overlay = this.template.querySelector('.overlay');
        overlay.style.display = 'block';

        this.resetFileControl();

    }

    closeModalBox() {

        let modalBox = this.template.querySelector('.modal');
        modalBox.style.display = 'none';

        //hide overlay
        let overlay = this.template.querySelector('.overlay');
        overlay.style.display = 'none';

        //Remove attached file
        let fileValuesObject = Object.entries(this.fileValues);
        fileValuesObject.forEach(([key, fileDocumentId]) => {
            removeHotlineFile({
                'documentId': fileDocumentId,
            });
        });

        this.resetFileControl();
    }
}