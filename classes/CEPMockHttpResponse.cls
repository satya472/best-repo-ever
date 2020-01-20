@istest
public class CEPMockHttpResponse implements HttpCalloutMock {
    
    String requestType;
    public CEPMockHttpResponse(String type){
        this.requestType = type;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        if(this.requestType == 'get_contracts'){
        	string response = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+
	                 'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"'+
	                 'xmlns:xsd="http://www.w3.org/2001/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
	                 '<SOAP-ENV:Body><namesp1:MRWebServices__searchResponse xmlns:namesp1="MRWebServices">'+
			         '<return xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="xsd:anyType[2]"><item><mrid xsi:type="xsd:int">2223</mrid></item>'+
                     '<item><mrid xsi:type="xsd:int">2224</mrid></item></return></namesp1:MRWebServices__searchResponse></SOAP-ENV:Body>'+
                     '</SOAP-ENV:Envelope>';
        	res.setBody(response);
        } else if(this.requestType == 'invalid_contracts'){
            string response = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+
	                 'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"'+
	                 'xmlns:xsd="http://www.w3.org/2001/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
	                 '<SOAP-ENV:Body><namesp1:MRWebServices__searchResponse xmlns:namesp1="MRWebServices">'+
			         '<return xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="xsd:anyType[2]"><item><entitlement xsi:type="xsd:string">Test 1</entitlement></item>'+
                     '<item><entitlement xsi:type="xsd:string">Test 2</entitlement></item></return></namesp1:MRWebServices__searchResponse></SOAP-ENV:Body>'+
                     '</SOAP-ENV:Envelope>';
        	res.setBody(response);
            
        } else if(this.requestType == 'create_case'){
            string response = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+ 
                'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"'+
                'xmlns:xsd="http://www.w3.org/2001/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
                '<SOAP-ENV:Body><namesp1:MRWebServices__createIssueResponse xmlns:namesp1="MRWebServices">'+
                '<return xsi:type="xsd:string">1071280</return></namesp1:MRWebServices__createIssueResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
			res.setBody(response);
        } else if(this.requestType == 'update_case'){
            string response = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'+ 
                'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"'+
                'xmlns:xsd="http://www.w3.org/2001/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
                '<SOAP-ENV:Body><namesp1:MRWebServices__editIssueResponse xmlns:namesp1="MRWebServices">'+
                '<return xsi:type="xsd:string">1071281</return></namesp1:MRWebServices__editIssueResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
			res.setBody(response);
        } else if(this.requestType == 'case_detail'){
            String response = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"'+
                'xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema"'+
                'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'+
                '<SOAP-ENV:Body><namesp1:MRWebServices__searchResponse xmlns:namesp1="MRWebServices">'+
                '<return xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="xsd:anyType[1]">'+
                '<item><sla__bdue__bdate xsi:nil="true" /><mrsubmitdate xsi:type="xsd:string">2019-04-26 09:35:13.000</mrsubmitdate>'+
                '<where__q xsi:nil="true" /><keywords xsi:nil="true" /><customer__bsolution xsi:nil="true" />'+
                '<mrescalatedby xsi:type="xsd:string">&lt;2&gt;&lt;180&gt;</mrescalatedby><fpmrid xsi:type="xsd:int">1071281</fpmrid>'+
                '<end__bof__bwarranty xsi:nil="true" /><product__blevel__b2 xsi:type="xsd:string">CM</product__blevel__b2>'+
                '<cause__bof__bdefect xsi:nil="true" /><defect__blocation xsi:nil="true" />'+
                '<mralldescriptions xsi:type="xsd:string">&lt;! 2019-04-26 09:35:13 CustomerPortal &gt;Lorem Ipsum has been the industry</mralldescriptions>'+
                '<project__b__f__bsite__bref__d__bno__d xsi:nil="true" /><top__bproblems xsi:nil="true" /><mrpopularity xsi:nil="true" />'+
                '<mrassignees xsi:type="xsd:string">CustomerPortal</mrassignees><system xsi:type="xsd:string">SPPA__uT2000</system>'+
                '<type__b2 xsi:nil="true" /><follow__uup__bdate__blink xsi:nil="true" /><mrtimestamp xsi:type="xsd:base64Binary">AAAAAAiKtWg=</mrtimestamp>'+
                '<charge__bnumber xsi:nil="true" /><attachment__blist xsi:nil="true" /><mrtitle xsi:type="xsd:string">Lorem Ipsum is simply dummy text</mrtitle>'+
                '<link__bto__bproject__bdata xsi:nil="true" /><responsible xsi:nil="true" /><version xsi:nil="true" /><detailed__bproduct__bversion xsi:nil="true" />'+
                '<trip__bdate xsi:nil="true" /><entitlement__bnote xsi:type="xsd:string">Additional Comments</entitlement__bnote><notes xsi:nil="true" />'+
                '<oncall__bsupport__btimetable xsi:nil="true" /><type__b1 xsi:nil="true" /><project__bname__b__pe__bf__bie__bti__p xsi:nil="true" />'+
                '<end__bof__bwarranty__bdate xsi:nil="true" /><start__bof__bcontract xsi:type="xsd:string">2016-06-20 00&amp;#58;00&amp;#58;00.000</start__bof__bcontract><ticket__bcallback__bpriority xsi:nil="true" />'+
                '<comments xsi:nil="true" /><cost__bvalue xsi:nil="true" /><reaction__bdate__btime xsi:nil="true" /><mrsubtask_order xsi:nil="true" />'+
                '<customer__bcomplaint xsi:nil="true" /><defect__bcreated__bon__blink xsi:nil="true" /><remote__bconnection__btype xsi:nil="true" /><work__bstarted xsi:nil="true" />'+
                '<plant__bpart xsi:type="xsd:string">Unit 1</plant__bpart><defect__bstatus xsi:nil="true" /><scope__bof__bcontract xsi:type="xsd:string">Hotline__bDCS</scope__bof__bcontract>'+
                '<reaction__bdate__btime__blink xsi:nil="true" /><agreement__btype xsi:nil="true" /><mrunassigned xsi:nil="true" /><type xsi:type="xsd:string">US__bREC__bTicket__bExecution</type>'+
                '<contract__bpriority xsi:type="xsd:string">US</contract__bpriority><e__uid xsi:type="xsd:string">2-1071281</e__uid><product__blevel__b4 xsi:nil="true" /><entitlement xsi:type="xsd:string">Support as LTSP</entitlement>'+
                '<gtm__bregion xsi:type="xsd:string">Wolfgang Gerndt</gtm__bregion><further__bactions xsi:nil="true" /><severity xsi:nil="true" /><defect__bnumber xsi:nil="true" /><urgency xsi:nil="true" /><business__bunit xsi:nil="true" />'+
                '<ticket__bpriority xsi:type="xsd:string">low</ticket__bpriority><contract__bservice__blevel xsi:type="xsd:string">Unlimited__bhours</contract__bservice__blevel><sla__bdue__bdate__blink xsi:nil="true" /><defect__bpriority xsi:nil="true" /><priority__breporter xsi:nil="true" /><short__bdescription xsi:nil="true" />'+
                '<follow__uup__bdate xsi:nil="true" /><product__blevel__b1 xsi:type="xsd:string">T3000</product__blevel__b1><optional__b__u__bselect__bpt__bworkgroup xsi:nil="true" /><mrdescription xsi:type="xsd:string">&lt;! 2019-04-26 09:35:13 CustomerPortal &gt;Lorem Ipsum has been the industry</mrdescription>'+
                '<product__bline xsi:nil="true" /><extent__q xsi:nil="true" /><campaign xsi:nil="true" /><mrstatus xsi:type="xsd:string">Open</mrstatus><fpprojid xsi:type="xsd:int">2</fpprojid><pac xsi:nil="true" /><purchaser xsi:nil="true" /><oncall__bsupport__bavailable__q xsi:type="xsd:string">Yes</oncall__bsupport__bavailable__q>'+
                '<region xsi:nil="true" /><awv__bcode xsi:type="xsd:string">N / N</awv__bcode><call__bcenter__boutbound__bcall__bdate__band__btime xsi:nil="true" /><mrnamp_id xsi:nil="true" /><analysis__band__bactions xsi:nil="true" /><mrref_to_ab xsi:nil="true" /><number__bof__bhigh__bpriority xsi:nil="true" />'+
                '<defect__bdescription xsi:nil="true" /><gtm__bhq xsi:type="xsd:string">Patrick__bSurkemper</gtm__bhq><remote__badmins xsi:nil="true" /><result xsi:nil="true" /><source xsi:type="xsd:string">Customer__bPortal</source><keywords__b__pfl__bno__d__p xsi:nil="true" /><currency xsi:nil="true" /><mrattachments xsi:nil="true" />'+
                '<system__bsoftware__bversion xsi:nil="true" /><account xsi:type="xsd:string">DemoPlantTXP</account><crsp__bsite__bname xsi:nil="true" /><project__bresponsible__b__psiemens__p xsi:nil="true" /><mrurgent xsi:type="xsd:int">200</mrurgent><power__bplant__bid xsi:type="xsd:int">25</power__bplant__bid><mrref_to_mr xsi:nil="true" />'+
                '<defect__bcreated__bon xsi:nil="true" /><customer__bdescription xsi:nil="true" /><contract__uid xsi:type="xsd:int">2221</contract__uid><problem__breport__bno__d xsi:nil="true" /><hide__boptions xsi:type="xsd:string">hidden</hide__boptions><reaction__btime__b__emin__e xsi:nil="true" /><occurence xsi:nil="true" />'+
                '<submitted__bat__blink xsi:nil="true" /><default__bphone__bno__d xsi:nil="true" /><affected__bplant__bpart__band__bserver__b__f__bsystem xsi:nil="true" /><defect__bseverity xsi:nil="true" /><complaint__bcause xsi:nil="true" /><mrsubmitter xsi:type="xsd:string">CustomerPortal</mrsubmitter><call__bcenter__boutbound__bcall__bdate__band__btime__blink xsi:nil="true" />'+
                '<remark xsi:nil="true" /><location xsi:type="xsd:string">2016-06-20 00&amp;#58;00&amp;#58;00.000</location><origin xsi:nil="true" /><ticket__bsolution__bpriority xsi:nil="true" /><mrsolution_type xsi:nil="true" /><mrref_to_mrx xsi:nil="true" /><service_request_ci_type_id xsi:nil="true" /><channel__bno__d__bnuc xsi:nil="true" />'+
                '<what__q xsi:type="xsd:string">Lorem Ipsum has been the industry</what__q><value__bamount xsi:nil="true" /><contractual__brelationship xsi:nil="true" /><hotline__bhours xsi:type="xsd:string">2016-06-20 00&amp;#58;00&amp;#58;00.000</hotline__bhours><type__bof__bdefect xsi:nil="true" /><submitted__bat xsi:type="xsd:string">2019-04-26 07:33:21.000</submitted__bat>'+
                '<mrpriority xsi:type="xsd:int">3</mrpriority><accountcopy xsi:type="xsd:string">Germany (DE)</accountcopy><entitlement__bforward xsi:nil="true" /><contract__bexpiry__bdate xsi:type="xsd:string">null</contract__bexpiry__bdate><classifications xsi:nil="true" /><product__blevel__b3 xsi:nil="true" /><work__bstarted__blink xsi:nil="true" />'+
                '<mrid xsi:type="xsd:int">1071281</mrid><when__q xsi:nil="true" /><reproducible xsi:nil="true" /><mrupdatedate xsi:type="xsd:string">2019-04-26 09:35:13.000</mrupdatedate><product__blevel__b5 xsi:nil="true" /><show__bin__bcp__q xsi:type="xsd:string">Yes</show__bin__bcp__q><remote__baccess__btime__b__emin__e xsi:nil="true" /></item></return>'+
                '</namesp1:MRWebServices__searchResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
            res.setBody(response);
        } else if(this.requestType == 'get_cases'){
            String response = '<?xml version="1.0" encoding="UTF-8"?>';
            	response += '<SOAP-ENV:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">';
            	response += '<SOAP-ENV:Body>';
            	response += '<namesp1:MRWebServices__searchResponse xmlns:namesp1="MRWebServices">';
            	response += '<return xsi:type="SOAP-ENC:Array" SOAP-ENC:arrayType="xsd:anyType[2]">';
            	response += '<item>';
            	response += '<e__uid xsi:type="xsd:string">2-1071296</e__uid>';
            	response += '<mrtitle xsi:type="xsd:string">tttttttttttt</mrtitle>';
            	response += '<mrstatus xsi:type="xsd:string">Closed</mrstatus>';
            	response += '<submitted__bat xsi:type="xsd:string">2019-04-26 12:21:41.000</submitted__bat>';
            	response += '<product__blevel__b1 xsi:type="xsd:string">T3000</product__blevel__b1>';
            	response += '<product__blevel__b2 xsi:type="xsd:string">AS620__uS7</product__blevel__b2>';
            	response += '<mrid xsi:type="xsd:int">1071296</mrid>';
            	response += '<entitlement xsi:type="xsd:string">Support as LTSP</entitlement>';
            	response += '<plant__bpart xsi:type="xsd:string">Unit 1</plant__bpart>';
            	response += '<ticket__bpriority xsi:type="xsd:string">low</ticket__bpriority>';
            	response += '</item>';
            	response += '<item>';
            	response += '<e__uid xsi:type="xsd:string">2-1071295</e__uid>';
            	response += '<mrtitle xsi:type="xsd:string">New Title</mrtitle>';
            	response += '<mrstatus xsi:type="xsd:string">Closed</mrstatus>';
            	response += '<submitted__bat xsi:type="xsd:string">019-04-26 12:05:18.000</submitted__bat>';
            	response += '<product__blevel__b1 xsi:type="xsd:string">T3000</product__blevel__b1>';
            	response += '<product__blevel__b2 xsi:type="xsd:string">AS620__uS7</product__blevel__b2>';
            	response += '<mrid xsi:type="xsd:int">1071295</mrid>';
            	response += '<entitlement xsi:type="xsd:string">Support as LTSP</entitlement>';
            	response += '<plant__bpart xsi:type="xsd:string">Unit 1</plant__bpart>';
            	response += '<ticket__bpriority xsi:type="xsd:string">low</ticket__bpriority>';
            	response += '</item>';
            	response += '</return>';
            	response += '</namesp1:MRWebServices__searchResponse>';
            	response += '</SOAP-ENV:Body>';
            	response += '</SOAP-ENV:Envelope>';
            res.setBody(response);
        }
        res.setStatusCode(200);
        return res;
    }
}