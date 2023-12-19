[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

<# Variable of the Configuration #>
$Config = @{
    Description = 'PDF24'
    DriveRoot ='C:'
    FolderInstall = 'Tools'
    FileInstall = 'pdf24-creator-11.9.1.msi'
    FileArguments = ("/i c:\Tools\pdf24-creator-11.9.1.msi", "/quiet")
    RootKey = 'HKLM:\Software\ManutTools\PDF24'
    KeyName = '11.8.0'
    UrlDownloadInstall = 'https://download3.pdf24.org/pdf24-creator-11.9.1.msi'
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
            #Write-Host "=> Iniciando o download do arquivo de instalacao."
            DownloadFile $ConfigApp
        } Else {
            Write-Host "=> Arquivo de instalacao ja encontra-se na pasta - $Destination"
        }

        If( (Test-Path $Destination) -eq $true ) {
            Write-Host "=> Iniciando a instalacao em modo silencioso."
            Write-Host "=> Aguarde instalacao."
            
            Start-Process Msiexec.exe -ArgumentList $ConfigApp.FileArguments -Wait        
            #&$Destination $ConfigApp.FileArguments

            Write-Host "=> Instalacao finalizada."
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

If( $command -eq $false ) { Write-Host "Comando => .\PDF24Tools.ps1 [ install | download ] " }

