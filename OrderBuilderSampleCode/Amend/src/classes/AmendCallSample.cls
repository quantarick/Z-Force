public with sharing class AmendCallSample { // Sample
  public void amendForTermsAndConditions() {
    String subscriptionId = '4028e697366ae41401366ca3176f6ee0';
    AmendCallDemostration amend = new AmendCallDemostration();
    amend.amendForTermsAndConditions(subscriptionId);
  }

  public void amendForNewProduct() {
    String subscriptionId = '4028e697366ae41401366ca3176f6ee0';
    String productRatePlanId = '4028e6963640ae3301365829229e7ff2';
    String productRatePlanChargeId = '4028e6973640a5520136582a67542b38';

    AmendCallDemostration amend = new AmendCallDemostration();
    amend.amendForNewProduct(subscriptionId, productRatePlanId, productRatePlanChargeId);
  }

  public void amendForUpdateProduct() {
    String subscriptionId = '4028e697366ae41401366ca3176f6ee0';
    String amendmentSubscriptionRatePlanId = '4028e6963640ae330136582f13ee7aac';
    String productRatePlanChargeId = '4028e6973640a5520136582a67542b38';

    AmendCallDemostration amend = new AmendCallDemostration();
    amend.amendForUpdateProduct(subscriptionId, amendmentSubscriptionRatePlanId, productRatePlanChargeId);
  }

  public void amendForRemoveProduct() {
    String subscriptionId = '4028e697366ae41401366ca3176f6ee0';
    String amendmentSubscriptionRatePlanId = '4028e6963640ae330136582f13ee7aac';

    AmendCallDemostration amend = new AmendCallDemostration();
    amend.amendForRemoveProduct(subscriptionId, amendmentSubscriptionRatePlanId);
  }

  public Boolean success {
    get;
    set;
  }

  public String subId {
    get;
    set;
  }

  public PageReference amendForFullNewProduct() {
    // String subscriptionId = '4028e697368b38d50136961e9cf27c4a';
    AmendCallForAddNewProduct amend = new AmendCallForAddNewProduct();
    success = amend.amendForAddProduct(subId);
    return null;
  }
}