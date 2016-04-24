/**
 * Created by richasharma on 19/02/2016.
 */

public class createNewGUserMassEmail {

public createNewGUserMassEmail()
{
}
public Id guId{set;get;}
public Id orgWideEmailId{get;set;}
public Id contId{get;set;}

/////////// Utility function starts //////////////

// Helper function to get email template and send email

//public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateApiName, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity, Attachment[] attachList=null )
public static void sendTemplatedEmail(String toRecipients, String ccRecipients, String templateApiName, ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity )

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

/////// Utility function ends ////////

public createNewGUserMassEmail(Map<Id,Employee__c> emp)
{
system.debug('I am here'+ emp);
// Create a list of the geniac user

//Map<String,string> gUsersMap = new Map<String,string>();

// Create an list of employee to be created
List<Employee__c> UpdateEmpList = new List<Employee__c>();
List<Contact> createContactList = new List<Contact>();
List<Employee__c> empList_to_link_GU = new List<Employee__c>();
    List<Messaging.SingleEmailMessage>  emailList = new List<Messaging.SingleEmailMessage>();

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

// Check if the gUser with this email and firstName in the same company already exists
GENIAC_User__c existingGUser = new GENIAC_User__c();
try {
system.debug('Query print >>> '+'select Id, (select Id  from contacts__r) from GENIAC_User__c where firstName__c = :'+firstName+' and email__c = :'+email);
existingGUser = [select Id, (select Id from contacts__r where AccountId=:company) from GENIAC_User__c where firstName__c = :'firstName' and email__c = :'email'];

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
system.debug('Conversion_Account_ID__c	: >>>>>'+ company);
GENIAC_User__c gu = new GENIAC_User__c(Name = name, FirstName__c = firstName, LastName__c = lastName, email__c = email, position__c = position,Conversion_Account_ID__c	 = company);

// Do not bulkify trigger as we need to get inserted GUser Id to update the employee object for the GU ID for this new employee.
insert gu;

guId = gu.id;

// insert contact records which needs to be created for each GeniacUser record.
system.debug('First Name = '+ firstName+' Last Name = '+ lastName);
Contact cont = new Contact(accountId = company, email = email, firstName = firstName, LastName = lastName, User__c = gu.Id, position__c = position, phone = phone);

// insert contact as we need contact Id for email to be sent to this contact
insert cont;
contId = cont.Id;

// Create list of employee records to be updated with their respective GeniacUser ids.
employee__c tempEmpList = new employee__c(Id = EmployeeId, GENIACUser__c = gu.Id);

// Add to the list of all the employees to be updated
updateEmpList.add(tempEmpList);
}
// Link new GUser to employee
else
{
system.debug('existingGUser >>>>>>>> '+existingGUser);
// Create list of employee records to be updated with the existing GeniacUser ids.
Employee__c emplink_GU = new employee__c(Id = EmployeeId, GENIACUser__c = existingGUser.Id);
guId = existingGUser.Id;
guId = existingGUser.Id;
empList_to_link_GU.add(emplink_GU);
}

system.debug('emailist: >> '+email + 'guId: >> '+guId);
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

    // Create a list of Single email message



    Messaging.SingleEmailMessage emailM = new Messaging.SingleEmailMessage();

    Id templateId;
    try {templateId = [select id, name from EmailTemplate where developername = : 'Employee_Registration_Invitation'].id;}
    catch (Exception e) {
        system.debug('Error in fetching email template');
    }

    String[] listOfRecipients = new List<String>();
    listOfRecipients.add(contId);
    emailM.setToAddresses(listOfRecipients);
    emailM.setTargetObjectId(contId);
    emailM.setWhatId(guId);
    emailM.setorgWideEmailAddressId(orgWideEmailId);
    emailM.setTemplateId(templateId);
    emailM.setSaveAsActivity(true);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users

    emailList.add(emailM);

    /////////////////////////////////////////

//sendTemplatedEmail(contId,'','Employee_Registration_Invitation',contId,guId,orgWideEmailId,true);
}
    // Send All the emails here
    try {
        system.debug('I have reached safely till here >>>>>>'+ emailList);
        Messaging.sendEmail(emailList);
        return;
    }
    catch (EmailException e)
    {
        system.debug('Error in sending email - ');
    }

    try
{
if(updateEmpList!=null && !updateEmpList.isEmpty())
{
update updateEmpList;
}
if(empList_to_link_GU!=null && !empList_to_link_GU.isEmpty())
{
update empList_to_link_GU;
}
}
catch(exception e)
{
system.debug('Exception :'+ e.getMessage());
}
}
}