public with sharing class HPMCallbackController {

    public Map<String,String> callbackparameters {get;set;}
    
    public String token  {get;set;}
    public String timestamp {get; set;}
    public String signature {get;set;}
    
    public String success {get; set;}
    public String refId   {get; set;}
    public String errorCode  {get;set;}
    public String errorMessage {get;set;}
    public String paramString { get; protected set; }
    
    public void onload(){
        callbackparameters = ApexPages.currentPage().getParameters(); 
        
        this.success =  callbackparameters.get('success');   
        this.token = callbackparameters.get('token') == null ? '' : EncodingUtil.urlDecode(callbackparameters.get('token'), 'UTF-8');
        this.signature = callbackparameters.get( 'responseSignature' ) == null ? '' : EncodingUtil.urlDecode(callbackparameters.get('responseSignature'),'UTF-8');
        this.timestamp = callbackparameters.get('timestamp') == null ? '0' : callbackParameters.get( 'timestamp' );
        this.refId = callbackparameters.get('refId');        
        this.errorCode = callbackparameters.get ('errorCode');        
        this.errorMessage = callbackparameters.get('errorMessage');
        
        validateCallbackSignature();
        constructRedirectUrlParamString();
    }
    
    private void constructRedirectUrlParamString() {
      this.paramString = '';
      Map<String, String> params = ApexPages.currentPage().getParameters();
      if ( this.errorCode != null && this.errorCode.trim().length() > 0 ) {
        this.paramString = '?errorCode=' + this.errorCode; 
        if ( errorCode != 'InvalidCallbackSecurity' ) {
          this.paramString += '&errorMessage=' + this.errorMessage; 
          for ( String errorField : ErrorCodeMapping.ERROR_FIELD_MAPPING.keySet() ) {
            String errorFieldValue = params.get( errorField ); 
            if ( errorFieldValue != null && errorFieldValue.trim().length() > 0 ) {
              this.paramString += '&' + errorField + '=' + errorFieldValue; 
            }
          }
        }
      }
    }
    
    /**
     * Validates the callback signature against both of the following criteria. 
     * 
     * 1. Compare the re-generated signature with the 'responseSignature' parameter that was sent back.  If they differ, the 
     *    callback should not be trusted. 
     * 2. Compare the timestamp parameter from the query string with the current time (in UTC format). If they differ more than 300 seconds, the
     *    callback should not be trusted. 
     */
    public Boolean validateCallbackSignature() {
      HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
      String apiSecurityKey = hpmsetting.HPM_Security_Token__c; 
      String pageId = hpmsetting.HPM_Page_Id__c;
      String tenantId = hpmsetting.HPM_Tenant_Id__c;
      String mySig = generateCallbackSignature( pageId, tenantId, this.timestamp, this.token, apiSecurityKey ); 
      long currentTimestamp = DateTime.now().getTime();
      boolean timestampTooOld = ( currentTimestamp - Long.valueOf( this.timestamp ) > 300000 ); 
     if ( mySig != this.signature || timestampTooOld ) {
        System.debug( 'mySig = ' + mySig + ', responseSignature = ' + this.signature );
        this.success = 'false'; 
        this.errorCode = 'InvalidCallbackSecurity'; 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorCodeMapping.VALUES.get( this.errorCode )));
        return false;
      }
      return true;
    }
    
    public static String generateCallbackSignature( String pageId, String tenantId, String timestamp, String token, String apiSecurityKey )  {
      String queryString = 'id=' + pageId + '&tenantId=' + tenantId + '&timestamp=' + timestamp + '&token=' + token + apiSecurityKey;  
      return EncodingUtil.base64Encode(Blob.valueOf(EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(queryString)))));
    }
}