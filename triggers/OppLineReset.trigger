trigger OppLineReset on OpportunityLineItem (before insert) {

    for(OpportunityLineItem OLI : trigger.new){
    
        OLI.Case_created__c = false;
    
    }

}