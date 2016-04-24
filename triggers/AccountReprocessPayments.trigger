trigger AccountReprocessPayments on Account (after update) {

    for(Account a : trigger.new){
        if(a.CompanyStatus__c == 'Active' && trigger.oldMap.get(a.id).CompanyStatus__c == 'Update Payment Details'){
        
            List<Transaction__c> tr = new List<Transaction__c>();
            try{
                tr = [SELECT id, Payment_Status__c from Transaction__c WHERE Company__c = : a.Id AND Payment_Status__c = 'Failed'];
            
                for(Transaction__c trWa : tr){
                    trWa.Payment_Status__c = 'Sent';
                }
                
                update tr;
            
            }catch(exception ex){ }
        
        }
    
    }

}