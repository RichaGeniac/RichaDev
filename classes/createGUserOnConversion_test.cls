/**
 * Created by richasharma on 05/04/2016.
 */
@isTest
private class createGUserOnConversion_test
{

    public static testMethod void leadConversionTest()
    {
        // Start test
        // Create test lead record
        // Convert lead
        // Stop test
        test.StartTest();

        Id leadId;

        Lead testLead = new Lead();
        testLead.firstName = 'Lead FirstName';
        testLead.lastName = 'Lead LastName';
        testLead.email = 'testLead@gmail.com';
        testLead.company = 'Test Lead Company';
        testLead.status = 'Closed - Won';
        testLead.LeadSource = 'Web';
        testLead.Packages__c = 'Startup';
        testLead.On_boarding_Context__c = 'Test';
        testLead.Accounting_Context__c = 'Test';
        testLead.HR_Context__c = 'Test';
        testLead.Insurance_Context__c = 'Test';
        testLead.Company_Secretarial_Context__c = 'Test';
        insert testLead;

        leadId = testLead.Id;

        // Convert the lead

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.id);

        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];

        lc.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);

        System.assert(lcr.isSuccess());
        
        // Create lead again but with error i.e send no email        
        
        Lead testLead1 = new Lead();
        testLead1.firstName = 'Lead FirstName1';
        testLead1.lastName = 'Lead LastName1';
        testLead1.company = 'Test Lead Company1';
        testLead1.status = 'Closed - Won';
        testLead1.LeadSource = 'Web';
        testLead1.Packages__c = 'Startup';
        testLead1.On_boarding_Context__c = 'Test1';
        testLead1.Accounting_Context__c = 'Test1';
        testLead1.HR_Context__c = 'Test1';
        testLead1.Insurance_Context__c = 'Test1';
        testLead1.Company_Secretarial_Context__c = 'Test1';
        insert testLead1;

        leadId = testLead1.Id;

        // Convert the lead

        Database.LeadConvert lc1 = new database.LeadConvert();
        lc1.setLeadId(testLead1.id);

        LeadStatus convertStatus1 = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];

        lc1.setConvertedStatus(convertStatus.MasterLabel);

        Database.LeadConvertResult lcr1 = Database.convertLead(lc1);

        System.assert(lcr1.isSuccess());

        test.StopTest();

    }

}