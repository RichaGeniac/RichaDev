/**
 * Created by richasharma on 02/02/2016.
 */

public class createNewGUser {

    public createNewGUser()
    {
    }
    public Id guId{set;get;}
    public Id orgWideEmailId{get;set;}
    public Id contId{get;set;}
    Public Id wfId{get;set;}

    /////////// Utility function starts //////////////

    // Helper function to get email template and send email

    //public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateApiName, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, Attachment[] attachList=null )
    /*public static void sendTemplatedEmail(String toRecipients, String ccRecipients, String templateApiName, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity )

    {
        Messaging.SingleEmailMessage emailM = new Messaging.SingleEmailMessage();

        Id templateId;
        try {templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;}
        catch (Exception e) {
            system.debug('Error in fetching email template');
        }

        String[] listOfRecipients = new List<String>();
        listOfRecipients.add(toRecipients);
        emailM.setToAddresses(listOfRecipients);
        emailM.setTargetObjectId(targetObjId);
        emailM.setWhatId(whatId);
        emailM.setorgWideEmailAddressId(orgWideEmailId);
        emailM.setTemplateId(templateId);
        emailM.setSaveAsActivity(saveAsActivity);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users

        try {
            system.debug('I have reached safely till here');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailM});
            return;
        }
        catch (EmailException e)
        {
            system.debug('Error in sending email - ');
        }

    }
    */

   /* public Contact getContactId(String name,String email,String accountId)
    {
        try
        {
            Contact contactDet = [select Id from contact where Name = :name and email = :email and accountId = :accountId];
            if(contactDet!=null && !contactDet.isEmpty())
            {
                return contactDet;
            }
            else
            {

            }
        }
        catch(exception e)
        {
            system.debug('Exception when retrieving contactId');
        }
    }
    */

    /////// Utility function ends ////////

    public createNewGUser(Map<Id,Employee__c> emp)
    {
        system.debug('I am here'+ emp);
        // Create a list of the geniac user

        //Map<String,string> gUsersMap = new Map<String,string>();

        // Create an list of employee to be created
        List<Employee__c> UpdateEmpList = new List<Employee__c>();
        List<Contact> createContactList = new List<Contact>();
        List<Employee__c> empList_to_link_GU = new List<Employee__c>();
        List<Messaging.SingleEmailMessage>  emailList = new List<Messaging.SingleEmailMessage>();
        List<Opportunity> listOpportunities = new List<Opportunity>();


        for(string empList: emp.keySet())
        {
            string name = emp.get(empList).Name;
            string company = emp.get(empList).Company__c;
            string firstName = emp.get(empList).FirstName__c;
            string lastName = emp.get(empList).LastName__c;
            string email = emp.get(empList).Email__c;
            string phone = emp.get(empList).phone__c;
            string position = emp.get(empList).position__c;
            string employeeId = emp.get(empList).Id;
            string roles = emp.get(empList).company_roles__c;
            boolean isFromHRPortal = emp.get(empList).isFromHRPortal__c;

            // Check if the gUser with this email and firstName in the same company already exists
            GENIAC_User__c existingGUser = new GENIAC_User__c();
            try {
                system.debug('Query print >>> '+'select Id, (select Id  from contacts__r  where AccountId=:'+company+') from GENIAC_User__c where email__c = :'+email);
                existingGUser = [select Id, (select Id from contacts__r where AccountId=:company) from GENIAC_User__c where email__c = : email];
                //existingGUser = [select id, contact_c.account__r.Name from GENIAC_User__c where firstName__c = : firstName and email__c = : email];

            }
            catch(exception e)
            {
                system.debug('dml Exception : '+ e.getMessage() + 'existingGUser :'+existingGUser);
            }

            // Only create a new GENIAC_User__c if there is not an existing one

            //String[] emailList = new String[] {email};
            //emailList.add(email);

            if(existingGUser.get('Id')==null)
            {
                // Create a new sobject of Geniac User which can be inserted.
                system.debug('Conversion_Account_ID__c  : >>>>>'+ company);
                GENIAC_User__c gu = new GENIAC_User__c(Name=firstName +' '+ lastName, FirstName__c = firstName, LastName__c = lastName, email__c = email, position__c = position,Conversion_Account_ID__c  = company, company__c = company, company_roles__c = roles);

                // Do not bulkify trigger as we need to get inserted GUser Id to update the employee object for the GU ID for this new employee.
                try{
                insert gu;
                }
                catch(exception e)
                {
                    system.debug('Exception raised');
                    //throw new exception(e.getMessage() + 'Could not create GU');
                }
                guId = gu.id;

                contact contExists = new contact();
                try
                {
                    system.debug('Query print for contact >>> '+'select Id from contact where firstName__c = :'+firstName+' and email__c = :'+email);

                    //contId = getContactId(name,email,company);
                    Contact contactDet = [select Id from contact where email = :email];
                    contId = contactDet.Id;
                    //return contactDet;


                }
                catch(exception e)
                {
                    system.debug('catch exception : >>>>>'+ contExists);

                }
                if(contId!=null)
                {
                    //contId = contExists.Id;
                    system.debug('if contactid >>>'+contId);
                }
                else
                {
                    // insert contact records which needs to be created for each GeniacUser record.
                    system.debug('First Name = ' + firstName + ' Last Name = ' + lastName);
                    
                    // Last name is mandatory in Contact object
                    
                    
                    Contact cont = new Contact(accountId = company, email = email, firstName = firstName, LastName = lastName, User__c = guId, position__c = position, phone = phone);

                    // insert contact as we need contact Id for email to be sent to this contact
                    try{
                    insert cont;
                    }
                    catch(exception e)
                    {
                        system.debug('Exception - Contact could not be inserted');
                    }
                    contId = cont.Id;
                    system.debug('else contactid >>>'+contId);
                }
                // If statement starts
                // Only create on-board opp and case if the employee is created from HR portal
                
                if(isFromHRPortal == true) 
                {
                
                // Create new oppurtunity
                date oppDate = System.now().date();

                Opportunity opp = new Opportunity();
                opp.Name = 'On-board '+ firstName+' '+lastName;
                opp.AccountId = company;
                opp.LeadSource = 'Other';
                opp.CloseDate = oppDate;
                opp.stageName = 'Prospecting';
                
                try{
                insert opp;
                }
                catch(exception e)
                {
                    system.debug('Exception - Could not create oppurtunity '+ e.getMessage());
                }
                // Create a case
                Case newCase = new Case();
                newCase.Description = 'On-board '+ firstName+' '+lastName;
                newCase.Status = 'New';
                newCase.Opportunity__c = opp.id;
                newCase.accountId = company;
                newCase.ContactId = contId;
                // get the workflow id

                try
                {
                    Workflow__c workFlowId = [select id from Workflow__c where Name = 'HR_Portal_Add_New_Employee(Dev)'];
                    wfId = workFlowId.Id;
                }
                catch(exception e)
                {
                    system.debug('Exception >>>>>');
                    wfId = 'a0611000006blgc';
                }
                newCase.Workflow__c = wfId;
                   
                try
                {
                    insert newCase;
                }
                catch(exception e)
                {
                    system.debug('Exception creating case ' + e.getMessage());
                }
                system.debug('Opportunity >>>>> '+ opp);
                }
                // If statement ends

                // Create list of employee records to be updated with their respective GeniacUser ids.
                employee__c tempEmpList = new employee__c(Id = EmployeeId, GENIACUser__c = gu.Id);

                // Add to the list of all the employees to be updated
                updateEmpList.add(tempEmpList);
            }
            // Link existing GUser to employee
            else
            {
                // if the geniacUser already exists
                // fetch contact id
                system.debug('existingGUser >>>>>>>> '+existingGUser);
                // Create list of employee records to be updated with the existing GeniacUser ids.
                Employee__c emplink_GU = new employee__c(Id = EmployeeId, GENIACUser__c = existingGUser.Id);
                guId = existingGUser.Id;
                // fetch contact details
                try
                {
                    Contact contactDet = [select Id from contact where email =:email and firstName =: firstName and User__c = :guId];
                    system.debug('select Id from contact where email =:'+email +'and firstName__c =:'+ firstName +'and User__c = :'+guId);
                    contId = contactDet.Id;
                }
                catch(exception e)
                {

                    system.debug('Exception e >>>' + e.getMessage());
                    system.debug('contact Id in else >>>' + contId);
                }
                    empList_to_link_GU.add(emplink_GU);
            }

            system.debug('emailist: >> '+email + 'guId: >> '+guId+ ' contId >>> '+contId);
            // Select organisation wide email address LID

            OrgWideEmailAddress orgWideEmail = [select id from OrgWideEmailAddress where Address='payroll@geniac.com'];

            if(orgWideEmail!=null)
            {
                orgWideEmailId = orgWideEmail.Id;
            }
            else
            {
                orgWideEmailId = '0D2b0000000L0HKCA0';
            }

            // Create single email object and add to the list which will be sent at once.
            // First check before sending email that isFromHRPortal__c is set to true to send email.
            if (isFromHRPortal == true) 
            {
            Messaging.SingleEmailMessage emailM = new Messaging.SingleEmailMessage();

            Id templateId;
            try
            {
                templateId = [select id, name from EmailTemplate where developername = : 'Employee_Registration_Invitation'].id;
            }
            catch (Exception e)
            {
                system.debug('Error in fetching email template');
            }

            String[] listOfRecipients = new List<String>();
            listOfRecipients.add(contId);
            emailM.setToAddresses(listOfRecipients);
            emailM.setTargetObjectId(contId);
            //emailM.setWhatId(guId);
            emailM.setWhatId(EmployeeId);
            emailM.setorgWideEmailAddressId(orgWideEmailId);
            emailM.setTemplateId(templateId);
            emailM.setSaveAsActivity(true);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users

            emailList.add(emailM);


            //sendTemplatedEmail(contId,'','Employee_Registration_Invitation',contId,guId,orgWideEmailId,true);
        

        // Send Mass email here

        // Send All the emails here
        try
        {
            if(isFromHRPortal == true) 
            {
                system.debug('I have reached safely till here >>>>>>'+ emailList);
                // Commented as A&I does not need this functionality
                //Messaging.sendEmail(emailList);
            }
        }
        catch (EmailException e)
        {
            system.debug('Error in sending email');
        }
        }
        try
        {
            /*if(listOpportunities!=null && !listOpportunities.isEmpty())
            {
                system.debug('listOpportunities >>>>>' + listOpportunities);
                insert listOpportunities;
            }*/
            if(updateEmpList!=null && !updateEmpList.isEmpty())
            {
                system.debug('updateEmpList >>>>>'+ updateEmpList);
                try{
                update updateEmpList;
                }
                catch(exception e)
                {
                system.debug('Exception - Coud not update');
                }
            }
            if(empList_to_link_GU!=null && !empList_to_link_GU.isEmpty())
            {
                system.debug('empList_to_link_GU >>>>>'+ empList_to_link_GU);
                try{
                update empList_to_link_GU;
                }
                catch(exception e)
                {
                system.debug('Exception - Coud not update employee');
                }
            }
        }
        catch(exception e)
        {
            system.debug('Exception :'+ e.getMessage());
        }
        }
    }
}