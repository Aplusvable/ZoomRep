public class AccountHandler {
    public static ID insertNewAccount(String accountName){
        try{
        Account acct = new Account(Name = accountName);
        insert acct;
        ID accID = acct.Id;
        System.debug('ID: ' + accID);
        return accID;
        //return acct;
        }catch(DmlException e){
            System.debug('A DML exception has occured: ' + e.getMessage());
        }
        return null;
    }

}