public class CEP_JEPAuthorisationRequestCont {
    @AuraEnabled 
    public static void sendMailMethod(String emailId ,String fName, String lName, String accName, String plantRequest, String equipRequest){
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();     
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{'sahil.jain.ext@siemens.com','nisha.pinjarkar.ext@siemens.com'});
        mail.setReplyTo('sahil.jain.ext@siemens.com');
        mail.setSenderDisplayName(fName+' '+lName);
        mail.setSubject('Request to access JEP Portal');
        mail.setPlainTextBody(designMailBody(emailId, fName, lName, accName, plantRequest, equipRequest));
        mails.add(mail);
        try{
            if(!Test.isRunningTest()){
                Messaging.sendEmail(mails);
            }
        }catch(Exception ex){
            System.debug('Error: Request to access JEP failed: '+ex.getMessage());
        }
    }
    
    private static String designMailBody(String emailId, String fName,String lName,String accName,String plantRequest,String equipRequest){
        String body='Dear Admin,\n\n';
        body+='A customer with following details have requested for access to Joint Energy Portal:';
        body+='\nFirst Name: '+fName;
        body+='\nLast Name: '+lName;
        body+='\nEmail Id: '+emailID;
        body+='\nAccount Requested: '+accName;
        body+='\nPlant Name: '+plantRequest;
        body+='\nEquipment Name: '+equipRequest;
        body+='\n\n\nThanks,';
        body+='\nSiemens JEP';
        return body;
    }
}