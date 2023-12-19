[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

<# Variable of the Configuration #>
$Config = @{
    Description = 'Kaspersky'
    DriveRoot ='C:'
    FolderInstall = 'Tools'
    FileInstall = 'KESW-11.10.0.399.exe'
    FileInstallArguments = ("-s")
    RootKey = 'HKLM:\Software\ManutTools\Kaspersky'
    KeyName = '11.10.0.399'
    FolderManut = "${env:ProgramFiles(x86)}\Kaspersky Lab\KES.11.10.0"
    FileManut = "avp.com"
    FileManutExitPolicyArguments = ('exitpolicy','/login=KLAdmin','/password=FortSecure')
    FileManutStartPolicyArguments = ('startpolicy')
    FileManutUpdateArguments = ('update') 
    FileManutScanArguments = ('scan','/memory','/startup')
    FolderSync = "${env:ProgramFiles(x86)}\Kaspersky Lab\NetworkAgent"
    FileSync = "klnagchk.exe"
    FileSyncArguments = ('-sendhb')
    FileRemoval = 'KVRT.exe'
    FileRemovalScanArguments = ("-accepteula","-allvolumes","-processlevel 1","-silent","-adinsilent","-details")   
    UrlDownloadInstall = ''
    UrlDownloadUninstall = 'https://media.kaspersky.com/utilities/ConsumerUtilities/kavremvr.exe'
    UrlDownloadRemoval = 'https://devbuilds.s.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe'
}

Function DownloadFile( $ConfigApp, $removal ) {

        $Destination = $ConfigApp.DriveRoot + "\" + $ConfigApp.FolderInstall
        If( (Test-Path $Destination) -eq $false ) {
            New-Item -Path $Destination -ItemType Directory
        }

        If( $removal -eq $true ) {

            $Destination += "\" + $ConfigApp.FileRemoval
        
        } Else {
        
            $Destination += "\" + $ConfigApp.FileInstall
        
        }
        If( (Test-Path $Destination) -eq $false ) {
            Write-Host "=> Iniciando o download do arquivo de instalacao."

            If( $removal -eq $true ) {

                Invoke-WebRequest -Uri $ConfigApp.UrlDownloadRemoval -OutFile $destination

            } Else{

                Invoke-WebRequest -Uri $ConfigApp.UrlDownloadInstall -OutFile $destination

            }
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
            DownloadFile $ConfigApp $Destination
        } Else {
            Write-Host "=> Arquivo de instalacao ja encontra-se na pasta - $Destination"
        }

        If( (Test-Path $Destination) -eq $true ) {
            Write-Host "=> Iniciando a instalacao em modo silencioso."
            Write-Host "=> Aguarde instalacao."
            
            Start-Process -FilePath $Destination -ArgumentList $ConfigApp.FileInstallArguments -Wait         
            #&$Destination $ConfigApp.FileInstallArguments

            Write-Host "=> Instalacao finalizada."
        }

    } Else {
        Write-Host "=>"$ConfigApp.Description"ja esta instalado."
    }
}

Function Manut( $ConfigApp ) {

    Write-Host "=> Manutencao Kaspersky."

    $Destination = $ConfigApp.FolderManut + "\" + $ConfigApp.FileManut
    
    If( (Test-Path $Destination) ) {
    
        Write-Host "=> Desativando a politica."
        Start-Process -FilePath $Destination -ArgumentList $ConfigApp.FileManutExitPolicyArguments -Wait         
        #&$Destination $ConfigApp.FileManutExitPolicyArguments 

        Write-Host "=> Atualizando Base de dados Kasperksy."
        Start-Process -FilePath $Destination -ArgumentList $ConfigApp.FileManutUpdateArguments -Wait         
        #&$Destination $ConfigApp.FileManutUpdateArguments 

        Write-Host "=> Escaneando Kasperksy."
        Start-Process -FilePath $Destination -ArgumentList $ConfigApp.FileManutScanArguments -Wait         
        #&$Destination $ConfigApp.FileManutUpdateArguments 

        Write-Host "=> Reativando a politica."
        Start-Process -FilePath $Destination -ArgumentList $ConfigApp.FileManutStartPolicyArguments -Wait         
        #&$Destination $ConfigApp.FileManutUpdateArguments  
        
        Write-Host "=> Manutencao finalizada."      
       
    } Else {

        Write-Host "=> Kaspersky não esta instalado."

    }

}

Function Sync( $ConfigApp ) {

    Write-Host "=> Sincronismo Kaspersky."

    $Destination = $ConfigApp.FolderSync + "\" + $ConfigApp.FileSync
    
    If( (Test-Path $Destination) ) {
    
        Write-Host "=> Forçando Sincronismo."
        Start-Process -FilePath $Destination -ArgumentList $ConfigApp.FileSyncArguments -Wait         
        #&$Destination $ConfigApp.FileManutUpdateArguments        
       
        Write-Host "=> Sincronismo finalizado."

    } Else {

        Write-Host "=> Kaspersky não esta instalado."

    }

}

Function Removal( $ConfigApp ) {

        $Destination = $ConfigApp.DriveRoot + "\" + $ConfigApp.FolderInstall
        If( (Test-Path $Destination) -eq $false ) {
            New-Item -Path $Destination -ItemType Directory
        }

        $Destination += "\" + $ConfigApp.FileRemoval
        If( (Test-Path $Destination) -eq $false ) {
            #Write-Host "=> Iniciando o download do arquivo de instalacao."
            DownloadFile $ConfigApp $true #.UrlDownloadRemoval $Destination
        } Else {
            Write-Host "=> Arquivo de instalacao ja encontra-se na pasta - $Destination"
        }

        
        If( (Test-Path $Destination) -eq $true ) {

            Write-Host "=> Gerando script do KVRT."
            $Script = $Destination + ".bat"
            $Destination + " " + $ConfigApp.FileRemovalScanArguments | Set-content -Path $Script -force

            Write-Host "=> Inicializando o KVRT."
            Start-Process -FilePath $Script -Wait     
            #&$Destination $ConfigApp.FileRemovalScanArguments

            Write-Host "=> Aplicação do KVRT finalizada."
        }
        
}


<# Verificar paramentros e executar o script #>
$command = $false

$log = $Config.DriveRoot +"\"+ $Config.FolderInstall +"\"+ $Config.Description +".txt"

Start-Transcript -Path $log -NoClobber -Append

ForEach( $parameter in $args ) {

    Switch( $parameter ){
        'install' { Install $Config; $command = $true }
        'manut' { Manut $Config; $command = $true }
        'sync' { Sync $Config; $command = $true }
        'removal' { Removal $Config; $command = $true }
        'download' { DownloadFile $Config; $command = $true }
    }
}

Stop-Transcript

If( $command -eq $false ) { Write-Host "Comando => .\KasperskyTools.ps1 [ install | manut | sync | removal | download ] " }

