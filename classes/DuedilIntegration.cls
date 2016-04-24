public class DuedilIntegration {
    
    private static final Integer ERR  = 404;         // ERROR - overall, contact suppport.
         
    public static String responseString;
    public static String error;
    public static Duedil_Credentials__c ddilCred2;
    
    
    /** getError */
    /**
    public static String getError(){
        return error;
    }*/
    
    
    /** getDDilCred */    
    public static Duedil_Credentials__c getDDcredentials() {
        Duedil_Credentials__c ddilCred = [SELECT Id, Endpoint_URL__c, API_Key__c FROM Duedil_Credentials__c
                                           WHERE Active__c = TRUE
                                           LIMIT 1];
        
        return ddilCred;
    }
    
    
     /** DuedilCallout */
    public static String DuedilCallout (String url, String req) {
        
        try {
         
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            // request.setMethod('POST');
            request.setMethod('GET');
            if(req != null && req != '') {
                request.setHeader('Content-Type', 'application/json');
                request.setBody(req);        
                system.debug('\n\n### DuedilIntegration -- DuedilCallout -- REQUEST: \n'+request.getBody()+'\n');    
            }

            HttpResponse response = new HttpResponse();
            IF(!Test.isRunningTest()){
                response = http.send(request);        
                responseString = response.getBody();
                system.debug('\n\n### DuedilIntegration -- DuedilCallout -- RESPONSE: \n'+responseString+'\n'); 
            }ELSE{
                responseString = 'xxx';
            }

         
        } catch (Exception e) {
            system.debug('\n\n### DuedilIntegration -- DuedilCallout -- '+e.getMessage()+'\n');
        }
        
        return responseString;
    }
    
    
    /** processResponse (return: Account fields)*/
    public static Account processResponse (String resp, String resp2, Account acc) {
        
        if(resp != null && resp != ''){
        
            JSONParser parser = JSON.createParser(resp);
            String Cname = '';
            String CincorpDate = '';
            String Ctype = '';
            String Csic = '';
            String Cstreet = '';
            String Ccity = '';
            String Cstate = '';
            String Ccountry = '';
            String Ccep = '';
            String Cphone = '';
            Integer Cemployees = 0;
            String CshipStreet = '';
            String CshipCity = '';
            String CshipCEP = '';
            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'name')) {
                        parser.nextToken();
                        Cname = parser.getText();
                        system.debug('\n\n### DData.name: ' + Cname +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'incorporation_date')){
                        parser.nextToken();
                        CincorpDate = parser.getText();
                        system.debug('\n\n### DData.incorporation_date: ' + CincorpDate +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'company_type')){
                        parser.nextToken();
                        Ctype = parser.getText();
                        system.debug('\n\n### DData.company_type: ' + Ctype +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'sic_code')){
                        parser.nextToken();
                        Csic = parser.getText();
                        system.debug('\n\n### DData.sic_code: ' + Csic +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'reg_address1')){
                        parser.nextToken();
                        Cstreet = parser.getText();
                        system.debug('\n\n### DData.reg_address1: ' + Cstreet +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'reg_address2')){
                        parser.nextToken();
                        Ccity = parser.getText();
                        system.debug('\n\n### DData.reg_address2: ' + Ccity +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'reg_address3')){
                        parser.nextToken();
                        Cstate = parser.getText();
                        system.debug('\n\n### DData.reg_address3: ' + Cstate +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'reg_address4')){
                        parser.nextToken();
                        Ccountry = parser.getText();
                        system.debug('\n\n### DData.reg_address4: ' + Ccountry +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'reg_address_postcode')){
                        parser.nextToken();
                        Ccep = parser.getText();
                        system.debug('\n\n### DData.reg_address_postcode: ' + Ccep +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'reg_phone')){
                        parser.nextToken();
                        Cphone = parser.getText();
                        system.debug('\n\n### DData.reg_phone: ' + Cphone +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'trading_address1')){
                        parser.nextToken();
                        CshipStreet = parser.getText();
                        system.debug('\n\n### DData.trading_address1: ' + CshipStreet +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'trading_address2')){
                        parser.nextToken();
                        CshipCity = parser.getText();
                        system.debug('\n\n### DData.trading_address2: ' + CshipCity +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'trading_address_postcode')){
                        parser.nextToken();
                        CshipCEP = parser.getText();
                        system.debug('\n\n### DData.trading_address_postcode: ' + CshipCEP +'\n');
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'accounts_no_of_employees')){
                        parser.nextToken();
                        Cemployees = integer.valueof(parser.getText());
                        system.debug('\n\n### DData.accounts_no_of_employees: ' + Cemployees +'\n');
                        
                }

            }
        
                
                // map fields:
                acc.Name = Cname;
                acc.BillingStreet = Cstreet;
                acc.BillingCity = Ccity;
                acc.BillingState = Cstate;
                acc.BillingPostalCode = Ccep;
                //acc.BillingCountry = Ccountry;
                acc.Phone = Cphone;
                acc.NumberOfEmployees = Cemployees;
                acc.ShippingStreet = CshipStreet;
                acc.ShippingCity = CshipCity;
                acc.ShippingPostalCode = CshipCEP;
                acc.Sic = Csic;
                acc.Type_of_ownership__c = Ctype;
                
        }
        
        if(resp2 != null && resp2 != ''){
        
            JSONParser parser = JSON.createParser(resp2);
            String address1 = '';
            String address2 = '';
            String address3 = '';
            String postcode = '';
            String tps = '';
            String area_code = '';

            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'address1')) {
                        parser.nextToken();
                        address1 = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'address2')){
                        parser.nextToken();
                        address2 = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'address3')){
                        parser.nextToken();
                        address3 = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'postcode')){
                        parser.nextToken();
                        postcode = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'tps')){
                        parser.nextToken();
                        tps = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'area_code')){
                        parser.nextToken();
                        area_code = parser.getText();

                }

            }
        
        
                system.debug('\n\n### address1 '+address1);
                system.debug('\n\n### address2 '+address2);
                system.debug('\n\n### address3 '+address3);                                
                system.debug('\n\n### postcode '+postcode);
                system.debug('\n\n### tps '+tps);
                system.debug('\n\n### area_code '+area_code);                
                
                // map fields:
                system.debug('\n\n### xxx'); 
                acc.BillingStreet = address1;
                //acc.BillingCity = address3;   *** replaced by State by Stephane's request
                acc.BillingState = address3;
                acc.BillingPostalCode = postcode;
            

                
        }
        
        system.debug('\n\n### accAddr'+acc);
        return acc;
    } 
    
    
    /** processResponse (return: Bank Accounts fields)*/
    public static List<BankAccount__c> processResponse2 (String resp) {

        List<BankAccount__c> bankAcc = new List<BankAccount__c>(); 
        
        if(resp != null && resp != ''){
            JSONParser parser = JSON.createParser(resp);
            
            while (parser.nextToken() != null){
            // Start at the array
                if (parser.getCurrentToken() == JSONToken.START_ARRAY){
                    while (parser.nextToken() != null){
                    // Advance to the start object marker
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT){
                        // Read entire object
                        bankCL bank1 = (bankCL)parser.readValueAs(bankCL.class);
                        system.debug('### bank1.bank: '+bank1.bank);
                        system.debug('### bank1.sortCode: '+bank1.sortCode);
                        system.debug('### bank1.id: '+bank1.id);
                        BankAccount__c bankWA = new BankAccount__c();
                        bankWA.Bank_Name__c = bank1.bank;
                        bankWA.Sort_Code__c = bank1.sortCode;
                        bankWA.DueDil_Id__c = bank1.id;
                        
                        bankAcc.add(bankWA);
                        
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                        }
                    }
                }
            }
        }
        
        system.debug('### bankAcc: ' + bankAcc);
        return bankAcc;
    }


    /** processResponse (return: Directors fields)*/
    public static List<Employee__c> processResponse3 (String resp) {

        //List<Contact> Directors = new List<Contact>(); 
        List<Employee__c> Directors = new List<Employee__c>(); 
        
        if(resp != null && resp != ''){
            JSONParser parser = JSON.createParser(resp);
            
            while (parser.nextToken() != null){
            // Start at the array
                if (parser.getCurrentToken() == JSONToken.START_ARRAY){
                    while (parser.nextToken() != null){
                    // Advance to the start object marker
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT){
                        // Read entire object
                        DirectorsCL dir1 = (DirectorsCL)parser.readValueAs(DirectorsCL.class);
                        system.debug('### dir1.id: '+dir1.id);
                        system.debug('### dir1.forename: '+dir1.forename);
                        system.debug('### dir1.surname: '+dir1.surname);

                        //Contact contactWA = new Contact();
                        Employee__c contactWA = new Employee__c();
                        ContactWA.FirstName__c = dir1.forename;
                        ContactWA.LastName__c = dir1.surname;
                        ContactWA.DueDil_Director_Id__c = dir1.id;
                        //ContactWA.Birthdate = dir1.date_of_birth;
                        //ContactWA.Directorships_URL__c = dir1.directorships_url;
                        //ContactWA.Director_URL__c = dir1.director_url;
                        //ContactWA.Title = dir1.title;
                        //ContactWA.Suffix__c = dir1.suffix;
                        //ContactWA.Nationality__c = dir1.nationality;
                        //ContactWA.Postal_title__c = dir1.postal_title;
                        
                        //ContactWA.MailingStreet = dir1.address1 + ' ' + dir1.address2 + ' ' + dir1.address3 + ' ' + dir1.address4;
                        
                        Directors.add(ContactWA);
                        
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                        }
                    }
                }
            }
        }
        
        system.debug('### Directors: ' + Directors);
        return Directors;
    }


    /** processResponse (return: Directorships fields)*/
    public static List<Employee__c> processResponse4 (String resp) {

        //List<Contact> Directorships = new List<Contact>(); 
        List<Employee__c> Directorships = new List<Employee__c>();
        
        if(resp != null && resp != ''){
            JSONParser parser = JSON.createParser(resp);
            
            while (parser.nextToken() != null){
            // Start at the array
                if (parser.getCurrentToken() == JSONToken.START_ARRAY){
                    while (parser.nextToken() != null){
                    // Advance to the start object marker
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT){
                        // Read entire object
                        DirectorshipsCL dir2 = (DirectorshipsCL)parser.readValueAs(DirectorshipsCL.class);
                        
                        system.debug('### dir2.id: '+dir2.id);
                        system.debug('### dir2.status: '+dir2.status);
                        system.debug('### dir2.position: '+dir2.position);
                        system.debug('### dir2.function: '+dir2.function);
                        system.debug('### dir2.companies_url: '+dir2.companies_url);

                        //Contact contactWA = new Contact();
                        Employee__c contactWA = new Employee__c();
                        
                        ContactWA.DueDil_Director_Id__c = dir2.id;
                        ContactWA.Position__c = dir2.position;
                        ContactWA.Title__c = dir2.function;
                        ContactWA.Directorship_Status__c = dir2.status;
                        ContactWA.DueDil_Company_URL__c = dir2.companies_url;
                        
                        //ContactWA.Birthdate = dir1.date_of_birth;
                        //ContactWA.Directorships_URL__c = dir1.directorships_url;
                        //ContactWA.Director_URL__c = dir1.director_url;
                        //ContactWA.Title = dir1.title;
                        //ContactWA.Suffix__c = dir1.suffix;
                        //ContactWA.Nationality__c = dir1.nationality;
                        //ContactWA.Postal_title__c = dir1.postal_title;
                        
                        //ContactWA.MailingStreet = dir1.address1 + ' ' + dir1.address2 + ' ' + dir1.address3 + ' ' + dir1.address4;
                        
                        Directorships.add(ContactWA);
                        
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                        }
                    }
                }
            }
        }
        
        system.debug('### Directorships: ' + Directorships);
        return Directorships;
    }
    


    /** processResponse (return: Address fields)*/
    /**
    public static Account processResponse5 (String resp, Account accA) {
        
        if(resp != null && resp != ''){
        
            JSONParser parser = JSON.createParser(resp);
            String address1 = '';
            String address2 = '';
            String address3 = '';
            String postcode = '';
            String tps = '';
            String area_code = '';

            
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'address1')) {
                        parser.nextToken();
                        address1 = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'address2')){
                        parser.nextToken();
                        address2 = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'address3')){
                        parser.nextToken();
                        address3 = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'postcode')){
                        parser.nextToken();
                        postcode = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'tps')){
                        parser.nextToken();
                        tps = parser.getText();
                        
                }else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'area_code')){
                        parser.nextToken();
                        area_code = parser.getText();

                }

            }
        
        
                system.debug('\n\n### address1 '+address1);
                system.debug('\n\n### address2 '+address2);
                system.debug('\n\n### address3 '+address3);                                
                system.debug('\n\n### postcode '+postcode);
                system.debug('\n\n### tps '+tps);
                system.debug('\n\n### area_code '+area_code);                
                
                // map fields:
                system.debug('\n\n### xxx'); 
                accA.BillingStreet = address1;
                system.debug('\n\n### xxx'); 
                accA.BillingCity = address3;
                accA.BillingPostalCode = postcode;
            
                system.debug('\n\n### accAddr'+accA);
                
        }
        
        system.debug('\n\n### accAddr'+accA);
        return accA;

    } */



public class bankCL{
    public string bank;
    public string sortCode;
    public string id;
    
    public bankCL(string bank, string sortCode, string id){
        this.bank = bank;
        this.sortCode = sortCode;
        this.id = id;
    }
}

public class DirectorsCL{
    public string id;
    public string forename;
    public string surname;
    public string date_of_birth;
    /**
    public string directorships_url;
    public string director_url;
    
    public string middle_name;
    public string title;
    public string nationality;
    public string suffix;
    public string postal_title;
    public string address1;
    public string address2;
    public string address3;
    public string address4;
    */
    
    
    public DirectorsCL(string forename, string surname, string position){
        this.id = id;
        this.forename = forename;
        this.surname = surname;
        this.date_of_birth = date_of_birth;
        /**
        this.directorships_url = directorships_url;
        this.director_url = director_url;
        
        this.middle_name = middle_name;
        this.title = title;
        this.nationality = nationality;
        this.suffix = suffix;
        this.postal_title = postal_title;
        this.address1 = address1;
        this.address2 = address2;
        this.address3 = address3;
        this.address4 = address4;
        */
        
    }
}


public class DirectorshipsCL{
    public string id;
    public string status;
    public string position;
    public string function;
    public string companies_url;
    /**
    public string directorships_url;
    public string director_url;
    
    public string middle_name;
    public string title;
    public string nationality;
    public string suffix;
    public string postal_title;
    public string address1;
    public string address2;
    public string address3;
    public string address4;
    */
    
    
    public DirectorshipsCL(string id, string status, string position, string function, string companies_url){
        this.id = id;
        this.status = status;
        this.position = position;
        this.function = function;
        this.companies_url = companies_url;
        /**
        this.directorships_url = directorships_url;
        this.director_url = director_url;
        
        this.middle_name = middle_name;
        this.title = title;
        this.nationality = nationality;
        this.suffix = suffix;
        this.postal_title = postal_title;
        this.address1 = address1;
        this.address2 = address2;
        this.address3 = address3;
        this.address4 = address4;
        */
        
    }
}

/**
public class accAddrCL{
    public string address1;
    public string address2;
    public string address3;
    public string postcode;
    public string tps;
    public string area_code;
    
    
    public accAddrCL(string address1, string address2, string address3, string postcode, string tps, string area_code){
        this.address1 = address1;
        this.address2 = address2;
        this.address3 = address3;
        this.postcode = postcode;
        this.tps = tps;
        this.area_code = area_code;
        
    }
}*/


}