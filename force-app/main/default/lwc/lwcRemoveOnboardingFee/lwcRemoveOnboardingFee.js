import { LightningElement, api} from 'lwc';
import InvokeOtbMessageEndpoint from "@salesforce/apex/OutboundMessage.callFlow";

export default class FlowInLwc extends LightningElement {
    @api recordId;
    boolResponseOk = false;
    responseRequest;
    strUrl;
        // do something when flow status changed
    handleClick(){
        InvokeOtbMessageEndpoint({opportunityId: this.recordId}).then(result => {            
            this.boolResponseOk = true;
            this.responseRequest = result;
            
        }).catch(error => {
            this.responseRequest = error;
        });
    }
}