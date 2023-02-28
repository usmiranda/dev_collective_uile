public class DropboxFileURLRequestBody {
    public String file_id;

    public String stringify(){
        return JSON.serialize(this);
    }   
}