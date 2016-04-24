trigger Twinfield_sendTransactionDetail  on Opportunity (after update) {
    
    if(!Twinfield_ProcessorControl.inFutureContext)
    {
        set<id> oppId = new set<id>();
        for(Opportunity opp: trigger.new)
            if(opp.Send_to_Twinfield__c && !opp.Integrated_with_Twinfield__c)
                oppId.add(opp.id);
        if(oppId.size()>0)
        {
            Twinfield_ProcessorControl.inFutureContext = true;
            //Twinfield_Controller.sendTransactionData (oppId);
        }
    }
}