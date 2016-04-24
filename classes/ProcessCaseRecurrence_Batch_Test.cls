@isTest 
private class ProcessCaseRecurrence_Batch_Test{

    @isTest (SeeAllData=true)
     public static void teste()
     {
        
        
        Account accTeste = new Account();
        accTeste.Name = 'TestAccount';
        insert accTeste;
        
        Case c = new Case();
        
        c.AccountID = accTeste.id;
        c.Target_Date__c = date.Today().addDays(5);
        c.Days_for_Case_renewal__c = 5;
        c.CaseCategory__c = 'Recurring';
        c.Periodicity__c = 'Weekly';
        
        insert c;
        
               
        Test.StartTest();
        
        ProcessCaseRecurrence_Batch Batch_Cases = new ProcessCaseRecurrence_Batch ();
        
        Batch_Cases.query='SELECT '+
                              'id, AccountId, ParentId, ContactId, Subject, Description, Target_Date__c, Next_renewal_date__c, CaseCategory__c, '+
                              'Periodicity__c, Days_for_Case_renewal__c, ProductId, Workflow__c, Internal_Case__c, Parent_Product__c, '+
                              'Area__c, SubArea__c, Document_for_employee__c, Tier_2_Case__c '+
                           'FROM Case WHERE Next_Renewal_Date__c <= today '+
                           'AND Renewed__c != true ORDER BY AccountId';
                      
        Database.executeBatch(Batch_Cases);
        
        Test.StopTest(); 
    }
    
}