import { LightningElement, api} from 'lwc';
import InvokeSignupLinkEndpoint from "@salesforce/apex/GenerateNewSignupLinkCallout.InvokeNewSignupLinkEndpoint";

export default class LwcRegenerateSignupLink extends LightningElement {
    @api recordId;
    strUrl;
    errorMsf;
    boolResponseOk = false;
    progressStatus = false;
    handleClick(){
        this.progressStatus = true;
        InvokeSignupLinkEndpoint({memberId: this.recordId}).then(response => {            
            this.strUrl = JSON.parse(response).frontend_url;
            this.errorMsf = JSON.parse(response).error;
            this.progressStatus = false;
            if(this.errorMsf){
                this.boolResponseOk = false;
            } else{
                this.boolResponseOk = true;
            }
            
        }).catch(error => {
            this.strUrl = error.body.message;
            console.log('Error: ' +error.body.message);
        });
    }

}