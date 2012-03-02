public with sharing class SendToZBillingWithInvoiceOwnerController {
   
    public final List<zqu.ZChargeGroup> chargeGroupList {get; set;}
    private final ApexPages.StandardController controller;
    private zqu__Quote__c record;
    private String quoteId ;

    private Zuora.zApi api = new Zuora.zApi();    
    public List<SelectOption> billingAccountList       {get;set;}
    public String  selectedAccountType                 {get;set;}
    public String  selectedSubscriptionType            {get;set;}    
    private final String CRMId;
    public List<SelectOption> subscriptionList         {get;set;}
    private final Map <String,List<SelectOption>> cachedSubOptions = new Map <String,List<SelectOption>>();
    public String selectedAccount         {get;set;}
    
    public SendToZBillingWithInvoiceOwnerController (ApexPages.StandardController controller) {
        
        selectedAccountType = null;
        
        quoteId = controller.getId();
        if (null == quoteId || '' == quoteId) {
            appendMessage(ApexPages.Severity.ERROR,'Need to specify the id of quote.');
            return;
        }
        
        List<zqu__Quote__c> quoteRes = [SELECT Id, zqu__SubscriptionType__c, zqu__ZuoraAccountID__c from zqu__Quote__c where Id = :quoteId LIMIT 1];
        if(1 != quoteRes.size()){
            appendMessage(ApexPages.Severity.ERROR, 'Invalid quote id.');
            return ;
        }
        this.record = quoteRes[0];
        CRMId = record.zqu__ZuoraAccountID__c;
    
        this.controller = controller;
        if (this.validate()) {
           try {
               chargeGroupList = zqu.zQuoteUtil.getChargeGroups(this.controller.getRecord().Id);    
           } catch(Exception e) {
               appendMessage(ApexPages.Severity.ERROR, e.getMessage());
           }
        }
        
        try {
            api.zlogin();
        } catch (Zuora.zRemoteException ex) {
            if ('INVALID_LOGIN' == ex.code) {
               System.debug('Invalid Login');
            }
        } catch (Zuora.zAPIException ex) {
            System.debug('There was an api exception');
        } catch (Zuora.zForceException ex) {
            System.debug('There was a z-force exception');
        }
    }
   
    public PageReference send() {
        try {
            if(selectedAccountType==null){
                appendMessage(ApexPages.Severity.ERROR, 'Please select the billing account.');
                return null;
            }
            
            String accountId;
            if(selectedAccountType=='new'){
                accountId = 'New';
            } else {
                accountId = this.selectedAccount;
            }
           
            final String quoteId = this.controller.getRecord().Id;
            final Map<String, String> finalRes = zqu.zQuoteUtil.sendToZBilling(quoteId ,accountId, true, null, null);
           
            String resultString = '';
            for (String result : finalRes.values()) {
                resultString += result;
            }
            appendMessage(ApexPages.Severity.INFO, resultString);
            
            ChangeOwnerFuture();

         } catch(Exception e) {
            appendMessage(ApexPages.Severity.ERROR, e.getMessage());
        }
        return null;
    }
    
    public void ChangeOwnerFuture(){
        List<zqu__Quote__c> quoteRes = [SELECT Id, zqu__ZuoraAccountID__c,zqu__ZuoraSubscriptionID__c,InvoiceOwner__c from zqu__Quote__c where Id = :quoteId LIMIT 1];
        if(1 != quoteRes.size()){
            appendMessage(ApexPages.Severity.ERROR, 'Invalid quote id.');
            return ;
        }
        this.record = quoteRes[0];
        String subscriptionId = record.zqu__ZuoraSubscriptionID__c;
        String invoiceOwner = record.InvoiceOwner__c;
        if(invoiceOwner==null){
            appendMessage(ApexPages.Severity.INFO, 'No Invoice Owner selected. Subscription invoiced to subscription owner.');
            return;
        }
        List<Zuora__CustomerAccount__c> ownRes = [SELECT Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Id = :invoiceOwner LIMIT 1];
        if(1 != ownRes.size()){
            appendMessage(ApexPages.Severity.ERROR, 'Invalid Invoice Owner ID.');
            return ;
        }
        String newInvoiceOwner  = ownRes[0].Zuora__Zuora_Id__c;

        zqu__Quote__c thisQuote = [Select Owner_Transfer_Status__c from zqu__Quote__c where ID = :quoteId];
        thisQuote.Owner_Transfer_Status__c = 'Transferring';
        update thisQuote;

        OwnerTransferAmendment.ownerTransfer(quoteId, newInvoiceOwner, subscriptionId);
        appendMessage(ApexPages.Severity.INFO, 'Subscription will be invoiced to Zuora account with ID='+newInvoiceOwner);
    }
    
    
    public PageReference onSelectAccountType() {
        if ('new' == this.selectedAccountType) {
            this.selectedSubscriptionType = 'new';
        } else {
                try {
                this.loadBillingAccountList();
                } catch (Zuora.zAPIException e) {
                appendMessage(ApexPages.Severity.ERROR, e.getMessage());  
                return null;
                }
            this.selectDefaultAccount();
        }      
        return null;
    }
    
    private void loadBillingAccountList() {

        if (this.CRMId == null) return;
        //already queried from Zuora, no need to query again
        if (this.billingAccountList != null)
            return;
        else{
        
            //query from Zuora and build the billing account picklist
            this.billingAccountList = new List<SelectOption> ();
            String acczoql = 'SELECT AccountNumber, Name, Id FROM Account WHERE Status = \'Active\' AND CrmId LIKE \'' + this.CRMId.substring(0, 15) + '%\'';
            List <Zuora.zObject> acclist;
            try {
                acclist = api.zquery(acczoql);
            } catch (Zuora.zAPIException e) {
                throw e;
            }
           
            for(Zuora.zObject acc: acclist) {
                String accvalue = (String)acc.getValue('Id');                  
                String acclabel = acc.getValue('Name') +  ', Acct#:' + acc.getValue('AccountNumber') + ', Id=' + acc.getValue('Id');                                    
                SelectOption accso = new SelectOption (accvalue, acclabel);
                this.billingAccountList.add(accso);
            }  
        }
    }    
    
    private void selectDefaultAccount() {
        if (this.billingAccountList != null && this.billingAccountList.size() > 0) {
            this.selectedAccount = this.billingAccountList[0].getValue();
        }
    }
    
    public void onSelectAccount() {
        if (this.billingAccountList != null && this.billingAccountList.size() > 0) {
            this.selectedAccount = this.billingAccountList[0].getValue();
        }
    }

    private Boolean validate() {
        if (null == this.controller.getRecord() || null == this.controller.getRecord().Id) {
            appendMessage(ApexPages.Severity.ERROR, 'Need to specify the id of quote for creating subscription.');
            return false;
        }
        return true;
    }
   
    private static void appendMessage(ApexPages.Severity messageType, String message) {
        ApexPages.addMessage(new ApexPages.Message(messageType, message));
    }    
}