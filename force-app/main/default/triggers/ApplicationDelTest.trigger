trigger ApplicationDelTest on Application__c (before delete) {
    //Perform SOQL query once
    //Get the accounts and their related opportunities 
    if(trigger.isBefore){
    List<Application__c> appDeleted = [SELECT Id,Application__c.External_User_ID__c, Application_Type__r.Delete_User_URL__c, Application__c.Application_Type__r.Name FROM Application__c WHERE Id IN :Trigger.Old ];
    System.debug(appDeleted);
    for(Application__c a : appDeleted){
        if(String.isNotBlank(String.valueOf(a.External_User_ID__c))){
            if (a.Application_Type__r.Name.equals('Zoom')){
                ZoomCalloutTestOMG.makeDeleteUserCalloutString(String.valueOf(a.Application_Type__r.Delete_User_URL__c), String.valueOf(a.External_User_ID__c));
            }
        }        
    }
    }
}