@isTest
public class HPMSampleControllerTest{

    //Test case 1: test config are loaded properly and no error if this is a first onload
    @isTest
    private static void testOnloadFirstTime(){
        HPMSampleControllerTest.prepareHPMSetting();
        PageReference pageRef = Page.HPMSample;
        System.Test.setCurrentPage(pageRef);
        HPMSampleController hpmsc = new HPMSampleController();
        hpmsc.onload();
        System.assertEquals(false, ApexPages.hasMessages(), 'Not working for HPM sample page loading for first time, has errors during loading the page first time.');
    }
    
    @isTest
    private static void onloadWithInvalidSignature() {
      removeHPMSetting(); 
      prepareHPMSetting(); 
      
      PageReference pageRef = Page.HPMCallback; 
      System.Test.setCurrentPage( pageRef ); 
      
      pageRef.getParameters().put( 'errorCode', 'Invalid_Security' );
      
      HPMSampleController hpmsc = new HPMSampleController(); 
      hpmsc.onload(); 
      
      System.assertEquals( true, hpmsc.hasConfigError );
      
      pageRef = Page.HPMCallback;
      System.Test.setCurrentPage( pageRef );
      
      pageRef.getParameters().put( 'errorCode', 'InvalidCallbackSecurity' );
      
      hpmsc = new HPMSampleController(); 
      hpmsc.onload(); 
      
      System.assertEquals( true, hpmsc.hasConfigError );
      
      System.assert( hpmsc.iframeSrc.contains( 'field_maxConsecutivePaymentFailures=1') ); 
    }
    
    //Test case 2: error message are tracked as expected for all 256 cases
    @isTest
    private static void testOnloadWithFailureInCallBack(){  
        HPMSampleControllerTest.prepareHPMSetting();
        PageReference pageRef = Page.HPMSample;
        System.Test.setCurrentPage(pageRef);
        HPMSampleController hpmsc = new HPMSampleController();
        
        for(Integer i = 1; i < 255; i++){           
            if( (i & 1) != 0){
                pageRef.getParameters().put('errorCode', 'This is error code');
            }
            if( ((i>>1) & 1) != 0){
                pageRef.getParameters().put('errorCode', 'This is error code');
                pageRef.getParameters().put('errorMessage', 'This is error Message');
            }
            if( (i>>2 & 1) != 0){
                pageRef.getParameters().put('errorField_creditCardType','This is error credit Card Type');
            }
            if( (i>>3 & 1) != 0){
                pageRef.getParameters().put('errorField_creditCardNumber', 'This is error credit Card Number');
            }
            if( (i>>4 & 1) != 0){
                pageRef.getParameters().put('errorField_creditCardExpirationMonth', 'This is error credit Card Expiration Month' );
            }
            if( (i>>5 & 1) != 0){
                pageRef.getParameters().put('errorField_creditCardExpirationYear', 'This is error credit Card Expiration Year');
            }
            if( (i>>6 & 1) != 0){
                pageRef.getParameters().put('errorField_cardSecurityCode', 'This is error Security Code');
            }
            if( (i>>7 & 1) != 0){
                pageRef.getParameters().put('errorField_creditCardHolderName', 'This is error credit card holder name');
            }
            hpmsc.onload();
            System.assertEquals(true, ApexPages.hasMessages(), 'Not working for HPM sample page loading failure case ' + i + ', no expected error display to page.');
                 
        }
        
    }
    
    //Test case 3: no HPM custom setting set up
    @isTest
    private static void testWithoutHPMSettingConfigSetup(){
        HPMSampleControllerTest.removeHPMSetting();
        PageReference pageRef = Page.HPMSample;
        System.Test.setCurrentPage(pageRef);
        HPMSampleController hpmsc = new HPMSampleController();
        
        hpmsc.onload(); 
        System.assert( hpmsc.hasConfigError );
        system.assertEquals( ErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + ErrorCodeMapping.VALUES.get( 'Sfdc.NoConfiguration' ), ApexPages.getMessages().get(0).getSummary() );
        
        HPMSampleControllerTest.prepareHPMSetting();
        HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        hpmsetting.HPM_Page_Id__c = ''; 
        upsert hpmsetting;       
        
        hpmsc.onload(); 
        System.assert( hpmsc.hasConfigError );
        system.assertEquals( ErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + ErrorCodeMapping.VALUES.get( 'Sfdc.InvalidConfiguration' ) + ' Page ID', ApexPages.getMessages().get(1).getSummary() );
        
        HPMSampleControllerTest.prepareHPMSetting();
        hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        hpmsetting.HPM_Page_Id__c = ''; 
        hpmsetting.HPM_Tenant_Id__c = '';
        upsert hpmsetting;        
        hpmsc.onload(); 
        System.assert( hpmsc.hasConfigError );
        system.assertEquals( ErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + ErrorCodeMapping.VALUES.get( 'Sfdc.InvalidConfiguration' ) + ' Page ID, Tenant ID', ApexPages.getMessages().get(2).getSummary() );
        
        HPMSampleControllerTest.prepareHPMSetting();
        hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        hpmsetting.HPM_Page_Id__c = ''; 
        hpmsetting.HPM_Tenant_Id__c = '';
        hpmsetting.HPM_Security_Token__c = '';
        upsert hpmsetting;        
        hpmsc.onload(); 
        System.assert( hpmsc.hasConfigError );
        system.assertEquals( ErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + ErrorCodeMapping.VALUES.get( 'Sfdc.InvalidConfiguration' ) + ' Page ID, Tenant ID, Security Token', ApexPages.getMessages().get(3).getSummary() );
        
        HPMSampleControllerTest.prepareHPMSetting();
        hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        hpmsetting.HPM_Security_Token__c = '';
        hpmsetting.HPM_Page_Id__c = ''; 
        hpmsetting.HPM_Tenant_Id__c = '';
        hpmsetting.HPM_Security_Token__c = '';
        hpmsetting.HPM_App_Url__c = '';
        upsert hpmsetting;        
        hpmsc.onload(); 
        System.assert( hpmsc.hasConfigError );
        system.assertEquals( ErrorCodeMapping.VALUES.get( 'Sfdc.ErrorLoadingFrame' ) + ErrorCodeMapping.VALUES.get( 'Sfdc.InvalidConfiguration' ) + ' Page ID, Tenant ID, Security Token, App URL', ApexPages.getMessages().get(4).getSummary() );
    }
    
    
    @isTest
    public static void prepareHPMSetting(){
        HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        if(hpmsetting == null)
            hpmsetting = new HPM_Setting__c();
        hpmsetting.Name = 'Zuora HPM Setting';
        hpmsetting.HPM_Page_Id__c = 'page_id';
        hpmsetting.HPM_Tenant_Id__c = '100';
        hpmsetting.HPM_Security_Token__c = 'security_token'; 
        hpmsetting.HPM_App_Url__c = 'www.zuora.com/service/a/27.0';
        upsert hpmsetting;
    }
    
    @isTest
    public static void removeHPMSetting(){
        HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        if(hpmsetting != null)
            delete hpmsetting;
    }
    
}