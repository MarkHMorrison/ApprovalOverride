/**
 * @description Tests for OverrideApprovalExtension class
 * @author Mark H. Morrison
 * @date Friday Mar 01 2019
 */
@isTest
private class OverrideApprovalExtensionTest {

  @testSetup
  static void setup(){
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;
    System.assertNotEquals(null, testAccount.Id);

    // Create Opportunity with propper settings to allow for Approval process conditions
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = testAccount.Id,
      StageName = 'Pending',
      CloseDate = System.today().addDays(5),
      Discount_Percentage__c = 50
    );
    insert testOpportunity;
    System.assertNotEquals(null, testOpportunity.Id);

    // Test requires that there is an active Approval process on Opportunity
    // Create an approval request for the Opportunity
    Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitrequest();
    submitRequest.setObjectId(testOpportunity.Id);
    // Submit the ProcessSubmitRequest and get a result
    Approval.ProcessResult result = Approval.process(submitRequest);
    // Verify that the results are as expected
    System.assert(result.isSuccess());
    System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status' + result.getInstanceStatus());
    // Verify that we have a Workitem
    System.assert([
        SELECT Id FROM ProcessInstanceWorkitem 
        WHERE ProcessInstance.TargetObjectId = :testOpportunity.Id
      ].size() == 1
    );
  }

  @isTest
  static void testOverrideApprovalExtension() {
    Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];

    Test.startTest();
      // Setup page with Opportunity data
      ApexPages.CurrentPage().getparameters().put('id', opportunity.Id);     
      Apexpages.StandardController standardController = new Apexpages.StandardController(opportunity);
      OverrideApprovalExtension overrideApprovalExtension = new OverrideApprovalExtension(standardController);
      // Now call the method
      overrideApprovalExtension.overrideApproval();
    Test.stopTest();

    System.assert([
        SELECT Id FROM ProcessInstanceWorkitem 
        WHERE ProcessInstance.TargetObjectId = :opportunity.Id
      ].size() == 0
    );
  }
}
