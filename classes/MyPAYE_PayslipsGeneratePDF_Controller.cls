public class MyPAYE_PayslipsGeneratePDF_Controller{

    public id prId {get; set;}

    public MyPAYE_PayslipsGeneratePDF_Controller(ApexPages.StandardController controller) {

        Pay_Run2__c p = (Pay_Run2__c)controller.getRecord();
        prId = p.Id;

    }
    
    
    public pagereference generatePDFs(){
    
        MyPAYE_Controller.PayslipsGeneratePDF(prId);
        
        ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.info, 'Payslip PDFs generated');
        ApexPages.addMessage(msg);
        
        return null;
    
    }


}