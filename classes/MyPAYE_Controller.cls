global class MyPAYE_Controller
{
    public Pay_Run2__c payRun {get; set;}
    public List<Payslip__c> lines {get; set;}
    public List<Payslip__c> linesEarnings {get; set;}
    public List<Payslip__c> linesDeductions {get; set;}
    public Payslip__c totais {get;set;}
    
  
    

    //********************************************************************* [Pay Run PAGE]
    public MyPAYE_Controller(ApexPages.StandardController controller)
    {
        payRun = (Pay_Run2__c)controller.getRecord();
        payRun = PayRunInfo(payRun.id);
        lines = new List<Payslip__c>();
        lines = PayslipListing(payRun.id);
        linesEarnings = PayslipListingEarnings(payRun.id);
        linesDeductions = PayslipListingDeductions(payRun.id);
        totais = CalcPayslipTotals(payRun.id);
    }
    
    
    //********************************************************************* [Pay slip PAGE]
    
    
    
    //********************************************************************* [QUERY]
    public static Pay_Run2__c PayRunInfo (ID payRunID)
    {
        Pay_Run2__c prInfo = new Pay_Run2__c();
         
        prInfo = [SELECT id, Name, Company__c, Company__r.name, Date__c, Status__c, Type__c,
                         Payroll_ID__c, Tax_Period__c, Tax_Year__c, Company__r.id
                  FROM Pay_Run2__c
                  WHERE id = :payRunID];
                                  
        return prInfo; 
    }
    
    public List<Payslip__c> PayslipListing(ID payRunID)
    {
        List<Payslip__c> Payslip_List = new List<Payslip__c>();
         
        Payslip_List = [SELECT id, Name, Employee__c, Employee__r.Name, Employee__r.Payroll_Ref__c, Total_Earnings__c,
                               Total_Deductions__c, PAYE__c, NIC__c, Net_Pay__c
                        FROM Payslip__c
                        WHERE Pay_Run2__c = :payRunID];
                                  
        return Payslip_List ; 
    }
    
    public List<Payslip__c> PayslipListingEarnings(ID payRunID)
    {
        List<Payslip__c> Payslip_List = new List<Payslip__c>();
         
        Payslip_List = [SELECT id, Employee__r.Payroll_Ref__c, Employee__r.Name, Total_Earnings__c,
                            (SELECT id, DisplayName__c, Amount__c FROM Payroll_Items1__r
                              WHERE Type__c = 'Earnings')
                        FROM Payslip__c
                        WHERE Pay_Run2__c = :payRunID];
                                  
        return Payslip_List ; 
    }
    public List<Payslip__c> PayslipListingDeductions(ID payRunID)
    {
        List<Payslip__c> Payslip_List = new List<Payslip__c>();
         
        Payslip_List = [SELECT id, Employee__r.Payroll_Ref__c, Employee__r.Name, Total_Deductions__c,
                            (SELECT id, DisplayName__c, Amount__c FROM Payroll_Items1__r
                              WHERE Type__c = 'Deductions')
                        FROM Payslip__c
                        WHERE Pay_Run2__c = :payRunID];
                                  
        return Payslip_List ; 
    }

    private Payslip__c CalcPayslipTotals(id payRunID){
        List<Payslip__c> Payslip_List = new List<Payslip__c>();
         
        Payslip_List = [SELECT id, Total_Earnings__c, Total_Deductions__c, PAYE__c, NIC__c, Net_Pay__c,
                               Employee__r.Salary__c,
                               Student_loan__c
                        FROM Payslip__c
                        WHERE Pay_Run2__c = :payRunID];
    
        
        decimal sal = 0.00;
        decimal earn = 0.00;
        decimal ded = 0.00;
        decimal paye = 0.00;
        decimal empnic = 0.00;
        decimal eeenic = 0.00;
        decimal loan = 0.00;
        decimal net = 0.00;
        
        for(Payslip__c p : Payslip_List){
        
            if(p.Employee__r.Salary__c != null )
                sal = sal + p.Employee__r.Salary__c;
            
            if(p.Total_Earnings__c != null)
                earn = earn + p.Total_Earnings__c;
            
            if(p.Total_Deductions__c != null)
                ded = ded + p.Total_Deductions__c;
            
            if(p.PAYE__c != null)
                paye = paye + p.PAYE__c;
                
            if(p.NIC__c != null)
                empnic = empnic + p.NIC__c;
                
            if(p.Student_loan__c != null)
                loan = loan + p.Student_loan__c;
                
            if(p.Net_Pay__c != null)
                net = net + p.Net_Pay__c;
        
        }
        
        Payslip__c ptotais = new Payslip__c(
            Salary__c=sal, Total_Earnings__c=earn, Total_Deductions__c=ded,
            PAYE__c=paye, NIC__c=empnic, Student_loan__c=loan,Net_Pay__c=net);
        
        return ptotais;
    
    }
    
     public static Map<String, Employee__c> EmployeeMap (ID CompanyID)
    {
        List<Employee__c> employee_List = new List<Employee__c>();
         
        /*
        employee_List = [SELECT id, Name, MyPaye_Employee_ID__c, Company__c
                         FROM Employee__c
                         WHERE Company__c = :CompanyID
                           AND MyPaye_Employee_ID__c != null 
                           AND Active_for_payroll__c = true];
        
        */
        
        // Email is mandatory to be fetched --- Richa Changed on 12-04-16
        
        employee_List = [SELECT id,Email__c, Name, MyPaye_Employee_ID__c, Company__c
                         FROM Employee__c
                         WHERE Company__c = :CompanyID
                           AND MyPaye_Employee_ID__c != null 
                           AND Active_for_payroll__c = true];
        
        Map<String, Employee__c> employee_Map = new Map<String, Employee__c>();
        
        for(Employee__c e : employee_List)
            employee_Map.put(e.MyPaye_Employee_ID__c, e);                          
        
        return employee_Map; 
    }
    
    //********************************************************************* [PayslipsRun MyPAY API]
    @future (callout = true)
    public static void PayslipsRun (id payRunID)
    {
        
        // SELECT the data from the Account - OK
        Pay_Run2__c payRunInfo = PayRunInfo(payRunID);
        
        Map<String, Employee__c> ep_Map = new Map<String, Employee__c>();
        
        ep_Map = EmployeeMap(payRunInfo.Company__r.id);
        system.debug('\n\n ### --- GET PAYSLIPS - employee map: '+ep_Map);
                                  
        MyPAYE_SessionClass p_Session = new MyPAYE_SessionClass();
        
        String soapXML = '';
        if(!test.isRunningTest()){
            soapXML = p_Session.GetPayslip(payRunInfo.Company__c, payRunInfo);
        }else{
            soapXML = '<MyPAYELink><Login><LinkID>1598EE50-C99D-4E8D-B258-5918C7159DE4</LinkID>'+
            '<LinkPwd>DoUgeRe1E8AVA</LinkPwd></Login><Function>GetPayslip</Function>'+
            '<PayrollID>8ZseVXMPcMMkSIwU8rIeSw==</PayrollID><EmployeeID></EmployeeID>'+
            '<TaxYear>2015/16</TaxYear><TaxPeriod>11</TaxPeriod><IncludeNIEarnings>No</IncludeNIEarnings></MyPAYELink>';
        }
        system.debug('\n\n ### --- GET PAYSLIPS - soapXML: '+soapXML);
        

        String XMLResponse = '';
        if(!test.isRunningTest()){        
            XMLResponse = p_Session.processXML('https://www.MyPAYE.co.uk/Secure/AcctLink/GetPayslipDetails.asp', soapXML );
        }else{
            XMLResponse = '<Payslips><Payslip><PayrollID>8ZseVXMPcMMkSIwU8rIeSw==</PayrollID><PayrollType>Monthly</PayrollType>'+
            '<EmployerName>INDIVIDUUM CORP LTD</EmployerName><PayrollRef>AAPM01</PayrollRef><EmployeeName>Mr Afshin A P Moayed Sanandaji</EmployeeName>'+
            '<EmployeeID>bjGp9JmC/Ro=</EmployeeID><TaxYear>2015/16</TaxYear><TaxPeriodNumber>11</TaxPeriodNumber>'+
            '<Department>Director</Department><PayDate>2016-02-19</PayDate><NINumber>ST178478C</NINumber><TaxCode>1060L</TaxCode>'+
            '<PayMethod>Bank Transfer</PayMethod><StatutoryPayments><SSP>0.00</SSP><SMP>0.00</SMP><OSPP>0.00</OSPP><ASPP>0.00</ASPP><SAP>0.00</SAP></StatutoryPayments>'+
            '<StatutoryDeductions><StudentLoan>0.00</StudentLoan><PAYE>0.00</PAYE><NIC>199.36</NIC><TotalAttachments>0.00</TotalAttachments></StatutoryDeductions>'+
            '<Summary><TaxablePay>2333.33</TaxablePay><TotalEarnings>2333.33</TotalEarnings><TotalDeductions>199.36</TotalDeductions>'+
            '<NetPay>2133.97</NetPay></Summary><PaySlipItems><Earnings><PayItem><DisplayName>Salary</DisplayName><SubjectToPAYE>Yes</SubjectToPAYE>'+
            '<SubjectToNIC>Yes</SubjectToNIC><Quantity>1</Quantity><Rate>2333.33</Rate><Total>2333.33</Total></PayItem></Earnings>'+
            '<Deductions/></PaySlipItems></Payslip><PayslipCount>1</PayslipCount></Payslips>';
        }
        system.debug('\n\n ### --- GET PAYSLIPS - XMLresponse: '+XMLresponse);
        
        
        
        ///////////////////////////////////////////////////////////// parte 1
        // busca NIC do Employer e outros dados se for necessário no futuro:
        // isto tem de ser chamado aqui antes do tratamento de dados e da manipulação da base de dados
        // Look for Employer NIC and other data needed for the future
        // This needs to be caled here before processing the data or manipulating the database
        String soapXML2 = '';
        if(!test.isRunningTest()){
            soapXML2 = p_Session.GetPaySummary(payRunInfo.Company__c, payRunInfo);
        }else{
            soapXML2 = '<MyPAYELink><Login><LinkID>1598EE50-C99D-4E8D-B258-5918C7159DE4</LinkID><LinkPwd>DoUgeRe1E8AVA</LinkPwd></Login>'+
            '<Function>GetPaySummary</Function><PayrollID>8ZseVXMPcMMkSIwU8rIeSw==</PayrollID><TaxYear>2015/16</TaxYear>'+
            '<TaxPeriod>11</TaxPeriod></MyPAYELink>';
        }
        system.debug('\n\n ### --- GET PAY SUMMARY - soapXML2: '+soapXML2);
        
        String XMLResponse2 = '';
        if(!test.isRunningTest()){
            XMLResponse2 = p_Session.processXML('https://www.MyPAYE.co.uk/Secure/AcctLink/GetPaySummary.asp', soapXML2 );
        }else{
            XMLResponse2 = '<PaySummary><EmployerName>INDIVIDUUM CORP LTD</EmployerName><PayrollID>8ZseVXMPcMMkSIwU8rIeSw==</PayrollID>'+
            '<PayrollName>INDIVIDUUM CORP LTD</PayrollName><PayrollType>Monthly</PayrollType>'+
            '<TaxYear>2015/16</TaxYear><TaxPeriodNumber>11</TaxPeriodNumber>'+
            '<PayrollRunBy>Mrs Caroline Monks</PayrollRunBy><PayrollRunDate>2016-02-19 16:15:18</PayrollRunDate>'+
            '<RTIFPSSentOn>2016-02-19 17:02:11</RTIFPSSentOn><FPSRejected>No</FPSRejected><FPSPending>No</FPSPending>'+
            '<FPSWasAmendment>No</FPSWasAmendment><AmendedFPSNeeded>Yes</AmendedFPSNeeded><Employee><PayrollRef>AAPM01</PayrollRef>'+
            '<EmployeeName>Mr Afshin A P Moayed Sanandaji</EmployeeName><NINumber>ST178478C</NINumber>'+
            '<EmployeeID>bjGp9JmC/Ro=</EmployeeID><Department>Director</Department><Earnings>2333.33</Earnings>'+
            '<Deductions>199.36</Deductions><PAYE>0.00</PAYE><StudentLoan>0.00</StudentLoan><EmployeeNIC>199.36</EmployeeNIC>'+
            '<EmployerNIC>228.71</EmployerNIC><NetPay>2133.97</NetPay><PayMethod>Bank Transfer</PayMethod><PayDate>2016-02-19</PayDate></Employee>'+
            '<TotalEarnings>2333.33</TotalEarnings><TotalDeductions>199.36</TotalDeductions><TotalPAYE>0.00</TotalPAYE>'+
            '<TotalStudentLoan>0.00</TotalStudentLoan><TotalEmployeeNIC>199.36</TotalEmployeeNIC><TotalEmployerNIC>228.71</TotalEmployerNIC>'+
            '<TotalNetPay>2133.97</TotalNetPay></PaySummary>';
        }
        system.debug('\n\n ### --- GET PAY SUMMARY - XMLResponse2: '+XMLResponse2);
        
        
        /////////////////////////////////////////////////////////////
        // trata Payslips:
        XmlStreamReader reader = new XmlStreamReader(XMLResponse);
        PayslipsRead (reader, payRunInfo, ep_Map); 
        
        
        ///////////////////////////////////////////////////////////// parte 2
        // faz update aos Payslips com o NIC:
        XmlStreamReader reader2 = new XmlStreamReader(XMLResponse2);
        PayslipsUpdate(reader2, payRunInfo);
        
        
        
        // ------------- CREATE PAYSLIPS PDFs (cannot be done here because this method is @future...) -------------
        //PayslipsGeneratePDF(payRunID);
        
    }
    
    public static void PayslipsRead (XmlStreamReader reader, Pay_Run2__c payRunInfo, Map<String, Employee__c> ep_Map)
    {
        Payslip__c Payslip;
        Employee__c emp;
        Payroll_Items2__c PayrollItem;
        List<Payroll_Items2__c> PayrollItem_List = new List<Payroll_Items2__c>();
        String payItemType = '';
        
        system.debug('\n\n### --- XML READER: '+reader);
        
        String EmployeeID = '';
        
        while(reader.hasNext()) 
        {
            if(reader.getEventType() == XmlTag.START_ELEMENT)
            {
                String nodeName = reader.getLocalName();
                
                if('Payslip'.equalsIgnoreCase(nodeName))
                {
                    Payslip = new Payslip__c();
                    Payslip.Pay_Run2__c = payRunInfo.id;
                }
                
                
                
                if('PayrollRef'.equalsIgnoreCase(nodeName))
                {
                    emp = new Employee__c ();
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        emp.Payroll_ref__c= reader.getText();
                }
                
                if('EmployeeName'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        emp.Name= reader.getText();
                        // 27-Feb-2015 this was made because a Contact is to be created somewhere in a Trigger and LastName is mandatory
                        emp.LastName__c = emp.Name;
                }

                if('EmployeeID'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                    {
                        EmployeeID = reader.getText();
                         if(ep_Map.get(EmployeeID)== null)
                        {
                            emp.MyPaye_Employee_ID__c = EmployeeID;
                            emp.Draft__c = false;
                            emp.Active_for_Payroll__c = true;
                            emp.Company__c = payRunInfo.Company__r.id;
                            //emp.Email__c = 
                            upsert emp MyPaye_Employee_ID__c;
                        }
                        else
                        {
                            emp = ep_Map.get(EmployeeID);
                        }
                        
                        Payslip.Employee__c = emp.id;
                    }
                }
                
                if('PayDate'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Pay_Date__c = Date.valueOf(reader.getText());
                }
                
                if('NINumber'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        emp.NationalInsuranceNumber__c= reader.getText();
                        
                        //trata do employee:
                        if(ep_Map.get(EmployeeID)== null)
                        {
                            emp.MyPaye_Employee_ID__c = EmployeeID;
                            emp.Draft__c = false;
                            emp.Active_for_Payroll__c = true;
                            emp.Company__c = payRunInfo.Company__r.id;
                            upsert emp MyPaye_Employee_ID__c;
                        }
                        else
                            emp = ep_Map.get(EmployeeID);
                        
                        Payslip.Employee__c = emp.id;    
                        
                }
                
                if('TaxCode'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Tax_Code__c= reader.getText();
                }
                
                if('PayMethod'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Pay_Method__c= reader.getText();
                }
                
                if('SSP'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.SSP__c= Decimal.ValueOf(reader.getText());
                }
                
                if('SMP'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.SMP__c= Decimal.ValueOf(reader.getText());
                }
                
                if('OSPP'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.OSPP__c= Decimal.ValueOf(reader.getText());
                }
                
                if('ASPP'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.ASPP__c= Decimal.ValueOf(reader.getText());
                }
                
                if('SAP'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.SAP__c= Decimal.ValueOf(reader.getText());
                }
                
                if('StudentLoan'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Student_Loan__c= Decimal.ValueOf(reader.getText());
                }
                
                if('PAYE'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.PAYE__c = Decimal.ValueOf(reader.getText());
                }
                
                if('NIC'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.NIC__c = Decimal.ValueOf(reader.getText());
                }
                
                if('TotalAttachments'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Total_Attachments__c = Decimal.ValueOf(reader.getText());
                }
                
                if('TaxablePay'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Taxable_Pay__c= Decimal.ValueOf(reader.getText());
                }
                
                if('TotalEarnings'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Total_Earnings__c= Decimal.ValueOf(reader.getText());
                }
                
                if('TotalDeductions'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Total_Deductions__c = Decimal.ValueOf(reader.getText());
                }
                
                if('NetPay'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        Payslip.Net_Pay__c= Decimal.ValueOf(reader.getText());
                }
                
                if('PayItem'.equalsIgnoreCase(nodeName))
                {
                    PayrollItem = new Payroll_Items2__c();
                    PayrollItem.type__c = payItemType;
                }
                
                if('Earnings'.equalsIgnoreCase(nodeName))
                {
                    payItemType = 'Earnings';
                }
                
                if('Deductions'.equalsIgnoreCase(nodeName))
                {
                    payItemType = 'Deductions';
                }
                
                if('EmployerPensionContribution'.equalsIgnoreCase(nodeName))
                {
                     reader.next();
                     if(reader.getEventType() == XmlTag.CHARACTERS)
                     {
                         Payroll_Items2__c PayrollItemOther = new Payroll_Items2__c();
                         PayrollItemOther.type__c = 'Contributions';
                         PayrollItemOther.DisplayName__c = PayrollItem.DisplayName__c;
                         PayrollItem_List.add(PayrollItemOther);
                     }
                }
                
                if('DisplayName'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        PayrollItem.DisplayName__c= reader.getText();
                }
                
                if('SubjectToPAYE'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        PayrollItem.SubjectToPAYE__c= StringToBollean(reader.getText());
                }
                
                if('SubjectToNIC'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        PayrollItem.Subject_To_NIC__c = StringToBollean(reader.getText());
                }
                
                if('Quantity'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        PayrollItem.Quantity__c= Decimal.ValueOf(reader.getText());
                }
                
                if('Rate'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        PayrollItem.Amount__c= Decimal.ValueOf(reader.getText());
                }
                
                if('Total'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS)
                        PayrollItem.Total__c= Decimal.ValueOf(reader.getText());
                }
                
            
            }
            else
            {
                if(reader.getEventType() == XmlTag.END_ELEMENT)
                {
                    String nodeName = reader.getLocalName();
                    
                    if('Payslip'.equalsIgnoreCase(nodeName))
                    {
                        insert Payslip;
                        
                        List<Payroll_Items2__c> PayrollItem_List_AUX = new List<Payroll_Items2__c>();
                        
                        for(Payroll_Items2__c pItem : PayrollItem_List)
                            if(pItem.DisplayName__c != null && pItem.DisplayName__c != '')
                            {
                                pItem.Payslip__c = Payslip.id;
                                PayrollItem_List_AUX.add(pItem);
                            }
                        
                        insert PayrollItem_List_AUX;
                        PayrollItem_List = new List<Payroll_Items2__c>();
                    }
                }
                
                if(reader.getEventType() == XmlTag.END_ELEMENT)
                {
                    String nodeName = reader.getLocalName();
                    
                    if('PayItem'.equalsIgnoreCase(nodeName))
                        PayrollItem_List.add(PayrollItem);
                }
            
            }
            
           reader.next();
         }   
     }
     
     
     public static void PayslipsUpdate (XmlStreamReader reader, Pay_Run2__c payRunInfo)
    {
    
        //carrega Payslips
        List<Payslip__c> pslist = new List<Payslip__c>();
        pslist = [SELECT id, Employee__r.MyPaye_Employee_ID__c FROM Payslip__c WHERE Pay_Run2__c =: payRunInfo.id];
        
        //cria mapa de Payslips com Employee ID
        Map<string, id> psmap = new Map<string, id>();
        for(Payslip__c pwa: pslist){
            psmap.put(pwa.Employee__r.MyPaye_Employee_ID__c, pwa.id);
        }
        
        
        
        system.debug('\n\n### --- PAYSLIP MAP EMPLOYEE ID - PAYSLIP ID: '+psmap);
        
        system.debug('\n\n### --- XML READER2 - on PayslipsUpdate: '+reader);
        
        //cria lista de Payslips a actualizar:
        List<Payslip__c> pslistUpdate = new List<Payslip__c>();
        
        id empid = null;
    
        
        while(reader.hasNext()) 
        { 
            
            if(reader.getEventType() == XmlTag.START_ELEMENT)
            { 
                String nodeName = reader.getLocalName();
                
                system.debug('\n\n ### --- NODENAME: '+ nodeName);
                
                if('EmployeeID'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS){
                        string empcode = reader.getText();
                        empid = psmap.get(empcode);
                    }
                }
                if('EmployerNIC'.equalsIgnoreCase(nodeName))
                {
                    reader.next();
                    if(reader.getEventType() == XmlTag.CHARACTERS){
                        decimal NIC = Decimal.ValueOf(reader.getText());
                        if(empid != null){
                            Payslip__c p = new Payslip__c(id=empid, Employer_NIC__c=NIC);
                            pslistUpdate.add(p);
                        }
                    }
                }
             }else{
                
                if(reader.getEventType() == XmlTag.END_ELEMENT)
                {
                
                }
                
             }
                
             reader.next();
        } 
        
        if(pslistUpdate.size() > 0){
            update pslistUpdate;
        }
    
    }
     
     
     public static boolean StringToBollean (String s)
     {
         if('Yes'.equalsIgnoreCase(s))
             return true;
         return false;
     }
     
     public static void PayslipsGeneratePDF(id prId){
     
         system.debug('\n\n### --- CREATE PAYSLIP PDFs - START');
     
         List<Payslip__c> psList = new List<Payslip__c>();
         
         psList = [SELECT id, Name, Pay_run2__c FROM Payslip__c WHERE Pay_Run2__c =: prId];
         
         //apaga existing Attachments:
         List<Attachment> pdfListToDelete = new List<Attachment>();
         try{
             pdfListToDelete = [SELECT id FROM Attachment WHERE ParentId =: prId];
         }catch(exception ex){}
         if(pdfListToDelete.size() > 0){
             delete pdfListToDelete;
         }
         
         system.debug('\n\n### --- PAYSLIP LIST: '+psList);
         
         if(psList.size() > 0){
         
             List<Attachment> pdfList = new List<Attachment>();
             for(Payslip__c p: psList){
                 PageReference pdf = Page.Payslip;
                 pdf.getParameters().put('id',p.Id);
                  // the contents of the attachment from the pdf
                 Blob pdfBlob;
                 
                 try {
    
                 // returns the output of the page as a PDF
                 pdfBlob = pdf.getContentAsPDF();
            
                 // need to pass unit test -- current bug  
                 } catch (VisualforceException e) {
                   pdfBlob = Blob.valueOf('Some Text');
                 }
                 
                 Attachment a = new Attachment(parentId = p.Pay_run2__c, name=p.Name+'.pdf', body = pdfBlob);
                 pdfList.add(a);
             }
             
             system.debug('\n\n### --- PDF LIST: '+pdfList);
             
             if(pdfList.size()>0){
                 insert pdfList;
             }
         
         }
     
     }
}