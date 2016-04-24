trigger PaymentConfirmedActions on Transaction__c (after update) {

    List<Opportunity> OpList = new List<Opportunity>();
    List<Transaction__c> TrList = new List<Transaction__c>();
    Set<Id> AcIds = new Set<Id>();
    for(Transaction__c tr1 : trigger.new){
        string accId = tr1.Company__c;
        AcIds.add(accId);
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
    
    system.debug('\n\n### ---lastTransaction [1]: '+lastTransaction);
    system.debug('\n\n### ---cInfo.Invoice_Start_Number__c: '+cInfo.Invoice_Start_Number__c);
    
    if(lastTransaction.Document_Number__c == null){
        lastDoc = cInfo.Invoice_Start_Number__c.setScale(0);
    }else{
        lastDoc = lastTransaction.Document_Number__c.setScale(0) + 1;
    }
    system.debug('\n\n### ---lastDoc: '+lastDoc);


    //***** Document PAID ACTIONS *****
    for(Transaction__c tr : trigger.new){

        //1 - set opp as paid:
        if(tr.Payment_Status__c == 'Paid' && tr.Opportunity__c != null){
            
            system.debug('\n\n### ---go set Opportunity as paid');
            Opportunity op = new Opportunity();
            op.Id = tr.Opportunity__c;
            op.Paid__c = true;
            OpList.add(op);
        }
        
        
        //2 - create document number and type:
        if(tr.Payment_Status__c == 'Paid' &&
           tr.Payment_Status__c != trigger.oldMap.get(tr.id).Payment_Status__c &&
           tr.Total_Amount__c <> 0 &&
           tr.Document_Number__c == null ){
            
            system.debug('\n\n### --- go create Invoice');
            
            Transaction__c trUpdt = new Transaction__c();
            trUpdt.Id = tr.Id;

            //set send to email:
            Account AccWa = new Account();
            AccWa = AcMap.get(tr.Company__c);
            if(AccWa.GENIAC_User__r.Email__c != null){
                trUpdt.Send_Invoice_to__c = AccWa.GENIAC_User__r.Email__c;
            }

            //set invoice information ONLY IF THIS IS NOT CREATED IN BATCH MODE:

            if(tr.Created_via_Batch__c == false){
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
            
            }

            TrList.add(trUpdt);
        
        }
        
    }
    
    //updates lists:
    if(OpList.size()>0) update OpList;
    if(TrList.size()>0) update TrList;

}