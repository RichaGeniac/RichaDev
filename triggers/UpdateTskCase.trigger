trigger UpdateTskCase on Task (before insert, before update) {
    
    List <Case> caseList = new List <Case>();
    List <Task> caseTskList = new List <Task>();
    
    Set <Id> contIds = new Set <Id>();
    Set <Id> caseIds = new Set <Id>();
    Set <Id> preCaseIds = new Set <Id>();
    
    
    // 30-Jan-2015: assign user according to department of Task:
    Set <Id> accIds = new Set <Id>();
    Set <Id> casIds = new Set <Id>();
    
    
    for(Task t: trigger.new){
        string whatIdString = '';
        if(t.WhatId != null){
            whatIdString = t.WhatId;
            if(whatIdString.substring(0,3) == '500')
                casIds.add(t.whatId);
        }
    }
    
    //get Account Teams:
    List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
    List<Case> casList = new List<Case>();
    Map<Id,Id> casAcc = new Map<Id,Id>();
    if(casIds.size()>0){
        
        casList = [SELECT id, AccountId FROM Case WHERE id =: casIds];
        
        for(Case c : casList){
            accIds.add(c.AccountId);
        }
        
        accTeamList = [SELECT id, AccountId, TeamMemberRole, UserId 
                         FROM AccountTeamMember
                        WHERE AccountId =: accIds
                          AND IsDeleted = false];

        for(Case c : casList){
            casAcc.put(c.id, c.AccountId);
        }
    }
    // ---
    
    
    for(Task t : Trigger.new){
        
        // INSERT 
        if(Trigger.isInsert){
            contIds.add(t.WhoId);
            
            // 30-Jan-2015: assign user according to department of Task:
            if(t.WhatId != null){
                string whatIdString = '';
                whatIdString = t.WhatId;
            
                if(whatIdString.substring(0,3) == '500'){
        
                    if(t.Department__c != '' && t.Department__c != null && accTeamList.size() > 0){
                        string accIdAux = casAcc.get(t.WhatId);
                        for(AccountTeamMember m : accTeamList){
                            if(m.AccountId == accIdAux && m.TeamMemberRole == t.Department__c)
                                t.OwnerId = m.UserId;
                        }
                    }
                }
            }
            // ---
            
        } 
        
        
        // UPDATE
        if(Trigger.isUpdate){
            if(Trigger.oldMap.get(t.Id).WhoId != Trigger.newMap.get(t.Id).WhoId) {
                contIds.add(t.WhoId); 
            }
            if(Trigger.oldMap.get(t.Id).Status != Trigger.newMap.get(t.Id).Status && t.Status == 'Completed') {
                caseIds.add(t.WhatId); 
                
                if(t.PredecessorCaseID__c != null && t.PredecessorCaseID__c != ''){
                    preCaseIds.add(t.PredecessorCaseID__c);
                }
            }
        }
        
        
    }
    
    system.debug('\n ---------- UpdateTskCase -- contIds: '+contIds);
    system.debug('\n ---------- UpdateTskCase -- caseIds: '+caseIds);
    system.debug('\n ---------- UpdateTskCase -- preCaseIds: '+preCaseIds);
    
    Map <Id, Contact> contsMap;                                     // Map <Contact.ID, Contact> contsMap
    Map <Id, Case> casesMap;                                        // Map <Case.ID, Case> casesMap 
    Map <Id, Case> preCasesMap;                                     // Map <Case.ID, Case> preCasesMap 
    Map <Id, Case> preWFCasesMap;                                   // Map <Workflow.ID, Case> preWFCasesMap --» for creation of the new group of tasks
    Map <Id, Map <String, List <Task>>> tasksMap;                   // Map <Workflow.ID, Map <TaskGroup, List <Task>>> tasksMap
    Map <Id, Map <String, List <WorkflowTask__c>>> wfTasksMap;      // Map <Workflow.ID, Map <TaskGroup, List <WorkflowTask>>> wfTasksMap
    
    if(contIds.size() > 0){
        contsMap = new Map <Id, Contact>([SELECT Id, User__c, User__r.Name FROM Contact WHERE Id in: contIds]);
    }
    
    if(caseIds.size() > 0){
        casesMap = new Map <Id, Case> ([SELECT Id, ContactId, Status, Stage__c, Workflow__c, TotalTasks__c, TotalCompletedTasks__c, GENIAC_Manager_ID__c FROM Case WHERE Id in: caseIds]);
        
        if(preCaseIds.size() > 0){
            preCasesMap = new Map <Id, Case> ([SELECT Id, ContactId, Status, Stage__c, Workflow__c, TotalTasks__c, TotalCompletedTasks__c, IsClosed, GENIAC_Manager_ID__c FROM Case WHERE Id in: preCaseIds]);
        }
        
        if(casesMap != null && casesMap.size() > 0){
            
            Set <Id> wfIds = new Set <Id>();
            
            for(Case c : casesMap.values()){
                if(c.Workflow__c != null){
                    wfIds.add(c.Workflow__c); 
                }
            }
            
            Set <Id> prewfIds = new Set <Id>();
            if(wfIds.size() > 0){            
                wfTasksMap = new Map <Id, Map <String, List <WorkflowTask__c>>>();
                for(WorkflowTask__c wft : [SELECT id, Name, Workflow__c, TaskGroup__c, SortOrder__c, CaseStageNew__r.Name, CaseStatus__c, YesNoTask__c, GroupNo__c, GroupYes__c, NextGroupAlternative__c,
                                                  AssignTo__c, Department__c, TaskDescription__c, Hotdocs_ID__c, PredessessorWorkflow__c, Action__c, HotdocsVisible__c,
                                                  Deadline_in_days__c,
                                                  User_decision_task__c, Option_1__c, Option_2__c, Option_3__c, Option_4__c, Option_5__c,
                                                  Group_when_Option_1__c, Group_when_Option_2__c, Group_when_Option_3__c, Group_when_Option_4__c, Group_when_Option_5__c,
                                                  Description_body_1__c, Description_body_2__c,
                                                  Status__c, Product_Information__c, Product_Information__r.Name,
                                                  Product_new_Case__c, Internal_Case__c,
                                                  Product_Information__r.ProductTitle__c, Product_Information__r.ProductSubTitle__c, Product_Information__r.Description, Product_Information__r.Legally_required__c,
                                                  Product_Information__r.Needed_when__c, Product_Information__r.Disclaimer__c,
                                                  Internal_Instructions__c, Task_Visible__c, Solution__c, SolutionPublicURL__c, Solution_is_public__c, Close_Case__c, Transfer_Docs_to_Parent_Case__c, Transfer_Docs_from_previous_task__c,
                                                  Get_Payslip_information_when_closed__c,
                                                  XpressDocs_Data_Set__c,XpressDocs_Return_URL__c,XpressDocs_ID__c //lvadim01  
                                            FROM WorkflowTask__c 
                                            WHERE Workflow__c in: wfIds
                                            ORDER BY TaskGroup__c ASC, SortOrder__c ASC]){
                    
                    if(wfTasksMap.containsKey(wft.Workflow__c)){                    
                    
                        if(wfTasksMap.get(wft.Workflow__c).containsKey(wft.TaskGroup__c)){                        
                            wfTasksMap.get(wft.Workflow__c).get(wft.TaskGroup__c).add(wft);  
                            
                        } else {
                            List <WorkflowTask__c> wftl = new List <WorkflowTask__c>();
                            wftl.add(wft);
                            wfTasksMap.get(wft.Workflow__c).put(wft.TaskGroup__c, wftl);
                        
                        }
                        
                    } else {
                        List <WorkflowTask__c> wftl = new List <WorkflowTask__c>();
                        wftl.add(wft);
                        
                        Map <String, List <WorkflowTask__c> > wftm = new Map <String, List <WorkflowTask__c> >();
                        wftm.put(wft.TaskGroup__c, wftl);
                        
                        wfTasksMap.put(wft.Workflow__c, wftm);
                    
                    }     
                    
                    if(wft.PredessessorWorkflow__c != null){
                        prewfIds.add(wft.PredessessorWorkflow__c);
                    }    
                                   
                }    
                
                if(prewfIds.size() > 0) {
                    preWFCasesMap = new Map <Id, Case>();
                    for(Case prec : [SELECT Id, ContactId, CaseNumber, Workflow__c, IsClosed FROM Case WHERE Workflow__c in: prewfIds AND IsClosed = false]){
                        preWFCasesMap.put(prec.Workflow__c, prec);    
                    }
                }
            }  
            
            tasksMap = new Map <Id, Map <String, List <Task>>>();
            for(Task tsk : [SELECT id, WhatId, Status, TaskGroup__c, SortOrder__c, CaseStatus__c, CaseStage__c
                                       FROM Task 
                                       WHERE WhatId in: casesMap.keySet()
                                       ORDER BY TaskGroup__c ASC, SortOrder__c ASC]){
                
                if(tasksMap.containsKey(tsk.WhatId)){
                
                    if(tasksMap.get(tsk.WhatId).containsKey(tsk.TaskGroup__c)){
                        tasksMap.get(tsk.WhatId).get(tsk.TaskGroup__c).add(tsk);  
                        
                    } else {
                        List <Task> tl = new List <Task>();
                        tl.add(tsk);
                        tasksMap.get(tsk.WhatId).put(tsk.TaskGroup__c, tl);
                    
                    }
                    
                } else {
                    List <Task> tl = new List <Task>();
                    tl.add(tsk);
                    
                    Map <String, List <Task> > tm = new Map <String, List <Task> >();
                    tm.put(tsk.TaskGroup__c, tl);
                    
                    tasksMap.put(tsk.WhatId, tm);
                }  
            }
        }
    }
    
    system.debug('\n ---------- UpdateTskCase -- contsMap: '+contsMap);
    system.debug('\n ---------- UpdateTskCase -- casesMap: '+casesMap);
    system.debug('\n ---------- UpdateTskCase -- preCasesMap: '+preCasesMap);
    system.debug('\n ---------- UpdateTskCase -- preWFCasesMap: '+preWFCasesMap);
    system.debug('\n ---------- UpdateTskCase -- tasksMap: '+tasksMap);
    system.debug('\n ---------- UpdateTskCase -- wfTasksMap: '+wfTasksMap);
    
    for(Task t : Trigger.new){
        
        // INSERT 
        if(Trigger.isInsert) {
            system.debug('\n ---------- UpdateTskCase -- INSERT\n');
            
            // sets user on task (Customer User)
            if(contsMap != null && contsMap.size() > 0) {
                if(contsMap.containsKey(t.WhoId)){
                    t.UserID__c = contsMap.get(t.WhoId).User__c;
                    t.UserName__c = contsMap.get(t.WhoId).User__r.Name;
                }   
            }
        }
        
        // UPDATE
        if(Trigger.isUpdate){
            system.debug('\n ---------- UpdateTskCase -- UPDATE\n');
            
            // updates user on task (Customer User) if it changes
            if(Trigger.oldMap.get(t.Id).WhoId != Trigger.newMap.get(t.Id).WhoId) {
                 if(contsMap != null && contsMap.size() > 0) {
                    if(contsMap.containsKey(t.WhoId)){
                        t.UserID__c = contsMap.get(t.WhoId).User__c;
                        t.UserName__c = contsMap.get(t.WhoId).User__r.Name;
                    }   
                }
            }
            
            

            
            // updates case tasks (according to workflow) when the task is set to Status = 'Completed'
            if(Trigger.oldMap.get(t.Id).Status != Trigger.newMap.get(t.Id).Status && t.Status == 'Completed') {
                
                 if(casesMap != null && casesMap.size() > 0){
                     if(casesMap.containsKey(t.WhatId)){
                         
                         /**
                          * Verifies precase situation (open/closed?) -----------------------------------------------------------------------------
                          */
                         
                         // gets the corresponding precase (if the task has it)
                         if(preCasesMap != null){
                             Case prec = preCasesMap.get(t.PredecessorCaseID__c);
                             if(!prec.IsClosed){
                                t.addError('The task cannot be set to \'Completed\' if the Predecessor Case is not closed.');
                            }
                         }

                         /**
                          * Creates next group of tasks --------------------------------------------------------------------------------------------
                          */

                         // gets the corresponding case for this task
                         Case c = casesMap.get(t.WhatId);
                         
                         if(tasksMap != null && tasksMap.size() > 0){
                             if(tasksMap.containsKey(c.Id)){
                                 
                                 // gets all the tasks in this group of tasks
                                 List <Task> tl = tasksMap.get(c.Id).get(t.TaskGroup__c);
                                 Integer idx = 0;
                                 Integer idxAux = 0;
                                 Integer gtCompletes = 1;       // group task has at least 1 task completed, which is THIS one
                                 
                                 system.debug('\n\n### --- task list tl: '+tl);
                                 //pesquisa next tarefa:
                                 for(Task tt : tl){
                                     //logic replaced on 12-Feb-2015:
                                     idxAux = idxAux + 1;
                                     if(tt.Id == t.Id){
                                         idx = idxAux;
                                         break;
                                     }
                                     /**
                                     if(tt.Id != t.Id){
                                         idx++;
                                     }
                                     */
                                     
                                     // gets the rest of completed tasks in the group task
                                     if(tt.Status == 'Completed'){
                                         gtCompletes++;
                                     }
                                 }
                                 
                                 // set case stage & status with next task casestage & casestatus
                                 system.debug('\n\n### --- idx: '+idx);
                                 try{
                                     c.Stage__c = tl.get(idx).CaseStage__c;
                                     c.Status = tl.get(idx).CaseStatus__c;
                                 }catch(exception ex){
                                 }
                                 
                                 
                                 IF(c.TotalCompletedTasks__c == null){
                                    c.TotalCompletedTasks__c = 0; 
                                 }
                                 c.TotalCompletedTasks__c += 1;
                                 
                                 // checks if all tasks of the group are completed -- creates new set of tasks
                                 if(gtCompletes == tl.size()){
                                     
                                     if(wfTasksMap != null && wfTasksMap.size() > 0){
                                         
                                         // gets the tasks of the correspondent workflow for the task case
                                         Map <String, List <WorkflowTask__c>> wftm = wfTasksMap.get(c.Workflow__c);
                                        
                                         if(wftm != null && wftm.size() > 0){
                                             
                                             String nextTG;
                                            
                                             // sets the next group of tasks to be created, given the workflow
                                             List <String> tgl = new List <String> (wftm.keyset());
                                             tgl.sort();
                                             
                                             Integer idx2 = 0;
                                             for(String tg : tgl){
                                                 if(tg == t.TaskGroup__c){
                                                     break;
                                                 } 
                                                 idx2++;
                                             }
                                            
                                             // workflow in sequence (no yes/no tasks and no alternative paths)
                                             if(idx2 < tgl.size()-1){ 
                                                 nextTG = tgl.get(idx2+1);
                                             }
                                             
                                             // check if task is yes/no task
                                             if(t.YesNoTask__c) {    
                                                 if(t.TaskResult__c == 'Yes'){
                                                     nextTG = t.GroupYes__c;   
                                                 } else {
                                                     nextTG = t.GroupNo__c;
                                                 } 
                                             }
                                             
                                             //new process 12-Feb-2015: check if Task is to close Case:    ***new process*** 
                                                if(t.Close_Case__c == true){
                                                    c.Status = 'Closed';
                                                }
                                             //---
                                             
                                             
                                             //check if task is User-decision task    ***new process*** 
                                             if(t.User_decision_task__c){
                                                  system.debug('### User Decision Task');
                                                  
                                                  if(t.User_decision__c != '' && t.User_decision__c != null){
                                                     system.debug('### User Decision: '+t.User_decision__c);
                                                     
                                                     if(t.User_decision__c == 'Option 1'){
                                                         nextTG = t.Group_when_Option_1__c;
                                                     }
                                                     else if(t.User_decision__c == 'Option 2'){
                                                         nextTG = t.Group_when_Option_2__c;
                                                     }
                                                     else if(t.User_decision__c == 'Option 3'){
                                                         nextTG = t.Group_when_Option_3__c;
                                                     }
                                                     else if(t.User_decision__c == 'Option 4'){
                                                         nextTG = t.Group_when_Option_4__c;
                                                     }
                                                     else if(t.User_decision__c == 'Option 5'){
                                                         nextTG = t.Group_when_Option_5__c;
                                                     }
                                                 }
                                             }
                                             
                                             // check if it has alternative path    
                                             if(t.NextGroupAlternative__c != null && t.NextGroupAlternative__c != ''){
                                                 
                                                 if(t.NextGroupAlternative__c != t.TaskGroup__c) {
                                                     nextTG = t.NextGroupAlternative__c;
                                                 
                                                 // if Next Group Alternative == Task Group, the workflow stops there no more tasks to be created.
                                                 } else {
                                                     nextTG = '';
                                                 }
                                             }
                                                 
                                             // there is a next group of tasks to be created (nextTG != null)    
                                             if(nextTG != null && nextTG != ''){
                                                 
                                                 // get all the wftasks of the next group to be created
                                                 List <WorkflowTask__c> wftl = wftm.get(nextTG);
                                                 
                                                 if(wftl != null && wftl.size() > 0){
                                                 
                                                    // updates case total of tasks
                                                    c.TotalTasks__c += wftl.size();
                                                    
                                                    
                                                    // replicates the wftasks ot the group
                                                    for(WorkflowTask__c wft : wftl){
                                                
                                                        Task tk = new Task();
                                                        tk.WhatId = c.Id;
                                                        tk.WhoId = c.ContactId;
                                                        tk.Status = 'Not Started';

                                                        tk.SortOrder__c = wft.SortOrder__c;
                                                        tk.TaskGroup__c = wft.TaskGroup__c;
                                                        tk.CaseStage__c = wft.CaseStageNew__r.Name;
                                                        tk.CaseStatus__c = wft.CaseStatus__c;
                                                        tk.YesNoTask__c = wft.YesNoTask__c;
                                                        tk.Close_Case__c = wft.Close_Case__c;
                                                        tk.Transfer_Docs_to_Parent_Case__c = wft.Transfer_Docs_to_Parent_Case__c;
                                                        tk.Get_Payslip_information_when_closed__c = wft.Get_Payslip_information_when_closed__c;
                                                        tk.Transfer_Docs_from_previous_task__c = wft.Transfer_Docs_from_previous_task__c;
                                                        tk.GroupNo__c = wft.GroupNo__c;
                                                        tk.GroupYes__c = wft.GroupYes__c;
                                                        tk.NextGroupAlternative__c = wft.NextGroupAlternative__c;
                                                        tk.Subject = wft.Name;
                                                        
                                                        //[CT] changed on 29-Oct-2014:
                                                        //tk.Description = wft.TaskDescription__c;
                                                        tk.Description = '';
                                                        //[CT] removed on 24-12-2014 - request from Jerome:
                                                        /**
                                                        if(wft.TaskDescription__c != null) tk.Description = tk.Description +
                                                                                            '\n\n---\n'+
                                                                                            wft.TaskDescription__c;*/
                                                        if(wft.Description_body_1__c != null && wft.Description_body_1__c !='') tk.Description = tk.Description +
                                                                                            //'\n\n<hr>\n'+
                                                                                            wft.Description_body_1__c;
                                                        if(wft.Description_body_2__c != null && wft.Description_body_2__c !='') tk.Description = tk.Description +
                                                                                            '\n\n<hr>\n'+
                                                                                            wft.Description_body_2__c;
                                                        if(wft.Status__c != null && wft.Status__c != '') tk.Description = tk.Description +
                                                                                            '\n\n<b>Status</b>\n<hr>\n'+
                                                                                            wft.Status__c;
                                                        
                                                        system.debug('\n\n --- AssignTo xx: '+wft.AssignTo__c+' --- GENIAC_Manager__ID:'+c.GENIAC_Manager_ID__c);
                                                        tk.AssignTo__c = wft.AssignTo__c;
                                                        if(wft.AssignTo__c == 'SSC' && c.GENIAC_Manager_ID__c != null) tk.OwnerId = c.GENIAC_Manager_ID__c;
                                                        tk.Department__c = wft.Department__c;
                                                        tk.Hotdocs_ID__c = wft.Hotdocs_ID__c;
                                                        tk.HotdocsVisible__c = wft.HotdocsVisible__c;
                                                        tk.Action__c = wft.Action__c;
                                                        //lvadim01 09-Jul-2015
                                                        tk.XpressDocs_Data_Set__c = wft.XpressDocs_Data_Set__c;
                                                        tk.XpressDocs_Return_URL__c = wft.XpressDocs_Return_URL__c;
                                                        tk.XpressDocs_template_ID__c = wft.XpressDocs_ID__c;
                                                        
                                                        // new process: user decision tasks:
                                                        tk.User_decision_task__c = wft.User_decision_task__c; 
                                                        IF(wft.Option_1__c!= null){tk.Option_1__c = wft.Option_1__c;}
                                                        IF(wft.Option_2__c!= null){tk.Option_2__c = wft.Option_2__c;}
                                                        IF(wft.Option_3__c!= null){tk.Option_3__c = wft.Option_3__c;} 
                                                        IF(wft.Option_4__c!= null){tk.Option_4__c = wft.Option_4__c;} 
                                                        IF(wft.Option_5__c!= null){tk.Option_5__c = wft.Option_5__c;}
                                                        IF(wft.Group_when_Option_1__c!= null){tk.Group_when_Option_1__c = wft.Group_when_Option_1__c;}
                                                        IF(wft.Group_when_Option_2__c!= null){tk.Group_when_Option_2__c = wft.Group_when_Option_2__c;} 
                                                        IF(wft.Group_when_Option_3__c!= null){tk.Group_when_Option_3__c = wft.Group_when_Option_3__c;} 
                                                        IF(wft.Group_when_Option_4__c!= null){tk.Group_when_Option_4__c = wft.Group_when_Option_4__c;} 
                                                        IF(wft.Group_when_Option_5__c!= null){tk.Group_when_Option_5__c = wft.Group_when_Option_5__c;}
                                                        
                                                        //---
                                                        //IF(wft.Description_body_1__c!= null){IF(wft.Description_body_1__c.length()>255){tk.Description_body_1__c = wft.Description_body_1__c.substring(0,254);}ELSE{tk.Description_body_1__c = wft.Description_body_1__c;}}
                                                        //system.debug('\n\n ### Description Body 1: '+tk.Description_body_1__c);

                                                        //IF(wft.Description_body_2__c!= null){IF(wft.Description_body_2__c.length()>255){tk.Description_body_2__c = wft.Description_body_2__c.substring(0,254);}ELSE{tk.Description_body_2__c = wft.Description_body_2__c;}}
                                                        //system.debug('\n\n ### Description Body 1: '+tk.Description_body_2__c);
                                                        
                                                        IF(wft.Deadline_in_days__c != null){
                                                            tk.ActivityDate = System.today().addDays(integer.valueOf(wft.Deadline_in_days__c));
                                                        }
                                                        
                                                        //tk.Status_WF_Task__c = wft.Status__c;
                                                        
                                                        tk.Product_Information__c = wft.Product_Information__c;
                                                        tk.Product_Information_Label__c = wft.Product_Information__r.Name;
                                                        tk.ProductTitle__c        = wft.Product_Information__r.ProductTitle__c;
                                                        tk.ProductSubTitle__c     = wft.Product_Information__r.ProductSubTitle__c;
                                                        //tk.Needed_when__c         = wft.Product_Information__r.Needed_when__c;
                                                        //tk.Disclaimer__c          = wft.Product_Information__r.Disclaimer__c;
                                                        tk.Legally_required__c    = wft.Product_Information__r.Legally_required__c;
                                                        
                                                        //new fields added on 27 Jan 2015:
                                                        if(wft.Internal_Instructions__c != null)
                                                            tk.Internal_Instructions__c = wft.Internal_Instructions__c.abbreviate(254);
                                                        tk.Task_Visible__c          = wft.Task_Visible__c;
                                                        tk.Solution_Id__c           = wft.Solution__c;
                                                        
                                                        /**
                                                        IF( wft.Description_body_1__c != null && wft.Description_body_1__c != '' ){
                                                            tk.Description            = tk.Description + '\r\n' +
                                                                                       '---' + '\r\n' +
                                                                                       'Description 1:' + '\r\n' +
                                                                                       wft.Description_body_1__c;
                                                        }
                                                        
                                                        IF( wft.Description_body_2__c != null && wft.Description_body_2__c != '' ){
                                                            tk.Description            = tk.Description + '\r\n' +
                                                                                       '---' + '\r\n' +
                                                                                       'Description 2:' + '\r\n' +
                                                                                       wft.Description_body_2__c;
                                                        }
                                                        */
                                                        
                                                        IF( wft.Product_Information__c != null ){
                                                            tk.Description            = tk.Description + '\r\n' +
                                                                                       '---' + '\r\n' +
                                                                                       'Product Description:' + '\r\n' +
                                                                                       wft.Product_Information__r.Description + '\r\n' +
                                                                                       '---' + '\r\n' +
                                                                                       'Needed When:' + '\r\n' +
                                                                                       wft.Product_Information__r.Needed_when__c + '\r\n' +
                                                                                       '---' + '\r\n' +
                                                                                       'Disclaimer:' + '\r\n' +
                                                                                       wft.Product_Information__r.Disclaimer__c;
                                                        }
                                                        if(wft.Solution__c != null && wft.Solution_is_public__c){
                                                        
                                                                tk.Description       = tk.Description +
                                                                                       '\r\n<hr>\r\n'+
                                                                                       '<a href="'+wft.SolutionPublicURL__c+
                                                                                       '" target="_blank">Click here</a> for more information.';
                                                        }
                                                        
                                                        tk.Product_new_Case__c = wft.Product_new_Case__c;
                                                        tk.Internal_Case__c = wft.Internal_Case__c;
                                                        
                                                        
                                                        // checks if the task is connected to a predessessor workflow
                                                        if(wft.PredessessorWorkflow__c != null){
                                                            if(preWFCasesMap != null && preWFCasesMap.containsKey(wft.PredessessorWorkflow__c)){
                                                                
                                                                Case prec = preWFCasesMap.get(wft.PredessessorWorkflow__c);
                                                                if(prec != null){
                                                                    tk.PredecessorCaseID__c = prec.Id;
                                                                    tk.PredecessorCaseNumber__c = prec.CaseNumber;
                                                                }
                                                            }
                                                        }   
                                                    
                                                        caseTskList.add(tk);
                                                    }
                                                 } 
                                             }
                                         }
                                     }
                                 }
                             }
                             
                             caseList.add(c);
                         }
                     }
                 }
             }
        }    
    }
    
    system.debug('\n ---------- UpdateTskCase -- caseTskList: '+caseTskList);
    system.debug('\n ---------- UpdateTskCase -- caseList: '+caseList);
    
    if(caseTskList.size() > 0){
        insert caseTskList;
    }
    
    if(caseList.size() > 0){
        update caseList;
    }
    
}