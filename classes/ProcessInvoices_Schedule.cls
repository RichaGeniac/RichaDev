global class ProcessInvoices_Schedule implements Schedulable
{
   global void execute(SchedulableContext sc) 
   {
        ProcessInvoices_Batch Batch_Invoices = new ProcessInvoices_Batch ();
        
        Batch_Invoices.query='SELECT id, Company__c, Total_Amount__c '+
                             'FROM Transaction__c WHERE Payment_Status__c = \'Paid\' AND Document_Number__c = null ORDER BY CreatedDate ASC';
                      
        ID batchprocessid_Invoices = Database.executeBatch(Batch_Invoices);
    }
}