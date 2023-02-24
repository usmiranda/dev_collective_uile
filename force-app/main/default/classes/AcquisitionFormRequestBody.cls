public class AcquisitionFormRequestBody {
    public String email;
    public acquisitionFormClaims claims;
    public class acquisitionFormClaims{
        @InvocableVariable public String MemberFirstName;
        @InvocableVariable public String MemberLastName;
        @InvocableVariable public String PrimaryEmailAddress;
        @InvocableVariable public String EntityType;
        @InvocableVariable public String State;
        @InvocableVariable public String LeadSource;
        @InvocableVariable public String AssignedToID;
        @InvocableVariable public String AssignedToName;
        @InvocableVariable public String TaxCalcID;
        @InvocableVariable public String SFDCcontactID;
        @InvocableVariable public String SFDCaccountID;
        @InvocableVariable public String SFDCPrimaryOppID;
        @InvocableVariable public String DiscountCode;
        @InvocableVariable public String Profession;   
    }     
    
    public String stringify(){
        return JSON.serialize(this);
    }   
}