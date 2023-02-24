@isTest 
public class GenerateNewSignupLinkCallout_Test {
    Private Static Final String ACCOUNT_NAME = 'Test Acc';
    
    private class MockOk implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('OK');
            res.setStatusCode(201);
            res.setBody('{"email": "ewewewe@collective.com","frontend_url": "https://collective.heroku.com/signup-link/eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9","backend_url":"https://collective.com/","token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9"}');
            return res;
        }
    }
    
    private class MockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatus('Bad Request');
            res.setStatusCode(400);
            res.setBody('{"email": ["SignupLink with this email already exists."]}');
            return res;
        }
    }
    
    @testSetup static void setupData() {
        
        Account testAccount = New Account(Name = ACCOUNT_NAME, State_of_Business__c = 'California', Original_Entity_Type__c = 'SP -> SC', Tax_Calc_Discount_Code__c = 'ABCDEF0', Tax_Calculator_ID__c = '123456');
        insert testAccount;                
        
        Contact testContact = New Contact(AccountId = testAccount.Id, FirstName = 'Test', LastName = 'Account', Email = 'testAccount@testing.net', Secondary_Email__c = 'testAccount1234@testing.net', Profession__c = 'Dev', Plan__c = 'SP -> SC');
        insert testContact;
        
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE AccountId =: testAccount.Id LIMIT 1];     
        testOpportunity.Plan__c = Opportunity.Plan__c.getDescribe().getPicklistValues()[0].getValue();
        testOpportunity.LeadSource = Opportunity.LeadSource.getDescribe().getPicklistValues()[0].getValue();
        update testOpportunity;                  
        
        Connection_Settings__c cs = new Connection_Settings__c();
        cs.Name = 'AcquisitionFormRequest';
        cs.url__c = 'https://somefakeurl.net';
        cs.Token__c = '432kr32jhk3k2j432kjh4';        
        insert cs;            
       
    }    
    
    @isTest static void InvokeNewSignupLinkEndpoint() {

        //Run the Test
        Test.startTest();
        
        Account acct = [SELECT Id, Name, Tax_Calc_Discount_Code__c, State_of_Business__c, Tax_Calculator_ID__c FROM Account WHERE Name=: ACCOUNT_NAME LIMIT 1];
        System.debug('acct: ' + acct);
        Opportunity oppt = [SELECT Id, Plan__c, LeadSource FROM Opportunity WHERE AccountId =: acct.Id LIMIT 1];
        System.debug('oppt: ' + oppt);
        Contact contc = [SELECT Id, FirstName, LastName, Email, Profession__c FROM Contact WHERE AccountId =: acct.Id LIMIT 1];
        System.debug('contc: ' + contc);
        
        AcquisitionFormRequestBody.acquisitionFormClaims claimsData = new AcquisitionFormRequestBody.acquisitionFormClaims();      
        claimsData.AssignedToID = UserInfo.getUserId();
        claimsData.AssignedToName = UserInfo.getName();
        claimsData.DiscountCode = acct.Tax_Calc_Discount_Code__c;
        claimsData.EntityType = oppt.Plan__c;
        claimsData.LeadSource = oppt.LeadSource;
        claimsData.MemberFirstName = contc.FirstName;
        claimsData.MemberLastName = contc.LastName;
        claimsData.PrimaryEmailAddress = contc.Email;
        claimsData.Profession = contc.Profession__c;
        claimsData.SFDCaccountID = acct.Id;
        claimsData.SFDCcontactID = contc.Id;
        claimsData.SFDCPrimaryOppID = oppt.Id;
        claimsData.State = acct.State_of_Business__c;
        claimsData.TaxCalcID = acct.Tax_Calculator_ID__c;
        List<AcquisitionFormRequestBody.acquisitionFormClaims> listClaims = new List<AcquisitionFormRequestBody.acquisitionFormClaims>();
        listClaims.Add(claimsData);     
                        
		Test.setMock(HttpCalloutMock.class, new MockOk());
        String onboardingUrl;        
        onboardingUrl = GenerateNewSignupLinkCallout.InvokeNewSignupLinkEndpoint(oppt.Id);
        System.debug('onboardingUrl: ' + onboardingUrl);
        System.assertNotEquals('SignupLink with this email already exists', onboardingUrl);
        Test.stopTest();		
    }
    
    @isTest static void InvokeNewSignupLinkEndpointError() {
        //Run the Test
        Test.startTest();

        Account acct = [SELECT Id, Name, Tax_Calc_Discount_Code__c, State_of_Business__c, Tax_Calculator_ID__c FROM Account WHERE Name=: ACCOUNT_NAME LIMIT 1];
        System.debug('acct: ' + acct);
        Opportunity oppt = [SELECT Id, Plan__c, LeadSource FROM Opportunity WHERE AccountId =: acct.Id LIMIT 1];
        System.debug('oppt: ' + oppt);
        Contact contc = [SELECT Id, FirstName, LastName, Email, Profession__c FROM Contact WHERE AccountId =: acct.Id LIMIT 1];
        System.debug('contc: ' + contc);
                                
        String onboardingUrl;        
        Test.setMock(HttpCalloutMock.class, new MockError());
        onboardingUrl = GenerateNewSignupLinkCallout.InvokeNewSignupLinkEndpoint(oppt.Id);
        System.debug('onboardingUrl TEST: ' + onboardingUrl);
        System.assertEquals('SignupLink with this email already exists', onboardingUrl);
        Test.stopTest();	        
    }
}