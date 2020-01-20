/*
 Created By: Phaniram upalapati
 Description: Class is mainly used to write methods which helps in fetching list of records based on the Id provided
              as input.
*/
public with sharing class DisplayListOfRecords {

    @AuraEnabled(cacheable=true)
    public static List<SObject> getListOfCommentRecords(String recordId) {

     return [Select Id,CommentBody,parentId,CreatedDate,CreatedBy.Name from CaseComment Where ParentId =:recordId ];

    }

    @AuraEnabled
    public static void createCaseComment(String body,String parentId){

        CaseComment cc = new CaseComment();
        cc.CommentBody = body;
        cc.ParentId = parentId;

        try{
            insert cc;
        }catch(Exception e){
          
        }
      
    }
}