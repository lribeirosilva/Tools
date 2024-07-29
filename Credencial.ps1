
$Credential = Get-Credential

$Credential.Username

$ClearTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password))

Write-Host $ClearTextPassword

