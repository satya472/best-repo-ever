import { LightningElement } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import Auth0_v2 from '@salesforce/resourceUrl/Auth0_v2';

export default class Cep_logoutIdp extends LightningElement {
	connectedCallback() {
		Promise.all([
			loadScript(this, Auth0_v2+'/auth0_v2.js')
		]).then(() => {
			console.log("Promise resolved");
			logout();
		})
		.catch(function(error) {
			console.log("Promise rejected");
			logout();
		});
		function logout() {
			let webAuthObj = new auth0.WebAuth({
		        domain:       'siemens-qa-ps-002.eu.auth0.com',
		        // domain:       'siemens-00008.eu.auth0.com',
		        clientID:     'AEgjcTOOs68OPjrZ2MyKhQ7Qk1G3fEbh'
		        // clientID:     'qpsR0utMmdMgssLw5VbM5SntADys22Y7'
	      	});
	        webAuthObj.logout();
    	}
	}
}