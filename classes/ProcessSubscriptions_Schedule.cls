global class ProcessSubscriptions_Schedule implements Schedulable
{
   global void execute(SchedulableContext sc) 
   {
        ProcessSubscriptions_Batch Batch_Subscriptions = new ProcessSubscriptions_Batch ();
        
        Batch_Subscriptions.query='SELECT id, AccountId, Next_Billing_Date__c, Last_Billing_Date__c, Price_Unit__c, '+
                                         'Qty__c, Unit_Price__c, TaxPct__c, Product__r.Variable_Billing_Employees__c, '+
                                         'Product__r.Name, Product__r.Id, Account.No_of_active_employees__c '+
                                 'FROM Contract WHERE Next_Billing_Date__c <= today '+
                                 'AND Status != \'Terminated\' ORDER BY AccountId';
                      
        ID batchprocessid_OpenItem = Database.executeBatch(Batch_Subscriptions);
    }
}