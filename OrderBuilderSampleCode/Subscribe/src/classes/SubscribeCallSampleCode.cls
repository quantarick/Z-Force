/**
 * Sample Code for creating subscriptions in Zuora with OrderBuilder
 * use cases:
 * 1.  create a subscription using an existing account and a product rate plan
 *     that has two charges - a one-time charge and a monthly recurring charge
 * 2.  create a subscription using a product rate plan
 *     that has two charges - a one-time charge and a monthly recurring charge
 * 3.  preview the invoice for the next 2 periods when creating subscriptions
 */
global class SubscribeCallSampleCode {

  Zuora.zApi zApiInstance = new Zuora.zApi();

  SubscribeSampleCallHelper subscribeHelper;

  global SubscribeCallSampleCode() {
    zApiInstance.zlogin();
    subscribeHelper = new SubscribeSampleCallHelper(this.zApiInstance);
  }
  /**
   * zsubscribe() call 
   * create a subscription in zuora and handle with the response
   */
  global Boolean zsubscribe(List <Zuora.zApi.SubscribeRequest> subscriptionRequests) {

    //Zuora.zApi zApiInstance = new Zuora.zApi();
    //zApiInstance.zlogin();
    List < Zuora.zApi.SubscribeResult > subscribeResults = zApiInstance.zsubscribe(subscriptionRequests);
    Boolean actionResult = null;
    for (Zuora.zApi.SubscribeResult result: subscribeResults) {
      if (result.Success) {
        //get the newly created object id
        //result.AccountId,result.AccountNumber,result.InvoiceId,result.InvoiceNumber,result.PaymentTransactionNumber,
        //result.SubscriptionId,result.SubscriptionNumber
        actionResult = true;
        if (result.InvoiceDatas != null) {
          for (Zuora.zObject invData: result.InvoiceDatas) {
            //in Preview mode, handle with the invoice data
            Zuora.zObject invoice = (Zuora.zObject) invData.getValue('Invoice');
            Decimal amount = (Decimal) invData.getValue('Amount');
            List < Object > invoiceItems = invData.getArrayValue('InvoiceItem');
            if (invoiceItems != null) {
              for (Object invoiceItem: invoiceItems) {
                Zuora.zObject zInvoiceItem = (Zuora.zObject) invoiceItem;
                //zInvoiceItem.getValue( 'ChargeAmount' )
                //zInvoiceItem.getValue( 'ChargeDate' );
              }
            }
          }
        }
      } else {
        //failure
        //get the errors
        actionResult = false;
        Zuora.zObject[] errors = result.errors;
        for (Zuora.zObject error: errors) {
          String errorCode = (String) error.getValue('Code');
          String message = (String) error.getValue('Message');
          //more code here...
          System.debug(LoggingLevel.Info, 'Zuora: error -- ' + errorCode + ' : ' + message);
        }
      }
    }
    return (actionResult != null && actionResult);
  }


  /**
   * Preview invoice data with a product rate plan that has two charges
   */
  global Boolean previewSubscription() {
    final Zuora.zApi.SubscribeRequest subscriptionRequest = prepareSubscriptionRequest();
    subscriptionRequest.PreviewOptions = subscribeHelper.createPreviewOptions(true, 2);
    final List <Zuora.zApi.SubscribeRequest> subscriptionRequests = new List <Zuora.zApi.SubscribeRequest> {
    	subscriptionRequest
    };
    return zsubscribe(subscriptionRequests);
  }

  /**
   * Preview invoice data with an existing account and a product rate plan that has two charges
   */
  global Boolean previewSubscriptionWithExistingAccount() {
    return previewSubscriptionWithExistingAccount(subscribeHelper.createZuoraAccount());
  }

  /**
   * Preview invoice data with an existing account and a product rate plan that has two charges
   */
  global Boolean previewSubscriptionWithExistingAccount(String accountId) {
    final Zuora.zApi.SubscribeRequest subscriptionRequest = prepareSubScriptionRequest(accountId);
    subscriptionRequest.PreviewOptions = subscribeHelper.createPreviewOptions(true, 2);
    final List <Zuora.zApi.SubscribeRequest> subscriptionRequests = new List <Zuora.zApi.SubscribeRequest> {
    	subscriptionRequest
    };
    return zsubscribe(subscriptionRequests);
  }

  /**
   * Create a subscription with a product rate plan that has two charges
   */
  global Boolean createSubscription() {
    final Zuora.zApi.SubscribeRequest subscriptionRequest = prepareSubscriptionRequest();
    final List <Zuora.zApi.SubscribeRequest> subscriptionRequests = new List <Zuora.zApi.SubscribeRequest> {
    	subscriptionRequest
    };
    return zsubscribe(subscriptionRequests);
  }

  /**
   * Create multiple subscriptions with a product rate plan that has two charges, expect to return two sucessful results.
   */
  global Boolean createSubscriptions() {
    final Zuora.zApi.SubscribeRequest subscriptionRequest_1 = prepareSubscriptionRequest();
    final Zuora.zApi.SubscribeRequest subscriptionRequest_2 = prepareSubscriptionRequest();
    final List <Zuora.zApi.SubscribeRequest> subscriptionRequests = new List <Zuora.zApi.SubscribeRequest> {
    	subscriptionRequest_1,
    	subscriptionRequest_2
    };
    return zsubscribe(subscriptionRequests);
  }


  global Boolean createSubscriptionWithExistingAccount() {
    return createSubscriptionWithExistingAccount(subscribeHelper.createZuoraAccount());
  }
  /**
   * Create a subscription with an existing account and a product rate plan that has two charges
   */
  global Boolean createSubscriptionWithExistingAccount(String accountId) {
    final Zuora.zApi.SubscribeRequest subscriptionRequest = prepareSubScriptionRequest(accountId);
    final List <Zuora.zApi.SubscribeRequest> subscriptionRequests = new List <Zuora.zApi.SubscribeRequest> {
    	subscriptionRequest
    };
    return zsubscribe(subscriptionRequests);
  }

  /**
   * Prepare a subscription request with an existing account
   */
  private Zuora.zApi.SubscribeRequest prepareSubscriptionRequest(String accountId) {
    Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
    request.ZAccount = new Zuora.zObject('Account');
    request.ZAccount.setValue('Id', accountId);
    request.SubscribeOptions = subscribeHelper.createSubscribeOptions(true, false);
    request.SubscriptionData = subscribeHelper.createSubscriptionData();
    return request;
  }

  /**
   * Prepare a subscription request
   */
  private Zuora.zApi.SubscribeRequest prepareSubscriptionRequest() {
    Zuora.zApi.SubscribeRequest request = new Zuora.zApi.SubscribeRequest();
    request.ZAccount = subscribeHelper.createAccount();
    request.BillToContact = subscribeHelper.createBillToContact();
    request.SoldToContact = subscribeHelper.createSoldToContact();
    request.SubscribeOptions = subscribeHelper.createSubscribeOptions(true, false);
    request.SubscriptionData = subscribeHelper.createSubscriptionData();

    return request;
  }




}