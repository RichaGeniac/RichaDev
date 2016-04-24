Public Class GeniacInvoicePage{

    public Transaction__c invoice {get;set;}
    public List<Transaction_item__c> invoiceItems {get;set;}
    
    public GeniacInvoicePage(){
    
    string invoiceId = ApexPages.currentPage().getParameters().get('id');
    
    invoice = [SELECT id, Document_Number__c, Document_Date__c, Document_Type__c, Total_Amount__c, Total_Amount_w_Tax__c,
                        Company__r.Name, Company__r.BillingStreet, Company__r.BillingCity, Company__r.BillingPOstalCode, Company__r.BillingCountry,
                        Company__r.VAT_Number__c,
                        Internal_Company_Name__c,Internal_Company_VAT__c,Internal_Company_Street__c, Internal_Company_City__c,
                        Internal_Company_Postal_Code__c,Internal_Company_Country__c,Internal_Company_Footer_1__c,Internal_Company_Footer_2__c
                 FROM Transaction__c
                 WHERE id =: invoiceId];
    
    invoiceItems = [SELECT id, Item__c, Unit_Price__c, Qty__c, TaxPct__c, Total_Amount__c, Total_Amount_w_Tax__c
                      FROM Transaction_item__c
                     WHERE Transaction__c = : invoiceId];
    
    }


}