import { LightningElement,track } from 'lwc';

import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import bootstrap from '@salesforce/resourceUrl/bootstrap';
import Auth0_v2 from '@salesforce/resourceUrl/Auth0_v2';


/**
* environment specific variables (refactor this code)
* LOGIN_URL
* AUTH0_CLIENT_ID
* AUTH0_DOMAIN
* AUTH0_CALLBACK_URL
*/
export default class Cep_loginBody extends LightningElement {

	@track LOGIN_URL;
	@track showLogin = false;
    @track showSpinner = true;
    
	LOGIN_URL = 'https://dcube11-siemensconcierge.cs108.force.com/JEP/services/auth/sso/Siemens_ID_Staging';
    // LOGIN_URL = 'https://siemensconcierge.force.com/CEP/services/auth/sso/Siemens_ID_Prod';

    connectedCallback() {
        
        var that = this;
    	console.log("connectedCallback....");
   		Promise.all([
      		loadScript(this, bootstrap+'/js/jquery.js'),
      		loadScript(this, Auth0_v2+'/auth0_v2.js'),
            loadScript(this, bootstrap+'/js/bootstrap.min.js'),
      		loadStyle(this, bootstrap+'/css/bootstrap.min.css')
    	]).then(() => {
    		that.performAutoLogin(that);
            console.log("from then...");
    	}).catch(function(error) {
            setTimeout(() => that.performAutoLogin(that) , 1000);
            console.log("from catch...");
		});

   } //connectedCallback ends




    performAutoLogin = function(that) {
        const AUTH0_CLIENT_ID = 'AEgjcTOOs68OPjrZ2MyKhQ7Qk1G3fEbh';
        // const AUTH0_CLIENT_ID = 'qpsR0utMmdMgssLw5VbM5SntADys22Y7';
        const AUTH0_DOMAIN = 'siemens-qa-ps-002.eu.auth0.com';
        // const AUTH0_DOMAIN = 'siemens-00008.eu.auth0.com';
        const SCOPE = 'openid profile email';
        var AUTH0_CALLBACK_URL = 'https://dcube11-siemensconcierge.cs108.force.com/JEP/services/auth/sso/Siemens_ID_Staging_auto_login';
        // var AUTH0_CALLBACK_URL = 'https://siemensconcierge.force.com/CEP/services/auth/sso/Siemens_ID_Prod_auto_login';
        const AUTH0_CONNECTION = 'Username-Password-Authentication';

        if (window.location.search !== "") {
            AUTH0_CALLBACK_URL += window.location.search; 
        }

        const auth0WebAuth = new auth0.WebAuth({
            domain: AUTH0_DOMAIN,
            clientID: AUTH0_CLIENT_ID,
            redirectUri: AUTH0_CALLBACK_URL,
            responseType: 'id_token token',
            scope: SCOPE
        });
        auth0WebAuth.checkSession({
            responseType: 'token id_token',
            timeout: 5000,
            usePostMessage: true
        }, function (err, result) { 
            if (err) {
                console.log("SiemensID Session does not Exists");
                console.log(err);
                that.showLogin = true;
                that.showSpinner = false;
            } else {
                console.log("SiemensID Session Exists");
                console.log(result);
                window.location = AUTH0_CALLBACK_URL;
            }
        });
    }

}