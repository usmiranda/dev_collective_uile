import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistValues  from '@salesforce/apex/sObjectUtils.getPicklistValues'


const CLOSED = 'Closed';
const DENIED = 'Denied';
const CLOSED_CTA = 'Select Closed Status';
const MARK_COMPLETED = 'Approve'; //'Mark Status as Complete'
const SPECIAL_STATUS = 'Denied';

export default class CustomPath extends LightningElement {
  //start off with all @wire methods and dependencies
  //plus lifecycle methods
  @api recordId;
  @api sObjectName
  @api pickListField;
  sObjectType;
  @wire(getObjectInfo, { objectApiName: '$sObjectName'}) //'TransitionPlan__x' 
  objectInfo({ data, error }) {
    if(data){
        console.log('sobject');
        console.log(data);
        this.sObjectType = data.apiName;
        this.getPicklists(data.apiName);
    }else if (error) {
        console.log('error');
        console.log(error);
    }
  }

  @wire(getRecord, {
    recordId: '$recordId',
    layoutTypes : 'Full'
  })
  lead({ data, error }) {
    const leadCb = (data) => {
        console.log(data);
        console.log(data.fields[this.pickListField].value);
        this.status = data.fields[this.pickListField].value; 
        this.storedStatus = data.fields[this.pickListField].value; //.status__c
      console.log('from wire service ' + this.status + ' storedStatus ' +  this.storedStatus);
      //maybe update this for Denied
      if (this.status && this.status.includes(CLOSED)) {
        this.advanceButtonText = CLOSED_CTA;
        this.currentClosedStatus = this.status;
        this.customCloseDateSelected =
          this.currentClosedStatus === SPECIAL_STATUS;
      }
    };

    this._handleWireCallback({ data, error, cb: leadCb });
  }

  getPicklists(apiName){
    getPicklistValues({
        sObjectName: apiName,
        fieldApiName: 'status__c'
      }).then((result) => {
        console.log('status');
      console.log(result);
      const statusList = [];
      result.forEach((value) => {
        console.log('the value ' + value);
        if (!value.includes(CLOSED)) {
          statusList.push(value);
          this.visibleStatuses.push(this._getPathItemFromStatus(value));
        }
      });
      console.log('statusList');
      console.log(statusList);
      //statusList.push('Closed');
      this._statuses = statusList;
      console.log('hasData ' + this.hasData);
      //this._handleWireCallback({ data, error, cb: leadStatusCb });
    })
    .catch((error) => {
        this.error = error;
        this.contacts = undefined;
    }); 
  }

  /*
  @wire(getPicklistValues, {
    sObjectName: '$objectInfo.data.apiName',
    fieldApiName: 'status__c'
  })
  leadStatuses({ data, error }) {
      if(data){
      console.log('status');
      console.log(data);
      const statusList = [];
      data.forEach((picklistStatus) => {
        if (!picklistStatus.includes(CLOSED)) {
          statusList.push(picklistStatus.label);
        }
      });
      //statusList.push('Closed');
      this._statuses = statusList;

      //now build the visible/closed statuses
      /*data.values.forEach((status) => {
        if (status.label.includes(CLOSED)) {
          this.closedStatuses.push({
            label: status.label,
            value: status.label
          });
          if (!this.currentClosedStatus) {
            //promote the first closed value to the component
            //so that the combobox can show a sensible default
            this.currentClosedStatus = status.label;
          }
        } else {
          this.visibleStatuses.push(this._getPathItemFromStatus(status.label));
        }
      });
      //this.visibleStatuses.push(this._getPathItemFromStatus(CLOSED));
    }else if (error) {
        console.log('error');
        console.log(error);
    }
    //this._handleWireCallback({ data, error, cb: leadStatusCb });
  }*/

  renderedCallback() {
    if (!this._hasRendered && this.hasData) {
      //prevents the advance button from jumping to the side
      //as the rest of the component loads
      this.showAdvanceButton = false;
      this._hasRendered = true;
    }
    if (this.hasData) {
      //on the first render with actual data
      //we have to manually set the aria-selected value
      const current = this.visibleStatuses.find((status) =>
        this.storedStatus.includes(status.label)
      ) || { label: 'Unknown' };
      current.ariaSelected = true;
      current.class = (!current.isDenied) ? 'slds-path__item slds-is-current slds-is-active' : 'slds-path__item slds-is-current slds-is-active slds-is-lost';
      
      console.log('rerender denied? ' + current.isDenied);
      //if(current.isDenied) current.class += ' slds-is-lost';
      const currentIndex = this.visibleStatuses.indexOf(current);
      this.visibleStatuses.forEach((status, index) => {
        if (index < currentIndex && !status.label.includes('Approved')) {
          status.class = status.class.replace(
            'slds-is-incomplete',
            'slds-is-complete'
          );
        }
      });
    }
  }

  /* private fields for tracking */
  @track advanceButtonText = MARK_COMPLETED;
  @track closedStatuses = [];
  @track currentClosedStatus;
  @track customCloseDateSelected = false;
  @track dateValue;
  @track showAdvanceButton = false;
  @track showClosedOptions = false;
  @track status;
  @track storedStatus;
  @track visibleStatuses = [];

  //truly private fields
  _hasRendered = false;
  _statuses;
  _canClick = false;

  //private methods and getters
  get pathActionIconName() {
    return this.advanceButtonText === MARK_COMPLETED ? 'utility:check' : '';
  }

  get hasData() {

    console.log('hasdata storedStatus ' + this.storedStatus);
    console.log('hasdata visibleStatuses ' + this.visibleStatuses.length);
    return !!(this.storedStatus && this.visibleStatuses.length > 0);
  }

  modalSaveHandler = async (event) => {
    event.stopPropagation();
    event.preventDefault();

    const allValid = [
      ...this.template.querySelectorAll('.slds-form-element')
    ].reduce((validSoFar, formElement) => {
      formElement.reportValidity();
      return validSoFar && formElement.checkValidity();
    }, true);
    if (allValid) {
      this._toggleModal();
      await this._saveLeadAndToast();
    }
  };

  handleStatusClick(event) {
    event.stopPropagation();
    //update the stored status, but don't update the record
    //till the save button is clicked
    if(this._canClick){
        const updatedStatusName = event.target.textContent;
        this.advanceButtonText =
        updatedStatusName === this.status
            ? MARK_COMPLETED
            : 'Mark As Current Status';
        this.storedStatus = updatedStatusName;

        if (this.status !== this.storedStatus) {
        this._updateVisibleStatuses();
        }

        if (this.storedStatus === CLOSED) {
        this._advanceToClosedStatus();
        }
    }
  }

  handleClosedStatusChange(event) {
    const newClosedStatus = event.target.value;
    this.currentClosedStatus = newClosedStatus;
    this.storedStatus = newClosedStatus;
    this.customCloseDateSelected = this.storedStatus === SPECIAL_STATUS;
  }

  handleDateOnChange(event) {
    //this.dateValue = event.target.value;
  }

  async handleAdvanceButtonClick(event) {
    event.stopPropagation();

    if (
      this.status === this.storedStatus &&
      !this.storedStatus.includes(CLOSED)
    ) {
      const nextStatusIndex =
        this.visibleStatuses.findIndex(
          (visibleStatus) => visibleStatus.label === this.status
        ) + 1;
      this.storedStatus = this.visibleStatuses[nextStatusIndex].label;
      if (nextStatusIndex === this.visibleStatuses.length - 1) {
        //the last status should always be "Closed"
        //and the modal should be popped
        this._advanceToClosedStatus();
      } else {
        await this._saveLeadAndToast();
      }
    } else if (this.storedStatus.includes(CLOSED)) {
      //curses! they closed the modal
      //let's re-open it
      this._advanceToClosedStatus();
    } else {
      await this._saveLeadAndToast();
    }
  }

  //truly private methods, only called from within this file
  _advanceToClosedStatus() {
    this.advanceButtonText = CLOSED_CTA;
    this.storedStatus = this.currentClosedStatus;
    this.showClosedOptions = true;
    this._toggleModal();
  }

  _handleWireCallback = ({ data, error, cb }) => {
    if (error) console.error(error);
    else if (data) {
      cb(data);
    }
  };

  _getPathItemFromStatus(status) {
    const ariaSelected = !!this.storedStatus
      ? this.storedStatus.includes(status)
      : false;
      console.log('the check ' + !!this.status);
      console.log('the includes ' + (status.includes(DENIED)));
    const isCurrent = !!this.status ? this.status.includes(status) : false;
    const isDenied = (status.includes(DENIED)) ? true : false;; //!!this.status ? status.includes(DENIED) : false; //(status.includes(DENIED)) ? true : false;
    const classList = ['slds-path__item'];
    if (ariaSelected) {
      classList.push('slds-is-active');
    } else {
      classList.push('slds-is-incomplete');
    }
    if (isCurrent) {
      classList.push('slds-is-current');
    }
    console.log('isDenied ' + isDenied)
    
    //console.log(' statue ' + status + ' class list ' +);
    return {
      ariaSelected: false,
      class: classList.join(' '),
      label: status,
      isDenied : isDenied
    };
  }

  _toggleModal() {
    this.template.querySelector('c-modal').toggleModal();
  }

  _getLeadValueOrDefault(data, val) {
    return data ? data.fields[val].displayValue : '';
  }

  async _saveLeadAndToast() {
    let error;
    try {
      this.status = this.storedStatus;
      const recordToUpdate = {
        fields: {
          Id: this.recordId,
          Status: this.status,
          Future_Reactivation_Date__c : null
        }
      };
      /*if (this.dateValue && this.status === SPECIAL_STATUS) {
        recordToUpdate.fields.CustomDate__c = this.dateValue;
      }*/
      await updateRecord(recordToUpdate);
      this._updateVisibleStatuses();
      this.advanceButtonText = MARK_COMPLETED;
    } catch (err) {
      error = err;
      console.error(err);
    }
    //not crazy about this ternary
    //but I'm even less crazy about the 6
    //extra lines that would be necessary for
    //a second object
    this.dispatchEvent(
      new ShowToastEvent({
        title: !error ? 'Success!' : 'Record failed to save',
        variant: !error ? 'success' : 'error',
        message: !error
          ? 'Record successfully updated!'
          : `Record failed to save with message: ${JSON.stringify(error)}`
      })
    );
    //in reality, LDS errors are a lot uglier and should be handled gracefully
    //I recommend the `reduceErrors` utils function from @tsalb/lwc-utils:
    //https://github.com/tsalb/lwc-utils/blob/master/force-app/main/default/lwc/utils/utils.js
  }

  _updateVisibleStatuses() {
    //update the shown statuses based on the selection
    const newStatuses = [];
    for (let index = 0; index < this.visibleStatuses.length; index++) {
      const status = this.visibleStatuses[index];
      const pathItem = this._getPathItemFromStatus(status.label);
      if (this.status !== this.storedStatus || pathItem.label !== this.status) {
        pathItem.class = pathItem.class
          .replace('slds-is-complete', '')
          .replace('  ', ' ');
      }
      newStatuses.push(pathItem);
    }
    this.visibleStatuses = newStatuses;
  }
}