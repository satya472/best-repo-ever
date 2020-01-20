({
	scriptsLoaded : function(component, event, helper) {
			const AUTH0_CLIENT_ID = 'AEgjcTOOs68OPjrZ2MyKhQ7Qk1G3fEbh';
            const AUTH0_DOMAIN = 'siemens-qa-ps-002.eu.auth0.com';
            const SCOPE = 'openid profile email';
            const AUTH0_CALLBACK_URL = 'https://dcube11-siemensconcierge.cs108.force.com/JEP/services/auth/sso/Siemens_ID_Staging_auto_login';
            const AUTH0_CONNECTION = 'Username-Password-Authentication';
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
                    //window.location = 'https://dcube11-siemensconcierge.cs108.force.com/JEP/s/login';
                } else {
                    console.log("SiemensID Session Exists");
                    console.log(result);
                    window.location = AUTH0_CALLBACK_URL;
                }
            });
	}
})