[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

<#
Download Teams modo installer (MSI)
https://learn.microsoft.com/pt-br/microsoftteams/msi-deployment
#>

<# Variable of the Configuration #>
$Config = @{
    Description = 'Teams'
    DriveRoot ='C:'
    FolderInstall = 'Tools'
    FileInstall = 'Teams_windows_x64-1.5.00.msi'
    FileArguments = ("/i c:\Tools\Teams_windows_x64-1.5.00.msi", "/quiet")
    RootKey = 'HKLM:\Software\ManutTools\Teams'
    KeyName = '1.5.00'
    UrlDownloadInstall = 'https://statics.teams.cdn.office.net/production-windows-x64/1.5.00.31168/Teams_windows_x64.msi'
    UrlDownloadRemoval = ''
}

Function DownloadFile( $ConfigApp ) {

        $Destination = $ConfigApp.DriveRoot + "\" + $ConfigApp.FolderInstall
        If( (Test-Path $Destination) -eq $false ) {
            New-Item -Path $Destination -ItemType Directory
        }

        $Destination += "\" + $ConfigApp.FileInstall
        If( (Test-Path $Destination) -eq $false ) {
            Write-Host "=> Iniciando o download do arquivo de instalacao."
            Invoke-WebRequest -Uri $ConfigApp.UrlDownloadInstall -OutFile $destination
        } Else {
            Write-Host "=> Arquivo de instalacao ja encontra-se na pasta - $Destination"
        }
}

Function VerifyKey( $Root, $Key ) {

    $DestinationKey = $Root + "\" + $Key

    If( Test-Path $DestinationKey ) {
        $result = Get-ItemProperty -Path $DestinationKey -Name $Key
        Return $true
    } Else {
        $result = New-Item -Path $DestinationKey -Force
        $result = New-ItemProperty -Path $DestinationKey -Name $Key -PropertyType DWORD -Value '0x1'
        Return $false
    }   
}

Function Install( $ConfigApp ) {

    If( (VerifyKey $ConfigApp.RootKey $ConfigApp.KeyName) -eq $false ) {

        Write-Host "=> Iniciando a instalacao" $ConfigApp.Description

        $Destination = $ConfigApp.DriveRoot + "\" + $ConfigApp.FolderInstall
        If( (Test-Path $Destination) -eq $false ) {
            New-Item -Path $Destination -ItemType Directory
        }

        $Destination += "\" + $ConfigApp.FileInstall
        If( (Test-Path $Destination) -eq $false ) {
            Write-Host "=> Iniciando o download do arquivo de instalacao."
            DownloadFile $ConfigApp.UrlDownloadInstall $Destination
        } Else {
            Write-Host "=> Arquivo de instalacao ja encontra-se na pasta - $Destination"
        }

        If( (Test-Path $Destination) -eq $true ) {
            
            Write-Host "=> Iniciando a instalacao em modo silencioso."
            Write-Host "=> Aguarde instalacao."
            
            Start-Process Msiexec.exe -ArgumentList $ConfigApp.FileArguments -Wait
            #Start-Process $Destination -ArgumentList $ConfigApp.FileArguments -Wait        
            #&$Destination $ConfigApp.FileArguments

            Write-Host "=> Download finalizado."
        }

    } Else {
        Write-Host "=>"$ConfigApp.Description"ja esta instalado."
    }
}


<# Verificar paramentros e executar o script #>
$command = $false

$log = $Config.DriveRoot +"\"+ $Config.FolderInstall +"\"+ $Config.Description +".txt"

Start-Transcript -Path $log -NoClobber -Append

ForEach( $parameter in $args ) {

    Switch( $parameter ){
        'install' { Install $Config; $command = $true }
        'download' { DownloadFile $Config; $command = $true }
    }
}

Stop-Transcript

If( $command -eq $false ) { Write-Host "Comando => .\TeamsTools.ps1 [ install | download ] " }

