@isTest()
private class GetDueDilInfoTest{

    private static testMethod void CallGetDueDilInfoPagetest(){
    
        Duedil_Credentials__c ddkey = new Duedil_Credentials__c(Name='xxx', Endpoint_URL__c='xxx', API_Key__c='xxx', Active__c=true);
        insert ddkey;
    
        //Account A = new Account(Name='Test',Company_Number__c='68e3b9e793f242507365b221dad1fc8f3ae005c8');
        //Account A = new Account(Name='Test',Company_Number__c='ea8af9993b9d1a82ec2dfc09fbeec4808bb9d35a');
        Account A = new Account(Name='Test',Company_Number__c='09119857');
        upsert A Company_Number__c;
        
    
        PageReference pageRef = Page.GetDueDilInfo;
        Test.setCurrentPage(pageRef);
        
        // Add parameters to page URL
        //ApexPages.currentPage().getParameters().put('cn', '68e3b9e793f242507365b221dad1fc8f3ae005c8');
        ApexPages.currentPage().getParameters().put('cn', '09119857');
        
        // Verify that page fails without parameters
        GetDueDilInfo GDDcontroller = new GetDueDilInfo();
        String nextPage = GDDcontroller.saveDDil().getUrl();
        
        // Instantiate a new controller with all parameters in the page
        GDDcontroller = new GetDueDilInfo();
        nextPage = GDDcontroller.saveDDil().getUrl();
        
        // Edited by Richa Sharma - 14-Apr-16
        GDDcontroller.cancelDDil();
    }


}