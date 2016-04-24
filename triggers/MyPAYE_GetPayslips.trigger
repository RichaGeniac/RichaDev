trigger MyPAYE_GetPayslips on Pay_Run2__c (after update) 
{
    for(Pay_Run2__c pr : Trigger.new)
    {
        if(pr.Last_payslip_sync__c != trigger.oldMap.get(pr.id).Last_payslip_sync__c){
        
            List<Payslip__c> psList = new List<Payslip__c>();
            try{
                psList = [SELECT id FROM Payslip__c WHERE Pay_run2__c =: pr.id];
            }catch(exception ex){}
            if(psList.size() > 0){
                delete psList;
            }
            List<Attachment> prPdfList = new List<Attachment>();
            try{
                prPdfList = [SELECT id FROM Attachment WHERE ParentId =: pr.id];
            }catch(exception ex){}
            if(prPdfList.size() > 0){
                delete prPdfList;
            }
            
            MyPAYE_Controller.PayslipsRun(pr.id);
        }
            
    }
}