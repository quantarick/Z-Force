public with sharing class OwnerTransferAmendment {

    public OwnerTransferAmendment(ApexPages.StandardController controller) {

    }


    @Future(callout=true)
    public static void ownerTransfer(String quoteId, String newOwner, String subscriptionId) {
         Zuora.zApi zApiInstance = new Zuora.zApi();
        try {
            zApiInstance.zlogin();
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_LOGIN' == ex.code) {
               System.debug('Invalid Login');
               changeTransferStatusError(quoteId);
            }
        } catch (Zuora.zAPIException ex) {
            System.debug('There was an api exception');
            changeTransferStatusError(quoteId);
        } catch (Zuora.zForceException ex) {
            System.debug('There was a z-force exception');
            changeTransferStatusError(quoteId);
        }
        

        
        try {
            Zuora.zObject amd = new Zuora.zObject('Amendment');

            amd.setValue('Name', 'Ownership Transfer');
            amd.setValue('SubscriptionId', subscriptionId);
            amd.setValue('Status', 'Completed');
            amd.setValue('EffectiveDate', Zuora.zUtil.getZuoraDate(System.today()));
            amd.setValue('DestinationInvoiceOwnerId', newOwner);
            amd.setValue('Type', 'OwnerTransfer');

           System.debug('Sub='+(String)amd.getValue('SubscriptionId'));
           System.debug('Old='+(String)amd.getValue('DestinationAccountId'));
           System.debug('New='+(String)amd.getValue('DestinationInvoiceOwnerId'));
            
            List<Zuora.zObject> objs = new List<Zuora.zObject> {amd};
            List<Zuora.zApi.SaveResult> results = zApiInstance.zcreate(objs);
            
            for (Zuora.zApi.SaveResult result : results) {
                if (result.Success){
                    System.debug('Owner successfully changed');
                    changeTransferStatusComplete(zApiInstance, quoteId, subscriptionId);
                } else {
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors) {
                       System.debug('Amendment Error: '+error.getValue('Code')+ ',' + error.getValue('Message'));
                    }
                    changeTransferStatusError(quoteId);
                }
            }
        } catch (Zuora.zRemoteException ex) {
           System.debug('Failed to change owner to '+newOwner);
           
           changeTransferStatusError(quoteId);
        }
     }
     
     public static void changeTransferStatusComplete(Zuora.zApi zApiInstance, String quoteId, String oldId){
            String latestSubId = null;
            
            try{
                String qzoql;
                qzoql = 'SELECT Id from Subscription Where OriginalId=\''+oldId+'\' and Status=\'Active\'';
                List<Zuora.zObject> zobjs = zApiInstance.zquery(qzoql);
                for (Zuora.zObject o : zobjs) {
                    latestSubId = (String)o.getValue('Id');
                }
                if(latestSubId==null){
                    System.debug('Error: Subscription '+ oldId +' does not have an active version in Zuora.');
                    changeTransferStatusError(quoteId);
                    return;
                }
            } catch (Exception e) {
                System.debug('Query exception: '+e.getMessage());
                changeTransferStatusError(quoteId);
                return;
            }
     
            zqu__Quote__c thisQuote = [Select Owner_Transfer_Status__c,zqu__ZuoraSubscriptionID__c from zqu__Quote__c where ID = :quoteId LIMIT 1];
            thisQuote.Owner_Transfer_Status__c = 'Complete';
            thisQuote.zqu__ZuoraSubscriptionID__c = latestSubId;
            update thisQuote;         
     }
     
     public static void changeTransferStatusError(String quoteId){
            zqu__Quote__c thisQuote = [Select Owner_Transfer_Status__c from zqu__Quote__c where ID = :quoteId LIMIT 1];
            thisQuote.Owner_Transfer_Status__c = 'Error';
            update thisQuote;
     }
}