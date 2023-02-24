/*
 * About : class used to process outbound messages to external systems via API
 * Assume that this runs for each event type
 * 
 * 
 * 
 * 
 * 
 * 
 */
public class OutboundMessage {

    public static String finalOpportunityId;
    public static String responseRequest;    
    public static String eventTypeFinal;    
    
    @InvocableMethod(label='Process Outbound Platform Event Data' description='Sends a CNCF Cloud message for each FlowInput passed in' category='Outbound Message' callout=true)
  	public static void processOutboundMessage(List<OutboundMessageVars> requests) {
        system.debug(requests);
        //loop through all the records passed in to the flow and send a payload to the django endpoint
        Set<String> recordIds = New Set<String>();
        
        List<OutboundMessageResult> results = New List<OutboundMessageResult>();
        String eventType = '';
        //put all inbound record ides into a map with the event type as the key and the id as a set of values
        for(OutboundMessageVars request : requests){
            eventType = request.eventType;
            recordIds.add(request.recordId);
        }
        
        Map<String,sObject> recordMap = New Map<String,sObject>();
        
        //query all the records, one time put them in a map with the id(String) as a kay and the sObject record as the value 
        recordMap = getRecords(eventType, recordIds);
        system.debug(recordMap);
        results = generateOutboundMessage(eventType, requests, recordMap);
        system.debug('results: ' + results);
        //return results;
        
    }
    
    public static Map<String,sObject> getRecords(String eventType,Set<String> recordIds){
    	
        Map<String,sObject> results = New Map<String,sObject>();
        
        //get Message Type and Message Type Mapping based on Event Type        
        Message_Type__mdt mTypeMapping = getTypeMapping(eventType);
		
        List<sObject> theRecords;
        
        String sObjectName;
        
        //create a string to use as a dynamic query for queryting the record data we need to send to Django
        String query = 'Select ';
        
        //loop through the metadata record and add the fields to wuery to the query stirng
        for(Message_Type_Mapping__mdt mapping : mTypeMapping.Message_Type_Mappings__r){
        	query += mapping.Salesforce_API_Name__c + ','; 
            sObjectName = mapping.sObject_Outbound_Only__c;
        }

        query = query.substringBeforeLast(',');
        
        query = query + ' FROM ' + sObjectName + ' where id in : recordIds' ;	  
        system.debug('the query ' + query);
        //query for the record
        theRecords = database.query(query);
        system.debug('the records ' + theRecords);
        
        for(sObject so : theRecords){
			results.put((String)so.get('Id'), so);
        }
         
        return results;
    }//test
    
    public static List<OutboundMessageResult> generateOutboundMessage(String eventType, List<OutboundMessageVars> requests, Map<String,sObject> recordMap){
        
        //create a list to hold the results
        List<OutboundMessageResult> results = New List<OutboundMessageResult>();
        
        //get Message Type and Message Type Mapping based on Event Type        
        Message_Type__mdt mTypeMapping = getTypeMapping(eventType);
        
        
        OutboundMessageResult result = new OutboundMessageResult();  
        
        //build the CNCF cloud payload
        CNCFPayloadCollection calloutData = New CNCFPayloadCollection();
        //calloutData.cncf_id = EventBus.getOperationId(results);
        Request reqInfo = Request.getCurrent();        
        calloutData.cncf_id = reqInfo.getRequestId();
        calloutData.cncf_source = URL.getSalesforceBaseUrl().toExternalForm(); //'https://collect-hub.lightning.force.com/';
        calloutData.cncf_type = eventType.replace('_','.');
        calloutData.cncf_datacontenttype = 'application/json';  
        calloutData.cncf_time = Datetime.now();
        //calloutData.cncf_subject ='Tasks'; //this needs to be more dynamic
        //build the payload by looping through the mappings and setting the fields returned from the query
        for(OutboundMessageVars request : requests){
            System.debug('for request: ' + request);
            Map<String,Object> dataEl = buildPayload(mTypeMapping.Message_Type_Mappings__r, request, recordMap.get(request.recordId));
            //pass the payload on to a method that will call the service and return the body of the html call
            system.debug('data el ' + dataEl);
            calloutData.cncf_data = dataEl;
            calloutData.cncf_subject = dataEl.get('cncf_sfaccountid').toString();         
        }
        
        //system.debug('data el ' + calloutData);
        
        result.response = callHTTP(calloutData);
        System.debug('for response: ' + result.response);
            
        results.add(result);
        
        return results;

    }
    
    private static Map<String,Object> buildPayload(List<Message_Type_Mapping__mdt> mappings, OutboundMessageVars request, sObject theRecord){
    		
            Map<String,Object> theData = New Map<String,Object>();
        
            //create the CNCFPayloadCollection Data record by looping through the records
            for(Message_Type_Mapping__mdt mapping : mappings){
                system.debug(mapping.Salesforce_API_Name__c + ' ' + IntegrationUtils.extractedFieldValue(theRecord,mapping.Salesforce_API_Name__c));
                String payloadData = (IntegrationUtils.extractedFieldValue(theRecord,mapping.Salesforce_API_Name__c) != null) ? IntegrationUtils.extractedFieldValue(theRecord, mapping.Salesforce_API_Name__c) : '';
                theData.put('cncf_' + mapping.External_Field_Name__c, payloadData);        	
            }
            
            
        
        	return theData;
             	   
    }
    
    private static Message_Type__mdt getTypeMapping(String eventType){
		return [Select Id, MasterLabel, DeveloperName, (Select Id,External_Field_Name__c,Salesforce_API_Name__c,sObject_Outbound_Only__c from Message_Type_Mappings__r) from Message_Type__mdt where DeveloperName = : eventType];	    
    }
    
    public static string callHTTP(CNCFPayloadCollection calloutData){
        
        Connection_Settings__c django = Connection_Settings__c.getValues('Django');
        
        system.debug('Calling Endpoint with ' + calloutData.stringify());
        String resString = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(django.Url__c); //can move to setting
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Token ' + django.Token__c); //will move to setting
        request.setBody(calloutData.stringify());
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            system.debug(response.getBody());
            // Deserialize the JSON string into collections of primitive data types.
            //resString = response.getBody(); //JSON.deserializeUntyped()
            resString = 'success';
            if(eventTypeFinal == 'com_collective_onboarding_fee_status'){
                updateOnboardingFee();
            }
        }else if (response.getStatusCode() == 400){
            resString = 'error ' + response.getStatusCode();
            //throw new error
        }
        return resString;
    }
    
    @AuraEnabled()
    public static String callFlow(String opportunityId){
    
        finalOpportunityId = opportunityId;
       	List<OutboundMessageVars> otbMessageVars = new List<OutboundMessageVars>();
        
        OutboundMessageVars newOtbMessageVar = new OutboundMessageVars();
        newOtbMessageVar.recordId = opportunityId;
        newOtbMessageVar.eventType = 'com_collective_onboarding_fee_status';
        eventTypeFinal = 'com_collective_onboarding_fee_status';   
        
        otbMessageVars.add(newOtbMessageVar);

       	processOutboundMessage(otbMessageVars); 
        
        return responseRequest;
    }   
    
    public static void updateOnboardingFee(){
        Opportunity opp = [Select Id, Name, Onboarding_Fee_Status__c from Opportunity where Id = : finalOpportunityId limit 1];
        if (opp != null){
            if(opp.Onboarding_Fee_Status__c == 'Waived'){
                opp.Onboarding_Fee_Status__c = 'Included';                
                responseRequest = 'Add Fee request is being processed';
            }
            else if(opp.Onboarding_Fee_Status__c == '' || opp.Onboarding_Fee_Status__c == null || opp.Onboarding_Fee_Status__c == 'Included' || opp.Onboarding_Fee_Status__c == 'Included Requested'){
                opp.Onboarding_Fee_Status__c = 'Waived';
                responseRequest = 'Waive request is being processed';
            }            
            
            update opp;
        }
    }        
    
    
    //input details that comes to apex from flow
    public class OutboundMessageVars{
    
        @InvocableVariable
        public Id recordId;
        
        @InvocableVariable
        public String eventType;
        
        @InvocableVariable
        public String eventReplayId;
        
    }
    
    //response for porcessed records
    public class OutboundMessageResult {
        
    @InvocableVariable
    public String response;

  }  

}