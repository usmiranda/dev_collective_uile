public with sharing class IntegrationUtils {
    
    public static string extractedFieldValue(sObject sb, string fieldAPIName){
        string fvalue='';
        if(fieldAPIName.contains('.')){
            List<string> splitedFields = fieldAPIName.split('\\.');
            try{
                for(integer i=0;i<splitedFields.size()-1;i++){
                    sb=sb.getSobject(splitedFields[i]);   
                }
                fvalue = string.valueof(sb.get(splitedFields[splitedFields.size()-1]));
            }catch(exception ex){
                system.debug('******exception while fetching fieldValues as relationship '+fieldAPIName+'  value is blank.'+ex.getmessage()); 
                fvalue='';
            }
            
        }else if(sb.get(fieldAPIName)!=null){
            fvalue = string.valueOf(sb.get(fieldAPIName));
        }
        return fvalue;
    }
    
}