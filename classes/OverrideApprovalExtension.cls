/**
 * @description Extension for OverrideApproval visualforce page
 * @author Mark H. Morrison
 * @date Fri Mar 01 2019
 */
public class OverrideApprovalExtension {
  public Id recordId { get; set; }

  // Constructor to get the Opportunity Id
  public OverrideApprovalExtension(ApexPages.StandardController controller) {
    recordId = (Id)controller.getRecord().Id;
  }

  // Method called from the Visual Force page action attribute
  public PageReference overrideApproval() {
    // Do this until you don't find any ProcessWorkitems
    while(
      [
        SELECT Id FROM ProcessInstanceWorkitem
        WHERE ProcessInstance.TargetObjectId = :recordId
      ].size() > 0
    ) {
      //Get the Workitem Id
      Id workitemId = [
        SELECT Id FROM ProcessInstanceWorkitem
        WHERE ProcessInstance.TargetObjectId = :recordId
      ].Id;
      // Create a WorkitemRequest and set variables
      Approval.ProcessWorkitemRequest workitemRequest = new Approval.ProcessWorkitemRequest();
      // Set Comment
      workitemRequest.setComments('Bob\'s override approval');
      // Set Action to Approve
      workitemRequest.setAction('Approve');
      // Set Workitem Id
      workitemRequest.setWorkitemId(workitemId);
      // Process the WorkitemRequest
      Approval.ProcessResult result = Approval.process(workitemRequest);
    }
    // Set a PageReference so we can redirect back to the record page
    PageReference pageRef = new PageReference('/' + recordId);
    pageRef.setRedirect(true);
    // Return to the opportunity page
    return pageRef; 
  }
}
