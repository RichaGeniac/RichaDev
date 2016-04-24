global class GetDueDilInfo{

// variables:
    public String CompanyNumber {get; set;}

    public Duedil_Credentials__c cred;
    public String responseString;
    public String responseString2;
    public String error;

    public Account acc {get; set;}
    public Account accNow {get; set;}
    public Account accAddr {get; set;}
    public List<BankAccount__c> bankAcc {get; set;}
    //public List<Contact> Directors {get; set;}
    //public List<Contact> Directorships {get; set;}
    public List<Employee__c> Directors {get; set;}
    public List<Employee__c> Directorships {get; set;}

// function:
    public GetDueDilInfo(){
        String CompanyNumber = ApexPages.currentPage().getParameters().get('cn');
        IF(CompanyNumber == null){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.error, 'Company Number not specified');
            ApexPages.addMessage(msg);
        }ELSE{
        acc = [SELECT id, Company_Number__c, Name, Phone, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, BillingState, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, Sic, NumberOfEmployees, Type_of_ownership__c
                 FROM Account
                WHERE Company_Number__c =: CompanyNumber];
        
        accNow = [SELECT id, Company_Number__c, Name, Phone, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, BillingState, ShippingStreet, ShippingCity, ShippingPostalCode, ShippingState, ShippingCountry, Sic, NumberOfEmployees, Type_of_ownership__c
                 FROM Account
                WHERE Company_Number__c =: CompanyNumber];
        }

        
        cred = DuedilIntegration.getDDcredentials();
        IF(cred != null) {
        
            system.debug('### DDcred: ' + cred);
        
            //get key company information:
            TRY{
                String url;
                url = cred.Endpoint_URL__c + 'companies/' + CompanyNumber + 
                      '?fields=name,incorporation_date,company_type,sic_code,reg_address1,reg_address2,reg_address3,reg_address4,reg_address_postcode,' +
                      'reg_phone,trading_address1,trading_address2,trading_address_postcode,accounts_no_of_employees' +
                      '&api_key=' + cred.API_Key__c;
                system.debug('\n\n ### url Company: ' + url + '\n');    
                
                IF(!Test.isRunningTest()){
                    responseString = DuedilIntegration.DuedilCallout(url, null);
                    system.debug('\n\n ### responseString COMPANY: ' + responseString + '\n');
                }ELSE{
                    responseString = '{"response":{"id":"ea8af9993b9d1a82ec2dfc09fbeec4808bb9d35a","name":"K.V.C.VFHK YOXKJRH","incorporation_date":"1913-06-29","company_type":"Private limited with share capital","sic_code":"5243","reg_address4":"LONDON","accounts_no_of_employees":195,"reg_address_postcode":"WC1H 9LG","trading_address1":"Griffins","trading_address2":"Tavistock House South","trading_address_postcode":"WC1H 9LG"},"request_id":"541180d7a7236"}';
                }
                
                
                
                //07-10-2014
                //get address information:
                url = cred.Endpoint_URL__c + 'companies/' + CompanyNumber + '/registered-address'+
                      '?api_key=' + cred.API_Key__c;
                system.debug('\n\n ### url Address: ' + url + '\n');    
                
                IF(!Test.isRunningTest()){
                    responseString2 = DuedilIntegration.DuedilCallout(url, null);
                    system.debug('\n\n ### responseString ADDRESS: ' + responseString + '\n');
                }ELSE{
                    responseString2 = '{"response":{"id":"07794557","last_update":"2014-08-22","address1":"PARKSIDE 15 MILL LANE","address2":"KINGSTHORPE","address3":"NORTHAMPTONSHIRE","postcode":"NN2 6QA","tps":"N","area_code":"NN 2"},"request_id":"54345112d316a"}';
                }
                
                
                
                IF(responseString!=null){
                    acc = DuedilIntegration.processResponse(responseString, responseString2, acc); 
                    system.debug('### acc: ' + acc);
                }
            
            }CATCH(exception ex){
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.error, 'Unable to call DueDil - Company Info: '+ex.getMessage());
                //ApexPages.addMessage(msg);
            }
        
        
            //07-10-2014
            //get address information:
            /**
            TRY{
                String url;
                url = cred.Endpoint_URL__c + 'companies/' + CompanyNumber + '/registered-address'+
                      '?api_key=' + cred.API_Key__c;
                system.debug('\n\n ### url Address: ' + url + '\n');    
                
                IF(!Test.isRunningTest()){
                    responseString = DuedilIntegration.DuedilCallout(url, null);
                    system.debug('\n\n ### responseString ADDRESS: ' + responseString + '\n');
                }ELSE{
                    responseString = '{"response":{"id":"07794557","last_update":"2014-08-22","address1":"PARKSIDE 15 MILL LANE","address2":"KINGSTHORPE","address3":"NORTHAMPTONSHIRE","postcode":"NN2 6QA","tps":"N","area_code":"NN 2"},"request_id":"54345112d316a"}';
                }
                
                IF(responseString!=null){
                    //accAddr = DuedilIntegration.processResponse5(responseString, accAddr); 
                    //system.debug('### accAddr ' + accAddr);
                }
            
                //pass Address fields to Account:
                acc.BillingStreet = accAddr.BillingStreet;
                acc.BillingPostalCode = accAddr.BillingPostalCode;
                acc.BillingCity = accAddr.BillingCity;
            
            
            }CATCH(exception ex){
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.error, 'Unable to call DueDil - Company Info: '+ex.getMessage());
                //ApexPages.addMessage(msg);
            } */
            
            
        
            //get bank-accounts:
            TRY{
                String url;
                url = cred.Endpoint_URL__c + 'companies/' + CompanyNumber + '/bank-accounts' +
                      '?fields=bank,sortCode,id' +
                      '&api_key=' + cred.API_Key__c;
                system.debug('\n\n ### url Bank Accounts: ' + url + '\n');    
                
                IF(!Test.isRunningTest()){
                    responseString = DuedilIntegration.DuedilCallout(url, null);
                    system.debug('\n\n ### responseString BANKS: ' + responseString + '\n');
                }ELSE{
                    responseString = '{"response":{"pagination":{"total":1},"data":[{"bank":"ACVEKEDG FGNWCWIKFSA BBDH HXU","sortCode":"70-22-67","id":"2768563491a73526f278816ff16c11408fc6c47c"}]},"request_id":"541180d81730c"}';
                }
                
                IF(responseString!=null){
                    bankAcc = DuedilIntegration.processResponse2(responseString);
                }
            
            }CATCH(exception ex){
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.error, 'Unable to call DueDil - Bank Accounts: '+ex.getMessage());
                //ApexPages.addMessage(msg);
            }
        
        //get directors:
            TRY{
                String url;
                url = cred.Endpoint_URL__c + 'companies/' + CompanyNumber + '/directors' +
                      //'?fields=forename,surname,title,middle_name,date_of_birth,nationality,suffix,postal_title,address1,address2,address3,address4,directorships_url,director_url' +
                      '?fields=forename,surname,date_of_birth' +
                      '&api_key=' + cred.API_Key__c;
                system.debug('\n\n ### url Directors: ' + url + '\n');    
                
                IF(!Test.isRunningTest()){
                    responseString = DuedilIntegration.DuedilCallout(url, null);
                    system.debug('\n\n ### responseString DIRECTORS: ' + responseString + '\n');
                }ELSE{
                    responseString = '{"response":{"pagination":{"total":5},"data":[{"id":"c52d1b63481f4780356b3e9c6d7ca7ead5b0d4f8","forename":"Oqwmqb","surname":"Drbtgy","date_of_birth":"1946-12-28","directorships_url":"directorships","companies_url":"companies","director_url":"directors"},{"id":"606ad858ce102e3850b3795b32a4ca1b02c0b0a3","forename":"Jxdqxw","surname":"Tcqikgmyn","date_of_birth":"1952-08-14","directorships_url":"directorships","companies_url":"companies","director_url":"directors"}]},"request_id":"541180d862e5f"}';
                }
                
                IF(responseString!=null){
                    Directors = DuedilIntegration.processResponse3(responseString);
                }
            
            }CATCH(exception ex){
                //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.error, 'Unable to call DueDil - Directors: '+ex.getMessage());
                //ApexPages.addMessage(msg);
            }
        
        //get directorships:
            IF( Directors.size() > 0 ){
                TRY{
                    FOR( Employee__c Dir : Directors ){
                        String url;
                        url = cred.Endpoint_URL__c + 'directors/' + Dir.DueDil_Director_Id__c + '/directorships' +
                              '?fields=status,function,position'+
                              '&api_key=' + cred.API_Key__c;
                        system.debug('\n\n ### url Directorships: ' + url + '\n');
                        
                        IF(!Test.isRunningTest()){
                            responseString = DuedilIntegration.DuedilCallout(url, null);
                            system.debug('\n\n ### responseString DIRECTORSHIPS: ' + responseString + '\n');
                        }ELSE{
                            responseString = '{"response":{"pagination":{"total":2},"data":[{"id":"c1fae97b8006c4b04fb258cb6f80f111ecb8264a","status":"retired","function":"Director","position":"SOLICITOR","companies_url":"companies","directors_uri":"directors","service_address_uri":"service-addresses"},{"id":"d13cd1b714988573acdec9182c55b9e93e8b48ee","status":"retired","function":"Company Secretary","position":"SOLICITOR","companies_url":"companies","directors_uri":"directors","service_address_uri":"service-addresses"}]},"request_id":"541180d91133c"}';
                        }
                        
                        IF(responseString!=null){
                            Directorships= DuedilIntegration.processResponse4(responseString);
                        }
                        
                        IF( Directorships.size() > 0 ){
                            FOR( Employee__c Dirship : Directorships ){
                                IF( Dirship.DueDil_Company_URL__c.contains(CompanyNumber) ){
                                    Dir.Title__c = Dirship.Title__c;
                                    Dir.Position__c = Dirship.Position__c;
                                    Dir.Directorship_Status__c = Dirship.Directorship_Status__c;
                                    Dir.DueDil_Company_URL__c = Dirship.DueDil_Company_URL__c;
                                }
                            }
                        }
                    }
                
                }CATCH(exception ex){
                    //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.error, 'Unable to call DueDil - Directorships: '+ex.getMessage());
                    //ApexPages.addMessage(msg);
                }
            }
        
        }ELSE{
         //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.error, 'No DueDil credentials found');
         //ApexPages.addMessage(msg);
        }
    
    }

    public PageReference saveDDil(){
            
            IF(acc != null){
            
                //protect existing data from overwride:
                IF(acc.Phone == null || acc.Phone == '') acc.Phone = accNow.Phone;
                IF(acc.NumberOfEmployees == null || acc.NumberOfEmployees == 0) acc.NumberOfEmployees = accNow.NumberOfEmployees;
                IF(acc.Type_of_ownership__c == null || acc.Type_of_ownership__c == '') acc.Type_of_ownership__c = accNow.Type_of_ownership__c;
                IF(acc.BillingStreet == null || acc.BillingStreet == '') acc.BillingStreet = accNow.BillingStreet;
                IF(acc.BillingCity == null || acc.BillingCity == '') acc.BillingCity = accNow.BillingCity;
                IF(acc.BillingPostalCode == null || acc.BillingPostalCode == '') acc.BillingPostalCode = accNow.BillingPostalCode;
                IF(acc.BillingState == null || acc.BillingState == '') acc.BillingState = accNow.BillingState;
                IF(acc.BillingCountry == null || acc.BillingCountry == '') acc.BillingCountry = accNow.BillingCountry;
                IF(acc.ShippingStreet == null || acc.ShippingStreet == '') acc.ShippingStreet = accNow.ShippingStreet;
                IF(acc.ShippingCity == null || acc.ShippingCity == '') acc.ShippingCity = accNow.ShippingCity;
                IF(acc.ShippingPostalCode == null || acc.ShippingPostalCode == '') acc.ShippingPostalCode = accNow.ShippingPostalCode;
                IF(acc.BillingCountry == null || acc.BillingCountry == '') acc.BillingCountry = accNow.BillingCountry;
                
                system.debug('\n\n### --- ACCOUNT UPDATE: '+acc);
                update acc;
            }
            
            IF(bankAcc != null){
                List<BankAccount__c> bankAccInsert = new List<BankAccount__c>();
                FOR(BankAccount__c bank2:bankAcc){
                    BankAccount__c bankWA = new BankAccount__c();
                    bankWA.Bank_Name__c = bank2.Bank_Name__c;
                    bankWA.Sort_Code__c = bank2.Sort_Code__c;
                    bankWA.Account_Number__c = bank2.Account_Number__c;
                    bankWA.DueDil_Id__c = bank2.DueDil_Id__c;
                    bankWA.Company__c = acc.Id;
                    if(bankWA.DueDil_Id__c != '' && bankWA.DueDil_Id__c != null){
                        bankAccInsert.add(bankWA);
                    }
                }
                system.debug('\n\n### --- BANK ACCOUNT UPSERT LIST: '+bankAccInsert);
                //insert bankAccInsert;
                upsert  bankAccInsert DueDil_Id__c;
            }
            
            IF(Directors != null){
                //List<Contact> ContactsInsert = new List<Contact>();
                List<Employee__c> ContactsInsert = new List<Employee__c>();
                
                FOR(Employee__c dir2:Directors){
                    Employee__c dirWA = new Employee__c();
                    
                    dirWA.FirstName__c = dir2.FirstName__c;
                    dirWA.LastName__c = dir2.LastName__c;
                    dirWA.Company__c = acc.Id;
                    dirWA.Title__c = dir2.Title__c;
                    dirWA.Directorship_Status__c = dir2.Directorship_Status__c;
                    dirWA.Status__c = '';
                    
                    // Adding Email field
                    // Add Email as it is a required field in employee object
                    dirWA.Email__c = dir2.Email__c;
                    
                    
                    if(dir2.Directorship_Status__c == 'Open') dirWA.Status__c = 'Active';
                    if(dir2.Title__c == 'Director') dirWA.Director__c = TRUE;
                    
                    dirWA.Position__c = dir2.Position__c;
                    dirWA.Draft__c = false;
                    
                    dirWA.Name = dir2.FirstName__c + ' ' + dir2.LastName__c;
                    if(dir2.DueDil_Director_Id__c != '' && dir2.DueDil_Director_Id__c != null){
                        string key = CompanyNumber+'-'+dir2.DueDil_Director_Id__c;
                        dirWA.DueDil_Director_Id__c = key.abbreviate(40);
                        ContactsInsert.add(dirWA);
                    }
                }
                
                system.debug('\n\n### --- CONTACTS UPSERT LIST: '+ContactsInsert);
                //insert ContactsInsert;
                upsert ContactsInsert DueDil_Director_Id__c;
            }
            
            return new PageReference('/'+acc.Id);
    }
    public PageReference cancelDDil(){
            
            return new PageReference('/'+acc.Id);
    }

}