import { LightningElement, api} from 'lwc';
import InvokeDropboxURL from "@salesforce/apex/DropboxFileURLCallout.InvokeDropboxURL";

export default class helloW extends LightningElement {
    @api recordId;
    strUrl;
    handleClick(){

        InvokeDropboxURL({fileId: this.recordId}).then(response => {
            this.strUrl = JSON.parse(response).link;
            window.open(this.strUrl, "_blank");
        }).catch(error => {
            this.strUrl = error.body.message;
            console.log('Error: ' +error.body.message);
        });
    }
}