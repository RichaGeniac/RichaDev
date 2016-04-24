global class MyPayeGetPayruns{

    public List<PayRunObj> PayRunsList {get;set;}
    public string accName {get;set;}

    public Class PayRunObj
    {
        public string pr_name {get;set;}
        public string pr_type {get;set;}
        public string pr_aidi {get;set;}
        public string pr_year {get;set;}
        public string pr_peri {get;set;}
    }

    public MyPayeGetPayruns(){
    
        PayRunsList = new List<PayRunObj>();
        
        String accId = ApexPages.currentPage().getParameters().get('id');
    
        List<Account> accL = [SELECT Name FROM Account WHERE id =: accId];
        accName = accL[0].Name;
    
        MyPAYE_SessionClass p_Session = new MyPAYE_SessionClass();
        
        String soapXML = p_Session.GetPayrollList(accId);
        system.debug('\n\n ### --- GET PAYROLL LIST - soapXML: '+soapXML);
        
        String XMLResponse;
        if(test.isRunningTest() == false){
            XMLResponse = p_Session.processXML('https://www.MyPAYE.co.uk/Secure/AcctLink/GetPayrollList.asp', soapXML );
        }else{
            XMLResponse = '<Payrolls><Payroll><PayrollName>Test Payroll</PayrollName><PayrollID>2vpvMjZ7gyg=</PayrollID><PayrollType>Monthly</PayrollType><CurrentTaxYear>2015/16</CurrentTaxYear><CurrentPayrollPeriod>4</CurrentPayrollPeriod><LastPayrollPeriod>3</LastPayrollPeriod><LastPayDate>2015-06-25</LastPayDate></Payroll><PayrollCount>1</PayrollCount></Payrolls>';
        }
        system.debug('\n\n ### --- GET PAYROLL LIST - XMLresponse: '+XMLresponse);
    
        XmlStreamReader reader = new XmlStreamReader(XMLResponse);
        system.debug('\n\n### --- XML READER: '+reader);
        
        
        
         PayRunObj payrollInfo = new PayRunObj();
         while( reader.hasNext() ){
         
             if (reader.getEventType() == XmlTag.START_ELEMENT) {
                 String nodeName = reader.getLocalName();
                 
                 if ('PayrollName'.equalsIgnoreCase(nodeName)){
                     reader.next();
                     if(reader.getEventType() == XmlTag.CHARACTERS)
                         payrollInfo.pr_name = reader.getText();
                 }
                 if('PayrollID'.equalsIgnoreCase(nodeName)){
                       reader.next();
                       if(reader.getEventType() == XmlTag.CHARACTERS)
                         payrollInfo.pr_aidi = reader.getText();
                 }
                 if ('PayrollType'.equalsIgnoreCase(nodeName)){
                     reader.next();
                     if(reader.getEventType() == XmlTag.CHARACTERS)
                         payrollInfo.pr_type = reader.getText();
                 }
                 if('CurrentTaxYear'.equalsIgnoreCase(nodeName)){
                   reader.next();
                   if(reader.getEventType() == XmlTag.CHARACTERS)
                     payrollInfo.pr_year = reader.getText();
                }
                if('CurrentPayrollPeriod'.equalsIgnoreCase(nodeName)){
                   reader.next();
                   if(reader.getEventType() == XmlTag.CHARACTERS)
                     payrollInfo.pr_peri = reader.getText();
                }
             }
             
             if(reader.getEventType() == XmlTag.END_ELEMENT){
                String nodeName = reader.getLocalName();
                
                if('Payroll'.equalsIgnoreCase(nodeName)){
                    PayRunsList.add(payrollInfo);
                }
            }
            
            reader.next();
         }

    
    }


}