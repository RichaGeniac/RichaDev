trigger Twinfield_sendAccountDetail on Account (after insert, after update)
{
    if(!Twinfield_ProcessorControl.inFutureContext && system.isFuture() == false)
    {
        for(Account account: trigger.new)
            if(account.Send_to_Twinfield__c== true)
               Twinfield_Controller.sendAccountData(account.id);
    }
    else
    {
        Set<id> AccIds = new Set<id>();
        for(Account account: trigger.new)
            if(account.Send_to_Twinfield__c && account.Integrated_with_Twinfield__c)
                AccIds.add(account.id);
        
        if(AccIds.size()>0)
        {
            List<Transaction__c> t_list = new List<Transaction__c>();
            t_list = [SELECT id, Send_to_Twinfield__c, Integrated_with_Twinfield__c
                      FROM Transaction__c
                      WHERE Company__c IN :AccIds 
                        AND Send_to_Twinfield__c = true 
                        AND Integrated_with_Twinfield__c = true];
            
            if(t_list.size()>0)
            {
                try
                {
                    update t_list;
                }Catch(DmlException e){}
            }
        }
    }
    
}