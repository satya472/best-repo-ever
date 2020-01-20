/*
 * Created By: Phaniram Upalapati
 * Description: This is a controller Class for fetching details from FootPrint Environment.
 */
public with sharing class CEPFootPrintSoapCont {

   
    /*
     * Name: fetchingContracts
     * Input Params: String - Id of the Selected Plant from UI
     * Output Param: List<String> - List of Contracts
     * Description: The method send http request with XML string as Body and returns a List of Contracts.
     */
    public static Map<string, Map<String,String>> fetchingContracts(string plantId) {

        Http http = new Http();
        String qry =  '<param3 xsi:type="xsd:string">'+
                      'SELECT * FROM EFIE_CONTRACTS WHERE Power__bPlant__bID=\''+plantId+'\''+
                      '</param3>';
        HttpRequest req = prepareRequest('<SOAP-ENV:Body><ns1:MRWebServices__search>','</ns1:MRWebServices__search></SOAP-ENV:Body>',qry);
        HttpResponse res = http.send(req);
         if(res.getStatusCode() == 500){
            return new Map<string, Map<String,String>>();
        }
        Map<string, Map<String,String>> contractMap = new Map<string, Map<String,String>> ();
        try {
        	contractMap = parseXML(res.getBodyDocument().getRootElement(),new Map<string, Map<String,String>>());
        } catch(Exception ex){
            AuraHandledException e = new AuraHandledException(ex.getMessage());
            e.setMessage(ex.getMessage());
    		throw e;
        }
        return contractMap;
    }

    /*
     * Name: createCase
     * Input Params: String - Id of the Selected Plant from UI
     * Output Param: String - Created Case Number
     * Description: The method send http request with XML string as Body for Creating an Issue
                    and returns the case Number if Successfully Created otherwise a empty String
                    will be returned which is hanled on Client side.
     */
    public static String createCase(string dataInput) {

        CaseDetails cd = (CaseDetails)JSON.deserialize(dataInput, CaseDetails.class);

        Http http = new Http();
		
        String SOAPBODY =  '<param3 xsi:type="ns2:Map">';
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">projectID</key>';
            SOAPBODY += '<value xsi:type="xsd:string">2</value>';
        SOAPBODY += '</item>';
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">title</key>';
            SOAPBODY += '<value xsi:type="xsd:string">'+cd.title+'</value>';
        SOAPBODY += '</item>';
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">status</key>';
            SOAPBODY += '<value xsi:type="xsd:string">'+cd.status+'</value>';
        SOAPBODY += '</item>';
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">priorityNumber</key>';
            SOAPBODY += '<value xsi:type="xsd:string">'+cd.priorityNumber+'</value>';
        SOAPBODY += '</item>';
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">description</key>';
            SOAPBODY += '<value xsi:type="xsd:string">'+cd.description+'</value>';
        SOAPBODY += '</item>';
        
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">projfields</key>';
            SOAPBODY += '<value xsi:type="ns2:Map">';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Account</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.Account+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Contract__uID</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.contractUid+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Contract__bExpiry__bDate</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.contractExpiryDate+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Plant__bPart</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.plantPart+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Entitlement__bNote</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">Additional Comments</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">cRSP__bSite__bName</key>';
                    SOAPBODY += '<value xsi:type="xsd:string"></value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Remote__bConnection__bType</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.remoteConnectionType+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Show__bin__bCP__Q</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">Yes</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Contract__bService__bLevel</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.contractServiceLevel+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">GTM__bHQ</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.gtmHq+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Ticket__bPriority</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.ticketPriority+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">System</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.productLine+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Start__bOf__bContract</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.startOfContract+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">AWV__bCode</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">N / N</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">OnCall__bSupport__bAvailable__Q</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.onCallSupportAvailable+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Hotline__bHours</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.hotlineHrs+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Contract__bPriority</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.contractPriority+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Purchaser</key>';
                    SOAPBODY += '<value xsi:type="xsd:string"></value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Entitlement</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.entitlement+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Scope__bOf__bContract</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.scopeOfContract+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Product__bLevel__b1</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">T3000</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Power__bPlant__bID</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.powerPlantId+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Number__bOf__bHigh__bPriority</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.numberOfHighPriority+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">AccountCopy</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.accountCopy+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Location</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.location+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Product__bLevel__b2</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.productLevel2+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Source</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">Customer__bPortal</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Type</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.defaultTicketExeBy+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Submitted__bAt</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+System.now()+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">What__Q</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.description+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">GTM__bRegion</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.gtmRegion+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">OnCall__bSupport__bTimetable</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.onCallSupportTimeTable+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Project__bResponsible__b__PSiemens__p</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.projectSiemensResponsible+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">End__bOf__bWarranty</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.endOfWarranty+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Attachment__bList</key>';
                    SOAPBODY += '<value xsi:type="xsd:string"></value>';
                SOAPBODY += '</item>';
            SOAPBODY += '</value>';
        SOAPBODY += '</item>';
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">abfields</key>';
            SOAPBODY += '<value xsi:type="ns2:Map">';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">First__bName</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.firstName+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Last__bName</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">'+cd.lastName+'</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">E__uMail__bAddress</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">phaniram.upalapati.ext@siemens.com</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Phone__bNumber</key>';
                    SOAPBODY += '<value xsi:type="xsd:string">7680074871</value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Middle__bInitial</key>';
                    SOAPBODY += '<value xsi:type="xsd:string"></value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">Gender</key>';
                    SOAPBODY += '<value xsi:type="xsd:string"></value>';
                SOAPBODY += '</item>';
                SOAPBODY += '<item>';
                    SOAPBODY += '<key xsi:type="xsd:string">User__bID</key>';
                    SOAPBODY += '<value xsi:type="xsd:string"></value>';
                SOAPBODY += '</item>';
            SOAPBODY += '</value>';
        SOAPBODY += '</item>';
    SOAPBODY += '</param3>';
        
        HttpRequest req = prepareRequest('<SOAP-ENV:Body><ns1:MRWebServices__createIssue>','</ns1:MRWebServices__createIssue></SOAP-ENV:Body>',SOAPBODY);
        
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 500){
            return '';
        }

        String caseNumber = parseXMLForCreateIssue(res.getBodyDocument().getRootElement(),'');

        return caseNumber;

    }


    /*
     * The method Helps in Preparing the request i.e.XML String
     */
    public static HttpRequest prepareRequest(String bodyStart, String bodyEnd,String dataToMerge){

        HttpRequest req = new HttpRequest();
        
        String SOAPBODY = bodyStart;
        SOAPBODY += '<param0 xsi:type="xsd:string">CustomerPortal</param0>';
        SOAPBODY += '<param1 xsi:type="xsd:string">SWdp74*y</param1>';
        SOAPBODY += '<param2 xsi:type="xsd:string"></param2>';
        SOAPBODY += dataToMerge;
        SOAPBODY += bodyEnd;
        //Prepare final String
        String SOAPVAR = '<?xml version="1.0" encoding="UTF-8"?>';
        SOAPVAR += '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="MRWebServices" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns2="http://xml.apache.org/xml-soap" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
        SOAPVAR += SOAPBODY;
        SOAPVAR += '</SOAP-ENV:Envelope>';
        
        req.setEndpoint('https://www.csm.energy.siemens.com/MRcgi/MRWebServices.pl');
        req.setMethod('POST');
        req.setBody(SOAPVAR);
        req.setHeader('Content-Type', 'text/xml');
        return req;
    }

    /*
     * This method is for parsing the XML returned from FootPrint and Fetching the details needed.
     */
    private static Map<string, Map<String,String>> parseXML(DOM.XMLNode node, Map<string, Map<String,String>> contractMap) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName() == 'item'){
                String mrid = node.getChildElement('mrid', null).getText().trim();
                contractMap.put(mrid,new Map<String,String>());
                  
                for(Dom.XmlNode subChild: node.getChildElements()){
                    contractMap.get(mrid).put(subChild.getName(),subChild.getText().trim());
                }
            }
        }
        for (Dom.XMLNode child: node.getChildElements()) {
           contractMap =  parseXML(child,contractMap);
        }

        return contractMap;
    }

     /*
     * This method is for parsing the XML returned from FootPrint after Creating a Case.
     */
    private static String parseXMLForCreateIssue(DOM.XMLNode node,String caseNumber) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName()=='return'){
              caseNumber = node.getText().trim();
            }
        }
        for (Dom.XMLNode child: node.getChildElements()) {
           caseNumber = parseXMLForCreateIssue(child,caseNumber);
        }

        return caseNumber;
    }


    /*Class for Parsing the JSon*/
    public Class CaseDetails{
        public String firstName {get;set;} 
        public String lastName {get;set;} 
        public String email {get;set;} 
        public String phone {get;set;} 
        public String account {get;set;} 
        public String contractUid {get;set;} 
        public String contractExpiryDate {get;set;} 
        public string contractPriority{get;set;}
        public String remoteConnectionType {get;set;} 
        public String contractServiceLevel {get;set;} 
        public String ticketPriority {get;set;} 
        public String productLine {get;set;}
        public String startOfContract {get;set;} 
        public String hotlineHrs {get;set;} 
        public String entitlement {get;set;} 
        public String scopeOfContract {get;set;} 
        public String productLevel1 {get;set;} 
        public String productLevel2 {get;set;} 
        public String powerPlantId {get;set;} 
        public String plantPart{get;set;}
        public string gtmHq{get;set;}
        public String gtmRegion{get;set;}
        public string onCallSupportTimeTable{get;set;}
        public string onCallSupportAvailable{get;set;}
        public String numberOfHighPriority {get;set;} 
        public String accountCopy {get;set;} 
        public String location {get;set;} 
        public String defaultTicketExeBy {get;set;} 
        public String description {get;set;} 
        public Integer priorityNumber {get;set;} 
        public String status {get;set;} 
        public String title {get;set;} 
        public Integer projectId {get;set;} 
        public String projectSiemensResponsible{get;set;}
        public String endOfWarranty{get;set;}
        public String plantId {get;set;} 
        public String mrId {get;set;}
    }



    /*
     * Name: fetchingCases
     * Input Params: String - Id of the Selected Plant from UI
     * Output Param: List<String> - List of Cases
     * Description: The method send http request with XML string as Body and returns a List of Contracts.
     */
    public static Map<string, Map<String,String>> fetchingCases() {

        Http http = new Http();
        
        String qry =  '<param3 xsi:type="xsd:string">'+
                      'SELECT * FROM MASTER2 WHERE Power__bPlant__bID=\'25\' AND mrstatus!=\'_DELETED_\' AND Show__bin__bCP__Q=\'Yes\' ORDER BY mrsubmitdate DESC'+
                      '</param3>';
        HttpRequest req = prepareRequest('<SOAP-ENV:Body><ns1:MRWebServices__search>','</ns1:MRWebServices__search></SOAP-ENV:Body>',qry);
        
        HttpResponse res = http.send(req);

         if(res.getStatusCode() == 500){
            return new Map<string, Map<String,String>>();
        }

        Map<string, Map<String,String>> casesMap = parseXMLForCases(res.getBodyDocument().getRootElement(),new Map<string, Map<String,String>>());

        return casesMap;
    
    }

    /*
     * This method parse the XML for case list
     */
    private static Map<string, Map<String,String>> parseXMLForCases(DOM.XMLNode node, Map<string, Map<String,String>> casesMap) {

        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName() == 'item'){

                Map<String, String> tempList = new Map<String, String>();
                String euid = node.getChildElement('e__uid', null).getText().trim();

                tempList.put('e__uid', node.getChildElement('e__uid', null).getText().trim());
                tempList.put('mrtitle', node.getChildElement('mrtitle', null).getText().trim());
                tempList.put('mrstatus', node.getChildElement('mrstatus', null).getText().trim().replace('__b', ' '));
                tempList.put('submitted__bat', node.getChildElement('submitted__bat', null).getText().trim());
                tempList.put('product__blevel__b1', node.getChildElement('product__blevel__b1', null).getText().trim().replace('__b', ' '));
                tempList.put('product__blevel__b2', node.getChildElement('product__blevel__b2', null).getText().trim().replace('__b', ' '));
				tempList.put('mrid', node.getChildElement('mrid', null).getText().trim());
                tempList.put('contract', node.getChildElement('entitlement', null).getText().trim());
                tempList.put('plant_part', node.getChildElement('plant__bpart', null).getText().trim());
                tempList.put('ticket_priority', node.getChildElement('ticket__bpriority', null).getText().trim());

                casesMap.put(euid, tempList);
                  
            }
        }
        for (Dom.XMLNode child: node.getChildElements()) {
           casesMap =  parseXMLForCases(child,casesMap);
        }
        return casesMap;
    }

    /*
     * Name: getCaseDetail
     * Input Params: String - Id of the Selected Plant from UI, mrId of case Id
     * Output Param: List<String> - case Details
     * Description: The method send http request with XML string as Body and returns a List of Contracts.
     */
    public static Map<String, Map<String,String>> getCaseDetail(String dataInput) {
        
        CaseDetails cd = (CaseDetails)JSON.deserialize(dataInput, CaseDetails.class);

        Http http = new Http();
        
        String qry =  '<param3 xsi:type="xsd:string">'+
                      'SELECT * FROM MASTER2 WHERE Power__bPlant__bID=\''+cd.plantId+'\' AND mrID=\''+cd.mrId+'\''+
                      '</param3>';
        HttpRequest req = prepareRequest('<SOAP-ENV:Body><ns1:MRWebServices__search>','</ns1:MRWebServices__search></SOAP-ENV:Body>',qry);
        
        HttpResponse res = http.send(req);

         if(res.getStatusCode() == 500){
            return new Map<String, Map<String,String>>();
        }

        Map<String, Map<String,String>> caseDetailMap = parseXMLForCaseDetail(res.getBodyDocument().getRootElement(),new Map<String, Map<String,String>>());

        return caseDetailMap;
    
    }

    /*
     * This method parse the XML for case detail
     */
    private static Map<String, Map<String,String>> parseXMLForCaseDetail(DOM.XMLNode node, Map<String, Map<String,String>> caseDetailMap) {

        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getName() == 'item'){

                Map<String, String> tempList = new Map<String, String>();
                String euid = node.getChildElement('e__uid', null).getText().trim();

                tempList.put('e__uid', node.getChildElement('e__uid', null).getText().trim());
                tempList.put('mrtitle', node.getChildElement('mrtitle', null).getText().trim());
                tempList.put('mrstatus', node.getChildElement('mrstatus', null).getText().trim());
                tempList.put('submitted__bat', node.getChildElement('submitted__bat', null).getText().trim());
                tempList.put('product__blevel__b1', node.getChildElement('product__blevel__b1', null).getText().trim().replace('__b', ' '));
                tempList.put('product__blevel__b2', node.getChildElement('product__blevel__b2', null).getText().trim().replace('__b', ' '));
                tempList.put('work__bstarted', node.getChildElement('work__bstarted', null).getText().trim());
                tempList.put('source', node.getChildElement('source', null).getText().trim().replace('__b', ' '));
                tempList.put('description', node.getChildElement('what__q', null).getText().trim().replaceAll('&#92;n','<br>').replaceAll('\n','<br>'));
                tempList.put('mralldescriptions', node.getChildElement('mralldescriptions', null).getText().trim().unescapeHtml4().replaceAll('&#92;n','<br>').replaceAll('\n\n','<br>').replaceAll('\n','<br>'));
                tempList.put('mrdescription', node.getChildElement('mrdescription', null).getText().trim().unescapeHtml4().replaceAll('&#92;n','<br>').replaceAll('\n\n','<br>').replaceAll('\n','<br>'));
                tempList.put('contract', node.getChildElement('entitlement', null).getText().trim());
                tempList.put('plant_part', node.getChildElement('plant__bpart', null).getText().trim());
                tempList.put('mrId', node.getChildElement('mrid', null).getText().trim());
                
                caseDetailMap.put(euid, tempList);
            }
        }

        for (Dom.XMLNode child: node.getChildElements()) {
           caseDetailMap =  parseXMLForCaseDetail(child,caseDetailMap);
        }
        return caseDetailMap;
    }

    public static String updateCase(string dataInput) {
        CaseDetails cd = (CaseDetails)JSON.deserialize(dataInput, CaseDetails.class);
        Http http = new Http();
		
        String SOAPBODY = '<param3 xsi:type="ns2:Map">';
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">projectID</key>';
            SOAPBODY += '<value xsi:type="xsd:string">2</value>';
        SOAPBODY += '</item>';
        
        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">mrID</key>';
            SOAPBODY += '<value xsi:type="xsd:string">'+cd.mrId+'</value>';
        SOAPBODY += '</item>';

        SOAPBODY += '<item>';
            SOAPBODY += '<key xsi:type="xsd:string">description</key>';
            SOAPBODY += '<value xsi:type="xsd:string">'+cd.description+'</value>';
        SOAPBODY += '</item>';
        SOAPBODY += '</param3>';
                            
        HttpRequest req = prepareRequest('<SOAP-ENV:Body><ns1:MRWebServices__editIssue>','</ns1:MRWebServices__editIssue></SOAP-ENV:Body>',SOAPBODY);
        
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 500){
            return 'error';
        }

        String caseNumber = parseXMLForCreateIssue(res.getBodyDocument().getRootElement(),'');

        return caseNumber;
    }
}