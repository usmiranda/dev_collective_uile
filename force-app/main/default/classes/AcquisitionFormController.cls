public class AcquisitionFormController {
	@invocablemethod(Label='Acquisition Form Data' description='Callout to BE' callout=true)
    public static List<String> sendAcquisitionFormData(AcquisitionFormRequestBody.acquisitionFormClaims[] acquisitionFormData){
        List<String> listReturnCallout = new List<String>();
                
        AcquisitionFormRequestBody.acquisitionFormClaims claims = new AcquisitionFormRequestBody.acquisitionFormClaims();
        AcquisitionFormCallout.AcquisitionFormResponseBody formatResponse = new AcquisitionFormCallout.AcquisitionFormResponseBody();        
        formatResponse = AcquisitionFormCallout.InvokeAcquisitionFormAPI(acquisitionFormData);  
        
        return new List<String> {formatResponse.frontend_url};
    }
}