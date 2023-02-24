public class ContentDocumentLinkHandler {
    
    public static void shareNotesWithEveryone(List<ContentDocumentLink> triggerNew){
        
        Set<Id> ContentDocumentIds = New Set<Id>();
        for(ContentDocumentLink cdl : triggerNew){
            ContentDocumentIds.add(cdl.ContentDocumentId);
        }
        
        Map<Id,ContentDocument> cdMap = New Map<Id, ContentDocument>([Select Id, FileType from ContentDocument where id in : ContentDocumentIds AND FileType = 'SNOTE']);
        
        for(ContentDocumentLink cdl : triggerNew){
            if(cdl.shareType == 'V' && cdMap!= null && cdMap.containsKey(cdl.ContentDocumentId) && cdl.LinkedEntityId.getSObjectType() != Schema.User.SObjectType){
                cdl.shareType = 'I';
            }
        }
    }
    
}