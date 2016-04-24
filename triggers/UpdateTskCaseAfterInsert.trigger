trigger UpdateTskCaseAfterInsert on Task (after insert) {

    for(Task t: trigger.new){
        //new process (03-Mar-2015): TRANSFER DOCS TO PREVIOUS TASK
        IF(t.Transfer_Docs_from_previous_task__c == true ){
        
            system.debug('\n\n### --- TRANSFER DOCS PREVIOUS TASK - START!');
            
            List<Task> allTasks = new List<Task>();
            allTasks = [SELECT id, Subject FROM Task WHERE WhatId =: t.WhatId
                         //AND Status = 'Completed'
                         //AND Internal_Case__c = true deactivated on 2-Sep-15
                         ORDER BY SortOrder__c DESC
                         LIMIT 2];
            
            system.debug('\n\n### --- allTasks: '+allTasks);
            
            //search previous Task:
            Task originTask = new Task();
            for(Task line : allTasks){
               originTask = line;
            }
            
            system.debug('\n\n### --- originTask: '+originTask);
            
            
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            List<Attachment> attachmentsToDelete = new List<Attachment>();
            
            Attachment tempAtt;

            for(Attachment attachment: [SELECT
                    SystemModstamp, ParentId,
                    //OwnerId,
                    Name, LastModifiedDate, LastModifiedById, 
                    IsPrivate, IsDeleted, Id, Description, CreatedDate, CreatedById, ContentType, 
                    BodyLength, Body 
                FROM Attachment
               WHERE parentId =: originTask.Id])
                
                    {
                        tempAtt=attachment.clone(false,false);
    
                        tempAtt.parentId = t.Id;
                        tempAtt.OwnerId = t.OwnerId;
    
                        attachmentstoInsert.add(tempAtt);
                        //attachmentsToDelete.add(attachment);
    
                    }
                
                    //Copy docs to parent (origin) Task and delete reference docs:
                    insert attachmentsToInsert;
                    //delete attachmentsToDelete;
        
        }
    
    }

}