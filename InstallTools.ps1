
get-date

Write-Host "Instalar Modulos de Programas"

$Modules = Get-ChildItem * | Where-Object { ($_.Extension -eq ".ps1")  -and ( $_.Name -ne "DownloadTools.ps1" ) -and ( $_.Name -ne "InstallTools.ps1" ) }

$command = $false

ForEach( $Module in $Modules ) {

    $command = $true 

    Write-Host "`nModulo:" $Module.Name "encontrado."
    Write-Host "Iniciando o download do programa."

    $Destination = "powershell.exe" 
    $Argument = ($Module.FullName, "download")

    Start-Process -FilePath $Destination -ArgumentList $Argument -Wait         
    #&$Destination $ConfigApp.FileArguments

}

ForEach( $Module in $Modules ) {

    $command = $true 

    Write-Host "`nModulo:" $Module.Name "encontrado."
    Write-Host "Iniciando a instalacao do programa."

    $Destination = "powershell.exe" 
    $Argument = ($Module.FullName, "install")

    Start-Process -FilePath $Destination -ArgumentList $Argument -Wait         
    #&$Destination $ConfigApp.FileArguments

}

If( $command -eq $false ) {

    Write-Host "Nao encontrado Modulos de Programas"

} Else {

    Write-Host "Encerrando a Instalacao dos Programas"

}

get-date