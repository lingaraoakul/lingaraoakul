public with sharing class OwnerRecordsController {

    private static final String OWNER_TYPE_QUEUE = 'queue';
    private static final String OBJTYPE = 'Lead';

    @AuraEnabled(cacheable=true)
    public static List<OwnerInfo> getSearchRecords(String ownerType, String searchKey){
        try {            

            if (String.isBlank(ownerType) || String.isBlank(searchKey)) {
                return null;
            }

            List<OwnerInfo> ownerInfos = new List<OwnerInfo>();

            String sanitizedSearchKey = '%'+String.escapeSingleQuotes(searchKey)+'%';
			
            if (OWNER_TYPE_QUEUE.equalsIgnoreCase(ownerType)) {
                
                for (QueueSobject qs : [SELECT QueueId, Queue.Name FROM QueueSobject WHERE SobjectType = :OBJTYPE AND Queue.Name LIKE :sanitizedSearchKey] ) {
                    ownerInfos.add(
                        new OwnerInfo(qs.QueueId, qs.Queue.Name)
                    );
                }
                return ownerInfos;
            }

            for (User record : [SELECT Id, Name FROM USER WHERE Name LIKE :sanitizedSearchKey AND IsActive = True]) {                
                ownerInfos.add(
                    new OwnerInfo(record.Id, record.Name)
                );
            }
            return ownerInfos;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Owner Info
    public class OwnerInfo {

        @AuraEnabled
        public String uniqueId;

        @AuraEnabled
        public String ownerName;

        public OwnerInfo(String uniqueId, String ownerName) {
            this.uniqueId = uniqueId;
            this.ownerName = ownerName;
        }
    }
}