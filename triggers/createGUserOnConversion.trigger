trigger createGUserOnConversion on Lead (after update) 
{
        Id gUId{get;set;}
  // Create gUser after a lead has been converted

      //If new employee is created
      List<Geniac_User__c> gUserList = new List<Geniac_User__c>();
      //for(Lead l : trigger.new)
      //{
        //if (Trigger.old[0].isConverted == false && Trigger.new[0].isConverted == true) 
        //{
          // if a new contact was created
          
          if(Trigger.New[0].ConvertedContactId != null) 
          {
            // Create new gUser
            
            system.debug('firstName field >>> '+ Trigger.New[0].firstName);
            system.debug('lastName field >>> '+ Trigger.New[0].lastName);
            system.debug('ConvertedContactId >>> '+ Trigger.New[0].ConvertedContactId);
        
            GENIAC_User__c gUser = new GENIAC_User__c();
            
            gUser.Name = Trigger.New[0].firstName + ' '+ Trigger.New[0].lastName;
            gUser.FirstName__c = Trigger.New[0].firstName;
            gUser.LastName__c = Trigger.New[0].lastName;
            gUser.Email__c = Trigger.New[0].email;
            gUser.Phone__c = '';
            gUser.Position__c = 'Director';
            gUser.Company__c = Trigger.New[0].ConvertedAccountId;
            gUser.Company_roles__c = 'Director';
            
            /*gUser.Name = l.firstName + ' '+ l.lastName;
            gUser.FirstName__c = l.firstName;
            gUser.LastName__c = l.lastName;
            gUser.Email__c = l.email;
            gUser.Phone__c = '0';
            gUser.Position__c = 'Director';
            gUser.Company__c = l.ConvertedAccountId;
            */
            try
            {
                insert gUser;
            }
            catch(exception e)
            {
                system.debug('Exception - Could not create Geniac User ' +e.getMessage());
            }
            gUID = gUser.id;
            
            Contact con = new Contact(Id = Trigger.New[0].ConvertedContactId, User__c = gUID);
            
            try
            {   
                update con;
            }
            catch(exception e)
            {
                system.debug('Exception - Contact could not be updated >>> '+ gUserList);
            }
            
            //gUserList.add(gUser);
          }
         
    //}
}