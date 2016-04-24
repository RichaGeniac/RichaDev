/**
 * Created by richasharma on 16/02/2016.
 */
@isTest
private class createNewGUser_test {

    public static testMethod void newGUserTest()
    {
        test.startTest();

        // As the trigger runs on the creation of an employee record
        
        // Create an account as use its Id for this employee's companyId
        
        Account acc = new Account();
        acc.Name = 'Test Company for test class';
        acc.Type = 'Customer';
        acc.Industry = 'Chemicals';
        acc.Nature_of_Business__c = 'Test';
        acc.NumberOfEmployees = 5;
        
        insert acc;
        
        Id cId; 
        cId = acc.Id;

    
        Employee__c emp = new Employee__c();

        emp.Name = 'Test for trigger';
        emp.company__c = cId;
        emp.FirstName__c = 'TestFirstName';
        emp.LastName__c = 'TestLastName';
        emp.Email__c = 'test123@gmail.com';
        emp.Status__c = 'Active';
        insert emp;


        Employee__c emp1 = new Employee__c();

        emp1.Name = 'Test for trigger1';
        emp1.company__c = cId;
        emp1.FirstName__c = 'TestFirstName1';
        emp1.LastName__c = 'TestLastName1';
        emp1.Email__c = 'test1234@gmail.com';
        emp1.Status__c = 'Active';
        emp1.isFromHRPortal__c = true;
        insert emp1;
        
        test.stopTest();
    }


}