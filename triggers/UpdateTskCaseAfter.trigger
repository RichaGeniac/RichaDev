trigger UpdateTskCaseAfter on Task (after insert) {


    FOR( Task tk : trigger.new ){
        
        Case cas = new Case();
        
        string whatIdString = '';
        if(tk.WhatId != null){
        
            whatIdString = tk.WhatId;
            //system.debug('\n\n### ---CasePrefix: '+whatIdString.substring(0,3));
        
            if(whatIdString.substring(0,3) == '500'){

                cas  = [SELECT Id, AccountId, ContactId, Area__c, Type, Account.BillingCountry FROM Case WHERE id =: tk.WhatId];

                //Process 1: check if NEW CASE is to be created:
                system.debug('\n\n### ---tk.Product_new_Case__c: '+tk.Product_new_Case__c);
                IF( tk.Product_new_Case__c != '' && tk.Product_new_Case__c != null ){
                
                    Product2 prod1 = [SELECT Id, Workflow__c, Name FROM Product2 WHERE id =: tk.Product_new_Case__c];
                    TRY{
                    
                    Case newCas = new Case();
                    
                    newCas.Subject     = prod1.Name;
                    newCas.ProductId   = prod1.Id;
                    newCas.Workflow__c = prod1.Workflow__c;
                    newCas.ParentId    = cas.Id;
                    newCas.ContactId   = cas.ContactId;
                    newCas.Area__c     = cas.Area__c;
                    newCas.Type        = cas.Type;
                    newCas.Internal_Case__c = tk.Internal_Case__c;
                    newCas.Originated_from_Activity_Id__c = tk.Id;
                    
                    insert newCas;
                    }CATCH( EXCEPTION ex ){
                        system.debug('\n\n### --- Insert Case Error (Exception): '+ex);
                    }
                
                }
                
            } // validation: Task is assigned to a Case...
        } // validation: Task is assign to something...
        
        // [new process 06-Dec-2014:] Tasks with Action__c = "Process Payment": creates Transaction:
        system.debug('\n\n### --- task Name (subject): '+tk.Subject +' task Action: '+tk.Action__c+' task Product Information: '+tk.Product_Information__c);
        if(tk.Action__c == 'Process Payment' && tk.Product_Information__c != null && tk.Product_Information__c !=''){
        
            PriceBookEntry priceentry= [SELECT id, Name, UnitPrice, Product2.Tax__c, Product2.Tax_EU__c
                                 FROM PriceBookEntry
                                WHERE IsActive = true
                                  AND Product2Id =: tk.Product_Information__c
                                  AND PriceBook2.IsActive = true
                                  //AND PriceBook2.IsStandard = true
                                  LIMIT 1];
        
            system.debug('\n\n### ---priceentry: '+priceentry);
        
            Transaction__c trWa = new Transaction__c();
            trWa.Company__c = cas.AccountId;
            trWa.Payment_Status__c = 'Pending';
            trWa.Case__c = tk.WhatId;
            
            insert trWa;
            
            system.debug('\n\n### --- trWa: '+trWa);
            
            Transaction_item__c triWa = new Transaction_item__c();
            triWa.Transaction__c = trWa.Id;
            triWa.Product__c = tk.Product_Information__c;
            triWa.Item__c = priceentry.Name;
            triWa.Qty__c = 1;
            triWa.Unit_Price__c = priceentry.UnitPrice;
            if(cas.Account.BillingCountry == 'UK'){
                triWa.TaxPct__c = priceentry.Product2.Tax__c;
            }else{
                triWa.TaxPct__c = priceentry.Product2.Tax_EU__c;
            }
            insert triWa;
            
            system.debug('\n\n### --- triWa: '+triWa);
            
            /**
            trWa.Payment_Status__c = 'Sent';
            update trWa;
            */
            
        }  // process payment end \\
        
        
    }

}