/**
 * It is an assitant class to prepare related data with Amend call required.
 */
public without sharing class AmendCallHelper {
  /**
   * Create basic infomation for amendment.
   */
  public static Zuora.zObject createAmendment(String name, String subscriptionId, String amendType) {
    Zuora.zObject amendment = new Zuora.zObject('Amendment');
    amendment.setValue('ContractEffectiveDate', '2012-04-01T20:44:54.718+05:30');
    amendment.setValue('CustomerAcceptanceDate', '2011-01-01T20:44:54.718+05:30');
    amendment.setValue('Description', 'this is a new product amendment');
    amendment.setValue('EffectiveDate', '2011-01-01T20:44:54.718+05:30');
    amendment.setValue('Name', name);
    amendment.setValue('ServiceActivationDate', '2011-01-01T20:44:54.718+05:30');
    amendment.setValue('Status', 'Completed');
    amendment.setValue('SubscriptionId', subscriptionId);
    amendment.setValue('Type', amendType);

    return amendment;
  }

  /**
   * Create subscription rate plan data.
   */
  public static Zuora.zObject createSubscriptionRatePlanData(String amendmentSubscriptionRatePlanId) {
    Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
    ratePlan.setValue('AmendmentSubscriptionRatePlanId', amendmentSubscriptionRatePlanId);

    Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
    ratePlanData.setValue('RatePlan', ratePlan);

    return ratePlanData;
  }

  /**
   * Create rate plan charge data.
   */
  public static Zuora.zObject createRatePlanChargeData(String productRatePlanChargeId) {
    Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
    ratePlanCharge.setValue('ProductRatePlanChargeId', productRatePlanChargeId);

    Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
    ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);

    return ratePlanChargeData;
  }

  /**
   * Create 'RatePlanData' node definied in Zuora wsdl.
   * 'RatePlanData' is defined an complex data, 
   * Each RatePlanData identifies one RatePlan object and a list of one or more RatePlanChargeData objects. 
   */
  public static Zuora.zObject createRatePlanData(String productRatePlanId, String productRatePlanChargeId) {
    Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
    ratePlanData.setValue('RatePlan', createRatePlan(productRatePlanId));
    ratePlanData.setValue('RatePlanChargeData', new List < Zuora.zObject > {
      createRatePlanChargeDataForNewProduct(productRatePlanChargeId)
    });
    return ratePlanData;
  }

  public static Zuora.zObject createRatePlan(String productRatePlanId) {
    Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
    ratePlan.setValue('ProductRatePlanId', productRatePlanId);
    return ratePlan;
  }

  public static Zuora.zObject createRatePlanChargeDataForNewProduct(String productRatePlanChargeId) {
    Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
    ratePlanChargeData.setValue('RatePlanCharge', createRatePlanCharge(productRatePlanChargeId));
    return ratePlanChargeData;
  }

  public static Zuora.zObject createRatePlanCharge(String productRatePlanChargeId) {
    Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
    ratePlanCharge.setValue('ProductRatePlanChargeId', productRatePlanChargeId);
    ratePlanCharge.setValue('Price', 10);
    return ratePlanCharge;
  }

  public static Zuora.zObject createRatePlanChargeTiers() {
    Zuora.zObject ratePlanChargeTier = new Zuora.zObject('RatePlanChargeTier');
    ratePlanChargeTier.setValue('Tier', '2');
    ratePlanChargeTier.setValue('Price', 456.789);
    return ratePlanChargeTier;
  }

  /**
   * Order builder will invoke amend call with passed amendment.
   */
  public static Boolean amendApiCall(Zuora.zObject amendment) {
    Zuora.zApi zuorApi = new Zuora.zApi();
    zuorApi.zlogin();

    Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
    Zuora.zObject[] amendments = new List < Zuora.zObject > {
      amendment
    };
    amendRequest.amendments = amendments;

    Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
    amendmentOption.GenerateInvoice = false;
    amendmentOption.ProcessPayments = false;

    amendRequest.amendOptions = amendmentOption;

    Zuora.zApi.AmendResult result = zuorApi.zamend(new List < Zuora.zApi.AmendRequest > {
      amendRequest
    });

    // Print amend call 's result
    // System.debug(result);
    System.assertEquals(null, result);

    return result.success;
  }
}