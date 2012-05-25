public with sharing class ProductBundleController {

  static final String BASE_SOQL = 'SELECT Id, Name FROM Product_Bundle__c'; 
  
  private ApexPages.StandardController stdController;
  private zqu__Quote__c quote;
  public String selectedBundle {
    get {
    	if ( this.selectedBundle == null ) {
    		List<Product_Bundle__c> bundles = Database.query( BASE_SOQL + ' LIMIT 1 '); 
    		if (bundles != null && bundles.size() == 1) {
    			this.selectedBundle = (String) bundles.get(0).get('Id'); 
    		}
    	}
    	return this.selectedBundle;
    }
    set;
  }
  
  public ProductBundleController(ApexPages.StandardController stdController) {
    this.stdController = stdController;
    this.quote = (zqu__Quote__c) stdController.getRecord();
  }

  public List < SelectOption > getAvailableBundles() {
    List < SObject > bundles = Database.query(BASE_SOQL);

    List < SelectOption > options = new List < SelectOption > ();

    for (SObject sobj: bundles) {
      SelectOption option = new SelectOption((String) sobj.get('Id'), (String) sobj.get('Name'));
      options.add(option);
    }
    return options;
  }

  public PageReference selectBundle() {
    PageReference pageRef = null;
    try {
      addRatePlansToQuote();
      pageRef = new PageReference('/' + this.quote.Id);
    } catch (Exception e) {
      ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while adding Rate Plans in Product Bundle: ' + e.getMessage());
      ApexPages.addMessage(msg);
      return null;
    }
    return pageRef;
  }

  public PageReference cancel() {
    return new PageReference('/' + this.quote.Id);
  }

  private List < Id > getRatePlanIds() {
    List < Id > ratePlanIds = new List < Id > ();
    List < Product_Bundle_RatePlan__c > ratePlans = [SELECT Product_Rate_Plan__c FROM Product_Bundle_RatePlan__c WHERE Product_Bundle__c = :selectedBundle ORDER BY Name ASC];
    for (Product_Bundle_RatePlan__c ratePlan: ratePlans) {
      ratePlanIds.add(ratePlan.Product_Rate_Plan__c);
    }
    return ratePlanIds;
  }
  
  public PageReference onchangeBundle() {
  	return null;
  }

  private void addRatePlansToQuote() {
    List < Id > ratePlanIds = getRatePlanIds();
    for (Id ratePlanId: ratePlanIds) {
      zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(this.quote.Id, ratePlanId);
      if (chargeGroup != null) {
        List < zqu.zCharge > charges = chargeGroup.zCharges;
        if (charges != null && charges.size() > 0) {
          zqu.zQuoteUtil.addChargeGroup(chargeGroup);
        }
      }
    }
  }
  
  public Boolean bundleSelected { get {
  	  return this.selectedBundle != null; 
    }
    protected set;
  }
  
  public List<Product_Bundle_RatePlan__c> getRatePlans() {
  	return [SELECT Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__EffectiveStartDateTEXT__c, Product_Rate_Plan__r.zqu__EffectiveEndDateTEXT__c, Product_Rate_Plan__r.zqu__ZProduct__c FROM Product_Bundle_RatePlan__c WHERE Product_Bundle__c = :selectedBundle ORDER BY Name ASC];
  }
}