public with sharing class CheckoutController extends ZCheckoutBaseController {
	
	public static String CUSTOM_SETTING_NAME = 'Z-Checkout';
	
  public override String getCustomSettingName() {
    return CUSTOM_SETTING_NAME;
  }

  @isTest
  private static void testOnLoad() {
    CheckoutController.prepareCustomSetting();
    PageReference pageRef = Page.CheckoutSample;
    System.Test.setCurrentPage(pageRef);
    CheckoutController cc = new CheckoutController();
    cc.onload();
  }

  @isTest
  public static void prepareCustomSetting() {
    HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance( CheckoutController.CUSTOM_SETTING_NAME );
    if (hpmsetting == null) hpmsetting = new HPM_Setting__c();
    hpmsetting.Name = CheckoutController.CUSTOM_SETTING_NAME; 
    hpmsetting.HPM_Page_Id__c = 'page_id';
    hpmsetting.HPM_Tenant_Id__c = '100';
    hpmsetting.HPM_Security_Token__c = 'security_token';
    hpmsetting.HPM_App_Url__c = 'www.zuora.com/service/a/27.0';
    upsert hpmsetting;
  }

  @isTest
  public static void removeCustomSetting() {
    HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance( CheckoutController.CUSTOM_SETTING_NAME );
    if (hpmsetting != null) delete hpmsetting;
  }
}