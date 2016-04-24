public class ProcessSubscriptionsPage{

    public PageReference createTransactions(){
        
        List<Contract> coList = new List<Contract>();
        
        coList = [SELECT id, AccountId, Next_Billing_Date__c, Last_Billing_Date__c, Price_Unit__c, Qty__c, Unit_Price__c,
                         TaxPct__c, Product__r.Variable_Billing_Employees__c, Product__r.Name, Account.No_of_active_employees__c, Product__r.Id
                    FROM Contract
                   WHERE Next_Billing_Date__c <= : Date.today()
                     AND Status != 'Terminated'
                ORDER BY AccountId];
        
        if(coList.size() == 0){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.info, 'No valid Subscriptions found...');
            ApexPages.addMessage(msg);
        
        }else{
        
            ProcessSubscriptions.ProcessToday(coList, false);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.info, coList.size() + ' Subscriptions processed;');
            ApexPages.addMessage(msg);
        
        }
        return null;
        
        /**
        List<Contract> coList = new List<Contract>();
        
        coList = [SELECT id, AccountId, Next_Billing_Date__c, Last_Billing_Date__c, Price_Unit__c,
                         Qty__c, Unit_Price__c, TaxPct__c,
                         Product__r.Variable_Billing_Employees__c, Account.No_of_active_employees__c
                    FROM Contract
                    WHERE Next_Billing_Date__c <= : Date.today()
                      AND Status != 'Terminated'
                      ORDER BY AccountId];
                      
        if(coList.size() == 0){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.info, 'No valid Subscriptions found...');
            ApexPages.addMessage(msg);
        
        }else{
            //create Account Set:
            Set<id> aSet = new Set<id>();
            for(Contract coWa : coList){
                aSet.add(coWa.AccountId);
            }
            system.debug('\n\n### --- Account Set aSet: '+aSet);
            ApexPages.Message msg1 = new ApexPages.Message(ApexPages.severity.info, aSet.size() + ' Companie(s) found;');
            ApexPages.addMessage(msg1);
            ApexPages.Message msg2 = new ApexPages.Message(ApexPages.severity.info, coList.size() + ' Subscriptions found;');
            ApexPages.addMessage(msg2);
            
            //create lists:
            List<Transaction__c> trList = new List<Transaction__c>();
            List<Transaction_item__c> triList = new List<Transaction_item__c>();
            
            
            //get Account informations:
            //Map<id, Account> aList = new Map<id, Account>([SELECT id, No_of_active_employees__c FROM Account WHERE id in :aSet]);
            
            //insert Transactions (for each Account):
            for(id aId : aSet){
                Transaction__c trWa = new Transaction__c();
                trWa.Company__c = aId;
                trList.add(trWa);
            }
            insert trList;
            
            //insert each Subscription as Transaction Item:
            for(Transaction__c trWa2 : trlist){
                for(Contract coWa2 : coList){
                    if(coWa2.AccountId == trWa2.Company__c){
                        Transaction_item__c triWa = new Transaction_item__c();
                        triWa.Transaction__c = trWa2.Id;
                        triWa.Subscription__c = coWa2.id;
                        
                        //calculate quantity: special scenario: qty = active employees:
                        decimal qty = coWa2.Qty__c;
                        if(cowa2.Product__r.Variable_Billing_Employees__c)
                            qty = coWa2.Account.No_of_active_employees__c;
                        triWa.Qty__c = qty;
                        
                        triWa.Unit_Price__c = coWa2.Unit_Price__c;
                        triWa.TaxPct__c = coWa2.TaxPct__c;
                        triWa.Total_Amount__c = coWa2.Qty__c * coWa2.Unit_Price__c;
                        triWa.Total_Amount_w_tax__c = coWa2.Qty__c * coWa2.Unit_Price__c * (100 + coWa2.TaxPct__c) / 100;
                    
                        triList.add(triWa);
                    }
                
                }
            }
            insert triList;
        
            //request payment to Stripe:
            for(Transaction__c trWa3 : trList){
                trWa3.Payment_status__c = 'Sent';
            }
            update trList;
            
            //update Last Billing Date in Contracts:
            for(Contract coWa3 : coList){
                coWa3.Last_Billing_Date__c = coWa3.Next_Billing_Date__c;
            }
            update coList;
        
        }
        */

    }
    
    public PageReference createInvoices(){
        
        List<Transaction__c> trList = new List<Transaction__c>();
        
        trList = [SELECT id, Company__c, Total_Amount__c
                    FROM Transaction__c
                   WHERE Payment_Status__c = 'Paid'
                     AND Document_Number__c = null
                ORDER BY CreatedDate ASC];
        
        if(trList.size() == 0){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.info, 'No valid Subscriptions found...');
            ApexPages.addMessage(msg);
        
        }else{
        
            ProcessSubscriptions.ProcessInvoicesToday(trList, false);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.info, trList.size() + ' Subscriptions processed;');
            ApexPages.addMessage(msg);
        
        }
        return null;

    }
    

}