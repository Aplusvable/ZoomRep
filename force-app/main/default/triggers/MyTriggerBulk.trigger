trigger MyTriggerBulk on Account (before insert) {
    //This loop works if Trigger.New contains one sObject or many sObjects
    for(Account a : Trigger.New){
        a.Description = 'New description';
    }

}