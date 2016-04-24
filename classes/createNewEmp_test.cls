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
@isTest
private class createNewEmp_test {

    static testMethod void newEmpTest() 
    {
        // TO DO: implement unit test
        test.startTest();
        
        // Create new accuont and the create new GeniacUser and then trigger should work
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
        
        GENIAC_User__c gUser = new GENIAC_User__c();
        
        gUser.Name = 'Test Genic User';
        gUser.FirstName__c = 'Test First Name';
        gUser.LastName__c = 'Test Last Name';
        gUser.Email__c = 'test@gmailtest.com';
        gUser.Company__c = cId;
        gUser.phone__c = '09876584321';
        gUser.position__c = 'Director';
        gUser.company_roles__c = 'Employee';
        gUser.Conversion_Account_ID__c = cId;
        
        insert gUser;
        
        GENIAC_User__c gUser1 = new GENIAC_User__c();
        
        gUser1.Name = 'Test Genic User';
        gUser1.FirstName__c = 'Test First Name';
        gUser1.LastName__c = 'Test Last Name';
        gUser1.Email__c = 'test@gmailtest.com';
        //gUser1.Company__c = cId;
        gUser1.phone__c = '09876584321';
        gUser1.position__c = 'Director';
        gUser1.company_roles__c = 'Employee';
        gUser1.Conversion_Account_ID__c = cId;
        
        insert gUser1;
        
        
        test.stopTest();
    }
}