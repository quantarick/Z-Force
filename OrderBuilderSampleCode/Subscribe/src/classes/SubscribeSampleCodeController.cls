/**
 * Subscribe sample code controller
 */
public with sharing class SubscribeSampleCodeController {

  public Boolean actionResult {
    get;
    set;
  }
  public PageReference createSubscription() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.createSubscription();
    log();
    return null;
  }

  public PageReference createSubscriptions() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.createSubscriptions();
    log();
    return null;
  }

  public PageReference previewSubscription() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.previewSubscription();
    log();
    return null;
  }

  public PageReference createSubscriptionWithExistingAccount() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.createSubscriptionWithExistingAccount();
    log();
    return null;
  }

  public PageReference previewSubscriptionWithExistingAccount() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.previewSubscriptionWithExistingAccount();
    log();
    return null;
  }
  
  public void log() {
    for ( Zuora.zApi.Logger logger : Zuora.zApi.loggers ) {
      System.debug( 'ZUORADEBUG: ' + logger.toString() );
    }
  }
  
}