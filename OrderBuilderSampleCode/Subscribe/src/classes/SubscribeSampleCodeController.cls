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
    return null;
  }

  public PageReference previewSubscription() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.previewSubscription();
    return null;
  }

  public PageReference createSubscriptionWithExistingAccount() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.createSubscriptionWithExistingAccount();
    return null;
  }

  public PageReference previewSubscriptionWithExistingAccount() {
    SubscribeCallSampleCode sampleCode = new SubscribeCallSampleCode();
    actionResult = sampleCode.previewSubscriptionWithExistingAccount();
    return null;
  }
}