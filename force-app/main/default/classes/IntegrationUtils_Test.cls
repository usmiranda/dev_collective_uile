@isTest
public with sharing class IntegrationUtils_Test {
    
    Private Static Final String ACCOUNT_NAME = 'Test Account';
    Private Static Final String eventType = 'com.collective.member.payment.first';
    Private Static Final String STAGE_NAME = 'Take Intro Call';
    Private Static Final String TASK_STATUS = 'Completed';
    Private Static Final String OUTCOME = 'Follow Up'; //Send Onboarding Email
    Private Static Final String PLAN = 'SP -> SC';
    Private Static Final String CONTACT_EMAIL = 'testAccount@testing.net';
    Private Static Final String ACCOUNT_NAME_FIELD = 'Account.Name';
    
    @testSetup static void setupData() {

        //create our test data
        Account testAccount = New Account(name = ACCOUNT_NAME);
        insert testAccount;
        
        Contact testContact = New Contact(AccountId = testAccount.Id, FirstName = 'Test', LastName = 'Account', Email = CONTACT_EMAIL);
        insert testContact;
        
        Connection_Settings__c cs = new Connection_Settings__c();
        cs.Name = 'Django';
        cs.url__c = 'https://somefakeurl.net';
		cs.Token__c = '432kr32jhk3k2j432kjh4';

     	insert cs;
            
    }

    @isTest static void extractedFieldValue() {
                
        Contact testContact = [select Id, Account.Name from Contact where Email = : CONTACT_EMAIL limit 1];
        String dataValue = IntegrationUtils.extractedFieldValue(testContact, ACCOUNT_NAME_FIELD);
        system.assert(dataValue == ACCOUNT_NAME);

    }

}