trigger EmployeeDeleteDraft on Employee__c (after update) {

    FOR( Employee__c e : trigger.new ){
    
        IF( e.Draft__c == true && e.Delete_record__c == true ){
            List<Employee__c> EmployeeToDelete = [SELECT Id FROM Employee__c WHERE Id =: e.Id];
            Delete EmployeeToDelete;
        }
    
    }

}