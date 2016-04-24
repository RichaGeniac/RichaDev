public class ProcessSubscriptions{

    public static void ProcessToday(List<Contract> coList, boolean IsBatch)
    {                  
        if(coList.size() != 0)
        {

            //create Account Set:
            Set<id> aSet = new Set<id>();
            for(Contract coWa : coList){
                aSet.add(coWa.AccountId);
            }
            
            system.debug('\n\n### --- Account Set aSet: '+aSet);
            
            //create lists:
            List<Transaction__c> trList = new List<Transaction__c>();
            List<Transaction_item__c> triList = new List<Transaction_item__c>();
            
            
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
                        triWa.Item__c = coWa2.Product__r.Name;
                        triWa.Product__c = coWa2.Product__r.Id;
                        
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
                if(IsBatch)
                    trWa3.Created_via_batch__c = true;
                else
                    trWa3.Payment_status__c = 'Sent';
            }
            update trList;
            
            //update Last Billing Date in Contracts:
            for(Contract coWa3 : coList){
                coWa3.Last_Billing_Date__c = coWa3.Next_Billing_Date__c;
            }
            update coList;
        
        }
    }
    
    
    public static void ProcessInvoicesToday(List<Transaction__c> trList, boolean IsBatch){
    
        List<Transaction__c> TrListUpdate = new List<Transaction__c>();
        
        Set<Id> AcIds = new Set<Id>();
        for(Transaction__c trWa : trList){
            AcIds.add(trWa.Company__c);
        }
    
        Map<id, Account> AcMap = new Map<id, Account>([SELECT id, GENIAC_User__r.Email__c FROM Account WHERE id in: AcIds]);
    
        //get company info:
        GENIACinvoiceInfo__c cInfo = [SELECT id, Name, VAT_Number__c, Street__c, City__c, Postal_Code__c, Country__c,
                                             Invoice_Footer_1__c, Invoice_Footer_2__c, Invoice_Start_Number__c
                                        FROM GENIACinvoiceInfo__c
                                        WHERE Active__c = true
                                        LIMIT 1];
    
        //get last document:
        decimal lastDoc = 0;
        Transaction__c lastTransaction = new Transaction__c();
        try{
            lastTransaction = [SELECT Document_Number__c FROM Transaction__c
                        WHERE Document_Number__c != null
                          AND Internal_Company_Id__c =: cInfo.Id
                          ORDER BY Document_Number__c DESC
                          LIMIT 1];
        }catch(exception ex){}
        
        system.debug('\n\n### --- BATCH lastTransaction [1]: '+lastTransaction);
        system.debug('\n\n### --- BATCH cInfo.Invoice_Start_Number__c: '+cInfo.Invoice_Start_Number__c);
        
        if(lastTransaction.Document_Number__c == null){
            lastDoc = cInfo.Invoice_Start_Number__c.setScale(0);
        }else{
            lastDoc = lastTransaction.Document_Number__c.setScale(0) + 1;
        }
        system.debug('\n\n### ---lastDoc: '+lastDoc);
        
    
         for(Transaction__c tr : trList){
         
             Transaction__c trUpdt = new Transaction__c();
             trUpdt.Id = tr.Id;
         
              //set company info:
                trUpdt.Internal_Company_Id__c = cInfo.Id;
                trUpdt.Internal_Company_Name__c = cInfo.Name;
                trUpdt.Internal_Company_VAT__c = cInfo.VAT_Number__c;
                trUpdt.Internal_Company_Street__c = cInfo.Street__c;
                trUpdt.Internal_Company_City__c = cInfo.City__c;
                trUpdt.Internal_Company_Postal_Code__c = cInfo.Postal_Code__c;
                trUpdt.Internal_Company_Country__c = cInfo.Country__c;
                trUpdt.Internal_Company_Footer_1__c = cInfo.Invoice_Footer_1__c;
                trUpdt.Internal_Company_Footer_2__c = cInfo.Invoice_Footer_2__c;
    
    
                //set document number:
                trUpdt.Document_Number__c = lastDoc;
                lastDoc = lastDoc + 1;
                system.debug('\n\n### ---lastTransaction.Document_Number__c: '+lastTransaction.Document_Number__c);
                
                //set doc type:
                if(tr.Total_Amount__c >= 0){
                    trUpdt.Document_Type__c = 'Invoice';
                }else{
                    trUpdt.Document_Type__c = 'Credit Note';
                }
            
            TrListUpdate.add(trUpdt);
         
         }
    
    
        //updates lists:
        if(TrListUpdate.size()>0) update TrListUpdate;
    
    }
    
}