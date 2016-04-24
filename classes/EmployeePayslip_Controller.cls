global class EmployeePayslip_Controller
{
    public Payslip__c Payslip {get; set;}
    public Payslip__c yearToDateValues {get; set;}
    
    public List<Payroll_Items2__c> lines_earnings {get; set;}
    public List<Payroll_Items2__c> lines_deductions {get; set;}
    public List<Payroll_Items2__c> lines_others {get; set;}
    
    public Account Company {get; set;}
    public Employee__c Employee {get; set;}
    
    public EmployeePayslip_Controller(ApexPages.StandardController controller)
    {
        Payslip = (Payslip__c)controller.getRecord();
        Payslip = PayslipInfo (Payslip.id);
        
        Company = new account();
        Company = CompanyInfo(Payslip.Company_Id__c);
        Employee = new Employee__c();
        Employee = EmployeeInfo(Payslip.Employee__r.id);
        
        List<Payroll_Items2__c> lines = new List<Payroll_Items2__c>();
        lines_earnings = new List<Payroll_Items2__c>(); 
        lines_deductions = new List<Payroll_Items2__c>();
        lines_others = new List<Payroll_Items2__c>();
        
        yearToDateValues = PayslipGetYearToDateValues(Payslip.id);
        
        lines = PayslipItemListing(Payslip.id);
        
        for(Payroll_Items2__c p : lines )
        {
            if(p.Type__c.equalsIgnoreCase('Earnings'))
                lines_earnings.add(p);
            else if(p.Type__c.equalsIgnoreCase('Deductions'))
                lines_deductions.add(p);
            else
                lines_others.add(p); 
        }
        
        system.debug('\n\n ### --- LISTA: lines_earnings: '+lines_earnings);
        
    }
    private account CompanyInfo (ID CompanyID)
    {
        account a = new account();
        
        a = [SELECT Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Logo_url__c
             FROM Account
             WHERE id = :CompanyID];
        
        return a;
    
    }
    
    private Employee__c EmployeeInfo (ID EmployeeID)
    {
        Employee__c e = new Employee__c();
        
        e = [SELECT name, Department__c, Employee_No__c, NI_Letter__c, NationalInsuranceNumber__c, Payroll_ref__c,
                    AddressLine1__c, AddressLine2__c, City__c, Country__c, PostalCode__c
                    
             FROM Employee__c
             WHERE id = :EmployeeID];
        
        return e;
    
    }
    
    private static Payslip__c PayslipInfo (ID PayslipID)
    {
        Payslip__c Payslip = new Payslip__c();
         
        Payslip = [SELECT id, Name, ASPP__c, Employee__r.id, Net_Pay__c, Company_Id__c, 
                          NIC__c, OSPP__c, Pay_Date__c, PAYE__c,  Pay_Method__c, Payroll_Ref__c, Pay_Run2__c, 
                          Pay_Run2__r.id, SAP__c, SMP__c, SSP__c, Student_Loan__c, Taxable_Pay__c, Tax_Code__c,
                          Total_Attachments__c, Total_Deductions__c, Total_Earnings__c, Pay_Run2__r.Tax_Period__c
                   FROM Payslip__c
                   WHERE id = :PayslipID];
                                  
        return Payslip; 
    }
    
    private List<Payroll_Items2__c> PayslipItemListing(ID PayslipID)
    {
        List<Payroll_Items2__c> Payslip_List = new List<Payroll_Items2__c>();
         
        Payslip_List = [SELECT id, Amount__c, DisplayName__c, Payslip__c, Quantity__c, Subject_To_NIC__c, SubjectToPAYE__c,
                               Total__c, Type__c
                        FROM Payroll_Items2__c
                        WHERE Payslip__c = :PayslipID];
                                  
        return Payslip_List ; 
    }
    
    
    private Payslip__c PayslipGetYearToDateValues(ID PayslipID){
    
        Payslip__c p = new Payslip__c();
        p = [SELECT id, Employee__r.MyPaye_Employee_ID__c,
                    Employee__r.Past_NIC_Employee__c, Employee__r.Past_Tax__c, Employee__r.Past_Taxable_Pay__c, Employee__r.Past_Tax_Year__c,
                    Pay_Run2__r.Tax_year__c, Pay_Run2__r.Tax_period__c 
               FROM Payslip__c 
              WHERE id =: PayslipID];
    
        List<Payslip__c> pslist = new List<Payslip__c>();
        
        pslist = [SELECT id, Taxable_Pay__c, NIC__c, PAYE__c FROM Payslip__c
                  WHERE Employee__r.MyPaye_Employee_ID__c =: p.Employee__r.MyPaye_Employee_ID__c
                    AND Pay_run2__r.Tax_year__c =: p.Pay_Run2__r.Tax_year__c
                    AND Pay_run2__r.Tax_period__c <=: p.Pay_Run2__r.Tax_period__c];
    
        decimal taxable = 0.00;
        decimal tax = 0.00;
        decimal nic = 0.00;
    
        for(Payslip__c line: pslist ){
            if(line.Taxable_Pay__c != null)
                taxable = taxable + line.Taxable_Pay__c;
            if(line.NIC__c != null)
                tax = tax + line.PAYE__c;
            if(line.NIC__c != null)
                nic = nic + line.NIC__c;
        }
        if(p.Pay_Run2__r.Tax_year__c == p.Employee__r.Past_Tax_Year__c){
            if(p.Employee__r.Past_Taxable_Pay__c != null){taxable = taxable + p.Employee__r.Past_Taxable_Pay__c;}
            if(p.Employee__r.Past_Tax__c != null){tax = tax + p.Employee__r.Past_Tax__c;}
            if(p.Employee__r.Past_NIC_Employee__c != null){nic = nic + p.Employee__r.Past_NIC_Employee__c;}
        }
        Payslip__c pfinal = new Payslip__c(Taxable_Pay__c=taxable, NIC__c=nic, PAYE__c=tax); 
        return pfinal;
    }

    

}