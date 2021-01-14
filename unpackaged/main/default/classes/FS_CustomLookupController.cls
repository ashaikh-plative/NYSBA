/**
 *  @author:    cubiascaceres
 *  @date:      2019.10.03
 *  @desc:      Apex class used to retrieve sObjects to be displayed by Custom Lookup component
 */
public class FS_CustomLookupController {

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String value, String additionalWhereClause) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\'';
            } else {
                query += ' WHERE '+filterField+
                		' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
            }
            if (String.isNotBlank(additionalWhereClause)) {
                query += additionalWhereClause;
            }
            query += ' LIMIT 10';
	        for(SObject s : Database.query(query)) {
	            recordsDataList.add(new RecordsData((String)s.get(filterField), (String)s.get('id')));
	        }
            return recordsDataList;
	    } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
	    }
    }
 
    public class RecordsData {
        
        @AuraEnabled 
        public String label;
        
        @AuraEnabled 
        public String value;
        
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}