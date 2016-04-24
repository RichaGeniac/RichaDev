public class ProcessCaseRecurrence{

    public static void ProcessToday(List<Case> caList, boolean IsBatch)
    {                  
        if(caList.size() != 0)
        {
            
            //create lists:
            List<Case> casListInsert = new List<Case>();
            List<Case> casListUpdate = new List<Case>();
            
            for(Case c : caList){
                Case casWa = new Case();
                
                casWa.AccountId = c.AccountId;
                casWa.ParentId  = c.ParentId;
                casWa.ContactId = c.ContactId;
                casWa.Subject   = c.Subject;
                casWa.Description    = c.Description;
                casWa.ProductId = c.ProductId;
                
                Integer daysTo = integer.valueOf(c.days_for_case_renewal__c);
                casWa.Target_Date__c = c.Next_renewal_Date__c.addDays(daysTo);
                
                casWa.CaseCategory__c = c.Casecategory__c;
                casWa.Periodicity__c = c.Periodicity__c;
                casWa.Days_for_Case_renewal__c = c.days_for_case_renewal__c;
                casWa.Workflow__c = c.Workflow__c;
                casWa.Internal_Case__c = c.Internal_Case__c;
                casWa.Parent_Product__c = c.Parent_Product__c;
                casWa.Area__c = c.Area__c;
                casWa.SubArea__c = c.SubArea__c;
                casWa.Document_for_employee__c = c.Document_for_Employee__c;
                casWa.Tier_2_Case__c = c.Tier_2_Case__c;
                
                casListInsert.add(casWa);
                
                //build list for updating renewed Cases:
                Case casWa2 = new Case();
                casWa2.Id = c.Id;
                casWa2.Renewed__c = true;
                casListUpdate.add(casWa2);
            
            }
            
            if(casListInsert.size() > 0){
                insert casListInsert;
                update casListUpdate;
            }
        

        }
        
    }
}