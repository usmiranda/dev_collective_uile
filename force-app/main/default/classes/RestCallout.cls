public class RestCallout {

    public static Map<String, Object> callService(String requestURI, String requestBody, String calloutMethod, Map<String,String> HeaderInfo){
        Map<String, Object> parsedResponse;
        
        String accessToken;
        
        HttpRequest req = new HttpRequest();

        req.setEndpoint(requestURI);

        req.setMethod(calloutMethod);

        req.setTimeout(60*100);

        for(String h : HeaderInfo.keySet()){
            req.setHeader(h, HeaderInfo.get(h));       
        }
        
        req.setBody(requestBody);
        
        Http h = new Http();

        String resp;

        HttpResponse res = h.send(req);

        resp = res.getBody();
        system.debug(resp); 
        parsedResponse = InboundMessageUtils.parsePayload(resp);
        
        Return parsedResponse;
    }
}