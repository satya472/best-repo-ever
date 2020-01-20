import { LightningElement,track,api } from 'lwc';
import {loadStyle,loadScript} from 'lightning/platformResourceLoader';
import BOOTSTRAP from '@salesforce/resourceUrl/bootstrap';
import getCaseDetail from '@salesforce/apex/CEPCaseCont.getCaseDetail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Cep_caseDetail extends LightningElement {
  @track _recordId;
  @track counter = 0; 
  @track caseDetailArr;
  @track error;
  @track loaded = false;
  @track ticketNo = 0;
  @track _showDetail;
  
  @api
  get recordId() {
    return this._recordId;
  }
  
  set recordId(value) {
     this._recordId = value;
     this.loaded = false;
     this.getCaseDetailData();
  }

  @api
  get showDetail() {
    return this._recordId;
  }
  
  set showDetail(value) {
      this._showDetail = value;
      if (value === true) {
        this.openModalBox();
        this._showDetail = false;
      }

  }
  
  get getKey(){
    return this.counter++;
  }
    
  getCaseDetailData() {

    if (this._recordId == 0) {
     return;
    }
    let dataJson = {
      'plantId': '25',
      'mrId': this._recordId
    };
    this.caseDetailArr = [];
    getCaseDetail({
        'data': JSON.stringify(dataJson)
      }).then(data => {
        Object.entries(data).forEach(([key, map2]) => {
          //console.log(map2);
          this.ticketNo = map2.e__uid;
          this.caseDetailArr.push({
            'euid': map2.e__uid,
            'submittedbat': map2.submitted__bat,
            'mrtitle': map2.mrtitle,
            'mrstatus': map2.mrstatus,
            'system': map2.product__blevel__b1,
            'product': map2.product__blevel__b2,
            'source': map2.source,
            'workStart': map2.work__bstarted,
            'description': map2.description,
            'plant_part': map2.plant_part,
            'contract': map2.contract,
            'mralldescriptions': map2.mralldescriptions
          });
        });
      })
      .then(() => {
        //console.log('then');
        //console.log(this.loaded);
        this.loaded = !this.loaded;
      })
      .catch(error => {
        this.error = error;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error loading data',
            message: this.error,
            variant: 'error'
          })
        );
      });
  }

  @api
  openModalBox() {
    //open pop up box
    let modalBox = this.template.querySelector('.modal');
    modalBox.style.display = 'block';
    //Show overlay
    let overlay = this.template.querySelector('.overlay');
    overlay.style.display = 'block';

  }

  closeModalBox() {
    //console.log('child');
    let modalBox = this.template.querySelector('.modal');
    modalBox.style.display = 'none';
    //hide overlay
    let overlay = this.template.querySelector('.overlay');
    overlay.style.display = 'none';
  }
}