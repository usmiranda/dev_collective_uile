import { LightningElement, api, wire } from 'lwc';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import DB_URL_FIELD from '@salesforce/schema/Account.Dropbox_Folder__c';

export default class DropboxLink extends LightningElement {
    objectApiName = ACCOUNT_OBJECT;
    
    @api recordId;
    @api objectApiName;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [DB_URL_FIELD]
      })
      record;

      get partialURL() {
        let urlLink = this.record.data ? getFieldValue(this.record.data, DB_URL_FIELD ) : "";
        return urlLink       
      }

      get urlField() {
        let urlLink = this.record.data ? getFieldValue(this.record.data, DB_URL_FIELD ) : "";
        return 'https://www.dropbox.com/home/Hyke%20Dropbox' + urlLink;
      }
}