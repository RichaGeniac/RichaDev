trigger createCaseOnActivation on Account (after update) {
    List<Case> lCase = new List<Case>(); 
    for(Account acc: Trigger.new){
        if(acc.companystatus__c =='Active' && acc.Activation_date__c == null && Trigger.oldMap.get(acc.id).companystatus__c != acc.companystatus__c){
        case c = new case();
        c.workflow__c =  label.AML_Workflow;
        c.ownerid = acc.ownerid;
        c.Subject = 'Anti-Money-Laundering Check';
        c.type = 'Provisioning';
        c.area__c = 'Services';
        c.accountid = acc.id;
        lCase.add(c);}
    }
    
    if(lcase.size() > 0){
        insert lcase;  
        
    system.debug('----- after debug---'+lcase);}     
}