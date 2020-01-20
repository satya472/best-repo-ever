import { LightningElement,track } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getAuthProviders from '@salesforce/apex/CEP_FetchAuthProviderDetails.getAuthProviders';
import bootstrap from '@salesforce/resourceUrl/bootstrap';

export default class TestServerInteraction extends LightningElement {

	@track authorizeUrl;
	@track clientId;
	@track domain;
	@track developerName;
	@track redirectUri;

	connectedCallback() {
		getAuthProviders()
		.then(data => {
			console.log("Promise resolved");
			console.log(data);
			this.developerName = data.developer_name;
			this.clientId = data.client_id;
			this.authorizeUrl = data.authorize_url;
			this.domain = data.authorize_url.split("/")[2];
			this.redirectUri = document.location.origin+'/JEP/services/auth/sso/'+this.developerName+'_auto_login';
			console.log(document.location.origin+'/JEP/services/auth/sso/'+this.developerName+'_auto_login');
		})
		.catch(error => {
			console.log("Promise rejected");
			console.log(error);
		});


		console.log("from connectedCallback...");
		Promise.all([
      		loadScript(this, bootstrap+'/js/jquery.js'),
            loadScript(this, bootstrap+'/js/bootstrap.min.js'),
      		loadStyle(this, bootstrap+'/css/bootstrap.min.css')
    	]).then(() => {
            console.log("from then...");
    	}).catch(function(error) {
            console.log("from catch...");
		});
	}

}