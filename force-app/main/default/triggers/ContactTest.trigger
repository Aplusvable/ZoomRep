trigger ContactTest on Contact (after insert) {
    //Perform SOQL query once
    //Get the accounts and their related opportunities 
    List<Contact> contactCreated = [SELECT Id, Email,Name  FROM Contact WHERE Id IN :Trigger.New];
    List<Contact> contactWithEmails = New List<Contact>();
    
    //Collect contacts added that has a email related to it
    for(Contact a : contactCreated){
        if(String.isNotBlank(String.valueOf(a.Email)))
        contactWithEmails.add(a);
    }

    List<String> emailList = new List<String>();
    
    //If there is new contacts with email field added, do a callout to Zoom to create a user under main account.
    if (contactWithEmails.size() > 0){
    for(Contact a : contactWithEmails){
        emailList.add(a.Email);
        
        //Probably can but this in a function somewhere else?
        String emailStr = String.valueOf(a.Email);
        String nameStr = String.valueOf(a.Name);
        String lastName = nameStr.split(' ').get(1);
        String firstName = nameStr.split(' ').get(0);
        
        List<String> input = ZoomCalloutTestOMG.processConcact(a);
        ZoomCalloutTestOMG.makeAddUserCallout(input[0], input[1], input[2], '1');
    }
    }
    
}