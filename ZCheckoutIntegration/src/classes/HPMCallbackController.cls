public with sharing class HPMCallbackController extends ZCheckoutBaseCallbackController {
	
  public override String getCustomSettingName() {
    return 'Zuora HPM Setting'; 
  }
  
  public override void postProcess() {
    HPMPostProcessController postProcessController = new HPMPostProcessController( this ); 
    postProcessController.execute(); 
  }
  
  public String refId {
    get;
    set;
  }
  public override void processCallbackParameters() {
  	super.processCallbackParameters();
    this.refId = callbackparameters.get('refId');
  }

}