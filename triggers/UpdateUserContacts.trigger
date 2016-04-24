trigger UpdateUserContacts on GENIAC_User__c (before update) {
    
     
    Set <Id> userIds = new Set <Id>();
    for(GENIAC_User__c u : Trigger.new){
        userIds.add(u.Id);
    }

    if(userIds != null && userIds.size() > 0){
        
        Map <Id, List <Contact>> userContactsMap = new Map <Id, List <Contact>>();
        for(Contact c : [SELECT Id, User__c, FirstName, LastName, Email, Phone, Position__c, PositionOther__c FROM Contact WHERE User__c in: userIds]){
            if(userContactsMap.containsKey(c.User__c)){
                userContactsMap.get(c.User__c).add(c);
            } else {
                List <Contact> l = new List <Contact>();
                l.add(c);
                userContactsMap.put(c.User__c, l);
            }
        }
        
        List <Contact> contactList = new List <Contact>();
        for(GENIAC_User__c u : Trigger.new){
        
            boolean fname, lname, email, phone, position, pOther;
            
            // first name
            if(Trigger.oldMap.get(u.Id).FirstName__c != Trigger.newMap.get(u.Id).FirstName__c){
                fname = true;
            } else fname = false;
            
            // last name
            if(Trigger.oldMap.get(u.Id).LastName__c != Trigger.newMap.get(u.Id).LastName__c){
                lname = true;
            } else lname = false;
             
            // email
            if(Trigger.oldMap.get(u.Id).Email__c != Trigger.newMap.get(u.Id).Email__c){
                email = true;
            } else email = false;
            
            // phone
            if(Trigger.oldMap.get(u.Id).Phone__c != Trigger.newMap.get(u.Id).Phone__c){
                phone = true;
            } else phone = false;
            
            // position or position other
            if(Trigger.oldMap.get(u.Id).Position__c != Trigger.newMap.get(u.Id).Position__c){
                position = true;
            } else position = false;
            
            if(Trigger.oldMap.get(u.Id).PositionOther__c != Trigger.newMap.get(u.Id).PositionOther__c){
                pOther = true;
            } else pOther = false;
            
            List <Contact> userContactsList = userContactsMap.get(u.Id);            
            if(userContactsList != null && userContactsList.size() > 0){
                for(Contact c : userContactsList){
                    
                    if(fname){ c.FirstName = u.FirstName__c; }
                    if(lname){ c.LastName = u.LastName__c; }
                    if(email){ c.Email = u.Email__c; }
                    if(phone){ c.Phone = u.Phone__c; }
                    if(position){ c.Position__c = u.Position__c; }
                    if(pOther){ c.PositionOther__c = u.PositionOther__c; }
                    
                }
                
                contactList.addAll(userContactsList);
            }
        }
        
        if(contactList != null && contactList.size() > 0){
            update contactList;
        }
    }
    
}