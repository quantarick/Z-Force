/**
 * Sample code for Amend Call.
 * It covers four types of amend usage, they are 'Terms And Conditions', 'New Product', 'Update Product', 'Remove Product'. 
 * If you want to get more detail infomation, 
 * please refer to 'http://knowledgecenter.zuora.com/D_Zuora_API_Developers_Guide/E_API_Calls/amend%28%29'
 */
global class AmendCallDemostration {
	
	/**
	 * Amendment Type For TermsAndConditions.
	 * Use this amendment type to extend or shorten the initial term or renewal term of the subscription by increasing 
	 * or decreasing the number of months in the term or by changing the current term start date and the current term end date. 
	 * Using this amendment type, you can autorenew a subscription in advance of the subscription's autorenewal date.
	 */ 
	global Boolean amendForTermsAndConditions(String subscriptionId) {
		Zuora.zObject amendment = AmendCallHelper.createAmendment('changing terms and conditions' + System.currentTimeMillis(), subscriptionId, 'TermsAndConditions');
		
		// Change to TERMED
		amendment.setValue('TermType', 'TERMED');
        amendment.setValue('InitialTerm', '12');
        amendment.setValue('RenewalTerm', '12');
        amendment.setValue('TermStartDate', '2012-01-01T00:00:00');
        amendment.setValue('AutoRenew', 'true');
        
        // Change to EVERGREEN
        // amendment.setValue('TermType', 'EVERGREEN');
        // amendment.setValue('TermStartDate', '2012-01-01T00:00:00');
        
		return AmendCallHelper.amendApiCall(amendment);
	}
	
	/**
	 * Amendment Type For NewProduct.
	 * Use this amendment type to add additional products or services to the existing subscription. 
	 * A separate amendment must be created for each new product added.
	 */
	global Boolean amendForNewProduct(String subscriptionId, String productRatePlanId, String productRatePlanChargeId) {
		Zuora.zObject amendment = AmendCallHelper.createAmendment('Add a Product 001' + System.currentTimeMillis(), subscriptionId, 'NewProduct');
		
		// Properties to set
		amendment.setValue('RatePlanData', AmendCallHelper.createRatePlanData(productRatePlanId, productRatePlanChargeId));
		return AmendCallHelper.amendApiCall(amendment);
	}
	
	/**
	 * Amendment Type For UpdateProduct.
	 * Use this amendment type to update the charge information, including the price or quantity of a product, 
	 * in the existing subscription (for example, add or remove seats).
	 */
	global Boolean amendForUpdateProduct(String subscriptionId, String amendmentSubscriptionRatePlanId, String productRatePlanChargeId) {
		Zuora.zObject amendment = AmendCallHelper.createAmendment('TimeTrade Test - Add New Product' + System.currentTimeMillis(), subscriptionId, 'UpdateProduct');
		
		// Properties to set
		Zuora.zObject ratePlan = AmendCallHelper.createSubscriptionRatePlanData(amendmentSubscriptionRatePlanId);
		Zuora.zObject ratePlanChargeData = AmendCallHelper.createRatePlanChargeData(productRatePlanChargeId);
		ratePlan.setValue('RatePlanChargeData', new List<Zuora.zObject> {ratePlanChargeData});
		amendment.setValue('RatePlanData', ratePlan);
		
		return AmendCallHelper.amendApiCall(amendment);
	}
	
	/**
	 * Amendment Type For RemoveProduct.
	 * Use this amendment type to remove a product from an existing subscription. 
	 * You can use this type in conjunction with the Add Product amendment if upgrading from one product to another 
	 * (for example, remove a monthly product and replace it with an annual product).
	 */ 
	global Boolean amendForRemoveProduct(String subscriptionId, String amendmentSubscriptionRatePlanId) {
		Zuora.zObject amendment = AmendCallHelper.createAmendment('Removing a product' + System.currentTimeMillis(), subscriptionId, 'RemoveProduct');
		
		// Properties to set
		amendment.setValue('RatePlanData', AmendCallHelper.createSubscriptionRatePlanData(amendmentSubscriptionRatePlanId));
		
		return AmendCallHelper.amendApiCall(amendment);
	}
	
	/**
	 * set a Renewal amendment to autorenew a subscription in advance of the next renewal term start date. 
	 * The renewal amendment option is only available in the Amendment Type list 
	 * if the applicable subscription has Auto Renew set to Yes.
	 * Note: If you want to use OwnerTransfer's function, please open related permission in Billing. 
	 */
	global Boolean amendForRenewal(String subscriptionId) {
		Zuora.zObject amendment = new Zuora.zObject('Amendment');
        
        amendment.setValue('Name', 'Renewal_Test' + System.currentTimeMillis());
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('Type', 'Renewal');
        amendment.setValue('ContractEffectiveDate', '2011-01-01T20:44:54.718+05:30');
        
		return AmendCallHelper.amendApiCall(amendment);
	}
	
	global Boolean amendForOwnerTransfer(String subscriptionId, String accId, String ownerId) {
		Zuora.zObject amendment = new Zuora.zObject('Amendment');
        
        amendment.setValue('Name', 'OwnerTransfer_Test' + System.currentTimeMillis());
        amendment.setValue('SubscriptionId', subscriptionId);
        amendment.setValue('Type', 'OwnerTransfer');
        amendment.setValue('ContractEffectiveDate', '2011-01-01T20:44:54.718+05:30');
        amendment.setValue('DestinationAccountId', accId);
        amendment.setValue('DestinationInvoiceOwnerId', ownerId);
        
        return AmendCallHelper.amendApiCall(amendment);
	}
}