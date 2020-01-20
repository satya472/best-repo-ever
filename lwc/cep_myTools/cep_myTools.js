import { LightningElement } from 'lwc';
import toolImages from '@salesforce/resourceUrl/CEP_ToolsIcon';
import {registerListener, unregisterAllListeners, fireEvent} from 'c/pubsub';
export default class Cep_myTools extends LightningElement {
    myAdvisor = toolImages + '/my-advisor.png';

    connectedCallback() {
        // subscribe to searchKeyChange event
        registerListener('PlantAsset', this.handleSearchKeyChange, this);
    }

    disconnectedCallback() {
        // unsubscribe from searchKeyChange event
        unregisterAllListeners(this);
    }

    handleSearchKeyChange(searchKey) {
        console.log('@@: '+searchKey.plant + ' '+searchKey.equipment);
    }
}