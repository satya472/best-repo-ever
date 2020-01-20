import { LightningElement, track, api } from 'lwc';
import {loadStyle, loadScript} from 'lightning/platformResourceLoader';
import BOOTSTRAP from '@salesforce/resourceUrl/bootstrap';
import FONTS from '@salesforce/resourceUrl/fontawesome';
import getCases from '@salesforce/apex/CEPCaseCont.getCases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
  	  { label: 'Case #', fieldName: 'euid' },
      { label: 'Plant Part', fieldName: 'plant_part'},
      { label: 'Title', fieldName: 'mrtitle' },
      { label: 'System', fieldName: 'submittedbat'},
      { label: 'Product', fieldName: 'submittedbat'},
      { label: 'Contracts', fieldName: 'contract'},
  	  { label: 'Opened Date', fieldName: 'submittedbat'},
   	  { label: 'Status', fieldName: 'mrstatus'},
      { label: 'Action', fieldName: 'mrstatus'}
];

export default class Cep_caseList extends LightningElement {

	  @track columns = columns;
    @track caseListArr;
    @track error;
    @track recordId = 0;
    @track loaded = false;
    @track status;

    connectedCallback() {

        loadStyle(this,BOOTSTRAP+'/css/bootstrap.min.css');
        loadStyle(this,FONTS+'/css/all.min.css')
        .then(()=>{
            getCases().then(data=>{
              this.caseListArr  = [];
              Object.entries(data).forEach(([key,map2]) =>{
                  this.caseListArr.push({
                      'euid': map2.e__uid,
                      'submittedbat': map2.submitted__bat,
                      'mrtitle': map2.mrtitle,
                      'mrstatus': map2.mrstatus,
                      'system': map2.product__blevel__b1,
                      'product': map2.product__blevel__b2,
                      'mrid': map2.mrid,
                      'contract': map2.contract,
                      'plant_part': map2.plant_part,
                      'displayEditButton': map2.mrstatus === 'Closed' ? false : true
                  });
              });
           })
           .then(()=>{
            this.loaded = !this.loaded;
           })
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading DataTables',
                    message: this.error,
                    variant: 'error'
                })
            );
        });  
    }


    getCaseDetail(event) {
      event.preventDefault();
      let recordId = event.currentTarget.dataset.id;
      this.recordId = recordId; 
      this.template.querySelector('c-cep_case-detail').openModalBox(); 
    }

    editCaseDetail(event) {
        event.preventDefault();
        let recordId = event.currentTarget.dataset.id;
        this.recordId = recordId; 
        this.template.querySelector('c-cep_case-update').openModalBox(); 
    }

    closeModalBox(){
      this.template.querySelector('c-cep_case-detail').closeModalBox();
      this.template.querySelector('c-cep_case-update').closeModalBox();
    }
    
}