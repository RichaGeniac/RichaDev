/**
 * Created by richasharma on 05/02/2016.
 */

public with sharing class createNewEmp {

    public Id gUserId{get;set;}
    public Id cId{get;set;}
    public createNewEmp()
    {
    }

    public createNewEmp(Map<Id, GENIAC_User__c> gUsers)
    {
        system.debug('I am here'+ gUsers);

        for(string userList: gUsers.keySet())
        {
            // Check if the employee already exists
            gUserId = gUsers.get(userList).id;
            cId = gUsers.get(userList).Company__c;
            String firstName = gUsers.get(userList).FirstName__c;
            String lastName = gUsers.get(userList).LastName__c;
            String email = gUsers.get(userList).Email__c;
            String position = gUsers.get(userList).position__c;
            String roles = gUsers.get(userList).company_roles__c;

            system.debug('gUserId '+ gUserId);
            List<Employee__c> empDet = new List<Employee__c>();
            List<Contact> conDet = new List<Contact>();

            try
            {
                empDet = [select id,email__c, GeniacUser__c from employee__c where email__c =: email and Company__c =: cId limit 1];
                system.debug('empDet' + empDet);
            }
            catch(exception e)
            {
                system.debug('Exception >>>' + e.getMessage());
            }
            //Check if contact exists or not
            
            try
            {
                conDet = [select id from Contact where email =: email];
            }
            catch(exception e)
            {
                system.debug('exception - could not fetch contact '+e.getMessage());
            }
            
            if((conDet!=null) && (!conDet.isEmpty()))
            {
                // Link this contact with GUserId
                Contact cUpd = new Contact(id=conDet.get(0).id, User__c= gUserId);
                
                try
                {
                    update cUpd;
                }
                catch(exception e)
                {
                    system.debug('Exception - Contact not updated '+ e.getMessage());
                }
            }
            else
            {
            
            // Create a contact, link it with account and Geniac User Id
            Contact con = new Contact();
            con.FirstName = firstName;
            con.LastName = lastName;
            con.email = email;
            con.position__c = position;
            con.accountId = cId;
            con.User__c = gUserId;
            
            try
            {          
                insert con;
            }
            catch(exception e)
            {
                system.debug('Exception - Contact not created'+ e.getMessage());
            }
            }

            // If employee exists, does not create employee
            // If employee exists, dont create, only link it with Geniac User Id
            
            if((empDet!=null) && (!empDet.isEmpty()))
            {
                // Check if this employee is linked to any GeniacUser
                if((empDet.get(0).GeniacUser__c!='') && (empDet.get(0).GeniacUser__c!=null))
                {
                    // Dont do anything as the employee is already linked to a GeniacUser
                }
                else
                {
                    system.debug('empDet = '+empDet);
                    Id userId = empDet.get(0).Id;
                    empDet.get(0).GENIACUser__c = gUserId;
                    try{
                    update empDet;
                    }
                    catch(exception e)
                    {
                        system.debug('exception - Could not update employee'+ e.getMessage());
                    }
                }
            }
            // Create employee
            else
            {
                Employee__c emp = new Employee__c();
                emp.FirstName__c = firstName;
                emp.LastName__c = lastName;
                emp.Email__c = email;
                emp.Name = firstName+' '+lastName;
                //emp.Company_Roles__c = position;
                emp.Company_Roles__c = roles;
                emp.Company__c = cId;
                emp.GENIACUser__c = gUserId;

                system.debug('cId >>>'+cId);
                try
                {
                    insert emp;
                }
                catch(exception e)
                {
                    system.debug('exception - Could not add employee'+ e.getMessage());
                }
            }



        }
    }
}