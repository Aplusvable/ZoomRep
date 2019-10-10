public class ApexWithSOQL {
    public static void throwSomeSampleData(){
        // Add account and related contact
        Account acct = new Account(
            Name='SFDC Computing',
            Phone='(415)555-1212',
            NumberOfEmployees=50,
            BillingCity='San Francisco');
        insert acct;
        // Once the account is inserted, the sObject will be 
        // populated with an ID.
        // Get this ID.
        ID acctID = acct.ID;
        // Add a contact to this account.
        Contact con = new Contact(
            FirstName='Carol',
            LastName='Ruiz',
            Phone='(415)555-1212',
            Department='Wingo',
            AccountId=acctID);
        insert con;
        // Add account with no contact
        Account acct2 = new Account(
            Name='The SFDC Query Man',
            Phone='(310)555-1213',
            NumberOfEmployees=50,
            BillingCity='Los Angeles',
            Description='Expert in wing technologies.');
        insert acct2;
    }
    //Go to Query Editor and type: SELECT Name,Phone FROM Account
    //SELECT fields FROM ObjectName [WHERE Condition]
    //SELECT Name,Phone FROM Account WHERE (Name='SFDC Computing' OR (NumberOfEmployees>25 AND BillingCity='Los Angeles'))
    //you can perform fuzzy matches by using the LIKE operator. For example, you can retrieve all accounts whose names start with SFDC 
    //by using this condition: WHERE Name LIKE 'SFDC%'. The % wildcard character matches any or no character. 
    //The _ character in contrast can be used to match just one character.
    //SELECT Name,Phone FROM Account ORDER BY Name ASC/DESC (alphabetical/descending order)
    //Account oneAccountOnly = [SELECT Name,Phone FROM Account LIMIT 1]; (Retrieve the first account)
    
    public static void combineAllTogether(){
        Account[] accts = [SELECT Name,Phone FROM Account 
                           WHERE (Name='SFDC Computing' AND NumberOfEmployees>25)
                           ORDER BY Name
                           LIMIT 10];
        System.debug(accts.size() + ' account(s) returned.');
        // Write all account array info
        System.debug(accts);
    }
    
    public static void accesVars(){
        String targetDepartment = 'Wingo';
        Contact[] techContacts = [SELECT FirstName, LastName FROM Contact WHERE Department=:targetDepartment]; //Dat "=:""
    }
    
    public static void relatedRecs(){
        Account[] acctsWithContacts = [SELECT Name, (SELECT FirstName,LastName FROM Contacts)
                                       FROM Account 
                                       WHERE Name = 'SFDC Computing'];
        // Get child records
        Contact[] cts = acctsWithContacts[0].Contacts;
        System.debug('Name of first associated contact: ' 
                     + cts[0].FirstName + ', ' + cts[0].LastName);
    }
    
    public static void chileToParent(){
        Contact[] cts = [SELECT Account.Name FROM Contact 
                         WHERE FirstName = 'Carol' AND LastName='Ruiz'];
        Contact carol = cts[0];
        String acctName = carol.Account.Name;
        System.debug('Carol\'s account name is ' + acctName);
    }
    
    public static void queryRecInBatches(){
        insert new Account[]{new Account(Name = 'for loop 1'), 
            new Account(Name = 'for loop 2'), 
            new Account(Name = 'for loop 3')};
                // The sObject list format executes the for loop once per returned batch
                // of records
                Integer i=0;
        Integer j=0;
        for (Account[] tmp : [SELECT Id FROM Account WHERE Name LIKE 'for loop _']) {
            j = tmp.size();
            i++;
        }
        System.assertEquals(3, j); // The list should have contained the three accounts
        // named 'yyy'
        System.assertEquals(1, i);
        // Since a single batch can hold up to 200 records and,
        // only three records should have been returned, the 
        // loop should have executed only once
    }

}