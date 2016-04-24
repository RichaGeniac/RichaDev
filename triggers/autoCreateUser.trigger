trigger autoCreateUser on Contact (before insert, before update) {


    for(Contact cont : trigger.new){
    
        if(trigger.isInsert){
    
            if( cont.Create_User__c ){
                GENIAC_User__c GeniU = new GENIAC_User__c();
                GeniU.Name = cont.FirstName + ' ' + cont.LastName;
                GeniU.Email__c = cont.Email;
                GeniU.FirstName__c = cont.FirstName;
                GeniU.LastName__c = cont.LastName;
                GeniU.Phone__c = cont.Phone;
                GeniU.Position__c = cont.Position__c;
                GeniU.PositionOther__c = cont.PositionOther__c;
                GeniU.Created_from_Lead_Conversion__c = true;
                GeniU.Conversion_Account_ID__c = cont.AccountId;
                
                insert GeniU;
                
                cont.User__c = GeniU.id;
            }
        }
        
        if(trigger.isUpdate){
        
            if( cont.Create_User__c && cont.Create_User__c != Trigger.oldMap.get(cont.Id).Create_User__c){
                GENIAC_User__c GeniU = new GENIAC_User__c();
                GeniU.Name = cont.FirstName + ' ' + cont.LastName;
                GeniU.Email__c = cont.Email;
                GeniU.FirstName__c = cont.FirstName;
                GeniU.LastName__c = cont.LastName;
                GeniU.Phone__c = cont.Phone;
                GeniU.Position__c = cont.Position__c;
                GeniU.PositionOther__c = cont.PositionOther__c;
                GeniU.Created_from_Lead_Conversion__c = true;
                GeniU.Conversion_Account_ID__c = cont.AccountId;
                
                insert GeniU;
                
                cont.User__c = GeniU.id;
            }
        
        }
    }

}