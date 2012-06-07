public with sharing virtual class ZCheckoutBaseController {
	
	public virtual String getCustomSettingName() {
		return 'Z-Checkout'; 
	}

  public String iframeSrc {
    get;
    set;
  }

  private String errorMessage;
  private String errorCode;

  public boolean hasConfigError {
    get;
    set;
  }

  private String pageId;
  private String apiSecurityKey;
  private String appUrl;
  private String tenantId;

  public PageReference pageRef {
    get;
    set;
  }

  public void onload() {
    try {
      validateConfiguration();
    } catch (HPMConfigException e) {
      hasConfigError = true;
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorCodeMapping.VALUES.get('Sfdc.ErrorLoadingFrame') + e.getMessage()));
    }

    String token = EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    String timestamp = String.valueOf(System.currentTimeMillis());

    String queryString = 'id=' + pageId + '&' + 'tenantId=' + tenantId + '&' + 'timestamp=' + timestamp + '&' + 'token=' + token;

    String queryHashString = queryString + apiSecurityKey;
    String signature = EncodingUtil.base64Encode(Blob.valueOf(EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(queryHashString)))));

    iframeSrc = appUrl + '/PublicHostedPage.do?method=requestPage&id=' + pageId + '&tenantId=' + tenantId + '&timestamp=' + timestamp + '&token=' + token + '&signature=' + signature;

    Map < String, String > extraParameters = getExtraParameters();
    for (String param: extraParameters.keySet()) {
      iframeSrc += '&' + param + '=' + extraParameters.get(param);
    }

    addCallBackfailure();
  }

  public String getExtraParamString() {
    String extraParam = '';
    Map < String, String > extraParameters = getExtraParameters();
    for (String param: extraParameters.keySet()) {
      extraParam += '&' + param + '=' + extraParameters.get(param);
    }
    return extraParam;
  }

  /**
   * Specify extra HPM parameters that can be used to (1) Preload field values (2) Override default HPM properties.  Please see 
   * HPM Implementation Guide for a complete list of HPM parameters.
   */
  public virtual Map < String, String > getExtraParameters() {
    if ( 1 == 2 ) {
      return new Map<String,String>();
    }
    
    return new Map < String, String > {
      'field_country' => 'USA', 
      'field_state' => 'CA', 
      'field_postalCode' => '95129',
      'field_city' => 'San Jose'
    }; 
  }

  private void validateConfiguration() {
    this.hasConfigError = false;
    HPM_Setting__c hpmSetting = HPM_Setting__c.getInstance( getCustomSettingName() );
    if (hpmSetting == null) {
      throw new HPMConfigException(ErrorCodeMapping.VALUES.get('Sfdc.NoConfiguration'));
    }

    String missingFields = '';
    this.pageId = hpmSetting.HPM_Page_Id__c;
    if (this.pageId == null || this.pageId.trim().length() == 0) {
      missingFields += ' Page ID,';
    }

    this.tenantId = hpmSetting.HPM_Tenant_Id__c;
    if (this.tenantId == null || this.tenantId.trim().length() == 0) {
      missingFields += ' Tenant ID,';
    }

    this.apiSecurityKey = hpmSetting.HPM_Security_Token__c;
    if (this.apiSecurityKey == null || this.apiSecurityKey.trim().length() == 0) {
      missingFields += ' Security Token,';
    }

    this.appUrl = hpmSetting.HPM_App_Url__c;
    if (this.appUrl == null || this.appUrl.trim().length() == 0) {
      missingFields += ' App URL,';
    }

    if (missingFields.length() > 0) {
      missingFields = missingFields.substring(0, missingFields.length() - 1);
      throw new HPMConfigException(ErrorCodeMapping.VALUES.get('Sfdc.InvalidConfiguration') + missingFields);
    }

    Map < String, String > paramMap = ApexPages.currentPage().getParameters();
    String errorCode = paramMap.get('errorCode');
    if (errorCode == 'Invalid_Security' || errorCode == 'InvalidCallbackSecurity') {
      this.hasConfigError = true;
    }
  }

  private void addCallBackfailure() {
    errorMessage = '';
    errorCode = '';
    
    this.pageRef = Page.CheckoutSample;

    PageReference curPage = System.currentPageReference();

    errorMessage = curPage.getParameters().get('errorMessage');
    errorCode = curPage.getParameters().get('errorCode');

    final String DefaultErrorPrefix = 'An error has occurred';
    String error = '';

    if (errorCode != null && errorCode != '') {
      boolean unknownErrorCode = false;
      error = ErrorCodeMapping.VALUES.get(errorCode);
      if (error == null) {
        error = DefaultErrorPrefix;
        unknownErrorCode = true;
      }
      if (errorMessage != null && errorMessage != '') {
        error += (': ' + errorMessage);
      } else if (unknownErrorCode) {
        error += (': ' + errorCode);
      }
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
      iframeSrc += '&retainValues=true';
      if (errorCode == 'InvalidCallbackSecurity') {
        return;
      }
    }

    List < String > validationErrors = new List < String > ();
    for (String errorField: ErrorCodeMapping.ERROR_FIELD_MAPPING.keySet()) {
      String errorFieldValue = curPage.getParameters().get(errorField);
      if (errorFieldValue != null && errorFieldValue.trim().length() > 0) {
        validationErrors.add(ErrorCodeMapping.ERROR_FIELD_MAPPING.get(errorField) + ': ' + ErrorCodeMapping.VALUES.get(errorFieldValue));
      }
    }
    if (validationErrors.size() > 0) {
      validationErrors.sort();
      for (String validationError: validationErrors) {
        ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, validationError));
      }
    }
  }


}