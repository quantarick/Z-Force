@isTest
private class HPMCallbackControllerTest{
	
	  @isTest
	  /**
	   * Test Case: 
	   * The form is submitted and the callback is received with success = true and a refId. 
	   * The callback signature is also validated. 
	   * Verify that HPMCallbackController reports success = true and no errorCode.
	   */
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
	  
	  @isTest
	  /**
	   * Test Case: 
	   * The form is submitted and the callback is received with success = false and validation errors.
	   * The callback signature is also validated. 
	   * Verify that HPMCallbackController reports success = false with proper error code.
	   */
	  private static void callbackOnError() {
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
            
      pageRef.getParameters().put('success', 'false');
      pageRef.getParameters().put('token', token);
      pageRef.getParameters().put('responseSignature', responseSignature );
      pageRef.getParameters().put('refId', refId);
      pageRef.getParameters().put('timestamp', signatureTimestamp );
      pageRef.getParameters().put('errorCode', 'HostedPageFieldValidationError');
      pageRef.getParameters().put('errorMessage', '');
      pageRef.getParameters().put('errorField_creditCardNumber', '234');
      pageRef.getParameters().put('errorField_creditCardExpirationYear', '1000');
      pageRef.getParameters().put('errorField_cardSecurityCode', '');
      pageRef.getParameters().put('errorField_creditCardType', 'Visa');
      pageRef.getParameters().put('errorField_creditCardHolderName', 'tina kung');
      pageRef.getParameters().put('errorField_creditCardExpirationMonth', '12');
      
      HPMCallbackController hpmcb = new HPMCallbackController();
      hpmcb.onload();
      
      System.assertEquals( 'false', hpmcb.success, 'Received Error callback');
      System.assertEquals( '32gsgu4358432348908253', hpmcb.refId, 'parameter refId is not assigned correctly.');
      System.assertEquals( token, hpmcb.token, 'parameter securitytoken is not assigned correctly.');
      System.assertEquals( responseSignature, hpmcb.signature, 'parameter signature testing is not assigned correctly.');
      System.assertEquals( signatureTimestamp, hpmcb.timestamp, 'parameter timestamp is not assigned correctly.');
      System.assertEquals( 'HostedPageFieldValidationError', hpmcb.errorCode );
      System.assertEquals( '', hpmcb.errorMessage );
      System.assert( hpmcb.paramString.contains( 'errorCode=HostedPageFieldValidationError' ) );
      System.assert( hpmcb.paramString.contains( 'errorMessage=' ) );
      System.assert( hpmcb.paramString.contains( 'errorField_creditCardNumber=234' ) );
      System.assert( hpmcb.paramString.contains( 'errorField_creditCardExpirationYear=1000' ) );
      System.assert( !hpmcb.paramString.contains( 'errorField_cardSecurityCode=' ) );
      System.assert( hpmcb.paramString.contains( 'errorField_creditCardType=Visa' ) );
      System.assert( hpmcb.paramString.contains( 'errorField_creditCardHolderName=' ) );
      System.assert( hpmcb.paramString.contains( 'errorField_creditCardExpirationMonth=12' ) );
    }
	  

    @isTest
    /**
     * Test Case: 
     * The form is submitted and the callback is received with success = true, and a refId. 
     * However, the callback signature cannot be validated. 
     * Verify that the HPMCallbackController reports success = false, errorCode = InvalidCallbackSecurity.  
     */
    private static void callInvalidatedOnSuccess(){
        
      HPMSampleControllerTest.removeHPMSetting(); 
      HPMSampleControllerTest.prepareHPMSetting(); 
      
      PageReference pageRef = Page.HPMCallback;
      System.Test.setCurrentPage(pageRef);
      
      pageRef.getParameters().put('success', 'true');
      pageRef.getParameters().put('token', 'securitytoken');
      pageRef.getParameters().put('responseSignature', 'false signature');
      pageRef.getParameters().put('refId', '32gsgu4358432348908253');
      pageRef.getParameters().put('timestamp', '1316846058928');
      pageRef.getParameters().put('errorCode', '');
      pageRef.getParameters().put('errorMessage', '');
      
      HPMCallbackController hpmcb = new HPMCallbackController();
      hpmcb.onload();
      
      System.assertEquals( 'false', hpmcb.success ); 
      System.assertEquals( '?errorCode=InvalidCallbackSecurity', hpmcb.paramString ); 
    }
    
    @isTest
    /**
     * Test Case: 
     * The form is submitted and the callback is received with success = false and fields validation error.
     * However, the callback signature cannot be validated.
     * Verify that the HPMCallbackController reports success = false, errorCode = InvalidCallbackSecurity.
     */
    private static void callbackInvalidatedOnError(){
      HPMSampleControllerTest.removeHPMSetting(); 
      HPMSampleControllerTest.prepareHPMSetting(); 
        
      PageReference pageRef = Page.HPMCallback;
      System.Test.setCurrentPage(pageRef);
      
      pageRef.getParameters().put('success', 'false');
      pageRef.getParameters().put('token', 'securitytoken');
      pageRef.getParameters().put('responseSignature', 'false signature');
      pageRef.getParameters().put('refId', '32gsgu4358432348908253');
      pageRef.getParameters().put('timestamp', '1316846058928');
      pageRef.getParameters().put('errorCode', 'HostedPageFieldValidationError');
      pageRef.getParameters().put('errorMessage', '');
      pageRef.getParameters().put('errorField_creditCardNumber', '234');
      pageRef.getParameters().put('errorField_creditCardExpirationYear', '1000');
      pageRef.getParameters().put('errorField_cardSecurityCode', '');
      pageRef.getParameters().put('errorField_creditCardType', 'Visa');
      pageRef.getParameters().put('errorField_creditCardHolderName', 'tina kung');
      pageRef.getParameters().put('errorField_creditCardExpirationMonth', '12');
      
      HPMCallbackController hpmcb = new HPMCallbackController();
      hpmcb.onload();
      
      System.assertEquals( 'false', hpmcb.success ); 
      System.assertEquals( '?errorCode=InvalidCallbackSecurity', hpmcb.paramString ); 
    }    
}