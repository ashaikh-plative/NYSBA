/**
* Description : Queueable class to upsert records in Netsuite
* History     :
* [26.Oct.2020] Plative - Code Creation
*/
public class Plative_UpsertRecordQueueable implements Queueable, Database.AllowsCallouts {

    public List<Sobject> lstSobjects;
    public List<SObject> lstChildRecords;
    public List<API_Settings__mdt> apiSettings;
    public Decimal currentSequence;
    public Map<Decimal, Plative_UpsertRecordQueueable> queue;
	public Sync_Settings__mdt syncSettings;

    public Plative_UpsertRecordQueueable(List<Sobject> lstSobjects, 
                                         List<SObject> lstChildRecords, 
                                         List<API_Settings__mdt> apiSettings,
                                         Decimal currentSequence,
										 Sync_Settings__mdt syncSettings) {
        this.lstSobjects = lstSobjects;
        this.lstChildRecords = lstChildRecords;
        this.apiSettings = apiSettings;
        this.syncSettings=syncSettings;
        this.currentSequence = currentSequence;
    }

    public void updateQueue(Map<Decimal, Plative_UpsertRecordQueueable> queue){ 
        this.queue = queue;
    }

    public void execute(QueueableContext context) {

        List<SObject> lstUnprocessedSobjects = Plative_SFToNSSyncUtility.upsertRecord(lstSobjects,lstChildRecords,apiSettings,syncSettings,true);
        
		//Process the unprocessed records
        if (lstUnprocessedSobjects != null && !lstUnprocessedSobjects.isEmpty() && 
            !Test.isRunningTest()) {
            System.enqueueJob(new Plative_UpsertRecordQueueable(lstUnprocessedSobjects, lstChildRecords,apiSettings, currentSequence,syncSettings));
        }
        else{
            //All records processed for current job, remove job from queue
            queue.remove(currentSequence);
        }
        
		//Enqueue next job in queue
        if(!queue.isEmpty()){
            for(Decimal seqNo: queue.keySet()){
                queue.get(seqNo).updateQueue(queue);
				if(!Test.isRunningTest()) System.enqueueJob(queue.get(seqNo));        
                break;      
            }   
        }
    }
}