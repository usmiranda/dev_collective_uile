public without sharing class DropboxFileURLCallout {
    
    @AuraEnabled
    Public static String InvokeDropboxURL(String fileId){
        DropboxFile__x dpFile;
        if(fileId.startsWith('id')){
            dpFile = null;
        }            
        else{
         	dpFile = [Select file_id__c from DropboxFile__x where id =: fileId];   
        }                             
        System.debug('dpFile: ' + dpFile);
        String id_path = null;
        if (dpFile != null){
            id_path = dpFile.file_id__c;
        } else{
            id_path = fileId;
        }
        System.debug('id_path: ' + id_path);
        Map<String, Object> newJsonData = new Map<String, Object>();
        Connection_Settings__c dropBoxAuth = Connection_Settings__c.getValues('DropboxFileUrl');
        
        Http h = new Http();
        String strResponse = null;
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(dropBoxAuth.Url__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');        
        req.setHeader('Authorization', 'Token ' + dropBoxAuth.Token__c);
        DropboxFileURLRequestBody dropboxFileFullRequestBody = new DropboxFileURLRequestBody();
        dropboxFileFullRequestBody.file_id = id_path;
        req.setBody(dropboxFileFullRequestBody.stringify());   
        //req.setBody('id:zroDv_tp_GAAAAAAAABVGQ');
        System.debug('request final: ' + req);
        
        try{
        	HttpResponse res = h.send(req);
            System.debug('response final: ' + res.getBody());
            if(res.getStatusCode() == 200){
                strResponse = res.getBody();
            } else {
                strResponse = null;
            }
        } catch(Exception ex){
            throw ex;
        }
        
        if(!String.isBlank(strResponse)){
            return strResponse;
        } else {
            return null;
        }
        
    } 
    
}