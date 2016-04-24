trigger AssignToAccount on GENIAC_User__c (after insert) {

    //When a GENIAC User is created via Lead conversion it should be assigned to the respective Account
    FOR( GENIAC_User__c GenU : Trigger.new ){
        IF( GenU.Created_from_Lead_conversion__c == true &&
            GenU.Conversion_Account_ID__c != null && GenU.Conversion_Account_ID__c !='' ){
            
            Account Acc = new Account();
            Acc.Id = GenU.Conversion_Account_ID__c;
            Acc.GENIAC_User__c = GenU.Id;
            update Acc;
            
        }
    }
}