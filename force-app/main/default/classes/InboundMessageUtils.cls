public class InboundMessageUtils {
	
    public static Map<String, Object> parsePayload(String payload){
        system.debug('payload ' + payload);
        Map<String, Object> response = New Map<String, Object>();
        response = (Map<String, Object>) JSON.deserializeUntyped(payload);
		system.debug(response.get('data'));
        return response;
    }
    
   
}