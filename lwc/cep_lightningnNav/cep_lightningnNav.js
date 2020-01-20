import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getNavigationItems from '@salesforce/apex/CEPLightningNavCont.getNavigationItems';

export default class Cep_lightningnNav extends LightningElement {

	connectedCallback(){

		getNavigationItems()
	}

}