public with sharing class FolderAPIRequest extends APIRequest {
    // listParameters allowed keys
    public static String NAMES = 'names';
    public static String PATHS = 'paths';
    public static String IDS = 'ids';

    // parameters allowed keys
    public static String ID = 'id';
    public static String PATH = 'path';
    public static String KIND = 'kind';
//    public static String COUNT_RECORDS = 'countRecords';



    // List of Actions
    public static String CREATE = 'create';
    public static String REMOVE = 'remove';
    public static String MOVE = 'move';
    public static String RENAME = 'rename';

    public FolderAPIRequest(){
        super();
    }
}