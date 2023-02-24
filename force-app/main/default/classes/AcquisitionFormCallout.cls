public class AcquisitionFormCallout {
    
    public static AcquisitionFormResponseBody InvokeAcquisitionFormAPI(AcquisitionFormRequestBody.acquisitionFormClaims[] calloutRequest){
        Connection_Settings__c acqFormAuth = Connection_Settings__c.getValues('AcquisitionFormRequest');
        
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(acqFormAuth.Url__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');        
        req.setHeader('Authorization', 'Token ' + acqFormAuth.Token__c);
        
        AcquisitionFormRequestBody.acquisitionFormClaims claims = new AcquisitionFormRequestBody.acquisitionFormClaims();
        claims = calloutRequest[0];      
        AcquisitionFormRequestBody acquisitionFullRequest = new AcquisitionFormRequestBody();
        acquisitionFullRequest.email = calloutRequest[0].PrimaryEmailAddress;
        acquisitionFullRequest.claims = claims;    
        
        req.setBody(acquisitionFullRequest.stringify());     
        
        HttpResponse res = h.send(req);
        
        AcquisitionFormResponseBody formatResponse = new AcquisitionFormResponseBody();
        if(res.getStatusCode() == 201) {
            formatResponse = (AcquisitionFormResponseBody) JSON.deserialize(res.getBody(), AcquisitionFormResponseBody.class);
        }else{
            formatResponse.frontend_url = 'SignupLink with this email already exists';
        }                
        return formatResponse;
    }
    
    public class AcquisitionFormResponseBody{
        public string email;
        public string frontend_url;
        public string backend_url;
        public string token;
    }
}