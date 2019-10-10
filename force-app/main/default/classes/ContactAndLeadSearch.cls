public class ContactAndLeadSearch {
    public static List<List< SObject>> searchContactsAndLeads(String para1){
         
        List<List<sObject>> searchList = [FIND 'Smith' IN ALL FIELDS 
                                          RETURNING Contact(FirstName,LastName),Lead(FirstName,LastName)];
        Contact[] searchContacts = (Contact[])searchList[0];
        Lead[] searchLeads = (Lead[])searchList[1];
        return searchList;
    }

}