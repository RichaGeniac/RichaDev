trigger ContractCalcBillingDates on Contract (before insert, before update) {

    for(Contract co : trigger.new){
        
        //Calc Next Billing Date:
        if(co.Last_Billing_date__c == null){
            co.Next_Billing_Date__c = co.First_Billing_Date__c;
        }else{
            if(co.Price_Unit__c == 'per Month'){
                co.Next_Billing_Date__c = co.Last_Billing_Date__c.addMonths(1);
            }else if(co.Price_Unit__c == 'per Year'){
                co.Next_Billing_Date__c = co.Last_Billing_Date__c.addYears(1);
            }
        }
    
    }


}