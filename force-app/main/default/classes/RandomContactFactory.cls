public class RandomContactFactory {
    public static list<contact> generateRandomContacts(integer n, string m) {
        list<contact> con = new list<contact>();
        for(integer i=1; i<n+1; i++) {   
            contact c = new contact(firstname='test'+i,lastname=m);
            con.add(c);
        }
        return con;
    }
}