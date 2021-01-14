/**
* Description : Class of utility methods for Salesforce to NetSuite Integration
* History     :
* [27.Oct.2020] Plative - Code Creation
*/

public class Plative_SFToNSSyncUtility {

    /**
    * Description : Real-time sync trigger 
    **/
	public static Boolean processForRealTimeSync(String sObjName, Map<Id, SObject> mapToProcess){
		
		//Check if sync settings exist
		Sync_Settings__mdt syncSetting = checkSyncSettings(sObjName);		
		if(syncSetting == null){
			return true;
		}

		List<SObject> lstChildSobjects;
		// Check if child records are to be sent in payload
		if(syncSetting.Sync_Child_Records__c){
			lstChildSobjects = Plative_SFToNSSyncUtility.getChildRecordsToSync(syncSetting,
																			   mapToProcess.keySet(),
																			   sObjName); 
			System.debug('lstChildSobjects '+lstChildSobjects);
		}
		//Get API settings
		List<API_Settings__mdt> apiSettings = [SELECT Account__c, Consumer_Key__c,
													  Consumer_Secret__c, Endpoint__c,
													  Signature_Method__c, Token_Id__c,
													  Token_Secret__c, Version__c
											   FROM API_Settings__mdt
											   WHERE DeveloperName = 'Netsuite'];

		System.debug('Sync Order '+syncSetting.Sync_Order__c);

		//Add to queue
		Map<Decimal, Plative_UpsertRecordQueueable> currentQ = new Map<Decimal, 
															   Plative_UpsertRecordQueueable>();
		currentQ.putAll(Plative_SyncQueue.getInstance());
		currentQ.put(syncSetting.Sync_Order__c, new Plative_UpsertRecordQueueable(mapToProcess.values(),
																				lstChildSobjects, apiSettings,
																				syncSetting.Sync_Order__c,
																				syncSetting));
		System.debug('currentQ '+currentQ);

		Plative_SyncQueue.getInstance().clear();

		Plative_SyncQueue.getInstance().putAll(currentQ);

		System.debug('QUEUE '+Plative_SyncQueue.getInstance());
		return true;
	}

    /**
    * Description : Sort and trigger queued jobs 
    **/
	@InvocableMethod
    public static void triggerJobsInQueue(){

        //Check if queue is empty
        if(!Plative_SyncQueue.getInstance().isEmpty()){         
            
            //Sort the queue 
            List<Decimal> lstSeqNos = new List<Decimal>(Plative_SyncQueue.getInstance().keySet());
            lstSeqNos.sort();
            Map<Decimal, Plative_UpsertRecordQueueable> sortedQueue = new  Map<Decimal, 
                                                                           Plative_UpsertRecordQueueable>();
            
            for(Decimal seqNo : lstSeqNos){
                sortedQueue.put(seqNo, Plative_SyncQueue.getInstance().get(seqNo));
            }

            //Add sorted queue elements
            Plative_SyncQueue.getInstance().clear();
            Plative_SyncQueue.getInstance().putAll(sortedQueue);

            //Queue first job
            for(Decimal seqNo : Plative_SyncQueue.getInstance().keySet()){      
                Plative_SyncQueue.getInstance().get(seqNo).updateQueue(Plative_SyncQueue.getInstance());
                System.enqueueJob(Plative_SyncQueue.getInstance().get(seqNo));
                break;
            }
        }
    }


    /**
    * Description : Initiates sync to Netsuite
    **/
    public static Sync_Settings__mdt checkSyncSettings(String sObjName){
        
        //Get sync settings for opportunity
        List<Sync_Settings__mdt> syncSetting = [SELECT Id,Sync_Child_Records__c,
                                                      Sync_Order__c,Object_Endpoint__c,
													  Relationship_Field__c,Child_Object_API_Name__c,
													  Sync_Type__c,SObject_Name__c,
													  External_Id_Field_API_Name__c
                                                FROM Sync_Settings__mdt 
                                                WHERE SObject_Name__c = :sObjName LIMIT 1];
        //No sync required for object
        if(syncSetting == null || syncSetting.isEmpty()){
            return null;
        }

        return syncSetting[0];
    }
    /**
    * Description : Checks if child object records to be synced in parent payload
    *               If yes, then queries and returns child object records to be synced.
    **/
    public static List<SObject> getChildRecordsToSync(Sync_Settings__mdt  parentSettings, 
                                                      Set<Id> parentIds,
                                                      String parentObjName){
        List<SObject> lstChildSobjects = new List<SObject>();
        try{
            List<Child_Object_Sync_Settings__mdt >lstChildObjects = [SELECT Parent_Object_Settings__c, 
                                                                            Object_API_Name__c,
                                                                            Relationship_Field__c,
																	        Filter_Field__c,
																			Filter_Value__c,
																			Filter_Field_Datatype__c
                                                                     FROM Child_Object_Sync_Settings__mdt
                                                      WHERE Parent_Object_Settings__c =:parentSettings.Id];
            if(lstChildObjects == null || lstChildObjects.isEmpty()){
                return lstChildSobjects;
            }

            //Create map of child object name to relationship field for parent object
            Map<String, String> mapObjToRelField = new Map<String, String>();

            //Create map of child object name with its JSON mapping
            Map<String, List<JSON_Mapping__mdt>> mapObjToJSONMapping = new Map<String, 
                                                                        List<JSON_Mapping__mdt>>();
            List<JSON_Mapping__mdt> lstChildJSONMApping;
		    Map<String,String> mapObjToFilterCriteria = new Map<String,String>();
			String filterCriteria;

            //Iterate over settings to populate the maps
            for(Child_Object_Sync_Settings__mdt childObj: lstChildObjects){
				filterCriteria = '';
                lstChildJSONMapping = new List<JSON_Mapping__mdt>();
                mapObjToRelField.put(childObj.Object_API_Name__c,
                                        childObj.Relationship_Field__c);
                lstChildJSONMApping = Plative_SFToNSSyncUtility.fetchJSONMappingListForChild(
                                                                parentObjName,
                                                                childObj.Object_API_Name__c);
                mapObjToJSONMapping.put(childObj.Object_API_Name__c,
                                        lstChildJSONMapping);
				if(!String.isBlank(childObj.Filter_Field__c) &&
				   !String.isBlank(childObj.Filter_Value__c) &&
				   !String.isBlank(childObj.Filter_Field_Datatype__c)){

				   filterCriteria = childObj.Filter_Field__c + ' = \''+
						  convertToDataType(childObj.Filter_Field_Datatype__c,
									 childObj.Filter_Value__c)+'\'';

				   mapObjToFilterCriteria.put(childObj.Object_API_Name__c ,
								filterCriteria);
				}
            }

            String strQuery;
            for(String childObjName : mapObjToRelField.keySet()){
                strQuery = '';
                strQuery = Plative_SFToNSSyncUtility.createQueryFromMappingForChild(childObjName,
                                                        mapObjToJSONMapping.get(childObjName)); 
                strQuery += ' WHERE '+mapObjToRelField.get(childObjName)+' IN :parentIds';
				if(mapObjToFilterCriteria.containsKey(childObjName)){
				  strQuery += ' AND '+mapObjToFilterCriteria.get(childObjName);
				}
                System.debug('strQuery '+strQuery);
                lstChildSobjects.addAll(Database.query(strQuery));  
            }
            return lstChildSobjects;
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
            return lstChildSobjects;
        }
    }

    /**
    * Description : Upsert record to Netsuite
    **/
    public static List<Sobject> upsertRecord(List<Sobject> lstSobjects,
                                             List<Sobject> lstChildSobjects,
                                             List<API_Settings__mdt> apiSettings,
                                             Sync_Settings__mdt syncSetting,
											 Boolean realTime){
        
        String requestBody, requestHeader, endpoint, response;
        //Add a counter to ensure the no. of callouts do not exceed the limit
        Integer counter = 0; 
        List<Sobject> lstUnprocessedSobjects = new List<SObject>();
        List<Sobject> lstProcessedSobjects = new List<SObject>();
        List<Integration_Log__c > integrationLogInsertList = new List<Integration_Log__c>();

		Boolean isSuccess;
        //Iterate through list and make callout for each record
        for (SObject sobj : lstSobjects) {     
            isSuccess = false;     
            HttpResponse httpResponse = new HttpResponse();
            try {
                counter++;
                endpoint = '';
                String objName =sobj.Id.getSObjectType().getDescribe().getName();
                endpoint = apiSettings[0].Endpoint__c+syncSetting.Object_Endpoint__c;
                            //'rest/platform/v1/record/customer'; 
                if (counter < 90) {
                    //Call method to create request body
                    requestBody = Plative_SFToNSSyncUtility.createJSONFromMapping(sobj, objName,
																				  null, 0, null, 
																				  lstChildSobjects,null,
																				  syncSetting);
                    System.debug('REQUEST ' + requestBody);

                    //Add external Id to URL
                    String eid = syncSetting.External_Id_Field_API_Name__c != null && sobj.get(syncSetting.External_Id_Field_API_Name__c) != null ? (String)sobj.get(syncSetting.External_Id_Field_API_Name__c) : null;
                     endpoint += '/eid:'+ eid;

                    //construct header for request
                    requestHeader = Plative_SFToNSSyncUtility.constructHeader('PUT', 'Netsuite', endpoint);
                    System.debug('HEADER ' + requestHeader);

                    //UpsertRecord
                    httpResponse = Plative_NSAPIHandlercls.upsertRecord(requestBody, endpoint, requestHeader);

                    //Get Response Body
                    response = httpResponse.getBody();
					system.debug('response: ' + response);
                    //If Status Code doesn't equal to 204, log an error.
					Sobject sObjToUpdate = Schema.getGlobalDescribe().get(objName).newSObject();
					sObjToUpdate.put('Id',sobj.get('Id'));
                    if (httpResponse.getStatusCode() != 204) {
						sObjToUpdate.put('Last_Sync_Error_Flag__c',true);
						sObjToUpdate.put('Last_Sync_Error_Message__c',httpResponse.getStatus());
                    }
                    else{
						isSuccess = true;
						sObjToUpdate.put('Last_Sync_Error_Flag__c',false);
						sObjToUpdate.put('Last_Sync_Error_Message__c','');
						String externalId = httpResponse.getHeader('Location').substringAfterLast('/');
						sObjToUpdate.put('Netsuite_ID__c',externalId);                         
                    }
                    if(!realTime){
                        sObjToUpdate.put('Sync_To_NetSuite__c',false);
                    }
                    else{
                        sObjToUpdate.put('Trigger_Sync_To_NetSuite__c',false);
                    }
                    lstProcessedSobjects.add(sObjToUpdate);					
                    Plative_IntegrationLog intLog  = new Plative_IntegrationLog(
														endpoint, 'Salesforce To NetSuite', 
														requestHeader, requestBody, 
														String.valueOf(httpResponse.getStatusCode()), 
														response, httpResponse.getStatus(), 
														isSuccess, (String)sobj.get('Id')
													); 
					integrationLogInsertList.add(intLog.logObject); 
                } 
                else{
                    lstUnprocessedSobjects.add(sobj);
                }
            } 
            catch (Exception ex) {
                String errorMessage = 'At: '+ex.getStackTraceString()+'. Message: '+ex.getMessage();
                system.debug('errorMessage: ' + errorMessage);
				
                Plative_IntegrationLog intLog = new Plative_IntegrationLog(
													endpoint, 'Salesforce To NetSuite', 
													requestHeader, requestBody, '', response, 
													errorMessage, false, (String)sobj.get('Id')
													);
                integrationLogInsertList.add(intLog.logObject);
            }
        }
		
        if (!integrationLogInsertList.isEmpty()) { 
			try{
				insert integrationLogInsertList;
			}
			catch (Exception ex) {
				System.debug('EXCEPTION '+ex.getMessage()+ex.getStackTraceString());
			}
        }

        //Set the sync fields on processed record
        if (!lstProcessedSobjects.isEmpty()) { 
            system.debug('lstProcessedSobjects ' + lstProcessedSobjects);    
            update lstProcessedSobjects;
        }
        return lstUnprocessedSobjects;
    }

    /**
    * Description : Gets json mappings for a child object 
    **/
    public Static List<JSON_Mapping__mdt> fetchJSONMappingListForChild(String sObjectApiName,
                                                                       String childObjectAPIName) {
        List<JSON_Mapping__mdt> jsonMappingList = [SELECT Default__c,Field_API_Name__c,
                                                           Group__c,JSON_Node__c,Object_API_Name__c,
                                                           Order__c,Parent_Node__c,Type_of_Node__c,
                                                           Data_type__c,Child_Object_API_Name__c,
                                                           Null_Check_field__c,Filter_Field__c,
														   Filter_Value__c, Filter_Field_Datatype__c
                                                     FROM JSON_Mapping__mdt
                                                     WHERE Object_API_Name__c = :sObjectApiName
                                                     AND Child_Object_API_Name__c= :childObjectAPIName];
        return jsonMappingList;
    }
    /**
    * Description : Creates query from field mapping
    **/
    public Static String createQueryFromMapping(String sObjectApiName, 
												List<JSON_Mapping__mdt> jsonMappingList) {
        String query = 'Select Sync_To_Netsuite__c, Netsuite_Id__c';
        Set<String> setFields = new Set<String>();
        for (JSON_Mapping__mdt mapping : jsonMappingList) {
            if(!String.isBlank(mapping.Field_API_Name__c) &&
               !mapping.Field_API_Name__c.equalsIgnoreCase('Id') &&
               !setFields.contains(mapping.Field_API_Name__c) &&
               String.isBlank(mapping.Child_Object_API_Name__c)){
                query += ',' + mapping.Field_API_Name__c;
                setFields.add(mapping.Field_API_Name__c);
            }
            if(!String.isBlank(mapping.Null_Check_field__c) &&
               !mapping.Field_API_Name__c.equalsIgnoreCase('Id') &&
               !setFields.contains(mapping.Null_Check_field__c) &&
               String.isBlank(mapping.Child_Object_API_Name__c)){
                query += ',' + mapping.Null_Check_field__c;
                setFields.add(mapping.Null_Check_field__c);
            }
            if(!String.isBlank(mapping.Filter_Field__c) &&
               !mapping.Filter_Field__c.equalsIgnoreCase('Id') &&
               !setFields.contains(mapping.Filter_Field__c) &&
               String.isBlank(mapping.Child_Object_API_Name__c)){
                query += ',' + mapping.Filter_Field__c;
                setFields.add(mapping.Filter_Field__c);
            }
        }
        query += ' from ' + sObjectApiName;
        System.debug('query '+query);
        return query;
    }

    /**
    * Description : Creates query from field mapping for child object
    **/
    public Static String createQueryFromMappingForChild(String sObjectApiName, 
                                                       List<JSON_Mapping__mdt> jsonMappingList) {
        String query = 'Select Sync_To_Netsuite__c';
        Set<String> setFields = new Set<String>();
        for (JSON_Mapping__mdt mapping : jsonMappingList) {
            if(!String.isBlank(mapping.Field_API_Name__c) &&
               !mapping.Field_API_Name__c.equalsIgnoreCase('Id') &&
               !setFields.contains(mapping.Field_API_Name__c)){
                query += ',' + mapping.Field_API_Name__c;
                setFields.add(mapping.Field_API_Name__c);
            }
            if(!String.isBlank(mapping.Filter_Field__c) &&
               !mapping.Filter_Field__c.equalsIgnoreCase('Id') &&
               !setFields.contains(mapping.Filter_Field__c)){
                query += ',' + mapping.Filter_Field__c;
                setFields.add(mapping.Filter_Field__c);
            }
            if(!String.isBlank(mapping.Null_Check_field__c) &&
               !mapping.Null_Check_field__c.equalsIgnoreCase('Id') &&
               !setFields.contains(mapping.Null_Check_field__c)){
                query += ',' + mapping.Null_Check_field__c;
                setFields.add(mapping.Null_Check_field__c);
            }
        }
        query += ' from ' + sObjectApiName;
        return query;
    }

    /**
    * Description : Creates payload for a record to send to Netsuite. 
    *               This method is called recursively to build a nested structure in JSON.
    *               In the first invocation the parentNode and groupNum is set to null.
    **/
    public static String createJSONFromMapping(SObject sobj, String sObjName, String parentNode,
                                               Integer currentNode, Integer groupNum,
                                                List<Sobject> lstChildSobjects,
                                                String parentObjName, Sync_Settings__mdt syncSetting){

        Map<String, Object> jsonMap = new Map<String, Object>();
        Map<String, Object> innerMap = new Map<String, Object>();

        List<JSON_Mapping__mdt> jsonMappingList;
        if(String.isBlank(parentObjName)){
             jsonMappingList = getMappingForParentByGroup(sObjName, parentNode,
                                                         currentNode, groupNum);
        }
        else{
             jsonMappingList = getMappingForChildByGroup(sObjName, parentObjName,parentNode, 
                                                          currentNode,groupNum);
        }
        List<Object> innerList;
        for(JSON_Mapping__mdt mapping: jsonMappingList){

            //check the condition field for null check
            if(!String.isBlank(mapping.Null_Check_field__c) &&
                String.isBlank((String)sobj.get(mapping.Null_Check_field__c))){
                continue;
            }

			//Check field filter condition, create current node only if matches
			if(!String.isBlank(mapping.Filter_Field__c) && 
				!String.isBlank(mapping.Filter_Value__c) && 
				!String.isBlank(mapping.Filter_Field_Datatype__c) && 
				(convertToDataType(mapping.Filter_Field_Datatype__c,mapping.Filter_Value__c) != 
				convertToDataType(mapping.Filter_Field_Datatype__c,(sobj.get(mapping.Filter_Field__c))))){
				continue;
			}
            //If simple type mapping            
            if(mapping.Type_of_Node__c == 'Simple' && mapping.Field_API_Name__c != null &&
                mapping.Parent_Node__c == parentNode && String.isBlank(mapping.Child_Object_API_Name__c)){
                jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
                                                  sobj.get(mapping.Field_API_Name__c)));
            }
            //If simple constants
            else if(mapping.Type_of_Node__c == 'Simple' && mapping.Default__c != null &&
                    mapping.Parent_Node__c == parentNode){
                jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
                                                  mapping.Default__c));
            }
            //If map for parent object
            else if(mapping.Type_of_Node__c == 'Map' &&
                    mapping.Parent_Node__c == parentNode &&
                    String.isBlank(mapping.Child_Object_API_Name__c)){
                jsonMap.put(mapping.JSON_Node__c,createJSONFromMapping(sobj,sObjName,
                                                    mapping.JSON_Node__c, currentNode+1,groupNum,
                                                    lstChildSobjects,null,syncSetting));
            }
            else if(mapping.Type_of_Node__c == 'Map' &&
                    mapping.Parent_Node__c == parentNode &&
                    !String.isBlank(mapping.Child_Object_API_Name__c)){
                jsonMap.put(mapping.JSON_Node__c,createJSONFromMapping(sobj,sObjName,
                                                    mapping.JSON_Node__c, currentNode+1,groupNum,
                                                    lstChildSobjects,mapping.Object_API_Name__c,
													syncSetting));
            }
            //If List of records from parent object
            else if(mapping.Type_of_Node__c == 'List' &&
                    mapping.Parent_Node__c == parentNode && !mapping.List_has_Child_Records__c){
                jsonMap.put(mapping.JSON_Node__c,createNestedListStructure(sobj,sObjName,
                                                    mapping.JSON_Node__c,currentNode+1, lstChildSobjects,
													syncSetting));                     
            }   
            //If List of records of child object
            else if(mapping.Type_of_Node__c == 'List' &&
                    mapping.Parent_Node__c == parentNode && mapping.List_has_Child_Records__c){
                innerList = new  List<Object>();
                innerMap = new Map<String, Object>();
                for(SObject childsobj: lstChildSobjects){
                    //If current object is parent of this child record
                    if(childsobj.get(syncSetting.Relationship_Field__c) == sobj.get('Id')){
                        innerList.add(createJSONFromMappingForChild(childsobj,
                                                         syncSetting.Child_Object_API_Name__c,
														 sObjName,mapping.JSON_Node__c, 
                                                         currentNode+1,1,lstChildSobjects,
														 syncSetting));
                    }   
                }       
                jsonMap.put(mapping.JSON_Node__c,innerList);        
            }               
        }
        String jsonStr = JSON.serialize(jsonMap);
        if(!String.isBlank(jsonStr)){
            jsonStr = jsonStr.replace('\\','').replace('"{','{').replace('}"','}');
        }
        System.debug('JSON '+jsonStr);
        return jsonStr;
    }

    /**
    * Description : Creates payload for a record to send to Netsuite. 
    *               This method is called recursively to build a nested structure in JSON.
    *               In the first invocation the parentNode and groupNum is set to null.
    **/
    public static Map<String,Object> createJSONFromMappingForChild(SObject sobj, String sObjName,
                                                                   String parentObjName,String parentNode,
                                                                   Integer currentNode, Integer groupNum,
                                                                   List<Sobject> lstChildSobjects,
																   Sync_Settings__mdt syncSetting){

        Map<String, Object> jsonMap = new Map<String, Object>();
        List<JSON_Mapping__mdt> jsonMappingList = getMappingForChildByGroup(sObjName, 
                                                                            parentObjName,parentNode,
                                                                            currentNode, groupNum);
        for(JSON_Mapping__mdt mapping: jsonMappingList){

            //check the condition field for null check
            if(!String.isBlank(mapping.Null_Check_field__c) &&
                String.isBlank((String)sobj.get(mapping.Null_Check_field__c))){
                continue;
            }

		   //Check field filter condition, create current node only if matches
		   if(!String.isBlank(mapping.Filter_Field__c) && 
			!String.isBlank(mapping.Filter_Value__c) && 
			!String.isBlank(mapping.Filter_Field_Datatype__c) && 
			(convertToDataType(mapping.Filter_Field_Datatype__c,mapping.Filter_Value__c) != 
			convertToDataType(mapping.Filter_Field_Datatype__c,(sobj.get(mapping.Filter_Field__c))))){
			    continue;
		   }

            //If simple type mapping            
            if(mapping.Type_of_Node__c == 'Simple' && mapping.Field_API_Name__c != null &&
                mapping.Parent_Node__c == parentNode){
                jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
                                                  sobj.get(mapping.Field_API_Name__c)));
            }
            //If simple constants
            else if(mapping.Type_of_Node__c == 'Simple' && mapping.Default__c != null &&
                    mapping.Parent_Node__c == parentNode){
                jsonMap.put(mapping.JSON_Node__c, convertToDataType(mapping.Data_type__c,
                                                  mapping.Default__c));
            }
            //If maps with parent object fields
            else if(mapping.Type_of_Node__c == 'Map' &&
                    mapping.Parent_Node__c == parentNode && 
                    String.isBlank(mapping.Child_Object_API_Name__c)){
                jsonMap.put(mapping.JSON_Node__c,createJSONFromMapping(sobj,sObjName,
                                                    mapping.JSON_Node__c, currentNode+1,groupNum,
                                                    lstChildSobjects,mapping.Object_API_Name__c,
													syncSetting));
            }
            //If maps with child object fields
            else if(mapping.Type_of_Node__c == 'Map' &&
                    mapping.Parent_Node__c == parentNode && 
                    !String.isBlank(mapping.Child_Object_API_Name__c)){
                jsonMap.put(mapping.JSON_Node__c,createJSONFromMappingForChild(sobj,sObjName,
                                                    mapping.Object_API_Name__c,mapping.JSON_Node__c, 
                                                    currentNode+1,groupNum,lstChildSobjects,
													syncSetting));
            }
            //If List of records from parent object
            else if(mapping.Type_of_Node__c == 'List' &&
                    mapping.Parent_Node__c == parentNode && !mapping.List_has_Child_Records__c){
                jsonMap.put(mapping.JSON_Node__c,createNestedListStructure(sobj,sObjName,
                                                    mapping.JSON_Node__c,currentNode+1, lstChildSobjects,
													syncSetting));                     
            }   
            //If List of records of child object
            else if(mapping.Type_of_Node__c == 'List' &&
                    mapping.Parent_Node__c == parentNode && mapping.List_has_Child_Records__c){
                for(SObject childsobj: lstChildSobjects){
                    //If current object is parent of this child record
                    if(childsobj.get(syncSetting.Relationship_Field__c) == sobj.get('Id')){
                        jsonMap.put(mapping.JSON_Node__c,createJSONFromMappingForChild(childsobj,
                                                         syncSetting.Child_Object_API_Name__c,
                                                         parentObjName, mapping.JSON_Node__c, currentNode+1,
                                                         groupNum,lstChildSobjects,syncSetting));       
                    }   
                }           
            }               
        }
        return jsonMap;
    }

    /**
    * Description : Converts to respective data type before adding to JSON
    **/
    public static Object convertToDataType(String datatype, Object fieldValue){
        
        //If value is null return object
        if(fieldValue == null || String.isBlank(datatype)){
            return null;
        }
        if(datatype == 'Text'){
            return String.valueOf(fieldValue);
        }
        else if(datatype == 'Boolean'){
            return Boolean.valueOf(fieldValue);
        }
        else if(datatype == 'Number'){
            return (Integer)fieldValue;
        }
        else if(datatype == 'Decimal'){
            return (Decimal)fieldValue;
        }
        else{
            return null;
        }
    }

    /**
    * Description : Logic to build list of nodes in JSON
    **/
    public static List<Object> createNestedListStructure(SObject sobj, String sObjName, 
                                                         String parentNode, Integer currentNode,
                                                         List<Sobject> lstChildSobjects,
														 Sync_Settings__mdt syncSetting){

        List<Object> innerList = new  List<Object>();
        List<JSON_Mapping__mdt> jsonMappingList;

        Integer counter=1;   //Group counter
        Map<String, Object> mapListElem = new Map<String, Object>();
        jsonMappingList = getMappingForParentByGroup(sObjName, parentNode,currentNode, counter);
        while(jsonMappingList != null && jsonMappingList.size() > 0){
            mapListElem = new Map<String, Object>();
            for(JSON_Mapping__mdt mapping: jsonMappingList){
                //check the condition field for null check
                if(!String.isBlank(mapping.Null_Check_field__c) &&
                String.isBlank((String)sobj.get(mapping.Null_Check_field__c))) {
                    continue;
                }
				//Check field filter condition, create current node only if matches
				if(!String.isBlank(mapping.Filter_Field__c) && 
				   !String.isBlank(mapping.Filter_Value__c) && 
				   !String.isBlank(mapping.Filter_Field_Datatype__c) && 
				  (convertToDataType(mapping.Filter_Field_Datatype__c,mapping.Filter_Value__c) != 
				  convertToDataType(mapping.Filter_Field_Datatype__c,(sobj.get(mapping.Filter_Field__c))))){
				   continue;
				}
                //If simple type mapping            
                if(mapping.Type_of_Node__c == 'Simple' && mapping.Field_API_Name__c != null &&
                    mapping.Parent_Node__c == parentNode && String.isBlank(mapping.Child_Object_API_Name__c)){
                    mapListElem.put(mapping.JSON_Node__c, convertToDataType(
                                                            mapping.Data_type__c,
                                                            sobj.get(mapping.Field_API_Name__c)));
                }
                //If simple constants
                else if(mapping.Type_of_Node__c == 'Simple' && mapping.Default__c != null &&
                        mapping.Parent_Node__c == parentNode){
                    mapListElem.put(mapping.JSON_Node__c, convertToDataType(
                                                            mapping.Data_type__c,
                                                            mapping.Default__c));
                }
                //If maps
                else if(mapping.Type_of_Node__c == 'Map' &&
                        mapping.Parent_Node__c == parentNode){
                    mapListElem.put(mapping.JSON_Node__c,createJSONFromMapping(sobj,sObjName,
                                                      mapping.JSON_Node__c, currentNode+1, counter,
                                                      lstChildSobjects,mapping.Child_Object_API_Name__c,
													  syncSetting));      
                }
                //If list
                else if(mapping.Type_of_Node__c == 'List' &&
                        mapping.Parent_Node__c == parentNode){
                    mapListElem.put(mapping.JSON_Node__c,createNestedListStructure(sobj,sObjName,
                                                     parentNode,currentNode+1, lstChildSobjects,
													 syncSetting));
                }       
            }
            innerList.add(mapListElem);
            counter++;
            jsonMappingList = getMappingForParentByGroup(sObjName, parentNode,
                                                         currentNode, counter);
        }
        System.debug('innerList '+innerList);
        return innerList;   
    }

    /**
    * Description : Queries child nodes for a given parent node and group
    **/
    public static List<JSON_Mapping__mdt> getMappingForParentByGroup(String sObjName, 
                                                                     String parentNode, 
                                                                     Integer currentNode,
                                                                     Integer groupNum){

        try{
            List<JSON_Mapping__mdt> jsonMappingList = [SELECT Default__c,Field_API_Name__c,
                                                              Group__c,JSON_Node__c,Object_API_Name__c,
                                                              Order__c,Filter_Field__c, Filter_Value__c, 
															  Filter_Field_Datatype__c,
                                                              Parent_Node__c,Type_of_Node__c,
                                                              Data_type__c,Child_Object_API_Name__c,
                                                              List_has_Child_Records__c,
                                                              Null_Check_field__c
                                                        FROM JSON_Mapping__mdt
                                                        WHERE Order__c = :currentNode AND 
                                                        Object_API_Name__c =:sObjName AND
                                                        Parent_Node__c =:parentNode AND
                                                        Group__c =:groupNum];   
            return jsonMappingList;
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
            return new List<JSON_Mapping__mdt>();
        }
    }   
    /**
    * Description : Queries child nodes for a given parent node and group
    **/
    public static List<JSON_Mapping__mdt> getMappingForChildByGroup(String sObjName, 
                                                                    String parentObjName,
                                                                     String parentNode, 
                                                                     Integer currentNode,
                                                                     Integer groupNum){

        try{
            List<JSON_Mapping__mdt> jsonMappingList = [SELECT Default__c,Field_API_Name__c,
                                                              Group__c,JSON_Node__c,Object_API_Name__c,
                                                              Order__c,Filter_Value__c, Filter_Field__c,
                                                              Parent_Node__c,Type_of_Node__c,
                                                              Data_type__c,Child_Object_API_Name__c,
                                                              List_has_Child_Records__c,
                                                              Null_Check_field__c,Filter_Field_Datatype__c
                                                        FROM JSON_Mapping__mdt
                                                        WHERE Order__c = :currentNode AND 
                                                        Child_Object_API_Name__c =:sObjName AND 
                                                        Object_API_Name__c =:parentObjName AND
                                                        Parent_Node__c =:parentNode AND
                                                        Group__c =:groupNum];   
            return jsonMappingList;
        }
        catch(Exception e){
            System.debug('EXCEPTION '+e.getMessage()+e.getStackTraceString());
            return new List<JSON_Mapping__mdt>();
        }
    }   

    /**
    * Description : Constructs oAuth signature using HMACSHA256 algorithm
    **/
    public static String constructSignature(String httpMethodName, String baseURI, 
                                            Map<String, String> mapSortedParams,
                                            String consumerSecret, String tokenSecret){
        String signature='';
        String nonce = mapSortedParams.get('oauth_nonce'); 
        String timestamp = mapSortedParams.get('oauth_timestamp'); 
        String encodedUrl = EncodingUtil.urlEncode(baseURI, 'UTF-8');
        String secret = EncodingUtil.urlEncode(consumerSecret,'UTF-8')+'&'+
                     EncodingUtil.urlEncode(tokenSecret,'UTF-8');
        String params =  '';

        //Map of header params and query params sorted alphabetically by keys
        Boolean isFirstElem = true;
        for(String key : mapSortedParams.keySet()){
            if(!isFirstElem){
                params += '&';
            }
            params += EncodingUtil.urlEncode(key,'UTF-8')+'='+
                      EncodingUtil.urlEncode(mapSortedParams.get(key),'UTF-8');
            isFirstElem = false;
        }
        System.debug('params '+params);
        String encodedparams = EncodingUtil.urlEncode(params,'UTF-8');
        System.debug('encodedparams '+encodedparams);
        String salt = httpMethodName+'&'+ encodedUrl+'&'+encodedparams;
        System.debug('salt '+salt);
        Blob sig = Crypto.generateMac('HmacSHA256', Blob.valueOf(salt),Blob.valueOf(secret));
        signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');

        return signature;
    }

    /**
    * Description : Creates header for Netsuite integration
    **/

    public static String constructHeader(String methodName, String apiName, String endpoint){
        //Get API settings from custom metadata types
        List<API_Settings__mdt> apiSettings = [SELECT Consumer_Key__c, Consumer_Secret__c,
                                                      Endpoint__c,Token_Id__c, Token_Secret__c,
                                                      Account__c,Signature_Method__c,Version__c
                                               FROM API_Settings__mdt
                                               WHERE DeveloperName = :apiName];

        //Construct map of params
        Map<String, String> mapParams = new Map<String, String>();
        mapParams.put('realm',apiSettings[0].Account__c);
        mapParams.put('oauth_consumer_key',apiSettings[0].Consumer_Key__c);
        mapParams.put('oauth_token',apiSettings[0].Token_Id__c);
        mapParams.put('oauth_signature_method',apiSettings[0].Signature_Method__c);
        mapParams.put('oauth_timestamp',String.valueOf(DateTime.now().getTime()/1000));//Unix time stamp
        mapParams.put('oauth_nonce',String.valueOf(Crypto.getRandomLong())); //Random number generator
        mapParams.put('oauth_version',String.valueOf(apiSettings[0].Version__c));

        //Sorted map
        Map<String, String> sortedMap = sortMapByKey(mapParams);
        System.debug('sortedMap '+sortedMap);

        String signature = constructSignature(methodName, endpoint,sortedMap,
                                              apiSettings[0].Consumer_Secret__c, 
                                              apiSettings[0].Token_Secret__c);

        String header = 'OAuth ';
        Boolean isFirstElem = true;
        for(String key : mapParams.keySet()){
            if(!isFirstElem){
                header += ',';
            }
            header += key+'="'+mapParams.get(key)+'"';
            isFirstElem = false;
        }
        header +=',oauth_signature="'+signature+'"';
        return header;
    }

    /**
    * Description : Sort keys of the map alphabetically
    **/
    public static Map<String, String> sortMapByKey(Map<String, String> mapParams){
        
        Map<String, String> sortedMap = new Map<String, String>();
        List<String> lstKeys = new List<String>();
        lstKeys.addAll(mapParams.keySet());
        lstKeys.sort();
        System.debug('lstKeys '+lstKeys);
        for(String key : lstKeys){
            if(key != 'realm'){
                sortedMap.put(key, mapParams.get(key));
            }
        }
        return sortedMap;
    }
}