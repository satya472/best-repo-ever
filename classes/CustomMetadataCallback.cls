/*
* Author: Yash Raikwar
* Date: 11-Mar-2019
* Description: Apex class to return custom metadata type deployment results
*/
public class CustomMetadataCallback implements Metadata.DeployCallback {
    // Method to track deploy results
    public void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('Deployment success: '+ result);
        } else {
            System.debug('Deployment fail: '+ result);
        }
    }
}