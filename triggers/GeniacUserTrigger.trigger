trigger GeniacUserTrigger on GENIAC_User__c (after insert) {
{
if(trigger.isAfter)
{
    if(Trigger.isInsert)
    {
       //If new employee is created
       Map<Id,Geniac_User__c> allGUsers = new Map<Id,Geniac_User__c>();
       for(Geniac_User__c e : trigger.new)
           {
               allGUsers.put(e.Id,e);
           }
       
       createNewEmp newEmp = New createNewEmp(allgUsers);
    }
}
}

}