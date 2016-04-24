@isTest
private class autoCreateUserTest{

    public static testMethod void InsertAccountContactUserTest(){
    
        Account A = new Account(Name='Test');
        insert A;
        
        Contact C = new Contact(AccountId=A.Id,FirstName='Test',LastName='Test',Email='test@test.com',Create_User__c=true);
        insert C;
        //this insert should trigger the auto Geniac User creation!
    
    }

}