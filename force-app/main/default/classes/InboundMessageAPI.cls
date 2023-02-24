@RestResource(urlMapping='/InboundMessage/*')
global with sharing class InboundMessageAPI {

    Public Static String RESPONSE_STRING = 'Ok';
    
	@HttpPost
    global static String doPost() {
    
        //Returns the RestRequest object for our Apex REST method.  
         RestRequest request = RestContext.request;  
         //Returns the RestResponse for our Apex REST method.  
         RestResponse response = RestContext.response;  
         //Access the request body with input data coming in the JSON format  
         String payload = request.requestBody.toString().trim();  
         //Deserializes the input JSON string into an GoCardless_Event__c object 
     
        //Parse Payload
        Map<String, Object> parsedPayload = InboundMessageUtils.parsePayload(payload);
        system.debug('parsedPayload: ' + parsedPayload);
        //parse data
        Map<String, Object> parsedData = (Map<String, Object>)parsedPayload.get('data');
        system.debug('parsedData: ' + parsedData);
        //Get Event Type and repalce the dot notation with underscores
        String eventType = (String)parsedPayload.get('type');
        system.debug('eventType: ' + eventType);
        eventType = eventType.replace('.','_');
                
        try{
            //get Message Type and Message Type Mapping based on Event Type
            Message_Type__mdt mTypeMapping = [Select Id, MasterLabel, DeveloperName, (Select Id,External_Field_Name__c,	Salesforce_API_Name__c from Message_Type_Mappings__r) from Message_Type__mdt where DeveloperName = : eventType];
            system.debug('mTypeMapping: ' + mTypeMapping);            
            //get the describe info ont he platform event Inbound_Message__eyes
            SObjectType objToken = Schema.getGlobalDescribe().get('Inbound_Message__e'); 
            DescribeSObjectResult objDef = objToken.getDescribe();
            Map<String, SObjectField> inboundMessagefields = objDef.fields.getMap();
            //Create a New Platform event with the type set to the new type and the fields set based on the Type Mappings returned
            Inbound_Message__e newInboundMessage = New Inbound_Message__e(Type__c = eventType);
            for(Message_Type_Mapping__mdt mapping : mTypeMapping.Message_Type_Mappings__r){
               
                if(inboundMessagefields.containsKey(mapping.Salesforce_API_Name__c)){
                    //need to cast based on display token
                    switch on inboundMessagefields.get(mapping.Salesforce_API_Name__c).getDescribe().getType() {
                        when DATE {	
                            String dateTimeString = (String)parsedData.get(mapping.External_Field_Name__c);    
                            String dateString = dateTimeString.split('T')[0];
                            Date theDate = date.valueOf(dateString);
                            newInboundMessage.put(mapping.Salesforce_API_Name__c, theDate);  
                        }	
                        when TEXTAREA {
                            newInboundMessage.put(mapping.Salesforce_API_Name__c, (String)parsedData.get(mapping.External_Field_Name__c));  
                        }
                        when STRING {
                            newInboundMessage.put(mapping.Salesforce_API_Name__c, (String)parsedData.get(mapping.External_Field_Name__c));  
                        }
                        when INTEGER {	
                            newInboundMessage.put(mapping.Salesforce_API_Name__c, (Integer)parsedData.get(mapping.External_Field_Name__c));  
                        }
                        when DOUBLE {	
                            String amountString = (String)parsedData.get(mapping.External_Field_Name__c);    
                            Double theAmount = double.valueOf(amountString);
                            newInboundMessage.put(mapping.Salesforce_API_Name__c, theAmount);  
                        }
                           
                    }
                      
                }    
            }
            system.debug(loggingLevel.INFO, 'newInboundMessage ' + newInboundMessage);
            //publish new platform event
            Database.SaveResult result = EventBus.publish(newInboundMessage);
            system.debug(loggingLevel.INFO, result);            
        } catch(Exception e){
            RESPONSE_STRING = e.getMessage();
        }

        return RESPONSE_STRING;
        
    }    
}