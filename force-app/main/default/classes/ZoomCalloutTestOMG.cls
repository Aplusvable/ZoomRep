public class ZoomCalloutTestOMG {
    @future(callout=true)
    //this test is mainly testing how to get data from the http resbond
    //@future(callout = true)  
    public static void makeAddUserCallout(String email, String firstName, String lastName, String acctType){
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        //remember to put all endpoint URL in a reference
        req.setEndpoint('callout:ZoomAPI/v2/users/');
        
        String jsonS = generateJSONContentAddUsr(email, firstName, lastName, acctType);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonS);
        Http h = new Http();
        HttpResponse res = h.send(req);
        //System.debug(res.getBody());
        
        //Check the status code in the API respond.
        if (res.getStatusCode() == 201){
            System.debug('Success!');
            List<String> listLst = new List<String>();
            Object results = JSON.deserializeUntyped(res.getBody());
            //System.debug(results);           
            listLst = organizeUserDataAddUsr(results, listLst);
            //System.debug('listLst:');
            //System.debug(listLst);
            integer index = findIdIndex(listLst, 'id');
            getValueAddUsr(listLst, index);
            System.debug(res.getBody());
            System.debug('Assigned user id: ' + (String) getValueAddusr(listLst, index));
            //return res.getBody();
        }
        else {
            System.debug('Something went wrong, error code: ' + res.getStatusCode());
            System.debug(res.getBody());
            //return res.getBody();
        }
    }
    
    
    //addUser V2 requires one more parameter: id, which allows to use this provided id to update External Id returned. 
    @future(callout=true)
    public static void makeAddUserCalloutV2(String email, String firstName, String lastName, String acctType, id anId){
        
        Application__c appl = [SELECT Name, Application_Type__r.Add_User_URL__c FROM Application__c WHERE Id = :anId];
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');

        //remember to put all endpoint URL in a reference
        req.setEndpoint(appl.Application_Type__r.Add_User_URL__c);
        
        String jsonS = generateJSONContentAddUsr(email, firstName, lastName, acctType);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setBody(jsonS);
        Http h = new Http();
        HttpResponse res = h.send(req);
        //System.debug(res.getBody());
        
        //Check the status code in the API respond.
        if (res.getStatusCode() == 201){
            System.debug('Success!');
            List<String> listLst = new List<String>();
            Object results = JSON.deserializeUntyped(res.getBody());
            //System.debug(results);           
            listLst = organizeUserDataAddUsr(results, listLst);
            //System.debug('listLst:');
            //System.debug(listLst);
            integer index = findIdIndex(listLst, 'id');
            getValueAddUsr(listLst, index);
            System.debug(res.getBody());
            System.debug('Assigned user id: ' + (String) getValueAddusr(listLst, index));
            //return res.getBody();
            //use the provided id to update the External Id record returned by the api response
            Application__c app = [SELECT Name FROM Application__c WHERE Id = :anId];
            app.External_User_ID__c = (String) getValueAddusr(listLst, index);               
            update app;
        }
        else {
            System.debug('Something went wrong, error code: ' + res.getStatusCode());
            System.debug(res.getBody());
            //return res.getBody();
        }
    }
    
    public static void makeGetUserCallout(Id anId){
        Application__c appl = [SELECT Name, Application_Type__r.Add_User_URL__c FROM Application__c WHERE Id = :anId LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(appl.Application_Type__r.Status_URL__c);        
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        //if the request is successful, parse the JSON response.
        if (res.getStatusCode() == 200){
            //Deserialize the JSON string into collections of primitive data types
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            //Create a 2D array to store user info, outer arry to split users, inner array to split attributes,
            //so one single user is listLst[index].
            //and his/her attributs can be access by listLst[index].get[attributeIndex].
            List<List<String>> listLst = new List<List<String>>();
            organizeUserDataGetUsr(results, listLst);
            
            //get the index of target attributs, such as user Id, email etc.
            integer index = findIdIndex(listLst[0], 'id=');
            System.debug(getValueGetUsr(listLst[0], index));
            
        }
        else {
            System.debug('Something went wrong, error code: ' + res.getStatusCode());
            System.debug(res.getBody());
            //return res.getBody();
        }        
        //System.debug(res);
        System.debug(res.getBody());
        //return res.getBody();
    }
    
    
    @future(callout=true)
    public static void makeVerifyUserCallout(Id anId){
        Application__c app = [SELECT Name, Application__c.Application_Type__r.Status_URL__c, Application__c.External_User_ID__c FROM Application__c WHERE Id = :anId LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(app.Application_Type__r.Status_URL__c + app.External_User_ID__c);        
        Http h = new Http();
        HttpResponse res = h.send(req);
        //System.debug(res.getBody());
        //System.debug(res.getStatusCode());        
        //if the request is successful, parse the JSON response.
        if (res.getStatusCode() == 200){
            //Deserialize the JSON string into collections of primitive data types
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());              
            String idStatus = organizeUserDataVerUsr(results);
            //System.debug('idStatus:');
            //System.debug(idStatus);
            //System.debug('User Id recorded in SF:');
            //System.debug(userZoomId);
            if (!idStatus.equals('pending')){
                //System.debug('enter the if');
                app.Verified__c = true;               
            }
            else{
                //System.debug('enter the else');
                app.Verified__c = false;               
            }   
            update app;

        }
        else {
            System.debug('Something went wrong, error code: ' + res.getStatusCode());
            System.debug(res.getBody());
            //return res.getBody();
        }        
    }
    
    //This method will be invoked by the scheduler to do regular checks to the users' status from Zoom and update 
    //if there is any changes 
    @future(callout=true)  
    public static void checkStatusFromZoom(Id anId){
        Application__c appl = [SELECT Name, Application_Type__r.Add_User_URL__c, Application__c.Active__c, Application__c.External_User_ID__c FROM Application__c WHERE Id = :anId LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(appl.Application_Type__r.Add_User_URL__c + appl.External_User_ID__c);
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        //if the request is successful, parse the JSON response.
        if (res.getStatusCode() == 200){
            //Deserialize the JSON string into collections of primitive data types
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
         
            //
            //Put this in a function!
            String idStatus = organizeUserDataVerUsr(results); 
            Application__c app = [SELECT Name, Application__c.Active__c FROM Application__c WHERE Id = :anId];
            
            if((idStatus == 'active') && (app.Active__c == true)){
                
            }
            else if ((idStatus == 'inactive') && (app.Active__c == false)){
                
            }
            else if ((idStatus == 'inactive') && (app.Active__c == true)){
                app.Active__c = false;               
                update app;
            }
            else if ((idStatus == 'active') && (app.Active__c == false)){
                app.Active__c = true;               
                update app;
            }
        }
        else {
            System.debug('Something went wrong, error code: ' + res.getStatusCode());
            System.debug(res.getBody());
            //return res.getBody();
        }        
        //System.debug(res);
        System.debug(res.getBody());
        //return res.getBody();
        
        
    }
    
    //
    //
    //
    //
    //
    @future(callout=true)  
    public static void makeDeleteUserCallout(Id anId){
        System.debug(anId);

        System.debug('aaaaaaaaa');
        Application__c applsall = [SELECT ID FROM Application__c WHERE Id = :anId];
        System.debug(applsall);
        Application__c appl = [SELECT Application_Type__r.Delete_User_URL__c, Application__c.External_User_ID__c FROM Application__c WHERE Id = :anId];
        System.debug(appl);
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');       
        //remember to put all endpoint URL in a reference
        req.setEndpoint(appl.Application_Type__r.Delete_User_URL__c + appl.External_User_ID__c);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
        //System.debug(res.getBody());
        if (res.getStatusCode() == 204){
            System.debug('Success!');
        }
        else if (res.getStatusCode() == 200){
            System.debug('Cannot delete user!');
        }
        else
            System.debug(res.getBody()); 
    }
    
    //The other version of delete user method, becuz the query is acting funny...
    @future(callout=true)  
    public static void makeDeleteUserCalloutString(String deleteURL, String externalID){
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');       
        //remember to put all endpoint URL in a reference
        req.setEndpoint(deleteURL + externalID);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
        //System.debug(res.getBody());
        if (res.getStatusCode() == 204){
            System.debug('Success!');
        }
        else if (res.getStatusCode() == 200){
            System.debug('Cannot delete user!');
        }
        else
            System.debug(res.getBody()); 
    }
    
    
    @future(callout=true)   
    public static void setUserStatusCall(Id anId, String status){
        Application__c appl = [SELECT Application_Type__r.Status_URL__c, Application__c.External_User_ID__c FROM Application__c WHERE Id = :anId LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');       
        
        String jsonS = generateJSONContentUpdateStats(status);
        req.setBody(jsonS);
        //remember to put all endpoint URL in a reference
        req.setEndpoint(appl.Application_Type__r.Status_URL__c + appl.External_User_ID__c + '/status');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
        System.debug(res.getBody());
        if (res.getStatusCode() == 204){
            System.debug('Success!');
        }
        else if (res.getStatusCode() == 200){
            System.debug('Zoom Room and Admin users’ status can not be activated or deactivated.');
        }
        else
            System.debug(res.getBody()); 
        
    }
    
    
    //the JSON file has users as one simgle long string so need to break it down
    public static void organizeUserDataGetUsr(Map<String, Object> httpResult, List<List<String>> output){
        List<Object> userList = (List<Object>)httpResult.get('users');
        List<String> userStr = new List<String>();
        for (Object usr : userList){
            userStr.add(String.valueOf(usr));
        }
        for (String usrS : userStr){               
            output.add(usrS.split(','));
        }
    }
    
    public static String organizeUserDataVerUsr(Map<String, Object> httpResult){
        //List<Object> userList = httpResult.get('status');
        String userStr = (String)httpResult.get('status');
        System.debug('userStr: ');
        System.debug(userStr);
        return (userStr);

    }
    
    //Zoom only allows to add one user within one API call.
    public static List<String> organizeUserDataAddUsr(Object httpResult, List<String> output){
        String userStr = String.valueOf(httpResult);                  
        output = userStr.split(',');
        //System.debug('Output from func.');
        //System.debug(output);
        return output;
    }
    
    //method to find the index of id(or any other properties specified in targetProp) in the user properties
    public static integer findIdIndex(List<String> inputList, String targetProp){
        integer i = 0;
        System.debug(targetProp);
        if (inputList.size() < 1){
            System.debug('Illeagle input list size:');
            System.debug(inputList.size());
            return -1;
        }
        //Go through the properties list to find the target.       
        while (i < inputList.size()){
            if (inputList[i].contains(targetProp)){
                //System.debug(inputList[i]);
                return i;
            }
            //System.debug(inputList[i]);            
            i++;            
            //System.debug('index value');
            //system.debug(i);
        }
        return -1;
    }
    
    
    //Maybe AddUsr and Getuser can be combined? Depends on how other types of calls are like...
    public static String getValueGetUsr(List<String> aUser, integer index){
        //after organize the raw data, the index will point to an entry like this:
        //"id=CujyLlwKRz-KQSGKA-gepA"
        return aUser.get(index).split('=').get(1);
    }
    
    public static String getValueAddUsr(List<String> aUser, integer index){
        //after organize the raw data, the index will point to an entry like this:
        //"id=CujyLlwKRz-KQSGKA-gepA"
        return aUser.get(index).split('=').get(1);
    }
    
    // Create a JSONGenerator object.String email, String firstName, String lastName, String acctType   
    public static String generateJSONContentAddUsr(String email, String firstName, String lastName, String acctType) {       
        JSONGenerator gen = JSON.createGenerator(true);    
        Case c = [Select Id ,CaseNumber , Status ,Priority from Case Limit 1];
        
        gen.writeStartObject(); 
        gen.writeStringField('action','create');  
        gen.writeFieldName('user_info');
        gen.writeStartObject();
        gen.writeStringField('email', email);        
        gen.writeStringField('first_name',firstName);        
        gen.writeStringField('last_name',lastName);  
        gen.writeStringField('type',acctType);  
        gen.writeEndObject();   
        gen.writeEndObject();    
        
        String jsonS = gen.getAsString();
        return jsonS;       
    }
    
    public static String generateJSONContentUpdateStats(String status){
        JSONGenerator gen  = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeStringField('action',status);
        gen.writeEndObject(); 
        
        String jsonS = gen.getAsString();
        return jsonS;   
    }
    
    public static List<String> processConcact(Contact c){
        List<String> input = New List<String>();
        String emailStr = String.valueOf(c.email);
        input.add(emailStr);
        String nameStr = String.valueOf(c.Name);        
        String lastName = nameStr.split(' ').get(1);
        String firstName = nameStr.split(' ').get(0);
        input.add(firstName);
        input.add(lastName);
        return input;
        //ZoomCalloutTestOMG.makeAddUserCallout(emailStr, firstName, lastName, '1');
    }
    
    public static boolean findMatchId(String anId, List<List<String>> listLst){
        List<String> allIds = New List<String>();
        for (List<String> a : listLst){
            allIds.add(getValueGetUsr(a, findIdIndex(a, 'id=')));
        }
        //System.debug(allIds);
        //System.debug('Found a match?');
        //System.debug(allIds.contains(anId));
        return allIds.contains(anId);        
    }
    
    //This method checks the "controllingField" field in an Object and prevent record edit if lockingValue is met
    public static void preventActiveEdit(map<id,sObject> oldObjects, map<id,sObject> newObjects, string controllingField, string lockingValue, string errorMessage)
    {
       //get the type of object this list is, like contact, account, etc
        Schema.sObjectType objectType = oldObjects.values().getSObjectType();
        
        //global describe of objects
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
        
        //describe object
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        
        //get all the valid fields on this object
        Map<String, Schema.SobjectField> objectFields = objectType.getDescribe().fields.getMap();
                
        for(sObject oldObject : oldObjects.values())
        {
            //System.debug('-1');
            //System.debug(controllingField);
            //System.debug(lockingValue);
            //System.debug(oldObject.get(controllingField));
            //System.debug(oldObject.get(controllingField) == lockingValue);
            //System.debug(String.valueOf(oldObject.get(controllingField)) == lockingValue);
            if(String.valueOf(oldObject.get(controllingField)) == lockingValue){
                System.debug('0');                            
            {
                System.debug('1');                
                sObject newObject = newObjects.get((id) oldObject.get('id'));
                for(string fieldName : objectFields.keySet())
                {
                if(oldObject.get('Active__c') != newObject.get('Active__c'))                    
                {
                    System.debug('2');                        
                    sObject actualRecord = (sObject) Trigger.newMap.get((id) oldObject.get('id'));
                    actualRecord.addError(errorMessage);
                } 
                }                
            }
            }
        }
    }
    
}