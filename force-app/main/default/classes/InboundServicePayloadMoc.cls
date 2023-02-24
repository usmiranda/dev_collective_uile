public class InboundServicePayloadMoc {

    public static string buildPayload(String eventType, String actId, String contId, String opptyId){
    
        CNCFPayload payload = New CNCFPayload(); 
        payload.cncf_id = '3d041212-758c-4786-acb4-61e5f738a414';
        payload.cncf_source = 'https://collective-backend-dev.herokuapp.com';
        payload.cncf_specversion = '1.0';
        payload.cncf_datacontenttype = 'application/json';
        payload.cncf_time = Datetime.now();
        payload.cncf_type = eventType; //com.collective.member.payment.first",'+
        payload.cncf_subject = 'testing@tester.com';
        payload.cncf_data.cncf_id = '99';
        payload.cncf_data.cncf_firstpayment = '2019-10-30T13:01:59-07:00';
        payload.cncf_data.cncf_sfaccountid = (actId != null) ? actId : '';
        payload.cncf_data.cncf_sfcontactid = (contId != null) ? contId : '';
        payload.cncf_data.cncf_sfopportunityid = (opptyId != null) ? opptyId : '';
        payload.cncf_data.cncf_status = 'OFF';
        payload.cncf_data.cncf_email = 'testing@tester.com';  
        payload.cncf_data.cncf_fullname = 'Test Testerson'; 
        payload.cncf_data.cncf_businessname = 'Testingnation';
        payload.cncf_data.cncf_dropbox_path = '/Dev Hyke/Test Path';
        payload.cncf_data.cncf_paymentamount = '199.00';
        
        system.debug(payload.stringify());
        return payload.stringify();
    
    }
}