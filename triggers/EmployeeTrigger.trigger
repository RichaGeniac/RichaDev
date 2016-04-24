trigger EmployeeTrigger on Employee__c (after insert,before insert,before update,after update) {

if(trigger.isBefore)
{
    if(Trigger.isInsert)
    {
        Map<Id,employee__c> allEmpRecords = new Map<Id,employee__c>();
       for(employee__c e : trigger.new)
           {
               system.debug('I am here' + e);
               allEmpRecords.put(e.Id,e);
           }
       
       checkEmpExistence newEmp = New checkEmpExistence(allEmpRecords);
    }
}


if(trigger.isAfter)
{
    if(Trigger.isInsert)
    {
       //If new employee is created
       Map<Id,employee__c> allEmp = new Map<Id,employee__c>();
       for(employee__c e : trigger.new)
           {
               allEmp.put(e.Id,e);
           }
       
       createNewGUser newUser = New createNewGUser(allEmp);
       //createNewGUserMassEmail newUser = New createNewGUserMassEmail(allEmp);
    }
    /* Commnenting right now before A&I goes live
    // As employee update trigger needs to be tested before going live and is not required in this release.
    if(Trigger.isUpdate)
    {
            //If an empoyee is updated
            Map<Id,employee__c> updEmp = new Map<Id,employee__c>();
            for(employee__c e : trigger.new)
            {
                updEmp.put(e.Id,e);
            }
            updateCaseDetails updCaseDet = New updateCaseDetails(updEmp);
    }
    */
}
}