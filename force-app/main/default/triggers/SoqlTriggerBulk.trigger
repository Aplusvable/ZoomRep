trigger SoqlTriggerBulk on Account (before insert) {
    //Perform SOQL query once
    //Get the accounts and their related opportunities 
    List<Account> acctsWithOpps = [SELECT Id, (SELECT Id,Name,CloseDate FROM Opportunities ) FROM Account WHERE Id IN :Trigger.New];
    
    //Iterate over the returned accounts
    for(Account a : acctsWithOpps){
        Opportunity[] relatedOpps = a.Opportunities;
        //Do some other stuff
    }
    
    //Or if you don't need the parent at all
    List<Opportunity> relatedOpps = [SELECT Id,Name,CloseDate FROM Opportunity WHERE AccountId IN : Trigger.New];
    for(Opportunity opp : relatedOpps){
        //do sum staff
    }
    
    //Or to make things even more concise
    for(Opportunity opp : [SELECT Id,Name,CloseDate FROM Opportunity WHERE AccountId IN : Trigger.New]){
        //do sum staff
    }

}