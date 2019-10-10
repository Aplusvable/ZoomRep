public class ManipulateRecordsWithDML {
    public static void manipulateRecordsDML(){
        //Create a list of contacts
        List<Contact> conList = new List<Contact>{
            new Contact(FirstName = 'Joe', LastName = 'Smith', Department = 'Finance'), 
                new Contact(FirstName = 'Kathy', LastName = 'Smith', Department = 'Technology'),
                new Contact(FirstName = 'Caroline', LastName = 'Roth', Department = 'Finance'),
                new Contact(FirstName = 'Kim', LastName = 'Shain', Department = 'Education')}; 
        
        //Bulk insert all contacts with one DML call
        insert conList;
        //List to hole the new contacts to update
        List<Contact> listToUpdate = new List<Contact>();
        //Iterate through the list and add a title only if the department is Finance
        for(Contact con : conList) {
            if (con.Department == 'Finance'){
                con.Title = 'Finacial analyst';
                //Add updated contact sObject to the list
                listToUpdate.add(con);
            }
        }
        //Bulk update all contacts with one DML call
        update listToUpdate;
        }
    
    public static void upsertRec(){
        // Insert the Josh contact
        Contact josh = new Contact(FirstName='Josh',LastName='Kaplan',Department='Finance');       
        insert josh;
        // Josh's record has been inserted
        //   so the variable josh has now an ID
        //   which will be used to match the records by upsert
        josh.Description = 'Josh\'s record has been updated by the upsert operation.';
        // Create the Kathy contact, but don't persist it in the database
        Contact kathy = new Contact(FirstName='Kathy',LastName='Brown',Department='Technology');
        // List to hold the new contacts to upsert
        List<Contact> contacts = new List<Contact> { josh, kathy };
        // Call upsert
        upsert contacts;
        // Result: Josh is updated and Kathy is created.
    }
    
    public static void upsertByEmail(){
        Contact jane = new Contact(FirstName='Jane',
                         LastName='Smith',
                         Email='jane.smith@example.com',
                         Description='Contact of the day');
        insert jane;
        // 1. Upsert using an idLookup field
        // Create a second sObject variable.
        // This variable doesn’t have any ID set.
        Contact jane2 = new Contact(FirstName='Jane',
                                    LastName='Smith',  
                                    Email='jane.smith@example.com',
                                    Description='Prefers to be contacted by email.');
        // Upsert the contact by using the idLookup field for matching.
        upsert jane2 Contact.fields.Email;
        // Verify that the contact has been updated
        System.assertEquals('Prefers to be contacted by email.',
                            [SELECT Description FROM Contact WHERE Id=:jane.Id].Description); 
    }
    
    public static void wipeOutSmith(){
        Contact[] contactsDel = [SELECT Id From Contact WHERE LastName = 'Smith'];
        delete contactsDel;
    }
    
    public static void DMLstatementExceptions(){
        try{
            //This cause an exception bcuz the required Name field is not provided
            Account acct = new Account();
            //Insert the Account
            insert acct;
        }catch (DmlException e){
            System.debug('A DML exception has occured: ' + e.getMessage());
        }
    }
    
    public static void databaseMethod(){
        List<Contact> conList = new List<Contact>{
            new Contact(FirstName = 'Joe', LastName = 'Smith', Department = 'Finance'), 
                new Contact(FirstName = 'Kathy', LastName = 'Smith', Department = 'Technology'),
                new Contact(FirstName = 'Caroline', LastName = 'Roth', Department = 'Finance'),
                new Contact()};
        //Bulk insert all contacts with one DML call
        Database.SaveResult[] srList = Database.insert(conList, false);
        //Iterate through each returned result
        for(Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                System.debug('Successfully inserted contact. Contact ID: ' + sr.getId());
            }else{
                for(Database.Error err : sr.getErrors()){
                    System.debug('The follwing error has occured.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Contact fields that affect this error: ' + err.getFields());
                }
            }
        }
    }
    
    public static void insertRelatedRecs(){
        Account acct = new Account(Name='SFDC Account');
        insert acct;
        //Once the account is inserted the sObject will be populated with an ID
        //get this ID
        ID acctID = acct.ID;
        //Add a contact to this account
        Contact mario = new Contact(
            FirstName = 'Mario',
            LastName = 'Ruiz',
            Phone = '415.555.1212',
            AccountId = acctID);
            insert mario;
    }
    
    public static void updateRelatedRecs(){
        //Query for the contact, which has been associated with an account
        Contact queriedContact = [SELECT Account.Name
                                  FROM Contact
                                  WHERE FirstName = 'Mario' AND LastName = 'Ruiz'
                                  LIMIT 1];
        //Update the contact's phone number
        queriedContact.Phone = '(415)555-1213';
        queriedContact.Account.Industry = 'Technology';
        //Make two separate calls
        //1. Update the contact's phone
        update queriedContact;
        //2. Update the related account's Industry field
        update queriedContact.Account;
    }
    
    public static void deleteRelatedRecs(){
        Account[] queriedAccounts = [SELECT Id FROM Account WHERE Name = 'SFDC Account'];
        delete queriedAccounts;
    }
}