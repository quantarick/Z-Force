public with sharing class SubscriptionChargeUpdateController {

  public Zuora__Subscription__c subscriptionForUpdate {
    get;
    set;
  }
  static Zuora.zApi zapiInstance = new Zuora.zApi();

  private List < Zuora__SubscriptionProductCharge__c > charges;
  private Map < String, Zuora__Subscription__c > subscriptions = new Map < String, Zuora__Subscription__c > ();

  public SubscriptionChargeUpdateController() {
    subscriptionForUpdate = new Zuora__Subscription__c(Name = 'For Update Only');
  }

  public PageReference updateCharges() {
    zApiInstance.zLogin();
    updateServiceActivationDate();
    updateTerm();
    return null;
  }

  private void updateServiceActivationDate() {
    List < Zuora.zObject > zCharges = new List < Zuora.zObject > ();

    for (Zuora__SubscriptionProductCharge__c charge: this.charges) {
      Zuora.zObject zCharge = new Zuora.zObject('RatePlanCharge');
      zCharge.setValue('Id', charge.Zuora__External_Id__c);
      zCharge.setValue('TriggerEvent', 'SpecificDate');
      zCharge.setValue('TriggerDate', Zuora.zUtil.getZuoraDate(this.subscriptionForUpdate.Zuora__ServiceActivationDate__c));
      zCharges.add(zCharge);
    }
    try {
      List < Zuora.zApi.SaveResult > results = zapiInstance.zUpdate(zCharges);

      for (Zuora.zApi.SaveResult result: results) {
        if (result.success) {
          continue;
        }
        Zuora.zObject[] errors = result.errors;
        for (Zuora.zObject error: errors) {
          String errorCode = (String) error.getValue('Code');
          String message = (String) error.getValue('Message');
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while updating charge: ' + message);
          ApexPages.addMessage(msg);
        }
      }
    } catch (Exception e) {
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while updating charges: ' + e.getMessage());
      ApexPages.addMessage(msg);
    } finally {
      System.debug('logger = ' + Zuora.zApi.currentLogger.toString());
    }
  }

  private void updateTerm() {
    List < Zuora.zObject > amends = new List < Zuora.zObject > ();

    for (String subId: subscriptions.keySet()) {
      Zuora__Subscription__c sub = subscriptions.get(subId);
      Zuora.zObject amend = new Zuora.zObject('Amendment');
      amend.setValue('Name', 'Update term');
      amend.setValue('SubscriptionId', subId);
      amend.setValue('EffectiveDate', Zuora.zUtil.getZuoraDate(System.today()));
      //amend.setValue( 'Status', 'Completed' );
      amend.setValue('Type', 'TermsAndConditions');
      amend.setValue('InitialTerm', this.subscriptionForUpdate.Zuora__InitialTerm__c);
      if (sub.Zuora__RenewalTerm__c != null && sub.Zuora__RenewalTerm__c != '') {
        sub.Zuora__RenewalTerm__c = sub.Zuora__RenewalTerm__c.substring(0, sub.Zuora__RenewalTerm__c.indexOf(' Months'));
      }
      amend.setValue('RenewalTerm', sub.Zuora__RenewalTerm__c);
      amend.setValue('TermStartDate', Zuora.zUtil.getZuoraDate(sub.Zuora__TermStartDate__c));
      amend.setValue('ContractEffectiveDate', Zuora.zUtil.getZuoraDate(sub.Zuora__ContractEffectiveDate__c));
      amend.setValue('ServiceActivationDate', Zuora.zUtil.getZuoraDate(sub.Zuora__ServiceActivationDate__c));
      amend.setValue('CustomerAcceptanceDate', Zuora.zUtil.getZuoraDate(sub.Zuora__ContractAcceptanceDate__c));
      amends.add(amend);
    }

    try {
      List < Zuora.zApi.SaveResult > results = zapiInstance.zCreate(amends);

      for (Zuora.zApi.SaveResult result: results) {
        if (result.success) {
          continue;
        }
        Zuora.zObject[] errors = result.errors;
        for (Zuora.zObject error: errors) {
          String errorCode = (String) error.getValue('Code');
          String message = (String) error.getValue('Message');
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while creating Terms and Conditions amendment: ' + message);
          ApexPages.addMessage(msg);
        }
      }
    } catch (Exception e) {
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while creating Terms and Conditions amendment: ' + e.getMessage());
      ApexPages.addMessage(msg);
    } finally {
      System.debug('logger = ' + Zuora.zApi.currentLogger.toString());
    }
  }

  public List < Zuora__SubscriptionProductCharge__c > getSubscriptionCharges() {
    if (this.charges == null) {
      this.charges = [
        SELECT Id, Zuora__External_Id__c, Zuora__Subscription__c, 
               Zuora__Subscription__r.Zuora__RenewalTerm__c, Zuora__Subscription__r.Zuora__TermStartDate__c, 
               Zuora__Subscription__r.Zuora__ContractEffectiveDate__c, Zuora__Subscription__r.Zuora__ServiceActivationDate__c, 
               Zuora__Subscription__r.Zuora__ContractAcceptanceDate__c, Zuora__Subscription__r.Zuora__External_Id__c, 
               Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c, Name, Zuora__Type__c, Zuora__Model__c, Zuora__Price__c, Zuora__UOM__c, Zuora__BillingPeriod__c
      FROM Zuora__SubscriptionProductCharge__c
      ORDER BY Zuora__Subscription__c];
    }
    for (Zuora__SubscriptionProductCharge__c charge: this.charges) {
      Zuora__Subscription__c sub = (Zuora__Subscription__c) charge.getSObject('Zuora__Subscription__r');
      this.subscriptions.put(charge.Zuora__Subscription__r.Zuora__External_Id__c, sub);
    }
    return this.charges;
  }
}