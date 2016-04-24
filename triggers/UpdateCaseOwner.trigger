trigger UpdateCaseOwner on Case (after insert) {
    
    // List of case ids
    List<String> lCaseIDs = new List<String>();
    for(Case c: Trigger.new){
        // Checking Case Owner and Created By User
        if(c.ownerid==Label.CaseOwner && c.createdByID==Label.CaseOwner ){
            lCaseIds.add(c.id);        
        }
    }
    
    // If there are any cases, code will to refer "future Class(UpdateCase)", and will update case onwer
    if(lcaseIds.size() > 0)
        UpdateCase.updateCaseRecords(lcaseIds);
}