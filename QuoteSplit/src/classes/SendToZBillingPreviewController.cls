/**
 * Entry page to call ExtendedZQuoteUtil.sendToZBilling(....).
 * 
 */
public with sharing class SendToZBillingPreviewController {

  public List < SelectOption > billingAccountOptionList {
    get;
    set;
  }

  public List < zqu.ZChargeGroup > chargeGroupList {
    get;
    set;
  }

  public String selectedBillingAccountId {
    get;
    set;
  }

  private final ApexPages.StandardController controller;

  private final Zuora.zApi zApiInstance = new Zuora.zApi();

  private String quoteId;

  /**
   * Constructor, initialize the context for sending.
   */
  public SendToZBillingPreviewController(ApexPages.StandardController controller) {
    this.controller = controller;
    if (this.validate()) {
      this.quoteId = this.controller.getRecord().Id;
      try {
        loadbillingAccountOptionList();
        loadChargeGroupList();
      } catch (Exception e) {
        appendMessage(ApexPages.Severity.ERROR, e.getMessage());
      }
    }
  }

  /**
  * Call ExtendedZQuoteUtil.sendToZBilling to split the MasterQuote, then send SubQuotes to Z-Billing.
  */
  public PageReference doSend() {
    try {
      ExtendedZQuoteUtil.sendToZBilling(this.quoteId, this.selectedBillingAccountId, false, null, null);
    } catch (Exception e) {
      appendMessage(ApexPages.Severity.ERROR, e.getMessage());
    }
    return null;
  }

  private void loadbillingAccountOptionList() {
    final String accountCrmId = getAccountCrmId();

    try {
      zApiInstance.zlogin();
    } catch (Zuora.zAPIException e) {
      appendMessage(ApexPages.Severity.ERROR, e.getMessage());
      return;
    }

    this.billingAccountOptionList = new List < SelectOption > ();
    String acczoql = 'SELECT AccountNumber, Name FROM Account WHERE Status = \'Active\' AND CrmId LIKE \'' + accountCrmId.substring(0, 15) + '%\'';
    List < Zuora.zObject > accountlist;
    try {
      accountlist = zApiInstance.zquery(acczoql);
    } catch (Zuora.zAPIException e) {
      throw e;
    }

    for (Zuora.zObject account: accountlist) {
      final String accountValue = (String) account.getValue('Id');
      final String accoutLabel = account.getValue('Name') + ', Acct#:' + account.getValue('AccountNumber');
      this.billingAccountOptionList.add(new SelectOption(accountValue, accoutLabel));
      // Set the first Billing Account as default value.
      if (null == this.selectedBillingAccountId) {
        this.selectedBillingAccountId = accountValue;
      }
    }
  }

  private void selectDefaultAccount() {
    if (this.billingAccountOptionList != null && this.billingAccountOptionList.size() > 0) {
      this.selectedBillingAccountId = this.billingAccountOptionList[0].getValue();
    }
  }

  private void loadChargeGroupList() {
    chargeGroupList = zqu.zQuoteUtil.getChargeGroups(this.controller.getRecord().Id);
  }

  private String getAccountCrmId() {
    final zqu__Quote__c quote = [SELECT zqu__Opportunity__c FROM zqu__Quote__c WHERE id = : this.quoteId];
    final Opportunity opp = [SELECT id, Account.id FROM Opportunity WHERE id = : quote.zqu__Opportunity__c LIMIT 1];
    return opp.AccountId;
  }

  private Boolean validate() {
    if (null == this.controller.getRecord() || null == this.controller.getRecord().Id) {
      appendMessage(ApexPages.Severity.ERROR, 'Need to specify the id of quote for creating subscription.');
      return false;
    }
    return true;
  }

  private static void appendMessage(ApexPages.Severity messageType, String message) {
    ApexPages.addMessage(new ApexPages.Message(messageType, message));
  }
  
  /**
  * Code coverage tests.
  */
  @isTest
  private static void pageControllerCodeCaverageTest() {
    final zqu__Quote__c masterQuote = TestDataSetup.getQuote();
    SendToZBillingPreviewController pageController = new SendToZBillingPreviewController(new ApexPages.StandardController(masterQuote));
    pageController.doSend();
  }
}