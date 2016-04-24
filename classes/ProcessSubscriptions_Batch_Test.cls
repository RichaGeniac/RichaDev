@isTest 
private class ProcessSubscriptions_Batch_Test{

    @isTest (SeeAllData=true)
     public static void teste()
     {
        
        GENIACinvoiceInfo__c cInfo = new GENIACinvoiceInfo__c(
             Name='test', VAT_Number__c='12345', Street__c='test',
             City__c='test', Postal_Code__c='12345', Country__c='UK',
             Invoice_Footer_1__c='xxx', Invoice_Footer_2__c='xxx', Invoice_Start_Number__c=3000,
             Active__c = true );
        insert cInfo;
        
        
        Account accTeste = new Account();
        accTeste.Name = 'TestAccount';
        insert accTeste;
        
        Product2 prod1 = new Product2(Name='prod1', IsActive=true, PriceUnit__c='Per Month', Family='Recurring', Area__c='Area1', SubArea__c='SubArea1', Type__c='Single', SortOrder__c='10', CreateProvisioningCase__c=true, CaseCategory__c='Recurring');   
        insert prod1;
        
        Contract c = new Contract();
        
        c.AccountID = accTeste.id;
        c.Next_Billing_Date__c = date.Today();
        c.Last_Billing_Date__c = date.Today().addMonths(-1);
        c.Price_Unit__c = '22';
        c.Qty__c = 2;
        c.Unit_Price__c = 33;
        c.TaxPct__c = 8;
        c.Product__c = prod1.id;
        
        insert c;
        
               
        Test.StartTest();
        
        ProcessSubscriptions_Batch Batch_Subscriptions = new ProcessSubscriptions_Batch ();
        
        Batch_Subscriptions.query='SELECT id, AccountId, Next_Billing_Date__c, Last_Billing_Date__c, Price_Unit__c, '+
                                          'Qty__c, Unit_Price__c, TaxPct__c, Product__r.Variable_Billing_Employees__c, '+
                                          'Product__r.Name, Account.No_of_active_employees__c, Product__r.Id '+
                                 'FROM Contract WHERE Next_Billing_Date__c <= TODAY '+
                                 'AND Status != \'Terminated\' ORDER BY AccountId';
                      
        //Database.executeBatch(Batch_Subscriptions);
        
        
        ProcessInvoices_Batch Batch_Invoices = new ProcessInvoices_Batch ();
        
        Batch_Invoices.query='SELECT id, Company__c, Total_Amount__c '+
                             'FROM Transaction__c WHERE Payment_Status__c = \'Paid\' AND Document_Number__c = null ORDER BY CreatedDate ASC';
        
        Database.executeBatch(Batch_Invoices);                     
        
        Test.StopTest(); 
    }
    
}