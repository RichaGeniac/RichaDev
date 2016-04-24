trigger CaseCreatePayrun on Case (after insert, after update) {

    for(Case c: trigger.new){
 
        if(trigger.isInsert && c.MyPaye_Payroll_ID__c != null ||
           trigger.isUpdate && c.MyPaye_Payroll_ID__c != null &&
                 c.MyPaye_Payroll_ID__c != trigger.oldMap.get(c.id).MyPaye_Payroll_ID__c){
        
           Pay_Run2__c lastPrun = null;
           Pay_Run2__c newPrun = new Pay_Run2__c();
        
           // 1 - get last payrun (if any):
           
               try{
                   lastPrun = [SELECT id, Tax_year__c, Tax_period__c FROM Pay_run2__c
                                WHERE Payroll_ID__c =: c.MyPaye_Payroll_ID__c];
               }catch(exception ex){}
           
           // 2 - creates the payrun:
           decimal newPeriod = null;
           if(lastPrun != null && lastPrun.Tax_period__c != null){
               newPeriod = lastPrun.Tax_period__c + 1;
           }
           
           string newTaxYear = null;
           if(lastPrun != null && lastPrun.Tax_year__c != null){
               newTaxYear = lastPrun.Tax_Year__c;
           }
           
           newPrun.Case__c = c.id;
           system.debug('\n\n### --- PAYRUN CASE ID: '+newPrun.Case__c);
           newPrun.Company__c = c.AccountId;
           newPrun.Payroll_ID__c = c.MyPaye_Payroll_ID__c;
           if(c.Target_date__c != null){
               newPrun.Date__c = c.Target_date__c;
           }else{
               newPrun.Date__c = system.today();
           }
           newPrun.Tax_year__c = newTaxYear;
           newPrun.Tax_period__c = newPeriod;
           newPrun.Type__c = 'Monthly payroll';
           newPrun.Status__c = 'Draft';
           
           //exception: case date >= 01.Apr.2015, reset Tax Period:
           /**
           date resetDate = date.newInstance(system.today().year(), 4, 1);
           if(newPrun.Date__c >= resetDate){
               newPrun.Tax_period__c = 1;
           }
           */
        
           insert newPrun;
        
        }
        
    
    }

}