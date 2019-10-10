public class StringArrayTest {
    public static String[] generateStringArray(Integer numRet){
        String[] stringArray = new String[numRet];
        for (Integer i = 0; i < numRet; i++){
            stringArray[i] = ('Test ' + i);
        }
        System.debug(stringArray);
        return stringArray;      
    }
}