import { LightningElement, track } from 'lwc';
import {registerListener, unregisterAllListeners} from 'c/pubsub';

export default class Cep_pubsubSample extends LightningElement {

    @track plant;
    @track equipment;
    connectedCallback() {
        // subscribe to searchKeyChange event
        registerListener('PlantAsset', this.handleSearchKeyChange, this);
    }

    disconnectedCallback() {
        // unsubscribe from searchKeyChange event
        unregisterAllListeners(this);
    }

    handleSearchKeyChange(searchKey) {

        this.plant = searchKey.plant;
        this.equipment = searchKey.equipment;
    }
}