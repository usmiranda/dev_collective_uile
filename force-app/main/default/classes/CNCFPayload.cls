public class CNCFPayload {
    
    Public String cncf_id;
   	Public String cncf_source;
    public String cncf_specversion;
    public String cncf_datacontenttype;
    public Datetime cncf_time;
    public String cncf_type;
    public String cncf_subject;
    public Data cncf_data;
    
    public Class Data {
    	public String cncf_id;
        public String cncf_firstpayment;
        public String cncf_sfaccountid;
        public String cncf_sfcontactid;
        public String cncf_sfopportunityid;
        public String cncf_status;
        public String cncf_email;  
        public String cncf_fullname; 
        public String cncf_businessname;
        public String cncf_street;
        public String cncf_city;
        public String cncf_state;
        public String cncf_postal;
        public String cncf_dropbox_path;
        public String cncf_paymentamount;
        
        
        public Data(){
            cncf_id = '';
            cncf_firstpayment= '';
            cncf_sfaccountid = '';
            cncf_sfcontactid = '';
            cncf_sfopportunityid = '';
            cncf_status = '';
            cncf_email = '';  
            cncf_fullname = '';
            cncf_businessname = '';
            cncf_city ='';
            cncf_dropbox_path = '';
            cncf_paymentamount = '';             
        }
        
    }

    public CNCFPayload(){
    	this.cncf_data = New CNCFPayload.Data();    
    }
    
    public String stringify(){
        return JSON.serialize(this).remove('cncf_');
    } 
    
}