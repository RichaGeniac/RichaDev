trigger ReplicateWFTasks on Case (before insert, after insert, before update) {
    
    List <Task> caseTskList = new List <Task>();
    
    Set <Id> cIds = new Set <Id>();
    Set <Id> wfIds = new Set <Id>();
    
    for(Case c : Trigger.new){
        
        // INSERT     
        if(Trigger.isInsert && c.Workflow__c != null){
            wfIds.add(c.Workflow__c); 
        }
        
        // UPDATE 
        if(Trigger.isUpdate){
            cIds.add(c.Id);            
            if(c.Workflow__c != null && Trigger.oldMap.get(c.id).Workflow__c != Trigger.newMap.get(c.id).Workflow__c){
                wfIds.add(c.Workflow__c); 
            } 
        }
    }
    
    system.debug('\n ---------- ReplicateWFTasks -- cIds: '+cIds);
    system.debug('\n ---------- ReplicateWFTasks -- wfIds: '+wfIds);


    Map <Id, Case> preCasesMap;
    Map <Id, List <Task>> tasksMap = new Map <Id, List <Task>>();    
    Map <Id, Map <String, List <WorkflowTask__c> > > wfTasksMap = new Map <Id, Map <String, List <WorkflowTask__c> > >();        // Map < WorkflowId, Map < GroupTask, List < WorkflowTak > > > ()
    
    if(cIds.size() > 0){
        for(Task t : [SELECT id, WhatId, Status
                      FROM Task
                      WHERE WhatId in: cIds
                      ORDER BY TaskGroup__c ASC, SortOrder__c ASC]){
            
            if(tasksMap.containsKey(t.WhatId)){
                tasksMap.get(t.WhatId).add(t);
                
            } else {
                List <Task> tl = new List <Task>();
                tl.add(t);
                tasksMap.put(t.WhatId, tl);
            
            }                           
        }
    }
    
    if(wfIds.size() > 0){
                
        Set <Id> prewfIds = new Set <Id>();
    
        for(WorkflowTask__c wft : [SELECT id, Name, Workflow__c, TaskGroup__c, SortOrder__c, CaseStageNew__r.Name, CaseStatus__c, YesNoTask__c, GroupNo__c, GroupYes__c,
                                          AssignTo__c, Department__c, TaskDescription__c, PredessessorWorkflow__c, Action__c, Hotdocs_ID__c, HotdocsVisible__c,
                                          Deadline_in_days__c,
                                          User_decision_task__c, Option_1__c, Option_2__c, Option_3__c, Option_4__c, Option_5__c,
                                          Group_when_Option_1__c, Group_when_Option_2__c, Group_when_Option_3__c, Group_when_Option_4__c, Group_when_Option_5__c,
                                          Description_body_1__c, Description_body_2__c,
                                          Status__c, Product_Information__c, Product_Information__r.Name,
                                          Product_new_Case__c, Internal_Case__c,
                                          Product_Information__r.ProductTitle__c, Product_Information__r.ProductSubTitle__c, Product_Information__r.Description, Product_Information__r.Legally_required__c,
                                          Product_Information__r.Needed_when__c, Product_Information__r.Disclaimer__c,
                                          Task_Visible__c, Internal_Instructions__c, 
                                          Solution__c, Solution_is_public__c, SolutionPublicURL__c, Close_Case__c, Transfer_Docs_to_Parent_Case__c,Transfer_Docs_from_previous_task__c,
                                          Get_Payslip_information_when_closed__c,
                                          XpressDocs_Data_Set__c,XpressDocs_Return_URL__c,XpressDocs_ID__c,SubArea__c//lvadim01 
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
        
        preCasesMap = new Map <Id, Case>();
        if(prewfIds.size() > 0) {
            for(Case prec : [SELECT Id, CaseNumber, Workflow__c, Account.OwnerId FROM Case WHERE Workflow__c in: prewfIds AND IsClosed = false]){
                preCasesMap.put(prec.Workflow__c, prec);    
            }
        }     
    }  
    
    system.debug('\n ---------- ReplicateWFTasks -- preCasesMap: '+preCasesMap);
    system.debug('\n ---------- ReplicateWFTasks -- tasksMap: '+tasksMap);
    system.debug('\n ---------- ReplicateWFTasks -- wfTasksMap: '+wfTasksMap);
    
    if(cIds.size() > 0 || wfIds.size() > 0){
    
        for(Case c : Trigger.new){
            
            // INSERT ------------------------------------
            if(Trigger.isInsert && c.Workflow__c != null){
            
                system.debug('\n ---------- ReplicateWFTasks -- INSERT\n');
            
                if(wfTasksMap != null && wfTasksMap.size() > 0){
                
                    Map <String, List <WorkflowTask__c>> wftm = wfTasksMap.get(c.Workflow__c);
                    if(wftm != null && wftm.size() > 0){
                        
                        List <String> tgl = new List <String> (wftm.keyset());
                        tgl.sort();
                        
                        String fstTG = tgl.get(0);
                        List <WorkflowTask__c> wftl = wftm.get(fstTG);
                        
                        if(wftl != null && wftl.size() > 0){
                           
                            // BEFORE 
                            if(Trigger.isBefore){
                                system.debug('\n ---------- ReplicateWFTasks -- BEFORE\n');
                                    
                                c.TotalTasks__c = wftl.size(); 
                                c.TotalCompletedTasks__c = 0;
                                c.Stage__c = wftl.get(0).CaseStageNew__r.Name;
                                c.Status = wftl.get(0).CaseStatus__c;
                                
                            } 
                            
                            // AFTER
                            if(Trigger.isAfter){
                                system.debug('\n ---------- ReplicateWFTasks -- AFTER\n');
                            
                                for(WorkflowTask__c wft : wftl){
                            
                                    Task t = new Task();
                                    t.WhatId = c.Id;
                                    t.WhoId = c.ContactId;
                                    t.Status = 'Not Started';

                                    t.SortOrder__c = wft.SortOrder__c;
                                    t.TaskGroup__c = wft.TaskGroup__c;
                                    t.CaseStage__c = wft.CaseStageNew__r.Name;
                                    t.CaseStatus__c = wft.CaseStatus__c;
                                    t.YesNoTask__c = wft.YesNoTask__c;
                                    t.Close_Case__c = wft.Close_Case__c;
                                    t.Transfer_Docs_to_Parent_Case__c = wft.Transfer_Docs_to_Parent_Case__c;
                                    t.Transfer_Docs_from_previous_task__c = wft.Transfer_Docs_from_previous_task__c;
                                    t.Get_Payslip_information_when_closed__c = wft.Get_Payslip_information_when_closed__c;
                                    t.GroupNo__c = wft.GroupNo__c;
                                    t.GroupYes__c = wft.GroupYes__c;
                                    t.Subject = wft.Name;                                    
                                    //[CT] changed on 29-Oct-2014:
                                    //t.Description = wft.TaskDescription__c;
                                    t.Description = '';
                                    //[CT] removed on 24-12-2014 (request from Jerome):
                                    /**
                                    if(wft.TaskDescription__c != null) t.Description = t.Description +
                                                                        '\n\n<hr>\n'+
                                                                        wft.TaskDescription__c;*/
                                    if(wft.Description_body_1__c != null && wft.Description_body_1__c != '') t.Description = t.Description +
                                                                        //'\n\n<hr>\n'+
                                                                        wft.Description_body_1__c;
                                    if(wft.Description_body_2__c != null && wft.Description_body_2__c != '') t.Description = t.Description +
                                                                        '\n\n<hr>\n'+
                                                                        wft.Description_body_2__c;
                                    if(wft.Status__c != null && wft.Status__c != '') t.Description = t.Description +
                                                                        '\n\n<b>Status</b>\n<hr>\n'+
                                                                        wft.Status__c;
                                                                        

                                    //IF(wft.Description_body_1__c!= null){IF(wft.Description_body_1__c.length()>255){t.Description_body_1__c = wft.Description_body_1__c.substring(0,254);}ELSE{t.Description_body_1__c = wft.Description_body_1__c;}}
                                    //IF(wft.Description_body_2__c!= null){IF(wft.Description_body_2__c.length()>255){t.Description_body_2__c = wft.Description_body_2__c.substring(0,254);}ELSE{t.Description_body_2__c = wft.Description_body_2__c;}}

                                    system.debug('\n\n --- AssignTo: '+wft.AssignTo__c+' --- GENIAC_Manager__ID:'+c.GENIAC_Manager_ID__c);
                                    t.AssignTo__c = wft.AssignTo__c;
                                    if(wft.AssignTo__c == 'SSC' && c.GENIAC_Manager_ID__c != null) t.OwnerId = c.GENIAC_Manager_ID__c;
                                    t.Deadline_in_days__c= wft.Deadline_in_days__c;
                                    if(t.Deadline_in_days__c != null){
                                        t.Deadline__c = date.today().addDays(t.Deadline_in_days__c.intvalue());
                                    }
                                    t.Department__c = wft.Department__c;
                                    t.SubArea__c = wft.SubArea__c;
                                    t.Hotdocs_ID__c = wft.Hotdocs_ID__c;
                                    t.HotdocsVisible__c = wft.HotdocsVisible__c;
                                    t.Action__c = wft.Action__c;
                                    //lvadim01 09-Jul-2015
                                    t.XpressDocs_Data_Set__c = wft.XpressDocs_Data_Set__c;
                                    t.XpressDocs_Return_URL__c = wft.XpressDocs_Return_URL__c;
                                    t.XpressDocs_template_ID__c = wft.XpressDocs_ID__c;   
                                    // new process: user decision tasks:
                                    t.User_decision_task__c = wft.User_decision_task__c; 
                                    IF(wft.Option_1__c!= null){t.Option_1__c = wft.Option_1__c;}
                                    IF(wft.Option_2__c!= null){t.Option_2__c = wft.Option_2__c;}
                                    IF(wft.Option_3__c!= null){t.Option_3__c = wft.Option_3__c;} 
                                    IF(wft.Option_4__c!= null){t.Option_4__c = wft.Option_4__c;} 
                                    IF(wft.Option_5__c!= null){t.Option_5__c = wft.Option_5__c;}
                                    IF(wft.Group_when_Option_1__c!= null){t.Group_when_Option_1__c = wft.Group_when_Option_1__c;}
                                    IF(wft.Group_when_Option_2__c!= null){t.Group_when_Option_2__c = wft.Group_when_Option_2__c;} 
                                    IF(wft.Group_when_Option_3__c!= null){t.Group_when_Option_3__c = wft.Group_when_Option_3__c;} 
                                    IF(wft.Group_when_Option_4__c!= null){t.Group_when_Option_4__c = wft.Group_when_Option_4__c;} 
                                    IF(wft.Group_when_Option_5__c!= null){t.Group_when_Option_5__c = wft.Group_when_Option_5__c;}
                                    
                                    
                                    IF(wft.Deadline_in_days__c != null){
                                        t.ActivityDate = System.today().addDays(integer.valueOf(wft.Deadline_in_days__c));
                                    }
                                    
                                    //t.Status_WF_Task__c = wft.Status__c;
                                    
                                    t.Product_Information__c = wft.Product_Information__c;
                                    t.Product_Information_Label__c = wft.Product_Information__r.Name;
                                    t.ProductTitle__c        = wft.Product_Information__r.ProductTitle__c;
                                    t.ProductSubTitle__c     = wft.Product_Information__r.ProductSubTitle__c;
                                    //t.Needed_when__c         = wft.Product_Information__r.Needed_when__c;
                                    //t.Disclaimer__c          = wft.Product_Information__r.Disclaimer__c;
                                    t.Legally_required__c    = wft.Product_Information__r.Legally_required__c;
                                    
                                    //new fidled added on 27 Jan 2015
                                    if(wft.Internal_Instructions__c != null)
                                     t.Internal_Instructions__c = wft.Internal_Instructions__c.abbreviate(254);
                                    t.Task_Visible__c          = wft.Task_Visible__c;
                                    t.Solution_Id__c           = wft.Solution__c;
                                    
                                    /**
                                    IF( wft.Description_body_1__c != null && wft.Description_body_1__c != '' ){
                                        t.Description            = t.Description + '\r\n' +
                                                                   '---' + '\r\n' +
                                                                   'Description 1:' + '\r\n' +
                                                                   wft.Description_body_1__c;
                                    }
                                    
                                    IF( wft.Description_body_2__c != null && wft.Description_body_2__c != '' ){
                                        t.Description            = t.Description + '\r\n' +
                                                                   '---' + '\r\n' +
                                                                   'Description 2:' + '\r\n' +
                                                                   wft.Description_body_2__c;
                                    }
                                    */
                                    
                                    IF( wft.Product_Information__c != null ){
                                        t.Description            = t.Description + '\r\n' +
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
                                            t.Description       = t.Description +
                                                                   '\r\n<hr>\r\n'+
                                                                   '<a href="'+wft.SolutionPublicURL__c+
                                                                   '" target="_blank">Click here</a> for more information.';
                                    }
                                    
                                    t.Product_new_Case__c = wft.Product_new_Case__c;
                                    t.Internal_Case__c = wft.Internal_Case__c;

                                    
                                    // checks if the task is connected to a predessessor workflow
                                    if(wft.PredessessorWorkflow__c != null){
                                        if(preCasesMap != null && preCasesMap.containsKey(wft.PredessessorWorkflow__c)){
                                            
                                            Case prec = preCasesMap.get(wft.PredessessorWorkflow__c);
                                            if(prec != null){
                                                t.PredecessorCaseID__c = prec.Id;
                                                t.PredecessorCaseNumber__c = prec.CaseNumber;
                                            }
                                        }
                                    }   
                                    
                                    caseTskList.add(t);
                                }
                            }
                        }
                    }
                }
            }
            // INSERT - END ------------------------------
            
            // UPDATE ------------------------------------
            if(Trigger.isUpdate){
                system.debug('\n ---------- ReplicateWFTasks -- UPDATE\n');

                Integer totalTs = 0;
                Integer totalCTs = 0;
            
                if(tasksMap != null && tasksMap.size() > 0){

                    List <Task> tl = tasksMap.get(c.Id);
                    if(tl != null && tl.size() > 0){
                        totalTs = tl.size();

                        for(Task t : tl){
                            if(t.Status == 'Completed'){
                                totalCTs++;
                            }
                        }                    
                    
                    }
                    

                }

                c.TotalTasks__c = totalTs;
                
                if(c.Workflow__c != null && Trigger.oldMap.get(c.id).Workflow__c != Trigger.newMap.get(c.id).Workflow__c){
                
                    if(wfTasksMap != null && wfTasksMap.size() > 0){
                
                        Map <String, List <WorkflowTask__c>> wftm = wfTasksMap.get(c.Workflow__c);
                        if(wftm != null && wftm.size() > 0){
                        
                            List <String> tgl = new List <String> (wftm.keyset());
                            tgl.sort();
                            
                            String fstTG = tgl.get(0);
                            List <WorkflowTask__c> wftl = wftm.get(fstTG);
                            
                            if(wftl != null && wftl.size() > 0){
                                
                                c.TotalTasks__c += wftl.size();
                            
                                for(WorkflowTask__c wft : wftl){
                            
                                    Task t = new Task();
                                    t.WhatId = c.Id;
                                    t.WhoId = c.ContactId;
                                    t.WhatId = c.Id;
                                    t.Status = 'Not Started';

                                    t.SortOrder__c = wft.SortOrder__c;
                                    t.TaskGroup__c = wft.TaskGroup__c;
                                    t.CaseStage__c = wft.CaseStageNew__r.Name;
                                    t.CaseStatus__c = wft.CaseStatus__c;
                                    t.YesNoTask__c = wft.YesNoTask__c;
                                    t.Close_Case__c = wft.Close_Case__c;
                                    t.Transfer_Docs_to_Parent_Case__c = wft.Transfer_Docs_to_Parent_Case__c;
                                    t.Transfer_Docs_from_previous_task__c = wft.Transfer_Docs_from_previous_task__c;
                                    t.Get_Payslip_information_when_closed__c = wft.Get_Payslip_information_when_closed__c;
                                    t.GroupNo__c = wft.GroupNo__c;
                                    t.GroupYes__c = wft.GroupYes__c;
                                    t.Subject = wft.Name;                        
                                    //[CT] changed on 29-Oct-2014:
                                    //t.Description = wft.TaskDescription__c;
                                    t.Description = '';
                                    //[CT] removed on 24-12-2014 - request form Jerome:
                                    /**
                                    if(wft.TaskDescription__c != null) t.Description = t.Description +
                                                                        '\n\n<hr>\n'+
                                                                        wft.TaskDescription__c;*/
                                    if(wft.Description_body_1__c != null && wft.Description_body_1__c !='') t.Description = t.Description +
                                                                        //'\n\n<hr>\n'+
                                                                        wft.Description_body_1__c;
                                    if(wft.Description_body_2__c != null && wft.Description_body_2__c !='') t.Description = t.Description +
                                                                        '\n\n<hr>\n'+
                                                                        wft.Description_body_2__c;
                                    if(wft.Status__c != null && wft.Status__c != '') t.Description = t.Description +
                                                                        '\n\n<b>Status</b>\n<hr>\n'+
                                                                        wft.Status__c;
                                                                        
                                    //IF(wft.Description_body_1__c!= null){IF(wft.Description_body_1__c.length()>255){t.Description_body_1__c = wft.Description_body_1__c.substring(0,254);}ELSE{t.Description_body_1__c = wft.Description_body_1__c;}}
                                    //IF(wft.Description_body_2__c!= null){IF(wft.Description_body_2__c.length()>255){t.Description_body_2__c = wft.Description_body_2__c.substring(0,254);}ELSE{t.Description_body_1__c = wft.Description_body_2__c;}}
                                    t.AssignTo__c = wft.AssignTo__c;
                                    if(wft.AssignTo__c == 'SSC' && c.GENIAC_Manager_ID__c != null) t.OwnerId = c.GENIAC_Manager_ID__c;
                                    t.Deadline_in_days__c = wft.Deadline_in_days__c;
                                    if(t.Deadline_in_days__c != null){
                                        t.Deadline__c = date.today().addDays(t.Deadline_in_days__c.intvalue());
                                    }
                                    t.Department__c = wft.Department__c;
                                    t.SubArea__c = wft.SubArea__c;
                                    t.Hotdocs_ID__c = wft.Hotdocs_ID__c;
                                    t.HotdocsVisible__c = wft.HotdocsVisible__c;
                                    t.Action__c = wft.Action__c;
                                    //lvadim01 09-Jul-2015
                                    t.XpressDocs_Data_Set__c = wft.XpressDocs_Data_Set__c;
                                    t.XpressDocs_Return_URL__c = wft.XpressDocs_Return_URL__c;
                                    t.XpressDocs_template_ID__c = wft.XpressDocs_ID__c;
                                    // new process: user decision tasks:
                                    t.User_decision_task__c = wft.User_decision_task__c; 
                                    IF(wft.Option_1__c!= null){t.Option_1__c = wft.Option_1__c;}
                                    IF(wft.Option_2__c!= null){t.Option_2__c = wft.Option_2__c;}
                                    IF(wft.Option_3__c!= null){t.Option_3__c = wft.Option_3__c;} 
                                    IF(wft.Option_4__c!= null){t.Option_4__c = wft.Option_4__c;} 
                                    IF(wft.Option_5__c!= null){t.Option_5__c = wft.Option_5__c;}
                                    IF(wft.Group_when_Option_1__c!= null){t.Group_when_Option_1__c = wft.Group_when_Option_1__c;}
                                    IF(wft.Group_when_Option_2__c!= null){t.Group_when_Option_2__c = wft.Group_when_Option_2__c;} 
                                    IF(wft.Group_when_Option_3__c!= null){t.Group_when_Option_3__c = wft.Group_when_Option_3__c;} 
                                    IF(wft.Group_when_Option_4__c!= null){t.Group_when_Option_4__c = wft.Group_when_Option_4__c;} 
                                    IF(wft.Group_when_Option_5__c!= null){t.Group_when_Option_5__c = wft.Group_when_Option_5__c;}
                                    // ---

                                    //t.Status_WF_Task__c = wft.Status__c;
                                    
                                    t.Product_Information__c = wft.Product_Information__c;
                                    t.Product_Information_Label__c = wft.Product_Information__r.Name;
                                    t.ProductTitle__c        = wft.Product_Information__r.ProductTitle__c;
                                    t.ProductSubTitle__c     = wft.Product_Information__r.ProductSubTitle__c;
                                    //t.Needed_when__c         = wft.Product_Information__r.Needed_when__c;
                                    //t.Disclaimer__c          = wft.Product_Information__r.Disclaimer__c;
                                    t.Legally_required__c    = wft.Product_Information__r.Legally_required__c;
                                    
                                    //new fields added on 27 Jan 2015:
                                    if(wft.Internal_Instructions__c != null)
                                        t.Internal_Instructions__c = wft.Internal_Instructions__c.abbreviate(254);
                                    t.Task_Visible__c          = wft.Task_Visible__c;
                                    t.Solution_Id__c           = wft.Solution__c;
                                    
                                    /**
                                    IF( wft.Description_body_1__c != null && wft.Description_body_1__c != '' ){
                                        t.Description            = t.Description + '\r\n' +
                                                                   '---' + '\r\n' +
                                                                   'Description 1:' + '\r\n' +
                                                                   wft.Description_body_1__c;
                                    }
                                    
                                    IF( wft.Description_body_2__c != null && wft.Description_body_2__c != '' ){
                                        t.Description            = t.Description + '\r\n' +
                                                                   '---' + '\r\n' +
                                                                   'Description 2:' + '\r\n' +
                                                                   wft.Description_body_2__c;
                                    }
                                    */
                                    
                                    IF( wft.Product_Information__c != null ){
                                        t.Description            = t.Description + '\r\n' +
                                                                   '---' + '\r\n' +
                                                                   'Product Description:' + '/r/n' +
                                                                   wft.Product_Information__r.Description + '\r\n' +
                                                                   '---' + '\r\n' +
                                                                   'Needed When:' + '\r\n' +
                                                                   wft.Product_Information__r.Needed_when__c + '\r\n' +
                                                                   '---' + '\r\n' +
                                                                   'Disclaimer:' + '\r\n' +
                                                                   wft.Product_Information__r.Disclaimer__c;
                                    }
                                    if(wft.Solution__c != null && wft.Solution_is_public__c){

                                            t.Description       = t.Description +
                                                                   '\r\n<hr>\r\n'+
                                                                   '<a href="'+wft.SolutionPublicURL__c+
                                                                   '" target="_blank">Click here</a> for more information.';
                                    }
                                    
                                    t.Product_new_Case__c = wft.Product_new_Case__c;
                                    t.Internal_Case__c = wft.Internal_Case__c;
                                    
                                    
                                    // checks if the task is connected to a predessessor workflow
                                    if(wft.PredessessorWorkflow__c != null){
                                        if(preCasesMap != null && preCasesMap.containsKey(wft.PredessessorWorkflow__c)){
                                            
                                            Case prec = preCasesMap.get(wft.PredessessorWorkflow__c);
                                            if(prec != null){
                                                t.PredecessorCaseID__c = prec.Id;
                                                t.PredecessorCaseNumber__c = prec.CaseNumber;
                                            }
                                        }
                                    }   
                                
                                    caseTskList.add(t);
                                }
                                
                            }
                        }
                    }
                }
            }
            // UPDATE - END ------------------------------
        
        }
    }
    
    system.debug('\n ---------- ReplicateWFTasks -- caseTskList: '+caseTskList);
    if(caseTskList.size() > 0){
        insert caseTskList;
    }
}