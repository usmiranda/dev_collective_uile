public  class sObjectUtils {

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String sObjectName, string fieldApiName) {
        List<String> retValues = New List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(sObjectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            retValues.add(pickListVal.getValue());
        }  
        return retValues;     
    }

    class fieldType{


    }
}