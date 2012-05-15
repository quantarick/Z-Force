/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class HPMPostProcessControllerTest {

    @isTest
    private static void callbackOnSuccess() {
      HPMSampleControllerTest.removeHPMSetting(); 
      HPMSampleControllerTest.prepareHPMSetting(); 
      
      PageReference pageRef = Page.HPMCallback; 
      System.Test.setCurrentPage( pageRef ); 
      
      String signatureTimestamp = String.valueOf( DateTime.now().getTime() - 300 );  
      
      String pageId = 'page_id'; 
      String tenantId = '100'; 
      String apiSecurityKey = 'security_token'; 
      String token = 'mytoken'; 
      String responseSignature = HPMCallbackController.generateCallbackSignature(pageId, tenantId, signatureTimestamp, token, apiSecurityKey);
      STring refId =  '32gsgu4358432348908253'; 
            
      pageRef.getParameters().put('success', 'true');
      pageRef.getParameters().put('token', token);
      pageRef.getParameters().put('responseSignature', responseSignature );
      pageRef.getParameters().put('refId', refId);
      pageRef.getParameters().put('timestamp', signatureTimestamp );
      pageRef.getParameters().put('errorCode', '');
      pageRef.getParameters().put('errorMessage', '');
      
      HPMCallbackController hpmcb = new HPMCallbackController();
      hpmcb.onload();
      
      System.assertEquals(hpmcb.success, 'true', 'Received Success callback');
      System.assertEquals(hpmcb.refId, '32gsgu4358432348908253', 'parameter refId is not assigned correctly.');
      System.assertEquals(hpmcb.token, token, 'parameter securitytoken is not assigned correctly.');
      System.assertEquals(hpmcb.signature, responseSignature, 'parameter signature testing is not assigned correctly.');
      System.assertEquals(hpmcb.timestamp, signatureTimestamp, 'parameter timestamp is not assigned correctly.');
    }
}