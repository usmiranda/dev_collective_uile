@isTest
public with sharing class sObjectUtils_Test {
    @isTest static void testgetPicklistValues() {
        
        List<String> pickValues = sObjectUtils.getPicklistValues('Account', 'Type');
        system.assert(!pickValues.isEmpty());
      	
    }
}