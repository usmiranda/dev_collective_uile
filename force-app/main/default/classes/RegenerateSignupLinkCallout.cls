public without sharing class RegenerateSignupLinkCallout {
    
    @AuraEnabled
    public static String InvokeSignupLinkEndpoint(String memberId){
        Opportunity opp = [Select id, Email__c, Signup_Link__c from Opportunity where Id =: memberId];
        Connection_Settings__c acqFormAuth = Connection_Settings__c.getValues('AcquisitionFormRequest');
        String memberEmail = opp.Email__c;
        System.debug('memberEmail: ' + memberEmail);
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(acqFormAuth.Url__c + 'regenerate/');
        req.setMethod('PATCH');
        req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');        
        req.setHeader('Authorization', 'Token ' + acqFormAuth.Token__c);      
        RegenerateSignupLinkRequestBody reqBody = new RegenerateSignupLinkRequestBody();
        reqBody.email = memberEmail;
        req.setBody(JSON.serialize(reqBody));       
        System.debug('request: ' + req);
        String strResponse = null;     
        String finalUrl = null;
        String error = null;
        
        try{
            HttpResponse res = h.send(req);
            RegenerateSignupLinkResponseBody formatResponse = new RegenerateSignupLinkResponseBody();
            System.debug('response final: ' + res.getBody());
            if(res.getStatusCode() == 200){
                formatResponse = (RegenerateSignupLinkResponseBody) JSON.deserialize(res.getBody(), RegenerateSignupLinkResponseBody.class);
                finalUrl = formatResponse.frontend_url;
                strResponse = res.getBody();
            } else {
                strResponse = res.getBody();
            }
        } catch(Exception ex){
            throw ex; 
        }
        
        if(!String.isBlank(finalUrl)){
            opp.Signup_Link__c = finalUrl;                
            update opp;            
            return strResponse;
        } else {
            return strResponse;
        }
    }
    
    public class RegenerateSignupLinkRequestBody{
        public string email;
    }    
        
    public class RegenerateSignupLinkResponseBody{
        public string email;
        public string frontend_url;
        public string backend_url;
        public string token;
    }            
}