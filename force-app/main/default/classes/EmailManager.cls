public class EmailManager {
    //Public method
    public static void sendMail(String address, String subject, String body){
        //Create an email msg obj
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {address};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        //Pass this email message to the built-in sendEmail method
        //of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        //Call a helper method to inspect the returned results
        inspectResults(results);
    }
    
    //Helper method
    private static Boolean inspectResults(Messaging.SendEmailResult[] results){
        Boolean sendResult = true;
        
        //sendEmail returns an array of result objs.
        //Iterate through the list to inspect results.
        //In this class, the methods send only one email,
        //so we should have just one result.
        for (Messaging.SendEmailResult res : results){
            if (res.isSuccess()){
                System.debug('Email sent successfully');
            }
            else{
                sendResult = false;
                System.debug('The follwing error(s) occured: ' + res.getErrors());
            }
        }
        
        return sendResult;
    }
    //Put this in debug to test:
    //EmailManager em = new EmailManager();
    //em.sendMail('spartan0332@gmail.com', 'Trailhead Tutorail', '123 body');
}