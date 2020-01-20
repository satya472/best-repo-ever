/*
 * Author : Phaniram Upalapati
 * Description : Util Class for Fetching different 
              report formats and its related Data.
 * Associated To : ReportsDisplay_Cont
 * Test Class : ReportsDisplay_ContTest
*/
public with sharing class Analytics_Util {

	/*
      * Description : Method fetches the Rows of a report based on the inputs provided.
      * Inputs :  Id,String - ReportId and Filter Values.
	  * Return Value: reportResponse - Class Containing all the report and its related
	                rows details.
	*/
	public static reportResponse getReportResponse(String reportAPIName, String filterData, String recordId) {
       
        //Based on the Report API Name fetching Id of the report
        List<Report> reportDetails = [Select Id,DeveloperName from Report Where DeveloperName = :reportAPIName LIMIT 1];
        if(reportDetails.isEmpty()){
            return new ReportResponse();
        }
       
        Id reportId = reportDetails.get(0).Id;
		Reports.ReportDescribeResult myReportResult = Reports.ReportManager.describeReport(reportId);
		Reports.ReportMetadata myReportMetaData = myReportResult.getReportMetadata();
        String[] filterLst= new List<String>();
        if(!String.isBlank(recordId)){
            filterLst.add(recordId);
        }
        if(!String.isEmpty(filterData)){ 
            if(filterData.indexOf(';') != -1){
                filterLst = filterData.split(';');
            }else{
                filterLst.add(filterData);
            }
        }
 
        if(!(myReportMetaData.getReportFilters()).isEmpty() && myReportMetaData.getReportFilters().size() >= filterLst.size() && !filterLst.isEmpty()){
            Reports.ReportFilter myFilters;
            for(Integer i=0;i<myReportMetaData.getReportFilters().size();i++){
                myFilters = myReportMetaData.getReportFilters()[i];
                //Checking Filter Size to make sure that we are accessing only the number of filters in the report
                //set the filter value
                if(i < filterLst.size()){
                    myFilters.setValue(filterLst.get(i));
                }
            }
		}

		Reports.ReportResults results = Reports.ReportManager.runReport(reportId,myReportMetaData ,true);
		
		//get the metadata
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();
		
		//find out what type of report it is by looking at the groupings down and groupings across
		Integer groupingsDown = 0;
		Integer groupingsAcross = 0;
		
		List<Reports.GroupingInfo> groupingDownList = reportMetadata.getGroupingsDown();
		List<Reports.GroupingInfo> groupingAcrossList = reportMetadata.getGroupingsAcross();
		
		if (groupingDownList != null) {
			groupingsDown = groupingDownList.size();
		}
		
		if (groupingAcrossList != null) {
			groupingsAcross = groupingAcrossList.size();
		}		
		
		String reportType = 'tabular';
		if ( (groupingsDown > 0) && (groupingsAcross == 0) ) {
			reportType = 'summary';	
		}
		
		if ( (groupingsDown > 0) && (groupingsAcross > 0) ) {
			reportType = 'matrix';	
		}		
		
		reportResponse reportResp = new reportResponse();
		reportResp.reportType = reportType;	

		if (reportType == 'tabular') {
			reportResp.tabResp = getTabularReportResponse(results);
		} else if (reportType == 'summary') {
			reportResp.sumResp = getSummaryReportResponse(results);
		} else if (reportType == 'matrix') {
			reportResp.tabResp = getMatrixReportResponse(results);
		}
		
		return reportResp;
	}

	/*
      * Description : Method fetches the Rows of a Tabular Report.
      * Inputs :  IReports.ReportResults.
	  * Return Value: reportResponse - Class Containing all the report related Row Details
	                in Tabular Format.
	*/

	public static tabularReportResponse getTabularReportResponse(Reports.ReportResults results) {
		tabularReportResponse trr = new tabularReportResponse();
		List<fieldDef> reportFields = new List<fieldDef>();	
		List<List<fieldData>> fieldDataList = new List<List<fieldData>>();	
		
		//get the metadata
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();

		//get a string array of the field names
		List<String> fieldNames = reportMetadata.getDetailColumns();		
		
		//get the extended metadata
		Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();

		//get the map of the column names to their name and label
		Map<String, Reports.DetailColumn> detailColumnMap = reportExtendedMetadata.getDetailColumnInfo();
		
	
		//loop over the detailColumnMap and get the name, label, and data type
		for (String fieldName: fieldNames) {
			Reports.DetailColumn detailColumn = detailColumnMap.get(fieldName);
			fieldDef fd = new fieldDef();
			fd.fieldName = detailColumn.getName(); 
			fd.fieldLabel = detailColumn.getLabel();
			fd.dataType = detailColumn.getDataType().name();
			reportFields.add(fd);
		}
		
		
		// Get the fact map from the report results
		Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');		
		
		List<Reports.ReportDetailRow> reportDetailRowList = factDetails.getRows();
		
        Integer cellCounter;
        List<fieldData> fieldDataRow;
        fieldData fd;
		//loop over the rows
		for (Reports.ReportDetailRow reportDetailRow: reportDetailRowList) {
			cellCounter = 0;
			fieldDataRow = new List<fieldData>();
			//loop over the cells in the row
			for (Reports.ReportDataCell reportDataCell: reportDetailRow.getDataCells()) {
				fd = new fieldData();
				fd.fieldValue = String.valueOf(reportDataCell.getValue());
				fd.fieldLabel = (String)reportDataCell.getLabel();
				fd.dataType = reportFields[cellCounter].dataType;
				fd.isHyperLink = isHyperlink(fd.fieldValue);
				cellCounter++;
				fieldDataRow.add(fd);
			}
			
			//add the row to the list
			fieldDataList.add(fieldDataRow);
		}

		trr.reportFields = reportFields;
		trr.fieldDataList = fieldDataList;
		return trr;
	}	
	
	
	/*
      * Description : Method fetches the Rows of a Summary Report Format and ir goes only 1 Level of 
	                Summarizing.
      * Inputs :  Reports.ReportResults.
	  * Return Value: reportResponse - Class Containing all the report related row details in Summary Format.
	*/
	public static summaryReportResponse getSummaryReportResponse(Reports.ReportResults results) {
		summaryReportResponse srr = new summaryReportResponse();
		List<fieldDef> reportFields = new List<fieldDef>();	
		
		//get the metadata
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();

		//get a string array of the field names
		List<String> fieldNames = reportMetadata.getDetailColumns();		
		
		//get the extended metadata
		Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();

		//get the map of the column names to their name and label
		Map<String, Reports.DetailColumn> detailColumnMap = reportExtendedMetadata.getDetailColumnInfo();
		
		//get the map of the grouping column names to their name and label
		Map<String, Reports.GroupingColumn> groupingColumnMap = reportExtendedMetadata.getGroupingColumnInfo();		

		//get the grouping column info
		Reports.GroupingInfo groupingInfo = reportMetadata.getGroupingsDown()[0]; //only supports one grouping level
		Reports.GroupingColumn groupingColumnDetail = groupingColumnMap.get(groupingInfo.getName());				
        
        Reports.DetailColumn detailColumn;
        fieldDef fd;
		//loop over the detailColumnMap and get the name, label, and data type
		for (String fieldName: fieldNames) {
			detailColumn = detailColumnMap.get(fieldName);
			fd = new fieldDef();
			fd.fieldName = detailColumn.getName(); 
			fd.fieldLabel = detailColumn.getLabel();
			fd.dataType = detailColumn.getDataType().name();
			reportFields.add(fd);
		}
		srr.reportFields = reportFields;

        summaryReportGroup srg;
        Reports.ReportFactWithDetails factDetails;
        List<Reports.ReportDetailRow> reportDetailRowList;
        List<List<fieldData>> fieldDataList;
        Integer cellCounter;
        List<fieldData> fieldDataRow;
        fieldData fdata;

		//get the summary grouping down dimension grouping values.  only going 1 level deep
		List<summaryReportGroup> groupList = new List<summaryReportGroup>();
		for (Reports.GroupingValue groupingValue: results.getGroupingsDown().getGroupings()) {
			srg = new summaryReportGroup();
			srg.fieldName = groupingColumnDetail.getLabel();			
			srg.fieldValue = (String)groupingValue.getValue();
			srg.fieldLabel = groupingValue.getLabel();
			srg.groupKey = groupingValue.getKey();
			srg.isHyperLink = isHyperlink(srg.fieldValue);

			//use our group key to get the group rows from the fact map
			factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(srg.groupKey+'!T');	
			reportDetailRowList = factDetails.getRows();	

			fieldDataList = new List<List<fieldData>>();

			//loop over the rows
			for (Reports.ReportDetailRow reportDetailRow: reportDetailRowList) {
				cellCounter = 0;
				fieldDataRow = new List<fieldData>();
				//loop over the cells in the row
				for (Reports.ReportDataCell reportDataCell: reportDetailRow.getDataCells()) {
					fdata = new fieldData();
					fdata.fieldValue = String.valueOf(reportDataCell.getValue());
					fdata.fieldLabel = (String)reportDataCell.getLabel();
					fdata.dataType = reportFields[cellCounter].dataType;
					fdata.isHyperLink = isHyperlink(fdata.fieldValue);
					cellCounter++;
					fieldDataRow.add(fdata);
				}
				
				//add the row to the list
				fieldDataList.add(fieldDataRow);
			}			
			srg.fieldsInGroup = srr.reportFields.size();			
			srg.fieldDataList = fieldDataList;
			groupList.add(srg);
		}
		srr.groupList = groupList;

		return srr;
	}		
	
	/*
	 * Description : Method fetches the Rows of Matrix report type.
     * Inputs :  Reports.ReportResults
	 * Return Value: tabularReportResponse - Class Containing the details of rows in
	                Tabular format.
	*/
	
	public static tabularReportResponse getMatrixReportResponse(Reports.ReportResults results) {
		tabularReportResponse trr = new tabularReportResponse();
		List<fieldDef> reportFields = new List<fieldDef>();
		List<List<fieldData>> fieldDataList = new List<List<fieldData>>();		
		
		//get the metadata
		Reports.ReportMetadata reportMetadata = results.getReportMetadata();

		//get a string array of the field names
		List<String> fieldNames = reportMetadata.getDetailColumns();		
		
		//get the extended metadata
		Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();

		//get the map of the grouping column names to their name and label
		Map<String, Reports.GroupingColumn> detailColumnMap = reportExtendedMetadata.getGroupingColumnInfo();

		//create the reportFields header row from the grouping fields
		
		//first add the grouping down field info
		Reports.GroupingInfo groupingInfoDown = reportMetadata.getGroupingsDown()[0]; //only supports one grouping level
		Reports.GroupingColumn groupingColumnDown = detailColumnMap.get(groupingInfoDown.getName());
		fieldDef fdGroupDown = new fieldDef();
		fdGroupDown.fieldName = groupingColumnDown.getName(); 
		fdGroupDown.fieldLabel = groupingColumnDown.getLabel();
		fdGroupDown.dataType = groupingColumnDown.getDataType().name();
		reportFields.add(fdGroupDown);
		
		//now add all the groupings across
		fieldDef fdata;
		for (Reports.GroupingValue groupingValue: results.getGroupingsAcross().getGroupings()) {
			fdata = new fieldDef();
			fdata.fieldName = (String)groupingValue.getValue(); 
			fdata.fieldLabel = groupingValue.getLabel();
			fdata.dataType = 'DOUBLE_DATA';
			reportFields.add(fdata);			
		}				
		
		//get the matrix grouping down dimension grouping values.  only going 1 level deep
		List<summaryReportGroup> groupListDown = new List<summaryReportGroup>();
        summaryReportGroup srg;
		for (Reports.GroupingValue groupingValue: results.getGroupingsDown().getGroupings()) {
			srg = new summaryReportGroup();
			srg.fieldValue = (String)groupingValue.getValue();
			srg.fieldLabel = groupingValue.getLabel();
			srg.groupKey = groupingValue.getKey();
			srg.isHyperLink = isHyperlink(srg.fieldValue);
			groupListDown.add(srg);
		}
		
		//get the matrix grouping across dimension grouping values.  only going 1 level deep
		List<summaryReportGroup> groupListAcross = new List<summaryReportGroup>();
        summaryReportGroup summaryGroup;
		for (Reports.GroupingValue groupingValue: results.getGroupingsAcross().getGroupings()) {
			summaryGroup = new summaryReportGroup();
			summaryGroup.fieldValue = (String)groupingValue.getValue();
			summaryGroup.fieldLabel = groupingValue.getLabel();
			summaryGroup.groupKey = groupingValue.getKey();
			summaryGroup.isHyperLink = isHyperlink(summaryGroup.fieldValue);
			groupListAcross.add(summaryGroup);
		}		

		//now we need to do a nested loop of the groupings down and across to get all the data from the fact map
		List<fieldData> fieldDataRow;
        fieldData fd;
        Reports.ReportFactWithDetails factDetails;
        Reports.SummaryValue summaryValue;
		for (summaryReportGroup down: groupListDown) {
			fieldDataRow = new List<fieldData>();

			//first cell is the grouping down
			fd = new fieldData();
			fd.fieldValue = down.fieldValue;
			fd.fieldLabel = down.fieldLabel;
			fd.dataType = 'STRING_DATA';
			fd.isHyperLink = down.isHyperLink;
			fieldDataRow.add(fd);					
			
			for (summaryReportGroup across: groupListAcross) {
				//use our composite down!across key to get values from the fact map
				factDetails = (Reports.ReportFactWithDetails)results.getFactMap().get(down.groupKey+'!'+across.groupKey);	
				summaryValue = factDetails.getAggregates()[0]; //only support 1 set of aggregates
				
				fd = new fieldData();
				fd.fieldValue = (String)(summaryValue.getValue()+'');
				fd.fieldLabel = (String)(summaryValue.getLabel()+'');
				fd.dataType = 'DOUBLE_DATA';
				fieldDataRow.add(fd);						
					
			}
			//add the row to the list
			fieldDataList.add(fieldDataRow);
		}

		trr.reportFields = reportFields;
		trr.fieldDataList = fieldDataList;
		
		return trr;
	}			
	
	/* Static Method to check whether the Cell value Consists if HyperLink or not */
	public static Boolean isHyperlink(String sVal) {
		Boolean isHyperLink = true;
		Id theId;
		try {theId = (Id)sVal;}
		catch (Exception e) {isHyperLink = false;}
		return isHyperLink;
	}	
	
	/*
	 * Description: Wrapper Class to return the data to
	                the lightning Component.
	 */
	public class reportResponse {
		public String reportType {get; set;}
		public tabularReportResponse tabResp {get; set;}
		public summaryReportResponse sumResp {get; set;}		
		public reportResponse(){}
	}	
	
	/*
	 * Description: Wrapper Class to return the data related
	                to the Summary report.
	 */
	public class summaryReportResponse {
		public List<fieldDef> reportFields {get; set;}
		public List<summaryReportGroup> groupList {get; set;}
		public summaryReportResponse(){}
	}	
	
    /*
	 * Description: Wrapper Class to return the data related
	                to the Summary report Groupings so that
	                data can be displayed in tabular format.
	 */
	public class summaryReportGroup {
		public String fieldName {get; set;}
		public String fieldValue {get; set;}
		public String fieldLabel {get; set;}
		public String groupKey {get; set;}
		public Boolean isHyperLink {get; set;}	
		public Integer fieldsInGroup {get; set;}					
		public List<List<fieldData>> fieldDataList {get; set;}
		public summaryReportGroup(){}
	}		
	
	/*
	 * Description: Wrapper Class to return the data related
                    to the Tabular report.
	 */
	public class tabularReportResponse {
		public List<fieldDef> reportFields {get; set;}
		public List<List<fieldData>> fieldDataList {get; set;}
		public tabularReportResponse(){}
	}
	
    /*
	 * Description: Wrapper Class to Store the data of the
                    fields related to header row in a report
	 */
	public class fieldDef {
		public String fieldName {get; set;}
		public String fieldLabel {get; set;}
		public String dataType {get; set;}
		public fieldDef(){}
	}

    /*
	 * Description: Wrapper Class to store the data of each
                    cell in a report
	 */
	public class fieldData {
		public String fieldValue {get; set;}
		public String fieldLabel {get; set;}
		public String dataType  {get; set;}
		public Boolean isHyperLink {get; set;}			
		public fieldData(){isHyperLink=false;}
	}
}