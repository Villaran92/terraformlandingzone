Connect-AzAccount -Identity
$subscriptionId = (Get-AzContext).Subscription.Id
Write-Output "Using Subscription: $subscriptionId"
Set-AzContext -SubscriptionId $subscriptionId


$policyAssignments = Get-AzPolicyAssignment

foreach ($policyAssignment in $policyAssignments) {
    $policyAssignmentId = $policyAssignment.ResourceId
    
    # Generate a unique remediation name with date and time
    $timestamp = Get-Date -Format "yyyyMMddHHmmss" # Format: YYYYMMDDHHMMSS
    $remediationName = "remediation_$timestamp"
    
    # Start the remediation
    Start-AzPolicyRemediation -PolicyAssignmentId $policyAssignmentId -Name $remediationName
    
    # Log the action
    Write-Output "Started remediation with Name: $remediationName for PolicyAssignmentId: $policyAssignmentId"
}