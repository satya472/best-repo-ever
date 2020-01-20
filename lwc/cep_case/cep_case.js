import { LightningElement,track,wire} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

import userId from '@salesforce/user/Id'
import { getRecord } from 'lightning/uiRecordApi';
import getContracts from '@salesforce/apex/CEPCaseCont.getContracts';
import createCase from '@salesforce/apex/CEPCaseCont.insertCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import removeHotlineFile from '@salesforce/apex/HotlineEmailCont.removeHotlineFile';
import sendHotlineEmail from '@salesforce/apex/HotlineEmailCont.sendHotlineEmail';
import fetchHotlineFile from '@salesforce/apex/HotlineEmailCont.fetchHotlineFile';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import contractCSS from '@salesforce/resourceUrl/contractCSS';

export default class Cep_case extends LightningElement {

    @track contractValue = 'Select Contracts';
    @track iconName = "utility:down"
    @track contractSelectClass = 'select_contract_disable';
    @track contractsArr;
    invaliadCharArr = ['__u', '__b', '__p', '__P'];

    @track recordId = '5001l000001ysxSAAQ';
    @track acceptedFormats = 'image/*,.png,.jpg,.txt,.doc,.zip,.pdf,.docx';
    @track showSpinner;

    @track contracts;
    @track priorities;
    @track systems;
    @track products;

    @track plant;
    @track controlSystem;
    @track contract;
    @track priority;
    @track system;
    @track product;
    @track description;
    @track title;
    @track phoneNumber;

    @track fileValues = new Array();
    @track fileData = [];
    @track emailAttachments;
    @track counter = 0;
    @track documentId;
    @track totalFileSize = 0;
    @track fileValid;

    @track disablePickList = true;

    fullDataMap;
    systemMap;
    contractPriorityMap;

    systemJsonMap = {
        'SPPA__uT2000': 'SPPA-T2000',
        'SPPA__uT3000': 'SPPA-T3000',
        'SPPA__uD3000': 'SPPA-D3000',
        'SPPA__uM3000': 'SPPA-M3000',
        'SPPA__uP3000': 'SPPA-P3000',
        'SPPA__uR3000': 'SPPA-R3000',
        'SPPA__uSx000': 'Sx000',
        'Malware__bProtection': 'Malware__bProtection'
    };

    priorityMap = {
        'DE__bService__bContract': {
            '2h': '2h',
            'next__bbd': 'next__bbd'
        },
        'DE__bService__bContract__b__Pbusiness__bhours__bonly__p': {
            'next__bbd': 'next__bbd'
        },
        'DE__bLMC__bSupport__b__P2__bcalendar__bdays__p': {
            '48h': '48h'
        },
        'DE__bService__bContract__b__P8h__bbho__p': {
            'next__bbd': 'next__bbd'
        },
        'DE__bProject__bSupport': {
            'low': 'low'
        },
        'DE__bEnd__bCustomer__bw__fo__bService__bContract': {
            'no__bcontract': 'no__bcontract'
        },
        'US': {
            'low': 'low'
        },
        'DE__bService__bContract__b__Pnext__bbd__p': {
            'next__bbd': 'next__bbd'
        }
    };

    productsJsonVal = {

        "SPPA__uT2000": {
            "AS620__uS5": "AS620__uS5",
            "AS620__uS7": "AS620__uS7",
            "CM": "CM",
            "DS670": "DS670",
            "ES680": "ES680",
            "ES685": "ES685",
            "ES686": "ES686",
            "Field__bPG": "Field__bPG",
            "LAN": "LAN",
            "LATS__b__f__bAuxiliary": "LATS__b__f__bAuxiliary",
            "OM650": "OM650",
            "OM650__uME": "OM650__uME",
            "OM690": "OM690",
            "OPC": "OPC",
            "Other": "Other",
            "PG740": "PG740",
            "tec4fde": "tec4fde",
            "tec4function": "tec4function",
            "tec4site": "tec4site",
            "tec4VT": "tec4VT",
            "Web4TXP": "Web4TXP",
            "WinTS": "WinTS",
            "UIS__bReport": "UIS__bReport"
        },
        "SPPA__uT3000": {
            "Application__bServer": "Application__bServer",
            "Application__bNode": "Application__bNode",
            "Automation": "Automation",
            "Communication": "Communication",
            "Field__band__bI__fO": "Field__band__bI__fO",
            "Migration": "Migration",
            "Thin__bClient": "Thin__bClient",
            "UIS__bReport": "UIS__bReport",
            "COMOS": "COMOS",
            "ART__uE": "ART__uE"
        },
        "SPPA__uD3000": {
            "none": "none"
        },
        "E3000": {
            "Product__bLevel__b2": [
                "Generator__bprotection__s__bGeneratorschutz",
                "Static__bexcitation__bequipment__b__PSEE__p__M__bErregereinrichtung",
                "Static__bfrequency__bconverter__b__PSFC__p__M__bAnfahrumrichter"
            ]
        },
        "SPPA__uM3000": {
            "Plant__bManagement": "Plant__bManagement",
            "Power__bPortal": "Power__bPortal",
            "Cockpit": "Cockpit",
            "Unknown": "Unknown"
        },
        "SPPA__uP3000": {
            "none": "none"
        },
        "SPPA__uR3000": {
            "none": "none"
        },
        "SPPA__uSx000": {
            "Communication": "Communication",
            "Emulation__bPlatform": "Emulation__bPlatform",
            "Process__bModel__b__f__bInstructor__bStation": "Process__bModel__b__f__bInstructor__bStation",
            "T2000__bPlatform": "T2000__bPlatform",
            "T3000__bPlatform": "T3000__bPlatform"
        },
        "cRSP": {
            "Product__bLevel__b2": [
                "Other",
                "Portal",
                "Sites",
                "Systems",
                "User__as__baccounts"
            ]
        },
        "DLS": {
            "none": "none"
        },
        "Malware__bProtection": {
            "AV__bPattern__bUpdate__b__u__bAutomatic": "AV__bPattern__bUpdate__b__u__bAutomatic",
            "AV__bPattern__bUpdate__b__u__bManual": "AV__bPattern__bUpdate__b__u__bManual",
            "TM__bOffice__bScan__bServer": "TM__bOffice__bScan__bServer",
            "TM__bOffice__bScan__bClient": "TM__bOffice__bScan__bClient"
        },
        "TME": {
            "AS220": "AS220",
            "GET": "GET",
            "MADAM": "MADAM",
            "OS": "OS"
        }
    };

    get getKey() {
        return this.counter++;
    }

    @wire(
        getRecord, {
            recordId: userId,
            fields: [
                'User.FirstName',
                'User.LastName',
                'User.Email',
                'User.ContactId',
                'User.Contact.Phone'
            ]
        }
    ) contactDetails

    get plants() {
        return [{
            label: 'Test1',
            value: '25'
        },
        {
            label: 'Test2',
            value: '35'
        },
        {
            label: 'Test3',
            value: '45'
        }
        ];
    }

    get controlSystems() {
        return [{
            label: 'Test1',
            value: 'Test1'
        },
        {
            label: 'Test2',
            value: 'Test2'
        },
        {
            label: 'Test3',
            value: 'Test3'
        }
        ];
    }

    handleFileChange(event) {
        this.emailAttachments = event.detail.files;
        Object.entries(this.emailAttachments).forEach(([key, file]) => {
            this.validateAndHandleFile(file.documentId)
        });
    }

    validateAndHandleFile(documentId) {
        fetchHotlineFile({
            'documentId': documentId
        }).then(response => {
            let result = JSON.parse(response);
            let fileSize = (result.ContentSize / 1024).toFixed(2);
            let fileName = result.Title + '.' + result.FileExtension;
            let fileValid = false;
            let message = 'File size can not be greater than 17MB.';
            fileSize = parseInt(fileSize, 10);

            if((fileSize/1024) <= 17) {
                this.totalFileSize += fileSize;
                if((this.totalFileSize / 1024) > 17) {
                    message = 'Total file size can not be greater than 17MB.';
                    removeHotlineFile({
                        'documentId': documentId,
                    });
                    this.totalFileSize -= fileSize;
                    fileValid = false;
                } else {
                    this.fileValues[this.fileValues.length] = documentId;

                    this.fileData.push({
                        'fileName': fileName,
                        'documentId': documentId,
                        'fileSize': fileSize
                    });
                    fileValid = true;

                }
            } else {
                removeHotlineFile({
                    'documentId': documentId,
                });
                fileValid = false;
            }

            if (! fileValid) {
                let title = 'File "' + fileName + '" is removed.'

                const evt = new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }

            
        }).then(() => {
            return this.fileValid;
        }).catch(error => {
            console.log("error");
            console.log(error);
        });
    }

    removeFile(event) {
        let documentId = event.currentTarget.dataset.value;
        let orginalFilesHolder = this.fileData;
        let fileDataObject;
        let loopFlag = 0;

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

        Object.entries(orginalFilesHolder).forEach(([index, fileValue]) => {
            if(loopFlag) {
                return;
            }
            if (fileValue.documentId === documentId) {
                fileDataObject = Object.entries(this.fileData);
                fileDataObject.splice(index, 1);
                this.fileData = [];
                this.fileValues = [];
                fileDataObject.forEach(([key, file]) => {
                    this.fileData.push({
                        'fileName': file.fileName,
                        'documentId': file.documentId,
                        'fileSize': file.fileSize

                    });
                    this.fileValues[this.fileValues.length] = file.documentId;
                });
                loopFlag = 1;
            }

        });
    }

    redirectToDashboard() {
        window.location.href = '/JEP/s/hotline';
    }

    handleClickCancel() {

        //Remove attached file
        let fileValuesObject = Object.entries(this.fileValues);
        fileValuesObject.forEach(([key, fileDocumentId]) => {
            removeHotlineFile({
                'documentId': fileDocumentId,
            });
        });
        
        this.fileValues = '';
        this.fileData = [];
        this.totalFileSize =
        this.redirectToDashboard();
    }

    handlePlantChange(event) {

        this.showSpinner = true;

        this.plant = event.currentTarget.value;


        this.systems = [];
        this.priorities = [];
        this.products = [];

        this.contract = '';
        this.system = '';
        this.priority = '';
        this.product = '';

        getContracts({ 'plantId': this.plant })
            .then(data => {

                this.fullDataMap = data;


                this.contracts = [];
                this.contract = '';
                this.contractsArr = [];

                Object.entries(data).forEach(([key, map2]) => {
                    let scope = this.removeInvalidChar(map2.scope__bof__bcontract);
                    let system = this.removeInvalidChar(map2.product__bline);
                    this.contracts.push({
                        'label': map2.entitlement,
                        'value': map2.mrid
                    });
                    //prepare data for new dropdown
                    this.contractsArr.push({
                        'type': map2.entitlement,
                        'mrid': map2.mrid,
                        'plant_part':map2.plant__bpart,
                        'scope':scope,
                        'system':system
                    });

                });
                this.contractSelectClass = 'select_contract';

                if (this.contracts.length === 0) {
                    this.disablePickList = true;
                } else {
                    this.disablePickList = false;
                }

                this.showSpinner = false;
            }).catch(error => {

                this.contracts = [];
                this.contract = '';
                this.disablePickList = true;

                this.error = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.error = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body === 'string') {
                    this.error = error;
                }

                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: this.error,
                    variant: 'error',
                });
                this.dispatchEvent(evt);

                this.showSpinner = false;

            })

    }

    handleContractChange(event) {

        this.showSpinner = true;

        this.systems = [];
        this.priorities = [];
        this.products = [];

        this.system = '';
        this.priority = '';
        this.product = '';

        this.contract = event.currentTarget.value;

        let systemVal = this.fullDataMap[this.contract].product__bline;

        let systemsLst = systemVal !== '' ? systemVal.split(';') : [];
        this.systems = [];
        this.system = '';

        systemsLst.forEach(ele => {
            if (ele !== '' && ele !== null) {
                let displayVal = this.systemJsonMap[ele];
                this.systems.push({
                    'label': displayVal,
                    'value': ele
                });

            }
        });

        //Priorities Mapping
        let priorityVal = this.fullDataMap[this.contract].contract__bpriority;
        let priority = priorityVal !== '' ? priorityVal.split(';') : [];
        this.priorities = [];
        this.priority = '';

        priority.forEach(ele => {
            if (ele !== '' && ele !== null) {
                let displayVal = this.priorityMap[ele];
                Object.entries(displayVal).forEach(([key, val]) => {
                    this.priorities.push({
                        'label': key,
                        'value': val
                    });
                })
            }
        });


        this.showSpinner = false;
    }

    handleSystemChange(event) {

        this.showSpinner = true;

        this.system = event.currentTarget.value;

        let productsLst = this.productsJsonVal[this.system];

        this.products = [];
        this.product = '';

        Object.entries(productsLst).forEach(([key, val]) => {
            this.products.push({
                'label': key,
                'value': val
            });
        })

        this.showSpinner = false;
    }

    //Handling change event for tracking the value changes
    handleChange(event) {
        let name = event.currentTarget.name
        if (name === 'priority') {
            this.priority = event.currentTarget.value;
        } else if (name === 'product') {
            this.product = event.currentTarget.value;
        } else if (name === 'title') {
            this.title = event.currentTarget.value;
        } else if (name === 'phoneNumber') {
            this.phoneNumber = event.currentTarget.value;
        } else if (name === 'description') {
            this.description = event.currentTarget.value;
        }

    }

    handleSave() {
      
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        };
        console.log('handleSave');
        console.log(this.fileValues);
        window.scrollTo(scrollOptions);

        this.showSpinner = true;

        let errorOccured = false;

        this.template.querySelectorAll('lightning-combobox').forEach(element => {

            if (!element.checkValidity()) {

                element.showHelpMessageIfInvalid();

                errorOccured = true;

            }

        });
        this.template.querySelectorAll('lightning-input').forEach(element => {

            if (!element.checkValidity()) {
                element.showHelpMessageIfInvalid();
                errorOccured = true;
            }

        });

        let textAreaEle = this.template.querySelector('lightning-textarea');

        if (!textAreaEle.checkValidity()) {

            textAreaEle.showHelpMessageIfInvalid();

            errorOccured = true;

        }

        console.log('====Contract====')
        console.log(this.contract);  
        console.log('====fullDataMap====')
        console.log(this.fullDataMap);

        let contract = this.fullDataMap[this.contract];

        console.log('====Let Contract====')
        console.log(contract);

        let dataJson = {
            'firstName': this.contactDetails.data.fields.FirstName.value,
            'lastName': this.contactDetails.data.fields.LastName.value,
            'email': this.contactDetails.data.fields.Email.value,
            'phone': this.phoneNumber,
            'account': contract.account,
            'contractUid': contract.mrid,
            'contractExpiryDate': contract.expiry__bdate,
            'plantPart': contract.plant__bpart,
            'remoteConnectionType': contract.remote__bconnection__btype,
            'contractServiceLevel': contract.contract__bservice__blevel,
            'gtmHq': contract.gtm__bhq,
            'ticketPriority': this.priority,
            'productLine': this.system,
            'startOfContract': contract.start__bof__bcontract,
            'onCallSupport': contract.oncall__bsupport__bavailable__q,
            'hotlineHrs': contract.hotline__bhours,
            'contractPriority': contract.contract__bpriority,
            'entitlement': contract.entitlement,
            'scopeOfContract': contract.scope__bof__bcontract,
            'productLevel1': this.product,
            'productLevel2': this.product,
            'powerPlantId': this.plant,
            'numberOfHighPriority': contract.number__bof__bhigh__bpriority,
            'accountCopy': contract.account,
            'location': contract.location,
            'defaultTicketExeBy': contract.default__bticket__bexecution__bby,
            'gtmRegion': contract.gtm__bregion,
            'onCallSupportTimeTable': contract.oncall__bsupport__btimetable,
            'onCallSupportAvailable': contract.oncall__bsupport__bavailable__q,
            'projectSiemensResponsible': contract.project__bresponsible__b__psiemens__p,
            'endOfWarranty': contract.end__bof__bwarranty,
            'description': this.description,
            'priorityNumber': 3,
            'status': 'Open',
            'title': this.title,
            'projectId': 2
        };

        console.log("==================");
        console.log(JSON.stringify(dataJson));

        // if (!errorOccured) {
        //     createCase({
        //         'data': JSON.stringify(dataJson)
        //     }).then(response => {

        //         let title, message, variant;

        //         if (response === '') {

        //             title = 'Error';
        //             message = 'There is an Error in Creating the Case';
        //             variant = 'error';

        //         } else {
        //             let mailBody = '<h2>Hotline Ticket Created</h2><br/><br/>';
        //             mailBody += '<h4>Hotline Ticket Id - ' + response + '</h4>';

        //             let mailSubject = 'Hotline ticket created';

        //             let mailText = {
        //                 'mailSubject': mailSubject,
        //                 'mailBody': mailBody,
        //             };

        //             sendHotlineEmail({
        //                 'mailText': JSON.stringify(mailText),
        //                 'fileValues': JSON.stringify(this.fileValues)
        //             });
        //             title = 'Success';
        //             message = 'Case ' + response + ' Created Successfully';
        //             variant = 'success';
        //         }

        //         const evt = new ShowToastEvent({
        //             title: title,
        //             message: message,
        //             variant: variant,
        //             mode: 'pester'
        //         });
        //         this.dispatchEvent(evt);

        //         this.showSpinner = false;
        //         this.redirectToDashboard();

        //     }).catch(error => {

        //         this.error = 'Unknown error';
        //         if (Array.isArray(error.body)) {
        //             this.error = error.body.map(e => e.message).join(', ');
        //         } else if (typeof error.body.message === 'string') {
        //             this.error = error.body.message;
        //         }

        //         const evt = new ShowToastEvent({
        //             title: 'Error',
        //             message: this.error,
        //             variant: 'error',
        //             mode: 'pester'
        //         });
        //         this.dispatchEvent(evt);

        //         this.showSpinner = false;

        //     });

        // } else {
        //     this.showSpinner = false;
        // }
    }


    connectedCallback() {
        Promise.all([
            loadStyle(this, bootstrap+'/css/bootstrap.min.css'),
            loadStyle(this, contractCSS),
            loadScript(this, bootstrap+'/js/jquery.js'),
            loadScript(this, bootstrap+'/js/bootstrap.min.js')
        ])
        .then(() => {
            console.log('file loaded.......')
        })
        .catch(error => {
            console.error({
                message: 'Error on loading bootstrap',
                error
            });
        })
    }

    displayContractList(event){
        let cls = event.currentTarget.className;
        if(cls != 'select_contract_disable'){
            let style = this.template.querySelector('div.contract_list').style.display;
            if (style == "none" || style == "") {
                this.template.querySelector('div.contract_list').style.display = 'block';
                this.iconName = "utility:up";
            } else {
                this.template.querySelector('div.contract_list').style.display = 'none';
                this.iconName = "utility:down";
            }
        }
    }


    displaySelectedOption(event){
        event.preventDefault();
        let ele  = event.currentTarget;
        this.template.querySelector('div.contracts_info').innerHTML = ele.innerHTML;
        this.template.querySelector('div.contract_list').style.display = 'none';
        this.iconName = "utility:down";
        this.contract = ele.getAttribute("data-id")
    }


    removeInvalidChar(value){
        if(value){
            let len = this.invaliadCharArr.length;
            for(var i=0; i<len; i++){
                value = value.replace(new RegExp(this.invaliadCharArr[i], 'g'), ' ');
            }
        } else { 
            value = 'N/A';
        }
        return value
    }

}