@isTest
private class onBoardThisCompany_test
{
    public static testMethod void onboardthisCompanyMethod()
    {
        test.StartTest();
        // Create test Account
        Account acc = new Account();
        acc.Name = 'Test Company for test class';
        acc.Type = 'Customer';
        acc.Industry = 'Chemicals';
        acc.Nature_of_Business__c = 'Test';
        acc.NumberOfEmployees = 5;
        
        insert acc;
        
        Id cId; 
        cId = acc.Id;
        
        
        // Create test Geniac User
        GENIAC_User__c gUser = new GENIAC_User__c(Name = 'Test fName test lName',firstName__c = 'test fName', lastName__c='Test Last Name', Email__c = 'test@testgmail.com', company__c = cId,phone__c = '09876543212',position__c = 'Director');
        
        insert gUser;
        
        // Create contact linked to this company and this user
        
        Contact con = new Contact(firstName='Test Contact fName',lastName = 'Test Contact lName', Email ='test@testgmail.com', AccountId=cId,position__c = 'Director',User__c = gUser.id);
        insert con;
        
        onBoardThisCompany onBoardObj = new onBoardThisCompany();
        onBoardObj.setSelectedUser(gUser.Id);
        onBoardObj.getoptions();
        onBoardObj.sendEmail();
        //onBoardObj.getcompanyName();
        onBoardObj.getMyself();
        
        // Create test Account
        Account acc1 = new Account();
        acc1.Name = 'Test Company for test class';
        acc1.Type = 'Customer';
        acc1.Industry = 'Chemicals';
        acc1.Nature_of_Business__c = 'Test';
        acc1.NumberOfEmployees = 5;
        
        insert acc1;
        
        Id cId1; 
        cId1 = acc1.Id;
        
        // Create test Geniac User
        GENIAC_User__c gUser1 = new GENIAC_User__c(Name = 'Test fName test lName',firstName__c = 'test fName', lastName__c='Test Last Name', Email__c = 'test1@testgmail.com', company__c = cId1, phone__c = '09876543212',position__c = 'Director');
        
        insert gUser1;
        
        onBoardThisCompany onBoardObj1 = new onBoardThisCompany();
        onBoardObj1.setSelectedUser(gUser1.Id);
        onBoardObj1.getoptions();
        onBoardObj1.sendEmail();
        //onBoardObj.getcompanyName();
        onBoardObj1.getMyself();
        
        
        test.StopTest();
    }
}