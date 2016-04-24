@istest
public class MyPAYE_test
{
    public static testMethod void MyPAYEController_test()
    {
        
        Account Acc1 = new Account (name = 'Teste 1');
        insert acc1;
        
        Pay_Run2__c prInfo = new Pay_Run2__c(Company__c = acc1.id, Date__c= date.Today(), Type__c='Monthly', Payroll_ID__c='oPw/MDFK2TU=',
                                             Tax_Period__c = 10, Tax_Year__c='2015');
        insert prInfo; 
        prInfo = MyPAYE_Controller.PayRunInfo(prInfo.id);
        
        PageReference pageRef = Page.PayRun;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(prInfo);
        ApexPages.currentPage().getParameters().put('Id',prInfo.id);

        MyPAYE_Controller controler = new MyPAYE_Controller(sc);
        
        String XML = '<Payslips><Payslip><PayrollID>oPw/MDFK2TU=</PayrollID><PayrollType>Monthly</PayrollType>'+
                     '<EmployerName>Consulting Specialists Ltd</EmployerName><PayrollRef>JB0001</PayrollRef>'+
                     '<EmployeeName>Mr Joe BloggsTest</EmployeeName><EmployeeID>YrtmUST/Mqg=</EmployeeID>'+
                     '<TaxYear>2014/15</TaxYear><TaxPeriodNumber>10</TaxPeriodNumber><PayDate>2015-01-30</PayDate>'+
                     '<NINumber>NB255670D</NINumber><TaxCode W1M1Ind="Yes">1000L</TaxCode><PayMethod>Bank Transfer</PayMethod>'+
                     '<StatutoryPayments><SSP>0.00</SSP><SMP>0.00</SMP><OSPP>0.00</OSPP><ASPP>0.00</ASPP><SAP>0.00</SAP></StatutoryPayments>'+
                     '<StatutoryDeductions><StudentLoan>98.00</StudentLoan><PAYE>333.00</PAYE><NIC>220.44</NIC>'+
                     '<TotalAttachments>0.00</TotalAttachments></StatutoryDeductions><Summary><TaxablePay>2500.00</TaxablePay>'+
                     '<TotalEarnings>2500.00</TotalEarnings><TotalDeductions>651.44</TotalDeductions><NetPay>1848.56</NetPay></Summary>'+
                     '<PaySlipItems><Earnings><PayItem><DisplayName>Salary (Basic)</DisplayName><SubjectToPAYE>Yes</SubjectToPAYE>'+
                     '<SubjectToNIC>Yes</SubjectToNIC><Quantity>1</Quantity><Rate>2500</Rate><Total>2500.00</Total></PayItem></Earnings>'+
                     '<Deductions><PayItem><DisplayName>Student Loan</DisplayName><SubjectToPAYE>No</SubjectToPAYE>'+
                     '<SubjectToNIC>No</SubjectToNIC><Quantity>1</Quantity><Rate>98</Rate><Total>98.00</Total><EmployerPensionContribution>98.00</EmployerPensionContribution></PayItem>'+
                     '</Deductions></PaySlipItems></Payslip><PayslipCount>1</PayslipCount></Payslips>';
                     
        XmlStreamReader xsr = new XmlStreamReader(XML);
        Map<String, Employee__c> empMap = new Map<String, Employee__c>(); 
        
        empMap = MyPAYE_Controller.EmployeeMap(acc1.id);
        
        MyPAYE_Controller.PayslipsRead(xsr, prInfo,empMap);
        
    }
    
    public static testMethod void EmployeePaysli_test()
    {
        Account Acc1 = new Account (name = 'Teste 1');
        insert acc1;
        
        Pay_Run2__c prInfo = new Pay_Run2__c(Company__c = acc1.id, Date__c= date.Today(), Type__c='Monthly', Payroll_ID__c='oPw/MDFK2TU=',
                                             Tax_Period__c = 10, Tax_Year__c='2015');
        insert prInfo; 
        prInfo = MyPAYE_Controller.PayRunInfo(prInfo.id);
        
         String XML = '<Payslips><Payslip><PayrollID>oPw/MDFK2TU=</PayrollID><PayrollType>Monthly</PayrollType>'+
                     '<EmployerName>Consulting Specialists Ltd</EmployerName><PayrollRef>JB0001</PayrollRef>'+
                     '<EmployeeName>Mr Joe BloggsTest</EmployeeName><EmployeeID>YrtmUST/Mqg=</EmployeeID>'+
                     '<TaxYear>2014/15</TaxYear><TaxPeriodNumber>10</TaxPeriodNumber><PayDate>2015-01-30</PayDate>'+
                     '<NINumber>NB255670D</NINumber><TaxCode W1M1Ind="Yes">1000L</TaxCode><PayMethod>Bank Transfer</PayMethod>'+
                     '<StatutoryPayments><SSP>0.00</SSP><SMP>0.00</SMP><OSPP>0.00</OSPP><ASPP>0.00</ASPP><SAP>0.00</SAP></StatutoryPayments>'+
                     '<StatutoryDeductions><StudentLoan>98.00</StudentLoan><PAYE>333.00</PAYE><NIC>220.44</NIC>'+
                     '<TotalAttachments>0.00</TotalAttachments></StatutoryDeductions><Summary><TaxablePay>2500.00</TaxablePay>'+
                     '<TotalEarnings>2500.00</TotalEarnings><TotalDeductions>651.44</TotalDeductions><NetPay>1848.56</NetPay></Summary>'+
                     '<PaySlipItems><Earnings><PayItem><DisplayName>Salary (Basic)</DisplayName><SubjectToPAYE>Yes</SubjectToPAYE>'+
                     '<SubjectToNIC>Yes</SubjectToNIC><Quantity>1</Quantity><Rate>2500</Rate><Total>2500.00</Total></PayItem></Earnings>'+
                     '<Deductions><PayItem><DisplayName>Student Loan</DisplayName><SubjectToPAYE>No</SubjectToPAYE>'+
                     '<SubjectToNIC>No</SubjectToNIC><Quantity>1</Quantity><Rate>98</Rate><Total>98.00</Total><EmployerPensionContribution>98.00</EmployerPensionContribution></PayItem>'+
                     '</Deductions></PaySlipItems></Payslip><PayslipCount>1</PayslipCount></Payslips>';
                     
        XmlStreamReader xsr = new XmlStreamReader(XML);
        Map<String, Employee__c> empMap = new Map<String, Employee__c>(); 
        
        empMap = MyPAYE_Controller.EmployeeMap(acc1.id);
        
        MyPAYE_Controller.PayslipsRead(xsr, prInfo,empMap);
        
        Payslip__c Payslip = new Payslip__c();
        Payslip = [SELECT id FROM Payslip__c WHERE Pay_Run2__c= :prInfo.id LIMIT 1];
        
        PageReference pageRef = Page.Payslip;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(Payslip);
        ApexPages.currentPage().getParameters().put('Id',Payslip.id);

        EmployeePayslip_Controller controler = new EmployeePayslip_Controller(sc);
        
        // testa página de geração de PDFs dos Payslips:
        
        ApexPages.standardController stdcontr9 = new ApexPages.standardController(prInfo);
        MyPAYE_PayslipsGeneratePDF_Controller stdcontr9_p = new MyPAYE_PayslipsGeneratePDF_Controller(stdcontr9);
        stdcontr9_p.generatePDFs();
        
        
    }
    
    public static testMethod void SessionClass_test()
    {
        Account Acc1 = new Account (name = 'Teste 1');
        insert acc1;
        
        Pay_Run2__c prInfo = new Pay_Run2__c(Company__c = acc1.id, Date__c= date.Today(), Type__c='Monthly', Payroll_ID__c='oPw/MDFK2TU=',
                                             Tax_Period__c = 10, Tax_Year__c='2015');
        insert prInfo; 
        
        prInfo = MyPAYE_Controller.PayRunInfo(prInfo.id);
        
        
        MyPAYE_SessionClass sessionClass = new MyPAYE_SessionClass();
        
        String login = sessionClass.GetPayrollList(acc1.id);
        String soapXML = sessionClass.GetPayslip(acc1.id, prInfo);
        
        sessionClass.CreateHttpRequest('TESTEURL',soapXML);
        
        // Added by Richa Sharma - 14-Apr-2016
        sessionClass.GetPaySummary(acc1.id, prInfo);
        
        
    }
    
    public static testMethod void trigger_test()
    {
        Account Acc1 = new Account (name = 'Teste 1');
        insert acc1;
        
        Pay_Run2__c prInfo = new Pay_Run2__c(Company__c = acc1.id, Date__c= date.Today(), Type__c='Monthly', Payroll_ID__c='oPw/MDFK2TU=',
                                             Tax_Period__c = 10, Tax_Year__c='2015');
        insert prInfo; 
        
        prInfo.Last_payslip_sync__c = string.valueOf(system.now());
        
        update prInfo;
        
    }


}