trigger UpdateTskCaseAfterUpdt on Task (after update) {

    for(Task t: trigger.new){
        //new process (11-Feb-2015): TRANSFER DOCS TO PARENT CASE
        if(t.Transfer_Docs_to_Parent_Case__c == true && t.Status == 'Completed' && trigger.oldMap.get(t.id).Status != 'Completed'){
            system.debug('\n\n### --- TRANSFER DOCS TO PARENT CASE - START!');
            
            system.debug('\n\n### --- Task What ID: '+t.whatId+' - '+t.subject);
            
            Case childCase = new Case();
            childCase = [SELECT id, Originated_from_Activity_Id__c 
                            FROM Case
                           WHERE id =: t.whatId];
            
            Task originTask = new Task();
            originTask = [SELECT id, OwnerId FROM Task WHERE id =: childCase.Originated_from_Activity_Id__c];
            
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            List<Attachment> attachmentsToDelete = new List<Attachment>();
            
            Attachment tempAtt;

            for(Attachment attachment: [SELECT SystemModstamp, ParentId,
                //OwnerId,
                 Name, LastModifiedDate, LastModifiedById, 
                IsPrivate, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, 
                BodyLength, Body FROM Attachment WHERE parentId=: t.Id])
                
                    {
                        tempAtt=attachment.clone(false,false);
    
                        tempAtt.parentId = childCase.Originated_from_Activity_Id__c;
                        tempAtt.OwnerId = originTask.OwnerId;
    
                        attachmentstoInsert.add(tempAtt);
    
                        attachmentsToDelete.add(attachment);
    
                    }
                
                    //control loop (to be removed:)
                    for(Attachment line : attachmentstoInsert){
                        system.debug('\n\n### --- Insert line.ParentId: '+line.ParentId);
                        system.debug('\n\n### --- Insert line.Name: '+line.Name);
                    }
                    
                    for(Attachment line : attachmentstoDelete){
                        system.debug('\n\n### --- Delete line.ParentId: '+line.ParentId);
                        system.debug('\n\n### --- Delete line.Name: '+line.Name);
                    }
                
                    //Copy docs to parent (origin) Task and delete reference docs:
                    insert attachmentsToInsert;
                    delete attachmentsToDelete;
                    
                            
                    //Close Originating Task:
                   
                    Task tUpdate = new Task();
                    tUpdate.Id = childCase.Originated_from_Activity_Id__c;
                    tUpdate.Status = 'Completed';
                    
                    update tUpdate;
                    
        }
    
    }

}