# audit.ps1
# Script PowerShell pour auditer les licences M365

# Connexion à Microsoft 365
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Récupération des utilisateurs
$users = Get-MgUser -All

# Initialisation des résultats
$results = @()

foreach ($user in $users) {
    $licenses = Get-MgUserLicenseDetail -UserId $user.Id
    foreach ($license in $licenses) {
        $results += [PSCustomObject]@{
            UserPrincipalName = $user.UserPrincipalName
            DisplayName = $user.DisplayName
            SkuPartNumber = $license.SkuPartNumber
            EnabledServices = ($license.ServicePlans | Where-Object {$_.ProvisioningStatus -eq "Success"}).ServicePlanName -join ", "
            DisabledServices = ($license.ServicePlans | Where-Object {$_.ProvisioningStatus -ne "Success"}).ServicePlanName -join ", "
        }
    }
}

# Export vers CSV
$results | Export-Csv -Path "LicenseAudit.csv" -NoTypeInformation

# Export vers HTML
$results | ConvertTo-Html | Out-File "LicenseAudit.html"
