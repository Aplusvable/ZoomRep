global class HelperClassForUpdateTriggers {
    global static boolean fromScheduledJobs = false;
    
    public static void setVariable(boolean s){
        fromScheduledJobs = s;
    }
    
    public static boolean getVariable(){
        return fromScheduledJobs;
    }
}