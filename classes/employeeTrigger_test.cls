/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData = false)
private class employeeTrigger_test {

    static testMethod void employeeTriggerTestmethod() 
    {
        test.StartTest();
        Account acc = new Account();
        acc.Name = 'Test Company for test class';
        acc.Type = 'Customer';
        acc.Industry = 'Chemicals';
        acc.Nature_of_Business__c = 'Test';
        acc.NumberOfEmployees = 5;
        
        insert acc;
        
        Id cId; 
        cId = acc.Id;
        
        Employee__c emp = new Employee__c(Name = 'Emp Name',company__c=cId,firstName__c='Test fName', lastName__c='Test lName',email__c='test@gmail.com');
        // TO DO: implement unit test
        insert emp;
        test.StopTest();
    }
}