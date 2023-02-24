public class CNCFPayloadCollection {
    
    Public String cncf_id;
   	Public String cncf_source;
    public String cncf_specversion;
    public String cncf_datacontenttype;
    public DateTime cncf_time;
    public String cncf_type;
    public String cncf_subject;
    public Map<String, Object> cncf_data;

    public CNCFPayloadCollection(){
        
    	this.cncf_data = New Map<String, Object>();  
        this.cncf_specversion = '1.0';
        
    }
    
    public String stringify(){
        return JSON.serialize(this).remove('cncf_');
    } 
    
}