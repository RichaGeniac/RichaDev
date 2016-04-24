public with sharing class MyPAYE_SessionClass 
{
     
    
    // ----------------------------------------------------------- [GetPayrollList]
    public String GetPayrollList(id accId)
    {
        // busca credenciais do empregador:
        Account a = new Account();
        a = [SELECT MyPaye_Web_Access_ID__c, MyPaye_Web_Access_Password__c FROM Account WHERE id =: accId];
    
        XmlStreamWriter w = new XmlStreamWriter();
        
        w.writeStartElement(null, 'MyPAYELink', null); // MyPAYELink - Start
            w.writeStartElement(null, 'Login', null); // Login- Start
                 w = AddElement(w, 'LinkID', a.MyPaye_Web_Access_ID__c);
                 w = AddElement(w, 'LinkPwd', a.MyPaye_Web_Access_Password__c);
             w.writeEndElement(); // Login- END 
             w = AddElement(w, 'Function', 'GetPayrollList');
        w.writeEndElement(); // MyPAYELink - END 
        system.debug('here i am >>>'+ w);
        return w.getXmlString();
    }
    
    // ----------------------------------------------------------- [GetPayslip]
    public String GetPayslip(id accId, Pay_Run2__c payRun)
    {
        // busca credenciais do empregador:
        Account a = new Account();
        a = [SELECT MyPaye_Web_Access_ID__c, MyPaye_Web_Access_Password__c FROM Account WHERE id =: accId];
    
        XmlStreamWriter w = new XmlStreamWriter();
        
        w.writeStartElement(null, 'MyPAYELink', null); // MyPAYELink - Start
            w.writeStartElement(null, 'Login', null); // Login- Start
                 w = AddElement(w, 'LinkID', a.MyPaye_Web_Access_ID__c);
                 w = AddElement(w, 'LinkPwd', a.MyPaye_Web_Access_Password__c);
             w.writeEndElement(); // Login- END 
             w = AddElement(w, 'Function', 'GetPayslip');
             w = AddElement(w, 'PayrollID', payRun.Payroll_ID__c);
             w = AddElement(w, 'EmployeeID', '');
             w = AddElement(w, 'TaxYear', payRun.Tax_Year__c);
             w = AddElement(w, 'TaxPeriod', payRun.Tax_Period__c);
             w = AddElement(w, 'IncludeNIEarnings', 'No');
        w.writeEndElement(); // MyPAYELink - END 
        
        return w.getXmlString();
    }
    
    // ----------------------------------------------------------- [GetPaySummary]
    public String GetPaySummary(id accId, Pay_Run2__c payRun)
    {
        // busca credenciais do empregador:
        Account a = new Account();
        a = [SELECT MyPaye_Web_Access_ID__c, MyPaye_Web_Access_Password__c FROM Account WHERE id =: accId];
    
        XmlStreamWriter w = new XmlStreamWriter();
        
        w.writeStartElement(null, 'MyPAYELink', null); // MyPAYELink - Start
            w.writeStartElement(null, 'Login', null); // Login- Start
                 w = AddElement(w, 'LinkID', a.MyPaye_Web_Access_ID__c);
                 w = AddElement(w, 'LinkPwd', a.MyPaye_Web_Access_Password__c);
             w.writeEndElement(); // Login- END 
             w = AddElement(w, 'Function', 'GetPaySummary');
             w = AddElement(w, 'PayrollID', payRun.Payroll_ID__c);
             w = AddElement(w, 'TaxYear', payRun.Tax_Year__c);
             w = AddElement(w, 'TaxPeriod', payRun.Tax_Period__c);
        w.writeEndElement(); // MyPAYELink - END 
        
        return w.getXmlString();
    }
    
    // -------------------------------------------------------------------- [Writer Element]
    public XmlStreamWriter AddElement (XmlStreamWriter w, String Field, String value)
    {
        w.writeStartElement(null, Field, null);
        w.writeCharacters(checkForNull(value));
        w.writeEndElement();
        
        return w;
    }
    
    public XmlStreamWriter AddElement (XmlStreamWriter w, String Field, Decimal value)
    {
        w.writeStartElement(null, Field, null);
        w.writeCharacters(checkForNull(value));
        w.writeEndElement();
        
        return w;
    }
        
    // ---------------------------------------------------------------[check empty - strings]
    private String checkForNull(String s){
        if(s == null)
            return '';
        return s;
    }
    
    // ---------------------------------------------------------------[check empty - Decimal]
    private String checkForNull(Decimal d){
        if(d == null)
            return '';
        return ''+d;
    }
    
    public String processXML(String endpoint, String xmlString)
    {
        HttpRequest request = CreateHttpRequest(endpoint, xmlString);
        String responseString = SendRequestHttp(request);
        
        System.debug('## RESPONSE RECEIVED =' + responseString );
        
        if(!responseString.contains('Error'))
        {
            responseString = responseString.replaceAll('&lt;', '<');
            responseString = responseString.replaceAll('&gt;', '>');
            responseString = responseString.replaceAll(' ', ' ');
        }
        
        System.debug('## RESPONSE AFTER ='+responseString);

        return responseString;
    }
    
     // -------------------------------------------------------------- [HTTP - Create Request ]
    public HttpRequest CreateHttpRequest (String endpoint, String soapXML)
    {
        HttpRequest request = new HttpRequest();
        
        request.setTimeout(120000);
        request.setMethod('POST');
        request.setEndPoint(endpoint); 
        request.setHeader('Content-type','application/x-www-form-urlencoded; charset=UTF-8');
        request.setBody(soapXML);
        
        return request;
    }
    
    // -------------------------------------------------------------- [HTTP - Send Request ]
    String SendRequestHttp (HttpRequest request)
    {
        Http http = new Http();
        try
        {
            HttpResponse response = new HttpResponse();
            response = http.send(request);
            
            system.debug('\n\n ### --- MYPAYE RESPONSE: '+response);
            
            
            if(response != null && response.getStatus() == 'OK' && response.getStatusCode() == 200)
            {
                system.debug('\n\n ### --- MYPAYE RESPONSE BODY: '+response.getBody());
            
                if(response.getBody() != '')
                    return response.getBody();
                else
                    return 'Error - HTTP Server response not found.';
            }
                
            else
            {
                if(response == null)
                    return 'Error - HTTP Server response not found.';
                else
                    return 'Error\n\tCode: ' + response.getStatusCode() + '\n\tStatus: '+ response.getStatus();
            }
        } catch (System.CalloutException e)
        {
            return e.getMessage();
        }
    }    

}