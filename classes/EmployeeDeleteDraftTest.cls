@isTest
private class EmployeeDeleteDraftTest{

    public static testMethod void InsertDraftEmployeeTest(){
    
        Account A = new Account(Name='Test');
        insert A;
        
        // Richa added mandatory fields in employee object - 14-04-2016
        Employee__c E = new Employee__c(Company__c=A.id,Name='Test', firstName__c = 'test first name', lastName__c = 'test last name',Draft__c=true, Delete_record__c=true);
        insert E;
        
        E.Delete_record__c = true;
        update E;
    
    }

}