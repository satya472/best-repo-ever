import { LightningElement, track } from 'lwc';

export default class MainComponent extends LightningElement {

    @track item = "parent to child"
   

    handleClick(){
        this.item="Updated in Parent"
    }
    handleNotify(){
        console.log('@@: Invoked by event');
    }
    handleDiv(){
        console.log('@@: catched inside Div Parent');
    }
    handleDiv2(){
        console.log('@@: catched inside Div Parent2');
    }
}