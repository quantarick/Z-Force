/**
 * Sample Code use cases: 
 * 1). I want to create an "add product" amendment, by adding a product rate plan that has two charges - a one time charge and a monthly recurring charge
 * 2). I want to preview the invoice for the next 2 months
 */
global class AmendCallForAddNewProduct {
	
	private static Zuora.zApi zApiInstance = new Zuora.zApi();

  global Boolean amendForAddProduct(String subscriptionId) {
  	zApiInstance.zLogin();
  	
    // Prepare product for amend call
    String productId = createProduct();
    String productRatePlanId = createProductRatePlan(productId);
    String oneTimeChargeId = createOneTimeCharge(productRatePlanId);
    String recurringChargeId = createRecurringCharge(productRatePlanId);

    // Amend call
    Zuora.zObject amendment = new Zuora.zObject('Amendment');
    amendment.setValue('Description', 'this is a new product amendment');
    amendment.setValue('ContractEffectiveDate', '2012-04-10T20:44:54.718+05:30');
    amendment.setValue('CustomerAcceptanceDate', '2011-04-10T20:44:54.718+05:30');
    amendment.setValue('EffectiveDate', '2012-04-10T20:44:54.718+05:30');
    amendment.setValue('Name', 'Add a Product v.2012.20_' + System.currentTimeMillis());
    amendment.setValue('ServiceActivationDate', '2012-04-03T20:44:54.718+05:30');
    amendment.setValue('Status', 'Completed');
    amendment.setValue('SubscriptionId', subscriptionId);
    amendment.setValue('Type', 'NewProduct');

    Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
    Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
    ratePlan.setValue('ProductRatePlanId', productRatePlanId);

    ratePlanData.setValue('RatePlan', ratePlan);

    amendment.setValue('RatePlanData', ratePlanData);

    return amendApiCall(amendment);
  }

  private Boolean amendApiCall(Zuora.zObject amendment) {
    Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
    Zuora.zObject[] amendments = new List < Zuora.zObject > {
      amendment
    };
    amendRequest.amendments = amendments;

    // Amend Options
    Zuora.zApi.AmendOptions amendmentOption = new Zuora.zApi.AmendOptions();
    amendmentOption.GenerateInvoice = true;
    amendmentOption.ProcessPayments = false;

    // Amend Preview
    Zuora.zApi.PreviewOptions previewOptions = new Zuora.zApi.PreviewOptions();
    previewOptions.EnablePreviewMode = true;
    previewOptions.NumberOfPeriods = 2;
    amendRequest.previewOptions = previewOptions;

    Zuora.zApi.AmendResult result = zApiInstance.zamend(new List < Zuora.zApi.AmendRequest > {
      amendRequest
    });

    // System.assertEquals(null, result);
    System.debug(result);

    return result.success;
  }

  private String createProduct() {
    Zuora.zObject product = new Zuora.zObject('Product');
    product.setValue('Name', 'Product for sample code 2012.20' + System.currentTimeMillis());
    product.setValue('EffectiveStartDate', '2011-06-01T20:44:54.718+05:30');
    product.setValue('EffectiveEndDate', '2019-15-01T20:44:54.718+05:30');

    String productId = createApiCall(product);

    return productId;
  }

  private String createProductRatePlan(String productId) {
    /*Create Product Rate Plan*/
    Zuora.zObject ratePlan = new Zuora.zObject('ProductRatePlan');
    ratePlan.setValue('Name', 'Rate Plan For Sample Code 2012.20' + System.currentTimeMillis());
    ratePlan.setValue('Description', '2011-06-01T20:44:54.718+05:30');
    ratePlan.setValue('EffectiveStartDate', '2011-15-01T20:44:54.718+05:30');
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

    ratePlanChargeData.setValue('ProductRatePlanChargeTier', new List < Zuora.zObject > {
      ratePlanChargeTier
    });
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

    ratePlanChargeData2.setValue('ProductRatePlanChargeTier', new List < Zuora.zObject > {
      ratePlanChargeTier2
    });
    ratePlanCharge2.setValue('ProductRatePlanChargeTierData', ratePlanChargeData2);

    String ratePlanChargeId2 = createApiCall(ratePlanCharge2);
    System.debug('Product Rate Plan Charge 002 ======================, rate plan charge id is [' + ratePlanChargeId2 + ']=================');

    return ratePlanChargeId2;
  }

  public static String createApiCall(Zuora.zObject zobj) {
    List < Zuora.zApi.SaveResult > results = zApiInstance.zcreate(new List < Zuora.zObject > {
      zobj
    });

    return results[0].Id;
  }
}