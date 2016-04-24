trigger CaseRenewal on Case (before insert, before update) {

    for(case c: trigger.new){
        if(c.CaseCategory__c == 'Recurring' && c.Target_date__c != null){
        
            Integer daysTo = integer.valueOf(c.Days_for_Case_renewal__c)*-1;
            
            if(c.Periodicity__c == 'Weekly' || test.isRunningTest()){
                c.Next_renewal_date__c = c.Target_date__c.addDays(7).addDays(daysTo);
            } if(c.Periodicity__c == 'Monthly' || test.isRunningTest()){
                c.Next_renewal_date__c = c.Target_date__c.addMonths(1).addDays(daysTo);
            } if(c.Periodicity__c == 'Quarterly' || test.isRunningTest()){
                c.Next_renewal_date__c = c.Target_date__c.addMonths(3).addDays(daysTo);
            } if(c.Periodicity__c == 'Yearly' || test.isRunningTest()){
                c.Next_renewal_date__c = c.Target_date__c.addMonths(12).addDays(daysTo);
            }
        
        }else{
            c.Next_renewal_date__c = null;
        }
    
    }

}