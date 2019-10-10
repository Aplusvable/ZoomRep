public class ZoomCalloutTest {
    //@future(callout = true)
    public static String makeCallout(){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        
        req.setEndpoint('callout:ZoomAPI/v2/users/');
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        //if the request is successful, parse the JSON response.
        if (res.getStatusCode() == 200){
            //Deserialize the JSON string into collections of primitive data types
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            System.debug(results);
            List<Object> userList = (List<Object>)results.get('users');
            List<String> userStr = new List<String>();
            for (Object usr : userList){
                userStr.add(String.valueOf(usr));
            }
            List<List<String>> listLst = new List<List<String>>();
            for (String usrS : userStr){
                
                listLst.add(usrS.split(','));
            }
            System.debug(userStr[0]);
            System.debug(listLst[0].get(1));
            System.debug(listLst[0].get(1).split('=').get(1));
            System.debug(userStr[0].indexOfAny('id='));
            System.debug(listLst[0].get(userStr[0].indexOfAny('id=')));



            //a[0].toString();
            //aString.replaceAll(',', ' ');
            //List<String> user1 = aString.split(' ');

            /*
            //Cast the values in "id" key as a list
            List<String> ids = (List<String>) results.get('id');
            System.debug ('Receieved the following ids:');
            for (String idss: ids){
                System.debug(idss);
                
            }
*/
        }
        
        //System.debug(res);
        //System.debug(res.getBody());
        return res.getBody();
    }
}