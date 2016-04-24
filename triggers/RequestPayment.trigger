trigger RequestPayment on Transaction__c (before insert, before update) {

    for(Transaction__c TR : trigger.new){
    
        IF( TR.Payment_status__c == 'Sent' && TR.Payment_status__c != Trigger.oldMap.get(TR.Id).Payment_status__c){
            IF(TR.Total_Amount__c<>0){
                StripeCharge.ChargeTransaction(TR.id);
            }ELSE{
                TR.Payment_Status__c = 'Paid';
            }
        }
    
    }


}