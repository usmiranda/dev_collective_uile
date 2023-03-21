@isTest
public class InboundMessageAPI_Test {
    
    Private Static Final String ACCOUNT_NAME = 'Test Account';
    Private Static Final String eventType_firstPayment = 'com.collective.member.payment.first';
	Private Static Final String eventType_folder = 'com.collective.member.folderupdated';
    
    @testSetup static void setupData() {

        //create our test data
        //Account testAccount = New Account(name = ACCOUNT_NAME);
        //insert testAccount;
        
        Contact testContact = New Contact(FirstName = 'Test', LastName = 'Account', Email = 'testAccount'+Math.rint(11) +'@testing.net',Intro_Call_Taker_Email__c = [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1].Email,Calendly_Intro_Call_Date__c = Date.today());
        insert testContact;
        system.debug('testContact: ' + testContact);
            
    }
    
    @isTest static void testFirstPaymentDate() {
        
        //get the test account
        Account testAccount = [Select Id, Name from Account where Name = : ACCOUNT_NAME];
        system.debug('testAccount: ' + testAccount);
        //get the test opportunity
        Opportunity testOppty = [Select Id from Opportunity where AccountId = : testAccount.Id];
        system.debug('testAccount: ' + testAccount);

        
        String firstPaymentPayload = InboundServicePayloadMoc.buildPayload(eventType_firstPayment, (String)testAccount.Id, '', (String)testOppty.Id);
        
        //Parse Payload
        Map<String, Object> parsedPayload = InboundMessageUtils.parsePayload(firstPaymentPayload);
        
        //parse data
        Map<String, Object> parsedData = (Map<String, Object>)parsedPayload.get('data');
        
        //Get Event Type
        String eventType = (String)parsedPayload.get('type');
        
        //Run the Test
        Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
        
            request.requestUri ='/services/apexrest/InboundMessage';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json'); 
            request.requestBody = Blob.valueof(firstPaymentPayload);
            RestContext.request = request;
            RestContext.response = response;
            InboundMessageAPI.doPost();  
        Test.stopTest();
        
        //Get the updated Opportunity
        Opportunity testOpptyUdpate = [Select Id,First_Payment_Date__c, Amount from Opportunity where AccountId = : testAccount.Id limit 1];
        system.debug('testOpptyUdpate: ' + testOpptyUdpate);
        String dateTimeString = (String)parsedData.get('firstpayment');   
        String dateString = dateTimeString.split('T')[0];
        Date theDate = date.valueOf(dateString);
        
        //Assert that the date on the Opportunity matches the payload
        //Assert.equals(theDate,testOpptyUdpate.First_Payment_Date__c,'Opp Date matches the payload');

       // String amountString = (String)parsedData.get('paymentamount');   
        //Double theAmount = double.valueOf(amountString); 

        //Assert that the Amount on the Opportunity matches the payload
       // Assert.equals(theAmount,testOpptyUdpate.Amount,'Opp Amount is correct');
    }
    
    @isTest static void testDropboxPath() {
        
        //get the test account
        Account testAccount = [Select Id, Name from Account where Name = : ACCOUNT_NAME];
        //get the test opportunity
        Opportunity testOppty = [Select Id from Opportunity where AccountId = : testAccount.Id];
        
        
        String dropboxUpdateLoad = InboundServicePayloadMoc.buildPayload(eventType_folder, (String)testAccount.Id, '', (String)testOppty.Id);
        
        //Parse Payload
        Map<String, Object> parsedPayload = InboundMessageUtils.parsePayload(dropboxUpdateLoad);
        
        //parse data
        Map<String, Object> parsedData = (Map<String, Object>)parsedPayload.get('data');
        system.debug('parsedData ' + parsedData);
        //Get Event Type
        String eventType = (String)parsedPayload.get('type');
        
        //Run the Test
        Test.startTest();
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
        
            request.requestUri ='/services/apexrest/InboundMessage';
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json'); 
            request.requestBody = Blob.valueof(dropboxUpdateLoad);
            RestContext.request = request;
            RestContext.response = response;
            InboundMessageAPI.doPost();  
        Test.stopTest();
        String db_folder = (String)parsedData.get('dropbox_path');   
        //Get the updated Opportunity
        Account testAccountResult = [Select Id, Name,  Dropbox_Folder__c From Account where Name = : ACCOUNT_NAME limit 1];
        
        //Assert that the date on the Opportunity matches the payload
        system.assertEquals(db_folder,testAccountResult.Dropbox_Folder__c);
    }
    
}