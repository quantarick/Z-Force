@isTest
private class CustomProductSelectorControllerTest {

  @isTest
  private static void negativeTest() {
    CustomProductSelectorController con;
    con = new CustomProductSelectorController(new ApexPages.StandardController(new zqu__Quote__c()));
    System.assert(Apexpages.hasMessages());
  }

  @isTest
  private static void selectProduct() {

    zqu__ZProduct__c product = TestDataSetup.prepareProductCatalog();
    Id productId = product.Id;

    Account acct = new Account(Name = 'TestAccount');
    insert acct;
    Opportunity oppty = new Opportunity(Name = 'TestOppty', AccountId = acct.Id, StageName = 'Prospect', CloseDate = Date.parse('12/8/2013'));
    insert oppty;
    zqu__Quote__c quote = new zqu__Quote__c(Name = 'TestQuote', zqu__Opportunity__c = oppty.Id, zqu__Currency__c = 'USD', zqu__StartDate__c = Date.today());
    insert quote;

    CustomProductSelectorController con = new CustomProductSelectorController(new ApexPages.StandardController(quote));

    System.assert(con.selectedProductShare != null && con.selectedProductShare.dataObject == null);
    System.assert(con.selectedRatePlanShare != null && con.selectedRatePlanShare.dataObject == null);

    zqu.ZComponentDataShare productShare = new zqu.zComponentDataShare();
    zqu.ZComponentDataShare ratePlanShare = new zqu.zComponentDataShare();

    List < zqu__ProductRatePlan__c > ratePlans = [SELECT id FROM zqu__ProductRatePlan__c WHERE zqu__zProduct__c = : productId LIMIT 1];
    zqu__ProductRatePlan__c ratePlan = ratePlans.get(0);

    productShare.dataObject = String.valueOf(productId);
    ratePlanShare.dataObject = String.valueOf(ratePlan.Id);

    con.selectedProductShare = productShare;
    con.selectedRatePlanShare = ratePlanShare;

    System.assertEquals(true, con.getIsRenderChargeGroup());
    System.assertEquals(false, con.getNoMatchProduct());
    System.assertEquals('/' + quote.Id, con.navigateBack().getUrl());

    con.addNewChargeGroupToQuote();

    con.currentChargeGroupId = con.chargeGroup.groupId;

    con.editChargeGroup();
    System.assert(true == con.editMode);

    con.saveChargeGroup();

    con.deleteChargeGroup();

    con.cancelEditing();
    System.assert(false == con.editMode);

    System.assertEquals(true, con.getIsRenderRatePlan());

    con.toSelectNewProductsView();
    System.assert(con.selectedProductShare.dataObject == null);
    System.assert(con.selectedRatePlanShare.dataObject == null);

    con.searchString = 'random search';
    con.refreshProducts();
    System.assert(true, con.getNoMatchProduct());
  }
}