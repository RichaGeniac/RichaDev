trigger Twinfield_sendTransaction on Transaction__c (after update) 
{
    if(!Twinfield_ProcessorControl.inFutureContext)
    {
        set<id> oppId = new set<id>();
        for(Transaction__c trasaction: trigger.new)
            if(trasaction.Send_to_Twinfield__c && !trasaction.Integrated_with_Twinfield__c)
            {
                Twinfield_ProcessorControl.inFutureContext = true;
                Twinfield_Controller.sendTransactionData(trasaction.id);
            }
    }
}