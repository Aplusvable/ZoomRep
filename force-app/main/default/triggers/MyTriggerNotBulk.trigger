trigger MyTriggerNotBulk on Account (before insert) {
    Account a = Trigger.New[0];
    a.Description = 'New description';

}