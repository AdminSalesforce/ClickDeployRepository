public class ReplaceHelperForEmail  {
@TestVisible 
    private static SObject getObjects(String emailTemplate, String objectName, String recordId){
        Pattern regex = Pattern.compile('\\{!([^}]*)\\}');
        Matcher regexMatcher = regex.matcher(emailTemplate);
        Set<String> tokens = new Set<String>();
        while (regexMatcher.find()){
            String dirtyVariable = regexMatcher.group();
            String variable = dirtyVariable.substring(2,dirtyVariable.length()-1);
            tokens.add(variable.replace(objectName + '.', ''));
        }
        String qry = 'Select ';
        for(String s : tokens){
            qry += s + ',';
        }
        qry = qry.substring(0, qry.length()-1);
        if (qry == 'Select') {
            return null;
        }
        SObject o = Database.query(qry + ' FROM ' + objectName + ' Where ID = :recordId');
        return o;
    }

@TestVisible 
    private static Set<String> getObjectNames(String emailTemplate, String objectName) {
        Pattern regex = Pattern.compile('\\{!([^}]*\\.)');
        Matcher regexMatcher = regex.matcher(emailTemplate);
        Set<String> tokens = new Set<String>();
        while (regexMatcher.find()){
            String dirtyVariable = regexMatcher.group();
            if (dirtyVariable != null && dirtyVariable != '') {
                String variable = dirtyVariable.substring(2,dirtyVariable.length()-1);
                tokens.add(variable.replace(objectName+'.',''));
            }
        }
        return tokens;
    }

@TestVisible
    private static String replace(String emailTemplate, String objectName, SObject record, String queriedObject){
        Pattern regex = Pattern.compile('\\{!([^}]*)\\}');
        Matcher regexMatcher = regex.matcher(emailTemplate);
        Set<String> tokens = new Set<String>();
        while (regexMatcher.find()){        
            String dirtyVariable = regexMatcher.group();
            String variable = dirtyVariable.substring(2,dirtyVariable.length()-1);
            if(variable.startsWith(objectName + '.') || !variable.contains('.')){
                tokens.add(variable);
            }
        }
        SObject o = record;
        for(String s : tokens){       
            if (objectName == queriedObject) {
                emailTemplate = emailTemplate.replace('{!' + s + '}', getValueForQueried(o, s.replace(objectName + '.', ''), objectName));
            }
            else {
                emailTemplate = emailTemplate.replace('{!' + s + '}', getValueForRelated(o, s.replace(objectName + '.', ''), objectName));
            }
        }
        return emailTemplate;
    }
@TestVisible
    private static String getValueForRelated(SObject o, String fieldName, String objName){
        return (o.getSObject(objName).get(fieldName) != null) ? String.valueOf(o.getSObject(objName).get(fieldName)) : '';
    }
@TestVisible
    private static String getValueForQueried(SObject o, String fieldName, String objectName){
        String[] obJectPlusField = fieldName.split('\\.');
        String returned;
        if (obJectPlusField.size() == 2) {
            System.debug(obJectPlusField);
            returned = String.valueOf(o.getSObject(obJectPlusField[0]).get(obJectPlusField[1]));
        }
        else if (o.get(fieldName) != null) {
            returned = String.valueOf(o.get(fieldName));
        }
        else returned ='';
        return returned;
    }

    public static String replacet(String replacement, String queryiedObject, String recordId) {
        if (replacement == null || replacement == '') {
            return '';
        }
        Sobject record = getObjects(replacement, queryiedObject, recordId);
        String replaced;
        Set<String> objectsNames = getObjectNames(replacement, queryiedObject);
        objectsNames.add(queryiedObject);
        for(String ObjectName : objectsNames) {
            replaced = replace(replacement, ObjectName, record, queryiedObject);
            replacement = replaced;
        }
        return replacement;
    }
}