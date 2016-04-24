trigger CreateOppCasesAndSubs on Opportunity (before update) {

    //List <Case> childCList = new List <Case>();
    //Map <String, Case>     parentCList = new Map <String, Case>();    
    List <Contract> subsList = new List <Contract>();
    Map <SubscriptionPrice__c, Contract> subsMap = new Map <SubscriptionPrice__c, Contract>();
    List<OpportunityLineItem> oppLinesUpdt = new List<OpportunityLineItem>();
    List<Transaction_Item__c> TRI = new List<Transaction_Item__c>();
    
    Set <Id> oppIds = new Set <Id> ();
    
    for(Opportunity o : Trigger.new){
        if(Trigger.oldMap.get(o.Id).isWon != Trigger.newMap.get(o.Id).isWon && o.isWon){
            oppIds.add(o.Id);
            
        }
    }
    
    
    if(oppIds.size() > 0){    
        Set <Id> packIds = new Set <Id>();
        Set <Id> subsIds = new Set <Id>();
        
        // get line items    
        Map <Id, List <OpportunityLineItem>> oppLineItemsMap = new Map <Id, List <OpportunityLineItem>>();
        for(OpportunityLineItem oli : [SELECT Id, OpportunityId, ProductType__c, ProductFamily__c, Parent_Product__c, PricebookEntry.Product2.Id, PricebookEntry.Product2.Name,
                                              PricebookEntry.Product2.CreateProvisioningCase__c, PricebookEntry.Product2.Area__c, 
                                              PricebookEntry.Product2.SubArea__c,PricebookEntry.Product2.PriceUnit__c, PricebookEntry.Product2.CaseCategory__c, 
                                              PricebookEntry.Product2.Workflow__c, PricebookEntry.Product2.Workflow__r.Name, Case_created__c,
                                              Opportunity.First_Payment_Date__c, TaxPct__c, Quantity, UnitPrice
                                       FROM OpportunityLineItem 
                                       WHERE OpportunityId in: oppIds AND Case_created__c = false]){
                                       //AND ProductFamily__c = 'Recurring'])
            
            if(oppLineItemsMap.containsKey(oli.OpportunityId)){
                oppLineItemsMap.get(oli.OpportunityId).add(oli);
                
            } else {
                List <OpportunityLineItem> olis = new List <OpportunityLineItem>();
                olis.add(oli);
                oppLineItemsMap.put(oli.OpportunityId ,olis);
            }
            
            if(oli.ProductType__c == 'Pack'){
                packIds.add(oli.PricebookEntry.Product2.Id);
            }   
            
            if(oli.ProductFamily__c == 'Recurring'){
                subsIds.add(oli.PricebookEntry.Product2.Id);
            }                        
        }
        
        // get pack items
        Map <Id, List <ProductPackItem__c>> packItemsMap = new Map <Id, List <ProductPackItem__c>>();
        if(packIds.size() > 0){
            for(ProductPackItem__c p : [SELECT Id, ProductPack__c, ProductPack__r.Name, ProductPack__r.Workflow__c, ProductPack__r.Workflow__r.Name, PackItem__c, 
                                               PackItem__r.Name, PackItem__r.CreateProvisioningCase__c, PackItem__r.Area__c, PackItem__r.SubArea__c,
                                               PackItem__r.PriceUnit__c, PackItem__r.CaseCategory__c, PackItem__r.Workflow__c, PackItem__r.Workflow__r.Name
                                        FROM ProductPackItem__c
                                        WHERE ProductPack__c in: packIds
                                        AND PackItem__r.CreateProvisioningCase__c = true]){
            
                if(packItemsMap.containsKey(p.ProductPack__c)){
                    packItemsMap.get(p.ProductPack__c).add(p);
                } else {
                    List <ProductPackItem__c> pis = new List <ProductPackItem__c>();
                    pis.add(p);
                    packItemsMap.put(p.ProductPack__c, pis);
                }    
            }
        }
        
        // get subs prices
        Map <Id, List <ProductSubscriptionPrice__c>> subsPricesMap = new Map <Id, List <ProductSubscriptionPrice__c>>();
        if(subsIds.size() > 0){
        
            for(ProductSubscriptionPrice__c psi : [SELECT Id, Price__c, Product__c, SortOrder__c, SubscriptionProduct__c 
                                                   FROM ProductSubscriptionPrice__c
                                                   WHERE SubscriptionProduct__c in: subsIds]){
           
                if(subsPricesMap.containsKey(psi.SubscriptionProduct__c)){
                    subsPricesMap.get(psi.SubscriptionProduct__c).add(psi);
                } else {
                    List <ProductSubscriptionPrice__c> psis = new List <ProductSubscriptionPrice__c>();
                    psis.add(psi);
                    subsPricesMap.put(psi.SubscriptionProduct__c, psis);
                }  
            }
        }
        
        
        for(Opportunity o : Trigger.new){
            if(Trigger.oldMap.get(o.Id).isWon != Trigger.newMap.get(o.Id).isWon && o.isWon){
                
                if(oppLineItemsMap.containsKey(o.Id)){
                    
                    
        
                    // get line items for this opp 
                    List <OpportunityLineItem> olis = oppLineItemsMap.get(o.Id);    
                    
                    if(olis != null && olis.size() > 0){
                    
                        for(OpportunityLineItem oli : olis) {
                        
                        OpportunityLineItem lineWA = new OpportunityLineItem();
                        
                            // -------------------------------------------------------------------------
                            // CREATE PROVISIONING CASE    
                        
                            /**
                            
                            // SINGLE product
                            if(oli.ProductType__c == 'Single'){
                                if(oli.PricebookEntry.Product2.CreateProvisioningCase__c = true){
        
                                    lineWA.id = oli.id;
                                    lineWA.Case_created__c = true;
                                    oppLinesUpdt.add(lineWA);
            
                                    Case c = new Case();
                                    c.AccountId = o.AccountId;
                                    c.ContactId = o.UserContact__c;
                                    c.Opportunity__c = oli.OpportunityId;
                                    c.OpportunityProduct_ID__c = oli.id;
                                    c.ProductId = oli.PricebookEntry.Product2.Id;
                                    c.Parent_Product__c = oli.Parent_product__c;
                                    c.Workflow__c = oli.PricebookEntry.Product2.Workflow__c;
                                    c.Subject = oli.PricebookEntry.Product2.Name;
                                    c.Type = 'Provisioning';
                                    c.Area__c =  oli.PricebookEntry.Product2.Area__c;
                                    c.SubArea__c = oli.PricebookEntry.Product2.SubArea__c;
                                    c.CaseCategory__c = oli.PricebookEntry.Product2.CaseCategory__c;
                                    c.Origin = 'Opportunity';
                                    c.Status = 'New';  
                                    
                                    childCList.add(c); 
                                }
                                
                            } else if(oli.ProductType__c == 'Pack'){
                                
                                Case pc;
                                                        
                                // creates case for the product pack (PARENT CASE) 
                                if(oli.PricebookEntry.Product2.CreateProvisioningCase__c == true){
                                    
                                    lineWA.id = oli.id;
                                    lineWA.Case_created__c = true;
                                    oppLinesUpdt.add(lineWA);
                                    
                                    pc = new Case();
                                    pc.AccountId = o.AccountId;
                                    pc.ContactId = o.UserContact__c;
                                    pc.Opportunity__c = oli.OpportunityId;
                                    pc.OpportunityProduct_ID__c = oli.id;
                                    pc.ProductId = oli.PricebookEntry.Product2.Id;
                                    pc.Parent_Product__c = oli.Parent_product__c;
                                    pc.Workflow__c = oli.PricebookEntry.Product2.Workflow__c;
                                    pc.Subject = oli.PricebookEntry.Product2.Name;
                                    pc.Type = 'Provisioning';
                                    pc.Area__c =  oli.PricebookEntry.Product2.Area__c;
                                    pc.SubArea__c = oli.PricebookEntry.Product2.SubArea__c;
                                    pc.CaseCategory__c = oli.PricebookEntry.Product2.CaseCategory__c;
                                    pc.Origin = 'Opportunity';
                                    pc.Status = 'New';
                                    
                                    // generates random FakeID to associate to child cases after insert
                                    Blob blobKey = crypto.generateAesKey(128);
                                    String fakeId = EncodingUtil.convertToHex(blobKey);                   
                                    pc.FakeID__c = fakeId.substring(0,18);
                                    
                                    parentCList.put(pc.FakeID__c, pc); 
                                    
                                }
                                
                                // creates case for each pack item (CHILD CASES) 
                                if(packItemsMap.containsKey(oli.PricebookEntry.Product2.Id)){
                                
                                    List <ProductPackItem__c> pis = packItemsMap.get(oli.PricebookEntry.Product2.Id);
                                    for(ProductPackItem__c pi : pis) {
                                    
                                        Case c = new Case();
                                        c.AccountId = o.AccountId;
                                        c.ContactId = o.UserContact__c;
                                        c.Opportunity__c = oli.OpportunityId;
                                        c.OpportunityProduct_ID__c = oli.id;
                                        c.ProductId = pi.PackItem__c;
                                        c.Parent_Product__c = oli.Parent_product__c;
                                        c.Workflow__c = pi.PackItem__r.Workflow__c;
                                        //c.Subject = pi.ProductPack__r.Name+' - '+pi.PackItem__r.Name;
                                        c.Subject = pi.PackItem__r.Name;
                                        c.Type = 'Provisioning';
                                        c.Area__c =  pi.PackItem__r.Area__c;
                                        c.SubArea__c = pi.PackItem__r.SubArea__c;
                                        c.CaseCategory__c = pi.PackItem__r.CaseCategory__c;
                                        c.Origin = 'Opportunity';
                                        c.Status = 'New';
                                        
                                        if(pc != null && pc.FakeID__c != null && pc.FakeID__c != ''){
                                            c.FakeParentID__c = pc.FakeID__c;
                                        }
                                        
                                        childCList.add(c);
                                    }      
                                }  
                            }    
                            */    
                            
                            // CREATE PROVISIONING CASE - END
                            // -------------------------------------------------------------------------
                            
                            
                            
                            // -------------------------------------------------------------------------
                            // CREATE SUBSCRIPTION (contract)
                            
                            
                            if(oli.ProductFamily__c == 'Recurring'){
                            
                                Contract ct = new Contract();
                                ct.AccountId = o.AccountId;
                                ct.Opportunity__c = oli.OpportunityId;
                                ct.Product__c = oli.PricebookEntry.Product2.Id;
                                ct.OpportunityProduct_ID__c = oli.id;
                                ct.StartDate = Date.today();
                                ct.Price_Unit__c = oli.PricebookEntry.Product2.PriceUnit__c;
                                ct.Qty__c = oli.Quantity;
                                ct.Unit_Price__c = oli.UnitPrice;
                                ct.TaxPct__c = oli.TaxPct__c;
                                if(oli.Opportunity.First_Payment_Date__c != null){
                                    ct.First_Billing_Date__c = oli.Opportunity.First_Payment_Date__c;
                                }else{
                                    ct.First_Billing_Date__c = Date.today();
                                }
                                ct.TransactionId__c = o.TransactionId__c;                      
                                /**
                                ct.ContractTerm = 1;
                                if(oli.PricebookEntry.Product2.PriceUnit__c == 'per Year'){
                                    ct.ContractTerm = 12;
                                }
                                */                       
                                subsList.add(ct);
                                
                                if(subsPricesMap.containsKey(oli.PricebookEntry.Product2.Id)){
                                
                                    List <ProductSubscriptionPrice__c> psps = subsPricesMap.get(oli.PricebookEntry.Product2.Id);
                                    for(ProductSubscriptionPrice__c psp : psps) {
                                    
                                        SubscriptionPrice__c sp = new SubscriptionPrice__c();
                                        sp.Price__c = psp.Price__c;
                                        sp.Product__c = psp.Product__c;
                                        sp.SortOrder__c = psp.SortOrder__c;
                                    
                                        subsMap.put(sp, ct);              
                                    }        
                                }
                            
                            
                            // CREATE SUBSCRIPTION (contract) - END
                            // -------------------------------------------------------------------------
                            
                            }else{
                            // -------------------------------------------------------------------------
                            // CREATE ONE-OFF TRANSACTION
                                if(oli.UnitPrice <> 0){
                                    Transaction_Item__c TRIwa = new Transaction_Item__c();
                                    
                                    TRIwa.Item__c = oli.PricebookEntry.Product2.Name;
                                    TRIwa.Product__c = oli.PricebookEntry.Product2.Id;
                                    TRIwa.TaxPct__c = oli.TaxPct__c;
                                    TRIwa.Qty__c = oli.Quantity;
                                    TRIwa.Unit_Price__c = oli.UnitPrice;
                                    TRIwa.Total_Amount__c = oli.Quantity * oli.UnitPrice;
                                    TRIwa.Total_Amount_w_Tax__c = oli.Quantity * oli.UnitPrice * (100 + oli.TaxPct__c) / 100;
                                    
                                    TRI.add(TRIwa);
                                }

                            // CREATE ONE-OFF TRANSACTION - END
                            // -------------------------------------------------------------------------
                            }

                            
                        } // loop to OppLineItems end \\
                        
                        if(TRI.size()>0){
                            Transaction__c TR = new Transaction__c();
                            TR.Opportunity__c = o.Id;
                            TR.Company__c = o.AccountId;
                            
                            insert TR;
                            for(Transaction_Item__c item : TRI){
                                item.Transaction__c = TR.Id;
                            }
                            insert TRI;
                            
                            //send payment request:
                            TR.Payment_status__c = 'Sent';
                            update TR;
                        }else{
                        //set Opp as Paid if all non-recurring products are free
                        o.Paid__c= true;
                        
                        }
                        
                        
                        
                    }
                }   
         
            }
        }
    
    }
    
    /**
    system.debug('\n\n### --- CreateOppCasesAndSubs -- parentCList : '+parentCList);
    if(parentCList != null && parentCList.values().size() > 0){
        
        insert parentCList.values();
        
        if(childCList != null && childCList.size() > 0){
            for(Case c : childCList) {
                if(c.FakeParentID__c != null && c.FakeParentID__c != ''){
                    
                    if(parentCList.containsKey(c.FakeParentID__c)){
                        c.ParentId = parentCList.get(c.FakeParentID__c).Id;
                    }
                }
            }
        }    
    }
    
    system.debug('\n\n### --- CreateOppCasesAndSubs -- childCList: '+childCList);
    if(childCList != null && childCList.size() > 0){
        insert childCList;
        update oppLinesUpdt;
    }
    */
    
    system.debug('\n\n### --- CreateOppCasesAndSubs -- subsMap: '+subsMap);
    if(subsList != null && subsList.size() > 0){
        insert subsList;     
        
        if(subsMap != null){
            for(SubscriptionPrice__c sp : subsMap.keySet()){
                sp.Subscription__c = subsMap.get(sp).Id;
            }
            
            List <SubscriptionPrice__c> sps = new List <SubscriptionPrice__c> (subsMap.keySet());
            insert sps;
        }
        
    }
    
}