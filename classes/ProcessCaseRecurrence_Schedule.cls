global class ProcessCaseRecurrence_Schedule implements Schedulable
{
   global void execute(SchedulableContext sc) 
   {
        ProcessCaseRecurrence_Batch Batch_Cases = new ProcessCaseRecurrence_Batch ();
        
        Batch_Cases.query='SELECT '+
                              'id, AccountId, ParentId, ContactId, Subject, Description, Target_Date__c, Next_renewal_date__c, CaseCategory__c, '+
                              'Periodicity__c, Days_for_Case_renewal__c, ProductId, Workflow__c, Internal_Case__c, Parent_Product__c, '+
                              'Area__c, SubArea__c, Document_for_employee__c, Tier_2_Case__c '+
                           'FROM Case WHERE Next_Renewal_Date__c <= today '+
                           'AND Renewed__c != true ORDER BY AccountId';
                      
        ID batchprocessid_Cases = Database.executeBatch(Batch_Cases);
    }
}