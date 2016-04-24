trigger SplitName on Lead (before insert) {

    FOR(Lead l : trigger.new){
        IF(l.Full_Name__c != null && l.Full_Name__c != ''){
            //fall-back:
            l.LastName = l.Full_Name__c;
            //split name:
            TRY{
                l.FirstName = l.Full_Name__c.substring(0, l.Full_Name__c.indexOf(' ', 0));
                l.LastName  = l.Full_Name__c.substring(l.Full_Name__c.indexOf(' ', 0)+1, l.Full_Name__c.length());
            }CATCH(exception ex){}
        
        }
    
    }

}