import { LightningElement, api, track} from 'lwc';

export default class TestComponent extends LightningElement {

    @track privateTitle;
    @api testVar;
 
 @api 
 get itemName(){
     return 'Testing 123';
 }

 set itemName(val){
     this.privateTitle = val.toUpperCase();
    // this.setAttribute('phani', this.privateTitle);
 }

 handleSample(){
    this.itemName = 'TestAfterclick';
    this.dispatchEvent(
        // Default values for bubbles and composed are false.
        new CustomEvent('notify')
    );

  /* this.dispatchEvent(
        new CustomEvent('notify',{bubbles: true,composed: true})
    );*/

 }

 handlediv(){
     console.log('@@: inside child comp');
 }
}