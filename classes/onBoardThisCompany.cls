/**
 * Created by richasharma on 15/02/2016.
 */

public with sharing class onBoardThisCompany {

    public Id cid;
    public String companyName;
    public GENIAC_User__c users{get;set;}
    public String selectedUser{get;set;}
    public Id orgWideEmailId{get;set;}
    public List<Contact> contDet{get;set;}
    public OrgWideEmailAddress orgWideEmail{get;set;}
    public List<GENIAC_User__c> userDet{get;set;}

    public pageReference sendEmail()
    {
        PageReference pageRef = new PageReference('http://www.google.com');
        system.debug('Send Email function here'+ selectedUser);

        try{
        userDet = [select id,Email__c from GENIAC_User__c where id =: selectedUser];
        system.debug('userDet - '+userDet);
        }
        catch(exception e)
        {
            system.debug('Exception - Could not fetch Geniac User');
        }
        // Get Contact Id for this Geniac User
        try{
        contDet = [select id from Contact where User__c =: selectedUser];
        system.debug('userDet - '+contDet);
        }
        catch(exception e)
        {
            system.debug('Exception - Could not fetch Contact');
        }
        if((contDet!=null) && (!contDet.isEmpty()))
        {
            Id conId= contDet.get(0).id;
        
            // Update contact by setting companyId to cId as contact can only be linked to one company at a time
            
            Contact conUpd = new contact(id= conId, accountId= cId);
            try{
            update conUpd;
            }
            catch(exception e)
            {
                system.debug('Exception - Contact could not be updated');
                
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Contact not found for this user. Create a contact for this GeniacUser and try again.'));
            return null;
        }

        /////////////////////////////////////
        try{
        orgWideEmail = [select id from OrgWideEmailAddress where Address='system@geniac.com'];
        }
        catch(exception e)
        {
            system.debug('Exception - OrganisationWideEmailAddress not found');
        }
        if(orgWideEmail!=null)
        {
            orgWideEmailId = orgWideEmail.Id;
        }
        else
        {
            orgWideEmailId = '0D2b0000000L0HKCA0';
        }

        // Create single email object and add to the list which will be sent at once.
        Messaging.SingleEmailMessage emailM = new Messaging.SingleEmailMessage();

        Id templateId;
        try
        {
            templateId = [select id, name from EmailTemplate where developername = : 'company_onboarding_NewChange'].id;
        }
        catch (Exception e)
        {
            system.debug('Error in fetching email template');
        }

        List<Messaging.SingleEmailMessage>  emailList = new List<Messaging.SingleEmailMessage>();
        String[] listOfRecipients = new List<String>();
        String toEmailAddress = userDet.get(0).Email__c;
        listOfRecipients.add(toEmailAddress);
        emailM.setToAddresses(listOfRecipients);
        emailM.setTargetObjectId(contDet.get(0).id);
        //emailM.setWhatId(guId);
        emailM.setWhatId(userDet.get(0).id);
        emailM.setorgWideEmailAddressId(orgWideEmailId);
        emailM.setTemplateId(templateId);
        emailM.setSaveAsActivity(true);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users

        emailList.add(emailM);

        try
        {
            system.debug('I have reached safely till here >>>>>>'+ emailList);
            Messaging.sendEmail(emailList);

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Email has been sent to the user.'));
            return null;
        }
        catch (EmailException e)
        {
            system.debug('Error in sending email');

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Email not sent'));
            return null;
        }

        /////////////////////////////////////

        return null;
    }

    public String getcompanyName()
    {

        List <Account> companyDetail = [select id,name from Account where id=:cId];
        system.debug('Company Name: '+ companyDetail);
        companyName = companyDetail.get(0).name;

        system.debug('i am here in getCompanyName');
        return companyName;
    }

    /*public void setcompanyName(String companyName)
    {
        this.companyName = companyName;
    }*/

    public List<SelectOption> getoptions()
    {
        // Select all the geniac users for this company
        system.debug('select id,FirstName__c,LastName__c, Email__c from GENIAC_User__c where Conversion_Account_ID__c =:'+ cId);
        //List<GENIAC_User__c> usersList = [select id,FirstName__c,LastName__c, Email__c from GENIAC_User__c where Conversion_Account_ID__c =: cId];
        List<Employee__c> usersList = [select GeniacUser__r.id,GeniacUser__r.email__c,GeniacUser__r.FirstName__c,GeniacUser__r.LastName__c from employee__c where Company__c =:cId and GeniacUser__r.id!=null];

        List<SelectOption> options = new List<SelectOption>();

        if(usersList!=null && !usersList.isEmpty())
        {
            //for(GENIAC_User__c optionList : usersList)
            for(Employee__c optionList : usersList)
            {
                options.add(new SelectOption(optionList.GeniacUser__r.id, optionList.GeniacUser__r.FirstName__c+ ' '+ optionList.GeniacUser__r.LastName__c));
                //options.add(new SelectOption(optionList.id, optionList.FirstName__c+ ' '+ optionList.LastName__c));
                //options.add(new SelectOption(optionList.FirstName__c+ ' '+ optionList.LastName__c, optionList.id));
            }
        }
        system.debug('Options >>> '+options);

        return options;
    }

    /*public GENIAC_User__c getUsers()
    {
        //List<GENIAC_User__c> users = [select id,FirstName__c,LastName__c, Email__c from GENIAC_User__c where Conversion_Account_ID__c =: cId];
        //system.debug('users +++++ '+users);
        return users;
    }*/

    public void setSelectedUser(String selectedUser)
    {
        this.selectedUser = selectedUser;
    }

    // Read from the url variable

    public onBoardThisCompany()
    {
        cId = ApexPages.currentpage().getparameters().get('cid');
    }

    public string getMyself()
    {
        string myself = 'Richa Sharma';
        return myself;
    }

}