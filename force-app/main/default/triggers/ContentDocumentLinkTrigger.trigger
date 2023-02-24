trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
    if(trigger.isInsert && trigger.isBefore){
    	ContentDocumentLinkHandler.shareNotesWithEveryone(trigger.New);
    }
}