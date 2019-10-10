public class ZoomJWT {
    public static void jwtWithZoom(){
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        
        req.setEndpoint('https://api.zoom.us/v2/users');
        
        //String username = 'spartan0332@gmail.com';
        //String password = '123456787Aa';
        String jwt = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOm51bGwsImlzcyI6IlpDbFV6OUZkU2NTcHkyUlNUa3ZzWmciLCJleHAiOjE1NjkzNTQ4NjQsImlhdCI6MTU2OTM0OTQ2NH0.NtUUbG5s5uTv-9CTX_lVyes8827hDj5KlNqxDX0vNhA';
        //Probably need to find a way to auto refresh the JWT within Apex.
        //Blob headerValue = Blob.valueOf(username + ':' + password);
        Blob headerValue = Blob.valueOf(jwt);
        
        //String authorizationHeader = 'Basic' + EncodingUtil.base64Encode(headerValue);
        String authorizationHeader = 'Bearer' + jwt;
        
        req.setHeader('Authorization', authorizationHeader);
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug(res);
        System.debug(res.getBody());
    }
    
}