@isTest(SeeAllData = false)
private class checkEmpExistence_test {

    static testMethod void checkEmpExistencetestMethod() 
    {
        test.StartTest();
        Map<Id, Employee__c> empMap = new Map<Id, EMployee__c>();

        Account acc = new Account();
        acc.Name = 'Test Company for test class';
        acc.Type = 'Customer';
        acc.Industry = 'Chemicals';
        acc.Nature_of_Business__c = 'Test';
        acc.NumberOfEmployees = 5;
        
        insert acc;
        
        Id cId; 
        cId = acc.Id;
        
        
        
        Employee__c emp1 = new Employee__c(Name = 'Emp Name1',company__c=cId,firstName__c='Test fName1', lastName__c='Test lName1',email__c='test1@gmail.com');
        // TO DO: implement unit test
        insert emp1;
        
        
        Employee__c emp2 = new Employee__c(Name = 'Emp Name2',company__c=cId,firstName__c='Test fName2', lastName__c='Test lName2',email__c='test2@gmail.com');
        // TO DO: implement unit test
        insert emp2;
        
        Employee__c emp3 = new Employee__c(Name = 'Emp Name3',company__c=cId,firstName__c='Test fName3', lastName__c='Test lName3',email__c='test3@gmail.com');
        // TO DO: implement unit test
        insert emp3;
        
        Employee__c emp4 = new Employee__c(Name = 'Emp Name4',company__c=cId,firstName__c='Test fName4', lastName__c='Test lName4',email__c='test4@gmail.com');
        // TO DO: implement unit test
        insert emp4;
        
        empMap.put(emp1.id, emp1);
        empMap.put(emp2.id, emp2);
        empMap.put(emp2.id, emp3);
        empMap.put(emp2.id, emp4);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(emp1);

        checkEmpExistence empEx = new checkEmpExistence(empMap);
        //empEx.CheckEmpExistence(empMap);
        
        
        test.StopTest();
    }
}