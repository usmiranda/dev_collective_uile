trigger noteTrigger on Note (after insert) {

    for (Note note : trigger.new){
	
        ContentNote cn = new ContentNote();
    	cn.Title = note.Title;
    	cn.Content = Blob.valueOf(note.Body);
        insert cn;

	    ContentDocumentLink cdl = new ContentDocumentLink();
    	cdl.LinkedEntityId = note.ParentId;
	    cdl.ContentDocumentId = cn.Id;
        insert cdl;
    }

}