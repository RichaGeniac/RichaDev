public class checkEmpExistence {

    public checkEmpExistence()
    {
    }
    public checkEmpExistence(Map<Id,Employee__c> empRecords)
    {
            List<employee__c> getEmp = new List<employee__c>();
            for(string empList: empRecords.keySet())
            {
            	//I am here
                string email = empRecords.get(empList).Email__c;
                string company = empRecords.get(empList).company__c;
                try
                {
                    getEmp = [select id, status__c from employee__c where email__c =: email and company__c =: company];
                }
                catch(exception e)
                {
                    system.debug('exception - could not fetch employee record'+ e.getMessage());
                }
                
                if((getEmp!=null) && (!getEmp.isEmpty()))
                {
                    try
                    {
                        throw new customException('Exception - Employee already exists');
                    }
                    catch(customException e)
                    {
                        //throw new Exception('Employee already exists');
                        system.debug('exception - Employee record exists' + e.getMessage());
                        //Trigger.New[0]. Email__c.addError('Employee already exists');
                        //throw new customException('Employee already exists');
                        //throw new HttpResponseException(Request.CreateErrorResponse(HttpStatusCode.NotFound,'Employee record exixts'));
                    }
                }
                
                
            }
        }
        
}