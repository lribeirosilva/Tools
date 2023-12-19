[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

<# Variable of the Configuration #>
$Config = @{
    Description = 'TeamViewer'
    DriveRoot ='C:'
    FolderInstall = 'Tools'
    FileInstall = 'TeamViewerQS.exe'
    FileArguments = ("--install", "--start-with-win", "--create-shortcuts", "--create-desktop-icon", "--silent")
    RootKey = 'HKLM:\Software\ManutTools\TeamViewer'
    KeyName = '15.36.9'
    UrlDownloadInstall = 'https://dl.teamviewer.com/download/TeamViewerQS.exe'
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
            
            #Start-Process $Destination -ArgumentList $ConfigApp.FileArguments -Wait        
            #&$Destination $ConfigApp.FileArguments
            $obj = New-Object -ComObject WScript.Shell
            $link = $obj.CreateShortcut( $env:USERPROFILE + '\Desktop\' + $ConfigApp.Description + '.lnk')
            $link.targetPath = $Destination
            $link.save()

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

If( $command -eq $false ) { Write-Host "Comando => .\TeamViewerTools.ps1 [ install | download ] " }

