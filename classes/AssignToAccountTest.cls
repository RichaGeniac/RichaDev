@istest
private class AssignToAccountTest{

    public static testMethod void CreateLeadAndGeniacUser(){
    
        //Create Lead:
        Lead L = new Lead(Company='Test',FirstName='Test',LastName='Test',Email='test@test.com');
        insert L;
    
        //Update Lead:
        L.Create_User__c = true;
        update L;
        
        //Convert Lead:
        Database.LeadConvert Lc = new database.LeadConvert();
        Lc.setLeadId(L.id);
        
    }

}