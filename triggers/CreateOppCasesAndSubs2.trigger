trigger CreateOppCasesAndSubs2 on Opportunity (after update) {

    //this trigger controls the Case Creation from the Opportunity when Transaction is PAID.
    
    List <Case> childCList = new List <Case>();
    Map <String, Case>     parentCList = new Map <String, Case>();    
    List<OpportunityLineItem> oppLinesUpdt = new List<OpportunityLineItem>();
    
    Set <Id> oppIds = new Set <Id> ();
    for(Opportunity o : Trigger.new){
        if(Trigger.oldMap.get(o.Id).Paid__c != Trigger.newMap.get(o.Id).Paid__c && o.Paid__c){
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
                                       WHERE OpportunityId in: oppIds AND Case_created__c = false
                                         AND Product2.CreateProvisioningCase__c = true]){
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
        
        
        
        for(Opportunity o : Trigger.new){
            if(Trigger.oldMap.get(o.Id).Paid__c != Trigger.newMap.get(o.Id).Paid__c && o.Paid__c){
                
                if(oppLineItemsMap.containsKey(o.Id)){
                    
                    
        
                    // get line items for this opp 
                    List <OpportunityLineItem> olis = oppLineItemsMap.get(o.Id);    
                    
                    if(olis != null && olis.size() > 0){
                    
                        for(OpportunityLineItem oli : olis) {
                        
                        OpportunityLineItem lineWA = new OpportunityLineItem();
                        
                            // -------------------------------------------------------------------------
                            // CREATE PROVISIONING CASE    
                            
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
                            
                            // CREATE PROVISIONING CASE - END
                            // -------------------------------------------------------------------------
   
                            
                        } // loop to OppLineItems end \\
                        
                    }
                }   
         
            }
        }
    
    }
    
    system.debug('\n\n### --- CreateOppCasesAndSubs2 -- parentCList : '+parentCList);
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
    
    system.debug('\n\n### --- CreateOppCasesAndSubs2 -- childCList: '+childCList);
    if(childCList != null && childCList.size() > 0){
        insert childCList;
        update oppLinesUpdt;
    }
    

}