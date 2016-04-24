trigger CheckWFTCreation on WorkflowTask__c (before insert, before update) {

    Set <ID> wfIds = new Set <ID>();
    for(WorkflowTask__c wft : trigger.new){        
        if(wft.YesNoTask__c){
            wfIds.add(wft.Workflow__c);
        }
    }
    
    Map <Id, Map <String, List <WorkflowTask__c>>> wfTasksMap = new Map <Id, Map <String, List <WorkflowTask__c>>>();
    if(wfIds.size() > 0){
    
        wfTasksMap = new Map <Id, Map <String, List <WorkflowTask__c>>>();
        for(WorkflowTask__c wft : [SELECT id, Name, Workflow__c, TaskGroup__c, SortOrder__c, CaseStage__c, CaseStatus__c, YesNoTask__c, GroupNo__c, GroupYes__c, NextGroupAlternative__c,
                                          AssignTo__c, Department__c, TaskDescription__c, Hotdocs_ID__c
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
        }
        
        for(WorkflowTask__c wft : trigger.new){        
            if(wft.YesNoTask__c){
                
                if(wfTasksMap != null && wfTasksMap.size() > 0){
                
                    Map <String, List <WorkflowTask__c>> wftm = wfTasksMap.get(wft.Workflow__c);
                    if(wftm != null && wftm.size() > 0){
                    
                        List <WorkflowTask__c> wftl = wftm.get(wft.TaskGroup__c);
                        if(wftl != null && wftl.size() > 1) { 
                            wft.addError(' A Yes/No task must be in a task group by itself!');
                        }
                    }
                }
            }
        }
    }
}