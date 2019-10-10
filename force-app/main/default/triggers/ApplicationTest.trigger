trigger ApplicationTest on Application__c (after insert) {
    //Perform SOQL query once
    //Get the accounts and their related opportunities 
    List<Application__c> appCreated = [SELECT Id, Application_Type__r.Name, Contact__r.Email, Contact__r.Name  FROM Application__c WHERE Id IN :Trigger.New];
    //List<Contact> contactWithEmails = New List<Contact>();
    
    //Keep a list of exsisting email addresses, conpare the new Contact's email to see if it's new.
    /*
    List<Application__c> appExsisting = [SELECT Contact__r.Email FROM Application__c WHERE Id IN :Trigger.Old];
    List<String> emails = New List<String>();
    for (Application__c a : appExsisting){
        emails.add(a.Contact__r.Email);
    }
*/
    //Collect contacts added that has a email related to it && (!emails.contains(a.Contact__r.Email))
    for(Application__c a : appCreated){
        if(String.isNotBlank(String.valueOf(a.Contact__r.email)) ){
            //contactWithEmails.add(a.Contact__r);
            if (a.Application_Type__r.Name.equals('Zoom') ){
                List<String> input = ZoomCalloutTestOMG.processConcact(a.Contact__r);
                ZoomCalloutTestOMG.makeAddUserCalloutV2(input[0], input[1], input[2], '1',a.id);
            }
        }        
    }
}