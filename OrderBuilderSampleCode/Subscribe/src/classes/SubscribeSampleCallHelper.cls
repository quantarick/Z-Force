public class SubscribeSampleCallHelper{

    public String accountId{get;set;}
    
    public String productId{get;set;}
   
    
    private Zuora.zApi zApiInstance;
    public SubscribeSampleCallHelper( Zuora.zApi zApiInstance ){
        this.zApiInstance = zApiInstance;
    }
    
    public Zuora.zObject createAccount(){
        Zuora.zObject acc = new Zuora.zObject('Account');
        acc.setValue('Name', 'Sample_Account_Name' + System.currentTimeMillis());
        acc.setValue('Currency', 'USD');
        acc.setValue('BillCycleDay', 1);
        acc.setValue('PaymentTerm', 'Net 30');
        acc.setValue('Batch', 'Batch1');
        return acc;
    }
    
    public Zuora.zObject createBillToContact(){
        Zuora.zObject billToContact = new Zuora.zObject('Contact');
        billToContact.setValue('FirstName', 'Jim');
        billToContact.setValue('LastName', 'Green');
        billToContact.setValue('WorkEmail', 'billto@com');
        billToContact.setValue('Country', 'US');
        billToContact.setValue('State', 'CA');
        return billToContact;
    }
    
    public Zuora.zObject createSoldToContact(){
        //sold to contact
        Zuora.zObject soldToContact = new Zuora.zObject('Contact');
        soldToContact.setValue('FirstName', 'Kate');
        soldToContact.setValue('LastName', 'Green');
        soldToContact.setValue('WorkEmail', 'soldto@com');
        soldToContact.setValue('Country', 'US');
        soldToContact.setValue('State', 'CA');
        return soldToContact;
    }
    
    public Zuora.zObject createPaymentMethod(){
        Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
        pm.setValue('Type', 'CreditCard');
        pm.setValue('CreditCardType', 'Visa');
        pm.setValue('CreditCardNumber', '4111111111111111');
        pm.setValue('CreditCardExpirationYear', '2013');
        pm.setValue('CreditCardExpirationMonth', '03');
        pm.setValue('CreditCardHolderName', 'Firstly Lastly');
        return pm;
    }
    
    public Zuora.zApi.SubscribeOptions createSubscribeOptions( Boolean generateInvoice, Boolean processPayments){
        Zuora.zApi.SubscribeOptions so = new Zuora.zApi.SubscribeOptions();
        so.GenerateInvoice = generateInvoice;
        so.ProcessPayments = processPayments;
        return so;
    }
    
    public Zuora.zApi.PreviewOptions createPreviewOptions( Boolean enablePreview, Integer numOfPeriods ){
        if( enablePreview ){
            Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
            previewOpt.EnablePreviewMode = true;
            previewOpt.NumberOfPeriods = numOfPeriods;
            return previewOpt;
        }
        return null;
    }
    
    public Zuora.zApi.SubscriptionData createSubscriptionData(){
        Zuora.zApi.SubscriptionData subscribeData = new Zuora.zApi.SubscriptionData();
        
        String ratePlanId = createProductRatePlan( createProduct() );
        String recurringChargeId = createRecurringCharge( ratePlanId );
        String oneTimeChargeId = createOneTimeCharge( ratePlanId );
        
        //RatePlanCharge
        //recurring charge
        Zuora.zObject ratePlanCharge1 = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge1.setValue('ProductRatePlanChargeId', recurringChargeId);
        ratePlanCharge1.setValue('Quantity', 20.00 );
        
        //one-time charge
        Zuora.zObject ratePlanCharge2 = new Zuora.zObject('RatePlanCharge');
        ratePlanCharge2.setValue('ProductRatePlanChargeId', oneTimeChargeId);
        
        Zuora.zObject rplanChargeData = new Zuora.zObject('RatePlanChargeData');
        rplanChargeData.setValue('RatePlanCharge', ratePlanCharge1);
        
        Zuora.zObject rplanChargeData2 = new Zuora.zObject('RatePlanChargeData');
        rplanChargeData2.setValue('RatePlanCharge', ratePlanCharge2);
        
        //RatePlan
        Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
        ratePlan.setValue('ProductRatePlanId', ratePlanId);

        Zuora.zObject rplanData = new Zuora.zObject('RatePlanData');
        rplanData.setValue('RatePlan', ratePlan);
        rplanData.setValue('RatePlanChargeData', new List < Zuora.zObject > {
            rplanChargeData, rplanChargeData2
        });
        
        //Subscription
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setValue('Name', 'Sample_Subscription' + System.currentTimeMillis());
        subscription.setValue('ContractEffectiveDate', '2012-01-09T02:47:06');
        subscription.setValue('InitialTerm', 12);
        subscription.setValue('RenewalTerm', 12);
        
        subscribeData.Subscription = subscription;
        subscribeData.RatePlanData = new List < Zuora.zObject > {
            rplanData
        };
        return subscribeData;
    }
    
    public String createZuoraAccount(){
        Zuora.zObject account = createAccount();
        account.setValue( 'Status', 'Draft' );
        String accountId = createApiCall( account );
        
        Zuora.zObject billToContact = createBillToContact();
        billToContact.setValue('AccountId', accountId);
        String contactId = createApiCall( billToContact );
 
        Zuora.zObject paymentMethod = createPaymentMethod();
        paymentMethod.setValue('AccountId', accountId);
        String paymentId = createApiCall( paymentMethod );
        
        //update the account
        account = new Zuora.zObject('Account');
        account.setValue( 'Id', accountId );
        account.setValue( 'BillToId', contactId );
        account.setValue( 'SoldToId', contactId );
        account.setValue( 'DefaultPaymentMethodId', paymentId );
        account.setValue( 'Status', 'Active' );
        updateApiCall( account );
        
        return accountId;              
    }
    
    public String createProduct() {
        Zuora.zObject product = new Zuora.zObject('Product');
        product.setValue('Name', 'Product for sample code 2012.20' + System.currentTimeMillis());
        product.setValue('EffectiveStartDate', '2011-06-01T20:44:54.718+05:30');
        product.setValue('EffectiveEndDate', '2019-15-01T20:44:54.718+05:30');
        
        String productId = createApiCall(product);

        return productId;
    }
    
    private String createProductRatePlan(String productId){
        /*Create Product Rate Plan*/
        Zuora.zObject ratePlan = new Zuora.zObject('ProductRatePlan');
        ratePlan.setValue('Name', 'Rate Plan For Sample Code 2012.20' + System.currentTimeMillis());
        ratePlan.setValue('Description', '2011-06-01T20:44:54.718+05:30');
        ratePlan.setValue('EffectiveStartDate', '2011-12-01T20:44:54.718+05:30');
        ratePlan.setValue('EffectiveEndDate', '2016-15-01T20:44:54.718+05:30');
        ratePlan.setValue('ProductId', productId);
        
        String ratePlanId = createApiCall(ratePlan);
        System.debug('Product Rate Plan ======================, rate plan id is [' + ratePlanId + ']=================');
        return ratePlanId;
    }
    
    private String createOneTimeCharge(String ratePlanId) { 
        Zuora.zObject ratePlanCharge = new Zuora.zObject('ProductRatePlanCharge');
        ratePlanCharge.setValue('Name', 'OneTime Rate Plan Charge For Sample Code 2012.20' + System.currentTimeMillis());
        ratePlanCharge.setValue('ChargeModel', 'Flat Fee Pricing');
        ratePlanCharge.setValue('ChargeType', 'OneTime');
        ratePlanCharge.setValue('ProductRatePlanId', ratePlanId);
        ratePlanCharge.setValue('TriggerEvent', 'ContractEffective');
        
        Zuora.zObject ratePlanChargeData = new Zuora.zObject('ProductRatePlanChargeTierData');
        Zuora.zObject ratePlanChargeTier = new Zuora.zObject('ProductRatePlanChargeTier');
        ratePlanChargeTier.setValue('Currency', 'USD');
        ratePlanChargeTier.setValue('IsOveragePrice', false);
        ratePlanChargeTier.setValue('Price', '5');
        ratePlanChargeTier.setValue('PriceFormat', 'Flat Fee');
        
        ratePlanChargeData.setValue('ProductRatePlanChargeTier', new List<Zuora.zObject> {ratePlanChargeTier});
        ratePlanCharge.setValue('ProductRatePlanChargeTierData', ratePlanChargeData);
        
        String ratePlanChargeId = createApiCall(ratePlanCharge);
        System.debug('Product Rate Plan Charge 001 ======================, rate plan charge id is [' + ratePlanChargeId + ']=================');
        return ratePlanChargeId;
    }   
    
    private String createRecurringCharge(String ratePlanId) {   
        Zuora.zObject ratePlanCharge2 = new Zuora.zObject('ProductRatePlanCharge');
        ratePlanCharge2.setValue('Name', 'Recurring Rate Plan Charge For Sample Code 2012.20' + System.currentTimeMillis());
        ratePlanCharge2.setValue('ChargeModel', 'Per Unit Pricing');
        ratePlanCharge2.setValue('ChargeType', 'Recurring');
        ratePlanCharge2.setValue('BillCycleType', 'DefaultFromCustomer');
        ratePlanCharge2.setValue('BillingPeriod', 'Month');
        ratePlanCharge2.setValue('BillingPeriodAlignment', 'AlignToCharge');
        ratePlanCharge2.setValue('DefaultQuantity', '3');
        ratePlanCharge2.setValue('ProductRatePlanId', ratePlanId);
        ratePlanCharge2.setValue('TriggerEvent', 'ContractEffective');
        ratePlanCharge2.setValue('UOM', 'License');
        
        Zuora.zObject ratePlanChargeData2 = new Zuora.zObject('ProductRatePlanChargeTierData');
        Zuora.zObject ratePlanChargeTier2 = new Zuora.zObject('ProductRatePlanChargeTier');
        ratePlanChargeTier2.setValue('Currency', 'USD');
        ratePlanChargeTier2.setValue('IsOveragePrice', false);
        ratePlanChargeTier2.setValue('Price', '4');
        ratePlanChargeTier2.setValue('PriceFormat', 'Per Unit');
        ratePlanChargeTier2.setValue('Tier', '1');
        
        ratePlanChargeData2.setValue('ProductRatePlanChargeTier', new List<Zuora.zObject> {ratePlanChargeTier2});
        ratePlanCharge2.setValue('ProductRatePlanChargeTierData', ratePlanChargeData2);
        
        String ratePlanChargeId2 = createApiCall(ratePlanCharge2);
        System.debug('Product Rate Plan Charge 002 ======================, rate plan charge id is [' + ratePlanChargeId2 + ']=================');
                
        return ratePlanChargeId2;
    }
    
    private String createApiCall(Zuora.zObject zobj){
              
        List<Zuora.zApi.SaveResult> results = zApiInstance.zcreate(new List<Zuora.zObject> {zobj});
        System.debug( 'Zuora: ' + results[0] );
        return results[0].Id;
    }
    
    private Boolean updateApiCall(Zuora.zObject zobj){
        List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(new List<Zuora.zObject> {zobj});
        System.debug( 'Zuora: ' + results[0] );
        return results[0].success;
    }
    

}