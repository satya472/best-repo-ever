import { LightningElement } from 'lwc';
import logoURL from '@salesforce/resourceUrl/SiemensLogo_new';

export default class Cep_loginHeader extends LightningElement {
	logoURL = logoURL;
	requestSupportURL = 'https://siemens.force.com/cep/CEP_ProblemsLoggingIn';
    requestAccessURL = 'https://siemens.force.com/cep/CEP_NewtonRegisterRequestAccess';
}