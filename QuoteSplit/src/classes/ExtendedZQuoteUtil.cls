/**
 * Sample code of splitting single Quote(MasterQuote) into two Quotes(SubQuote) and sending to Z-Billing.
 * 
 * User case
 *    a. The customers have two categories of Rate Plans (e.g. Regular/Power) that need to send to Z-Billing according to the categories but track using one MasterQuote. 
 *    b. Correspondingly to the two categories, there will be two SubQuotes. In the sample code, we send the two SubQuotes simultaneously to Z-Billing, and there will be two
 *       Subscriptions generated after sending to Z-Billing. 
 *    c. The Subscription will generated on single existing Billing Account;
 *    d. The Subscription Zuora IDs will be write back to the SubQuotes then roll up to the MasterQuote, among them, 
 *       the "Regular" Subscription's ID will be stored in MasterQuote's zqu__ZuoraSubscriptionID__c, and the "Power" Subscription's ID will be stored in the MasterQuotes' Extended_Zuora_Subscription_ID__c.
 *    e. The SubQuotes will be deleted after subscribing, and only MasterQuote will be stored.
 *
 * Pre-condition
 *    a. Set the value of the custom field Category__c in the zqu__ProductRatePlan__c, you can choose the value "Regular" or "Power", and the split rule will depend on this value, 
 *       please note that in the sample code we will handle the null value case as default one, which is "Regular";
 *    b. Create a "New Subscription" type Quote with multiple Rate Plans in upper Categories, and the Quote ID will be used as parameter during the API call;
 *    c. Create a Billing Account on Z-Billing side, and the Billing Account Zuora ID will be used as parameter during the API call;
 * 
 */
global Class ExtendedZQuoteUtil {

  global static final String CATEGORY_REGULAR = 'Regular';

  global static final String CATEGORY_POWER = 'Power';

  /**
   * Split single Quote(MasterQuote) into two Quotes(SubQuote) and sending to Z-Billing.
   */
  global static void sendToZBilling(String quoteId, String selectedBillingAccountId, Boolean overrideZContacts, Map < String, String > quoteFields, Map < String, Map < String, String >> chargeFields) {

    final String queryOfMasterQuote = 'SELECT q.Id, q.Name, q.zqu__AmendmentName__c, q.zqu__Amendment_Name__c, q.zqu__AutoRenew__c, q.zqu__BillToContact__c, q.zqu__BillingCycleDay__c, q.zqu__BillingMethod__c,' + 
                                      'q.zqu__Currency__c, q.zqu__Customer_Acceptance_Date__c,  q.zqu__DeltaMRR__c, q.zqu__DeltaTCV__c, q.zqu__Description__c, q.zqu__ExistSubscriptionID__c, q.zqu__Hidden_Subscription_Name__c, ' + 
                                      'q.zqu__InitialTerm__c, q.zqu__InvoiceOwnerId__c, q.zqu__InvoiceOwnerName__c, q.zqu__MRR__c, q.zqu__Number__c, q.zqu__Opportunity__c, q.zqu__Opportunity__r.Account.Id,q.zqu__Opportunity__r.Name, q.zqu__PaymentMethod__c, ' + 
                                      'q.zqu__PaymentTerm__c, q.zqu__ProductSelectorVersion__c, q.zqu__RecordReadOnly__c, q.zqu__RenewalTerm__c, q.zqu__Service_Activation_Date__c, q.zqu__SoldToContact__c,  ' + 
                                      'q.zqu__StartDate__c, q.zqu__Status__c, q.zqu__SubscriptionName__c, q.zqu__SubscriptionTermEndDate__c, q.zqu__SubscriptionTermStartDate__c, q.zqu__SubscriptionType__c, ' + 
                                      'q.zqu__SubscriptionVersion__c, q.zqu__Subscription_Name__c, q.zqu__Subscription_Term_Type__c, q.zqu__TCV__c, q.zqu__Tax__c, q.zqu__Terms__c, q.zqu__Total__c, q.zqu__ValidUntil__c,' + 
                                      ' q.zqu__ZuoraAccountID__c, q.zqu__ZuoraSubscriptionID__c FROM zqu__Quote__c q WHERE q.Id = :quoteId LIMIT 1';
    final zqu__Quote__c masterQuote = Database.query(queryOfMasterQuote);

    // Create two Quotes, one for "Regular" Quote, and another for "Power" Quote.
    String subscribeDate = String.valueOf(System.now());
    final zqu__Quote__c regularQuote = generateSubQuote(masterQuote, CATEGORY_REGULAR, subscribeDate);
    final zqu__Quote__c powerQuote = generateSubQuote(masterQuote, CATEGORY_POWER, subscribeDate);

    // Split the MasterQuote as two SubQuotes.
    splitQuote(masterQuote, regularQuote, powerQuote);

    // Send the Regular Quote to zBilling.
    doSend(regularQuote.id, CATEGORY_REGULAR, selectedBillingAccountId, overrideZContacts, false);

    // Send the Power Quote to zBilling.
    doSend(powerQuote.id, CATEGORY_POWER, selectedBillingAccountId, overrideZContacts, true);
  }

  /**
   * Split the MasterQuote as two SubQuotes.
   */
  private static void splitQuote(zqu__Quote__c masterQuote, zqu__Quote__c regularQuote, zqu__Quote__c powerQuote) {
    // Get Charge Groups of the Master Quote.
    final List < zqu.ZChargeGroup > chargeGroups = zqu.zQuoteUtil.getChargeGroups(masterQuote.id);
    for (zqu.ZChargeGroup chargeGroup: ChargeGroups) {
      zqu__ProductRatePlan__c productRatePlan = getProductRatePlan(chargeGroup);
      if (CATEGORY_REGULAR.equalsIgnoreCase(getCategory(productRatePlan))) {
        addChargeGroup(regularQuote, productRatePlan, chargeGroup);
      } else if (CATEGORY_POWER.equalsIgnoreCase(getCategory(productRatePlan))) {
        addChargeGroup(powerQuote, productRatePlan, chargeGroup);
      }
    }
  }

  /**
   * Send the SubQuote to Z-Billing and write back the information to the MasterQuote.
   */
  @Future(callout = true)
  private static void doSend(String subQuoteId, String subQuoteCategory, String selectedBillingAccountId, Boolean overrideZContacts, Boolean isMasterQuoteDone) {
    Map < String, String > subscribeResult = zqu.zQuoteUtil.sendToZBilling(subQuoteId, selectedBillingAccountId, overrideZContacts, null, null);
    final zqu__Quote__c subQuote = [SELECT id, MasterQuote__c, zqu__ZuoraSubscriptionID__c FROM zqu__Quote__c WHERE id = : subQuoteId LIMIT 1];

    // Write back subscribe result for MasterQuote.
    final zqu__Quote__c masterQuote = [SELECT id, zqu__Status__c, zqu__ZuoraSubscriptionID__c, Extended_Zuora_Subscription_ID__c FROM zqu__Quote__c WHERE id = : subQuote.MasterQuote__c];
    if (CATEGORY_REGULAR.equalsIgnoreCase(subQuoteCategory)) {
      masterQuote.zqu__ZuoraSubscriptionID__c = subQuote.zqu__ZuoraSubscriptionID__c;
    } else if (CATEGORY_POWER.equalsIgnoreCase(subQuoteCategory)) {
      masterQuote.Extended_Zuora_Subscription_ID__c = subQuote.zqu__ZuoraSubscriptionID__c;
    }
    if (isMasterQuoteDone) masterQuote.zqu__Status__c = 'Send To Z-Billing';

    // Remove the SubQuote before upsert the MasterQuote, in order to avoid duplicated External ID.
    delete subQuote;
    upsert masterQuote;
  }

  /**
   * Generate SubQuote.
   */
  private static zqu__Quote__c generateSubQuote(zqu__Quote__c masterQuote, String category, String timeStamp) {
    zqu__Quote__c subQuote = masterQuote.clone();
    // Initialize the SubQuote.
    {
	    subQuote.Extended_Zuora_Subscription_ID__c = null;
	    subQuote.zqu__ZuoraSubscriptionID__c = null;
	    subQuote.Name = '[' + category + ']' + ' ' + masterQuote.Name + ' ' + timeStamp;
	    subQUote.zqu__Description__c = subQuote.Name;
	    
	    // Set the look-up key to MasterQuote__c, if customer want to support sending SubQuotes seperately, 
	    // and update MasterQuote seperately, then the MasterQuote__c will be used.
	    subQuote.MasterQuote__c = masterQuote.id;
	    subQuote.zqu__Opportunity__c = masterQuote.zqu__Opportunity__c;
    }
    insert subQuote;
    return subQuote;
  }

  /**
   * Copy the ChargeGroup of MasterQuote and add to SubQuote.
   */
  private static void addChargeGroup(zqu__Quote__c subQuote, zqu__ProductRatePlan__c productRatePlan, zqu.ZChargeGroup chargeGroupOfMasterQuote) {
    zqu.zChargeGroup chargeGroupOfSubQuote = zqu.zQuoteUtil.getChargeGroup(subQuote.id, productRatePlan.id);
    copyCharges(chargeGroupOfMasterQuote, chargeGroupOfSubQuote);
    zqu.zQuoteUtil.addChargeGroup(chargeGroupOfSubQuote);
  }

  /**
   * Return the Product Rate Plan of the Charge Group.
   */
  private static zqu__ProductRatePlan__c getProductRatePlan(zqu.ZChargeGroup chargeGroup) {
    zqu__ProductRatePlan__c productRatePlan;
    if (chargeGroup.zCharges.size() > 0) {
      final String productRatePlanChargeId = chargeGroup.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID;
      zqu__ProductRatePlanCharge__c productRatePlanCharge = [SELECT id, zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c
                                                                                                                WHERE id = : productRatePlanChargeId LIMIT 1];
      final String productRatePlanId = productRatePlanCharge.zqu__ProductRatePlan__c;
      productRatePlan = [SELECT ID, Category__c FROM zqu__ProductRatePlan__c
                                                                                                                WHERE id = : productRatePlanId LIMIT 1];
    }
    return productRatePlan;
  }

  /**
   * Return the Category of the Product Rate Plan.
   */
  private static String getCategory(zqu__ProductRatePlan__c productRatePlan) {
    // Default as "Regular'.
    String category = CATEGORY_REGULAR;
    if (productRatePlan.Category__c != null) {
      category = productRatePlan.Category__c;
    }
    return category;
  }

  /**
   * Copy the calculation required information between Charges.
   */
  private static void copyCharges(zqu.ZChargeGroup srcChargeGroup, zqu.ZChargeGroup destChargeGroup) {
    // Set Quantity to fix the tier.
    for (zqu.zCharge srcZCharge: srcChargeGroup.zCharges) {
      for (zqu.zCharge destZCharge: destChargeGroup.zCharges) {
        if (destZCharge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID.equalsIgnoreCase(srcZCharge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)) {
          destZCharge.QUANTITY = srcZCharge.QUANTITY;
        }
      }
    }
    zqu.zQuoteUtil.calculateChargesOnQuantityChange(destChargeGroup.zCharges);

    // Set Total.
    for (zqu.zCharge srcZCharge: srcChargeGroup.zCharges) {
      for (zqu.zCharge destZCharge: destChargeGroup.zCharges) {
        if (destZCharge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID.equalsIgnoreCase(srcZCharge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)) {
          destZCharge.TOTAL = srcZCharge.TOTAL;
        }
      }
    }
    zqu.zQuoteUtil.calculateChargesOnTotalChange(destChargeGroup.zCharges);
  }

  /**
   * Unit Test.
   */@isTest
  private static void splitQuoteTest() {
    final zqu__Quote__c masterQuote = ExtendedTestDataSetup.getQuote();

    String subscribeDate = String.valueOf(System.now());
    final zqu__Quote__c regularQuote = ExtendedZQuoteUtil.generateSubQuote(masterQuote, '[Regular]', subscribeDate);
    final zqu__Quote__c powerQuote = ExtendedZQuoteUtil.generateSubQuote(masterQuote, '[Power]', subscribeDate);

    splitQuote(masterQuote, regularQuote, powerQuote);

    final List < zqu__QuoteCharge__c > regularQuoteCharges = [SELECT zqu__Quote__c, zqu__ProductRatePlanName__c FROM zqu__QuoteCharge__c WHERE zqu__Quote__c = : regularQuote.id];
    for (zqu__QuoteCharge__c regularQuoteCharge: regularQuoteCharges) {
      System.assertEquals(CATEGORY_REGULAR, ExtendedTestDataSetup.PLAN_NAME_CATEGORY_MAPPING.get(regularQuoteCharge.zqu__ProductRatePlanName__c));
    }

    final List < zqu__QuoteCharge__c > powerQuoteCharges = [SELECT zqu__Quote__c, zqu__ProductRatePlanName__c FROM zqu__QuoteCharge__c WHERE zqu__Quote__c = : powerQuote.id];
    for (zqu__QuoteCharge__c powerQuoteCharge: powerQuoteCharges) {
      System.assertEquals(CATEGORY_POWER, ExtendedTestDataSetup.PLAN_NAME_CATEGORY_MAPPING.get(powerQuoteCharge.zqu__ProductRatePlanName__c));
    }
  }

  @isTest
  private static void doSendCodeCoverageTest() {
    final zqu__Quote__c masterQuote = ExtendedTestDataSetup.getQuote();

    String subscribeDate = String.valueOf(System.now());
    final zqu__Quote__c regularQuote = generateSubQuote(masterQuote, '[Regular]', subscribeDate);
    final zqu__Quote__c powerQuote = generateSubQuote(masterQuote, '[Power]', subscribeDate);

    splitQuote(masterQuote, regularQuote, powerQuote);

    final String fakeSelectedBillingAccountId = 'This is a fake Billing Account Id';
    doSend(regularQuote.id, CATEGORY_REGULAR, fakeSelectedBillingAccountId, false, false);
    doSend(powerQuote.id, CATEGORY_POWER, fakeSelectedBillingAccountId, false, true);
  }

}