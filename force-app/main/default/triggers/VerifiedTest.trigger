trigger VerifiedTest on Application__c (after update) {
    List<Application__c> statusUpdated = [SELECT Id,Application__c.Verified__c, Application__c.External_User_ID__c, Application_Type__r.Status_URL__c, Application__c.Application_Type__r.Name FROM Application__c WHERE Id IN :Trigger.New Limit 1 ];
    if(!System.isFuture() && !System.isBatch()){
    for (Application__c a :statusUpdated){
        ZoomCalloutTestOMG.makeVerifyUserCallout(a.External_User_ID__c, a.Id);
        System.debug('a.Verified__c');
        System.debug(a.Verified__c);

    }
        /*
    if(statusUpdated[0].Verified__c == false){
        statusUpdated[0].Verified__c = Trigger.oldMap.get(statusUpdated[0].id).Verified__c;
        Trigger.oldMap.get(statusUpdated[0].Id).addError('Cannot delete account with related opportunities');
    }
*/
}
}