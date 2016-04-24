global class ProcessSubscriptions_Batch implements Database.Batchable<sObject>
{
    global String query;
    global Date till_Date;
    global List<Database.DeleteResult> dsrs {get;set;}
    global String errors{get;set;}
    global database.querylocator start(Database.BatchableContext BC)
    {
        errors = '';
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC,  List<Contract> Contract_List)
    {
        ProcessSubscriptions.ProcessToday(Contract_List, true);
    }
    global void finish(Database.BatchableContext BC)
    {
        
    }
}