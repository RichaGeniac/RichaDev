trigger TransactionItemCalculate on Transaction_Item__c (before insert, before update) {

    for( Transaction_Item__c TRI : trigger.new ){
        TRI.Total_Amount__c = TRI.Qty__c * TRI.Unit_Price__c;
        TRI.Total_Amount_w_Tax__c = TRI.Qty__c * TRI.Unit_Price__c * ( ( 100 + TRI.TaxPct__c ) /100 );
    
    }

}