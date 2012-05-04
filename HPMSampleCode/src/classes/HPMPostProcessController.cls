/**
 * Post-process after HPM callback occurs.
 * 
 * This default callback controller performs the following actions: 
 * (1) Set the newly created payment method as the default payment method for the Zuora billing account. 
 * (2) Enable the 'AutoPay' of the associated Zuora billing account. 
 */
public virtual with sharing class HPMPostProcessController {

  private HPMCallbackController callback;
  private String paymentMethodId;
  private Zuora.zObject zAccount = new Zuora.zObject('Account');
  private List < String > errorMessages = new List < String > ();
  
  private static Zuora.zApi zapi;

  public HPMPostProcessController(HPMCallbackController callback) {
    this.callback = callback;
  }

  /**
   * Validates the callback response. Proceed with the post-callback process only if the 
   * callback response is Success and contains a valid payment method ID.
   */
  public virtual Boolean isValidCallback() {
    if ('false' == this.callback.success) {
      return false;
    }

    this.paymentMethodId = this.callback.refId;

    if (this.paymentMethodId == null) {
      return false;
    }

    return true;
  }

  /** 
   * Initialize a Zuora API connection and cache it with the requrest. 
   */
  public static Zuora.zApi getApiStub() {
    if (zApi == null) {
      zapi = new Zuora.zApi();
      zapi.zLogin();
    }
    return zApi;
  }

  /**
   * Execute the post-callback action. 
   */
  public virtual void execute() {
    if (!isValidCallback()) {
      return;
    }

    getApiStub();
    getZuoraAccount();

    if (this.zAccount.getValue('Id') != null) {
      setDefaultPaymentMethod();
    }

    processMessages();
  }
  
  private String message; 
  public String getMessage() {
  	return message; 
  }

  private void processMessages() {
    if (errorMessages.size() > 0) {
      for (String msg: errorMessages) {
        message += msg + '/n';  
      }
    }
  }

  private void getZuoraAccount() {
    try {
      String zoql = 'SELECT AccountId FROM PaymentMethod WHERE id = \'' + this.paymentMethodId + '\'';
      System.debug( 'tina zoql = ' + zoql );
      List < Zuora.zObject > zobjs = zapi.zquery(zoql);
      if (zobjs != null && zobjs.size() > 0) {
        zAccount.setValue('Id', (String) zobjs.get(0).getValue('AccountId'));
        System.debug('zAccount ID = ' + zAccount.getValue('Id'));
      } else {
        errorMessages.add(ErrorCodeMapping.VALUES.get('Sfdc.CannotFindAccountId'));
      }
    } catch (Exception e) {
      if (e instanceof Zuora.zRemoteException) {
        Zuora.zRemoteException re = (Zuora.ZRemoteException) e;
      }
      errorMessages.add(ErrorCodeMapping.VALUES.get('Sfdc.ZoqlError') + ' ' + e.getMessage());
    }
  }

  private void setDefaultPaymentMethod() {
    try {
      zAccount.setValue('DefaultPaymentMethodId', this.paymentMethodId); 
      zAccount.setValue('AutoPay', 'true');

      List < Zuora.zApi.SaveResult > results = zapi.zUpdate(new List < Zuora.zObject > {
        zAccount
      });
    } catch (Exception e) {
      if (e instanceof Zuora.zRemoteException) {
        Zuora.zRemoteException re = (Zuora.ZRemoteException) e;
      }
      errorMessages.add(ErrorCodeMapping.VALUES.get('Sfdc.ErrorSettingDefaultPaymentMethod') + ' ' + e.getMessage());
      return;
    }
  }

}