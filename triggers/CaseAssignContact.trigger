trigger CaseAssignContact on Case (before insert) {

 for(Case newcase : trigger.new){
        if(newCase.SuppliedEmail != null){
        try{Contact dbContact = [select id, Account.ID from Contact where email= :newCase.SuppliedEmail limit 1];
           newCase.ContactID = dbContact.ID;
           newCase.AccountID = dbContact.Account.ID;
         }catch (Exception ex){ }
        }
    }

}