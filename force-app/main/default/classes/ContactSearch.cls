public class ContactSearch {
    public static List<Contact> searchForContacts(String para1, String para2){
        Contact[] cts = [SELECT LastName,MailingPostalCode FROM Contact 
                         WHERE (LastName =: para1 AND MailingPostalCode =: para2)];
        return cts;
    }

}