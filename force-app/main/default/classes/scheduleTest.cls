global class scheduleTest implements Schedulable {
   global void execute(SchedulableContext SC) {
       List<Application__c> apps = New List<Application__c>();
       apps = [SELECT Id,Application__c.External_User_ID__c, Application__c.Active__c,  Application_Type__r.Status_URL__c FROM Application__c ]; 
           for (Application__c a : apps){
           ZoomCalloutTestOMG.makeVerifyUserCallout(a.Id);
           ZoomCalloutTestOMG.checkStatusFromZoom(a.Id);
           HelperClassForUpdateTriggers.setVariable(true);   
           System.debug('Schedule:');
           System.debug(HelperClassForUpdateTriggers.fromScheduledJobs);
           }
   }
}