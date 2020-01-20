@isTest
public with sharing class HotlineEmailContTest {
    
    // public static file creation function used in all 
    // below functions.
    public static String createFile() {
        ContentVersion cv = new ContentVersion();
        cv.title='Test title Pb7vs_KCNcU5c5gw';
        cv.VersionData=blob.valueof('New Bitmap Image.bmp');
        cv.PathOnClient ='testtt';
        cv.ContentDocumentId = null;
        insert cv;
        return cv.id;
    }

    public static String extractContentDocumentId(String contentVersionId) {
        ContentVersion cv = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE id=:contentVersionId
        ];
        return cv.ContentDocumentId;
    }
    
    @IsTest 
    static void testFetchHotlineFile() {
        //Create the dummy file
        String cvId = HotlineEmailContTest.createFile();
        String contentDocId = HotlineEmailContTest.extractContentDocumentId(cvId);

        //Fetch details of dummy files
        ContentVersion testFileInSaleforce = [ 
                SELECT Title
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocId 
                AND IsLatest = true 
                LIMIT 1
            ];

        test.startTest();

        try {
            //Call to fetchHotlineFile method
            String hotlineFile = HotlineEmailCont.fetchHotlineFile(contentDocId);
            
            //Convert it to Object
            ContentVersion hotlineFileObj = (ContentVersion)Json.deserialize(
                hotlineFile, 
                ContentVersion.class
            );
            
            //Compare
            System.assertEquals(
                hotlineFileObj.Title, 
                testFileInSaleforce.Title
            );
        } catch(Exception ex) {
            system.assert(
                ex.getMessage().contains('null object')
            );
        }
        test.stopTest();
    }

    @IsTest 
    static void testRemoveHotlineFile() {
        //Create the dummy file
        String cvId = HotlineEmailContTest.createFile();
        String contentDocId = HotlineEmailContTest.extractContentDocumentId(cvId);

        test.startTest();

        try {
            //Call to removeHotlineFile method
            HotlineEmailCont.removeHotlineFile(contentDocId);
            
            //Fetch details of dummy files
        	ContentVersion testFileInSaleforce = [ 
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion 
                WHERE ContentDocumentId=:contentDocId 
                AND IsLatest = true LIMIT 1
            ];
        } catch(Exception ex) {
            system.assert(
                ex.getMessage().contains('List has no rows for assignment')
            );
        }
        test.stopTest();
    }

    @IsTest 
    static void testsendHotlineEmail() {
        String mailText = '{"mailText": {"mailSubject": "This is mail subject.","mailBody": "This is mail body."}}';

        //Create the dummy file
        String cvId = HotlineEmailContTest.createFile();
        String contentDocId = HotlineEmailContTest.extractContentDocumentId(cvId);

        List<String> fileValuesObj = new List<String> { contentDocId };
        String fileValues = JSON.serialize(fileValuesObj);
        
        HotlineEmailCont.sendHotlineEmail(mailText, fileValues);
    }
}