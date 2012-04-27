/**
 * As an rest api endpoint is used to recall by other sides, but nowadays it means zuora side.
 * the full rest api looks like “https://na8.salesforce.com/services/apexrest/SampleCodeForApi?[paraName=paraValue, ... ]”.
 */
@RestResource(urlMapping='/SampleCodeForApi/*')
global class RestSampleCodeForApiController {
    /**
     * Global method is exposed to call with rest api from any sources.
     * this method is designed as the only method to avoid too many rest api methods to be exposed.
     */
    @HttpGet
    global static RestSampleCodeForApiResult invoke(RestRequest request, RestResponse response){
        System.debug('Request Headers: ' + request.headers);
        System.debug('Request Query Parameters: ' + request.params);
        System.debug('Request Remote Address: ' + request.remoteAddress);
        System.debug('Request URI: ' + request.requestURI);
        return invokeAmendmentSampleCode(request);
    }
    
    /**
     * This method is used to invoke Amendment Sample Code.
     */
    private static RestSampleCodeForApiResult invokeAmendmentSampleCode (RestRequest request) {
        AmendCallDemostration amendCall = new AmendCallDemostration();
		RestSampleCodeForApiResult result = new RestSampleCodeForApiResult();
		
        String amendType = request.params.get('amendType');

        if('TermsAndConditions' == amendType){
        	String subscriptionId = request.params.get('subscriptionId');
        	
        	result.success = amendCall.amendForTermsAndConditions(subscriptionId);
        	result.statusMessage = 'Amendment type is TermsAndConditions' + ', Request Query Parameters: ' + request.params;
        }else if('NewProduct' == amendType){
        	String subscriptionId = request.params.get('subscriptionId');
			String productRatePlanId = request.params.get('productRatePlanId');
			String productRatePlanChargeId = request.params.get('productRatePlanChargeId');
			
        	result.success = amendCall.amendForNewProduct(subscriptionId, productRatePlanId, productRatePlanChargeId);
        	result.statusMessage = 'Amendment type is NewProduct' + ', Request Query Parameters: ' + request.params;
        }else if('UpdateProduct' == amendType){
        	String subscriptionId = request.params.get('subscriptionId');
			String productRatePlanChargeId = request.params.get('productRatePlanChargeId');
			String amendmentSubscriptionRatePlanId = request.params.get('amendmentSubscriptionRatePlanId');
		
        	result.success = amendCall.amendForUpdateProduct(subscriptionId, productRatePlanChargeId, amendmentSubscriptionRatePlanId);
        	result.statusMessage = 'Amendment type is not supported' + ', Request Query Parameters: ' + request.params;
        }else if('RemoveProduct' == amendType){
        	String subscriptionId = request.params.get('subscriptionId');
			String amendmentSubscriptionRatePlanId = request.params.get('amendmentSubscriptionRatePlanId');
		
        	result.success = amendCall.amendForRemoveProduct(subscriptionId, amendmentSubscriptionRatePlanId);
        	result.statusMessage = 'Amendment type is RemoveProduct' + ', Request Query Parameters: ' + request.params;
        }else{
        	result = new RestSampleCodeForApiResult();
        	result.success = false;
        	result.statusCode = 'AMEND_TYPE_NOT_SUPPORT';
        	result.statusMessage = 'Amendment type is not supported' + ', Request Query Parameters: ' + request.params;
        }
        
        return result;
    }
}