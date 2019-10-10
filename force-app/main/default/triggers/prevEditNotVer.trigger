trigger prevEditNotVer on Application__c (before insert) {
    public static void preventRecordEdit(map<id,sObject> oldObjects, map<id,sObject> newObjects, string controllingField, string lockingValue, string errorMessage)
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
            if(oldObject.get(controllingField) == lockingValue)
            {
                sObject newObject = newObjects.get((id) oldObject.get('id'));
                for(string fieldName : objectFields.keySet())
                {
                   if(oldObject.get(fieldName) != newObject.get(fieldName))
                   {
                       sObject actualRecord = (sObject) Trigger.newMap.get((id) oldObject.get('id'));
                       actualRecord.addError(errorMessage);
                   } 
                }                
            }
        }
    }

}