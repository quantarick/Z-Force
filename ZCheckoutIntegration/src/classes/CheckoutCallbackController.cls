public with sharing class CheckoutCallbackController extends ZCheckoutBaseCallbackController{
	
	public String accountId { get; set; }
	public String firstName { get; set; }
	public String lastName { get; set; }
	public String email { get; set; }
	public String subscriptionId { get; set; }
	public String productId { get; set; }
	public String productRatePlanId { get; set; }
	
  public override void processCallbackParameters() {
  	super.processCallbackParameters();
    this.accountId = callbackparameters.get('account_id');
    this.firstName = callbackparameters.get('firstName');
    this.lastName = callbackparameters.get('lastName');
    this.email = callbackparameters.get('email');
    this.subscriptionId = callbackparameters.get('subscriptionId');
    this.productId = callbackparameters.get('productId');
    this.productRatePlanId = callbackparameters.get('productRatePlanId');
  }
  
  public override String getCustomSettingName() {
    return 'Z-Checkout';
  }  
}