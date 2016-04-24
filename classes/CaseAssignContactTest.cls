@isTest
private class CaseAssignContactTest{

    public static testMethod void test1(){

        Account accTeste = new Account();
        accTeste.Name = 'TestAccount';
        insert accTeste;
        
        Contact contactTeste = new Contact();
        contactTeste.FirstName = 'TestContact';
        contactTeste.LastName = 'TestContact';
        contactTeste.Email = 'test@email.com';
        contactTeste.Title = 'Test';
        try{Account a = [select id from Account where Name = 'TestAccount' limit 1];
        contactTeste.AccountID = a.id;
        }catch (Exception ex){}
        insert contactTeste; 

        Case caseTeste = new Case();
        caseTeste.Subject = 'TestCase';
        caseTeste.Description = 'TestDescription';
        caseTeste.SuppliedEmail = 'test@email.com';
        insert caseTeste;

    }
}