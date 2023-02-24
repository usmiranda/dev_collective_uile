public without sharing class GenerateNewSignupLinkCallout {
    
    @AuraEnabled 
    public static String InvokeNewSignupLinkEndpoint(String memberId){
        Opportunity opp = [Select id, Email__c, Plan__c, LeadSource, Signup_Link__c, OwnerId, AccountId from Opportunity where Id =: memberId];
        System.debug('Opportunity: ' + opp);
        Account acc = [Select id, Email__c, Name, Original_Entity_Type__c, State_of_Business__c, Primary_Contact__c, Tax_Calc_Discount_Code__c, Tax_Calculator_ID__c from Account where Id =: opp.AccountId];
        System.debug('Account: ' + acc);
        Contact cntc = [Select Id, Email, FirstName, LastName, Secondary_Email__c, Profession__c from Contact where Id =: acc.Primary_Contact__c];
        System.debug('Contact: ' + cntc);
        User usr = [Select Id, Name from User where Id =: opp.OwnerId];
        System.debug('User: ' + usr);
        Connection_Settings__c acqFormAuth = Connection_Settings__c.getValues('AcquisitionFormRequest');
        String memberEmail = opp.Email__c;
        System.debug('memberEmail: ' + memberEmail);
        Http h = new Http();
        
        
        AcquisitionFormRequestBody.acquisitionFormClaims acquisitionFormData = new AcquisitionFormRequestBody.acquisitionFormClaims();
        acquisitionFormData.MemberFirstName = cntc.FirstName;
        acquisitionFormData.MemberLastName = cntc.LastName;
        acquisitionFormData.PrimaryEmailAddress = cntc.Email;
        acquisitionFormData.EntityType = opp.Plan__c;
        acquisitionFormData.State = acc.State_of_Business__c;
        acquisitionFormData.LeadSource = opp.LeadSource;
        acquisitionFormData.AssignedToID = opp.OwnerId;
        acquisitionFormData.AssignedToName = usr.Name;
        acquisitionFormData.TaxCalcID = acc.Tax_Calculator_ID__c;
        acquisitionFormData.SFDCcontactID = cntc.Id;
        acquisitionFormData.SFDCaccountID = acc.Id;
        acquisitionFormData.SFDCPrimaryOppID = opp.Id;
        acquisitionFormData.DiscountCode = acc.Tax_Calc_Discount_Code__c;
        acquisitionFormData.Profession = cntc.Profession__c;
        System.debug('acquisitionFormData: ' + acquisitionFormData);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(acqFormAuth.Url__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');        
        req.setHeader('Authorization', 'Token ' + acqFormAuth.Token__c);   
        
        AcquisitionFormRequestBody acquisitionFullRequest = new AcquisitionFormRequestBody();
        acquisitionFullRequest.email = acquisitionFormData.PrimaryEmailAddress;
        acquisitionFullRequest.claims = acquisitionFormData;    
        System.debug('acquisitionFullRequest: ' + acquisitionFullRequest);
        req.setBody(acquisitionFullRequest.stringify());       
        System.debug('request: ' + req);
        String strResponse = null;     
        String finalUrl = null;
        String error = null;
        
        try{
            HttpResponse res = h.send(req);
            AcquisitionFormResponseBody formatResponse = new AcquisitionFormResponseBody();
            System.debug('response final: ' + res.getBody());
            if(res.getStatusCode() == 201){
                formatResponse = (AcquisitionFormResponseBody) JSON.deserialize(res.getBody(), AcquisitionFormResponseBody.class);
                finalUrl = formatResponse.frontend_url;
                strResponse = res.getBody();
            } else {
                strResponse = 'SignupLink with this email already exists';
            }
        } catch(Exception ex){
            throw ex; 
        }
        
        System.debug('strResponse: ' + strResponse);
        System.debug('finalUrl: ' + finalUrl);
        
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
        
    public class AcquisitionFormResponseBody{
        public string email;
        public string frontend_url;
        public string backend_url;
        public string token;
    }    
}