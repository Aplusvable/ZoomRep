trigger ApplicationStatUpTest on Application__c (before update, after update) {
    System.debug('update:');
    System.debug(HelperClassForUpdateTriggers.fromScheduledJobs );
    if(HelperClassForUpdateTriggers.getVariable() == false){
        System.debug('This is a trigger fired.');  
        if(trigger.isBefore){
            ZoomCalloutTestOMG.preventActiveEdit(Trigger.oldMap, Trigger.newMap, 'Verified__c', 'false', 'User has not been verified yet!');           
        }
        if(trigger.isAfter){            
            List<Application__c> statusUpdated = [SELECT Id,Application__c.Verified__c,Application__c.External_User_ID__c, Application__c.Active__c,  Application_Type__r.Status_URL__c, Application__c.Application_Type__r.Name FROM Application__c WHERE Id IN :Trigger.New ];
            for (Application__c a : statusUpdated){
                //System.debug(a);
                Application__c oldApp = Trigger.oldMap.get(a.ID);
                if(!System.isFuture() && !System.isBatch() && a.Active__c != oldApp.Active__c ){
                    //ZoomCalloutTestOMG.makeVerifyUserCallout(a.External_User_ID__c, a.Id);           
                    if (a.Active__c == true) {
                        ZoomCalloutTestOMG.setUserStatusCall(a.Id, 'activate');
                    }
                    else if (a.Active__c == false){
                        ZoomCalloutTestOMG.setUserStatusCall(a.Id, 'deactivate');           
                    }
                    else
                        System.debug('What is happening...');
                    
                }
            }
        }
    }
    else if(HelperClassForUpdateTriggers.fromScheduledJobs == true){
        HelperClassForUpdateTriggers.setVariable(false);
        System.debug('The update was caused by a scheduled job');
    }
    else
        System.debug('What is happening...');
}