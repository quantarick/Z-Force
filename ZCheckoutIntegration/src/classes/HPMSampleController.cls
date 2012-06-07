public with sharing class HPMSampleController extends ZCheckoutBaseController {
	
	public override String getCustomSettingName() {
		return 'Zuora HPM Setting'; 
	}

  /**
   * Specify extra HPM parameters that can be used to (1) Preload field values (2) Override default HPM properties.  Please see 
   * HPM Implementation Guide for a complete list of HPM parameters.
   */
  public override Map < String, String > getExtraParameters() {
    String objectId = ApexPages.currentPage().getParameters().get('id');
    String billingAccountZuoraId = '';

    if (objectId != null && objectId.trim() != '') {
      List < zqu__Quote__c > quotes = [SELECT zqu__ZuoraAccountId__c from zqu__Quote__c WHERE id = : objectId];
      if (quotes != null && quotes.size() > 0) {
        billingAccountZuoraId = quotes.get(0).zqu__ZuoraAccountId__c;
        pageRef = Page.PaymentMethodCreation;
      } else {
        List < Zuora__CustomerAccount__c > billingAccounts = [SELECT Zuora__Zuora_Id__c FROM Zuora__CustomerAccount__c WHERE id = : objectId];
        if (billingAccounts != null && billingAccounts.size() > 0) {
          billingAccountZuoraId = billingAccounts.get(0).Zuora__Zuora_Id__c;
          pageRef = Page.PaymentMethodCreationBillingAccount;
        }
      }
    }
    return new Map < String, String > {
      'field_maxConsecutivePaymentFailures' => '1', 
      'field_maxConsecutivePaymentFailures' => '1', 
      'field_creditCardType' => 'Visa', 
      'field_accountId' => billingAccountZuoraId
    };
  }

}