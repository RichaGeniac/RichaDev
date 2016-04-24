trigger OppClearFieldsOnCreate on Opportunity (before insert) {

    for(Opportunity op : trigger.new){
        op.Paid__c = false;
        op.StageName = 'Prospecting';
        
        //Set First payment date IF not defined (change requested no 19-Feb-2015):
        if(op.First_payment_date__c == null){
            op.First_Payment_date__c = system.today();
        }
        
    }

}