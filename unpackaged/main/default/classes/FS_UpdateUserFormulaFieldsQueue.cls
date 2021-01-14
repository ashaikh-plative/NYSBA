/**
 * @author          cubiascaceres
 * @description:    Callouts are not allowed after a DML operation, so in order to avoid the 'You have uncommitted 
 *                  work pending. Please commit or rollback before calling out' error. We need to make the callout
 *                  on a separate context
 */
public class FS_UpdateUserFormulaFieldsQueue implements Queueable {

    private List<String> userIdList = new List<String>();

    public FS_UpdateUserFormulaFieldsQueue(List<String> userIdList) {
        userIdList = userIdList;
    }

    public void execute(QueueableContext context) {
        FS_UserSyncRequest.oktaSyncWorker(userIdList);
    }

}