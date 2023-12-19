
$inicio = Get-Date

Write-Host $inicio

Write-Host "Download dos Modulos de Programas"

$Modules = Get-ChildItem * | Where-Object { ($_.Extension -eq ".ps1") -and ( $_.Name -ne "DownloadTools.ps1" ) -and ( $_.Name -ne "InstallTools.ps1" ) }

$command = $false

ForEach( $Module in $Modules ) {

    $command = $true 

    Write-Host "`nModulo:" $Module.Name "encontrado."
    Write-Host "Iniciando o download do programa."

    #$Destination = "powershell.exe" 
    #$Argument = ($Module.FullName, "download")

    Start-Job -Name $Module.Name -FilePath $Module.FullName -ArgumentList "download"
    #Start-Process -FilePath $Destination -ArgumentList $Argument         
    #&$Destination $ConfigApp.FileArguments

}

If( $command -eq $false ) {

    Write-Host "Nao encontrado Modulos de Programas"

} Else {

    $running = $true

    While( $running ) {

        $job = Get-Job | Select-object Name, State

        Clear

        Write-Host "Status de Download"

        $job | FT

        Start-Sleep -Seconds 5

        If( $job.state.Contains("Running") -eq $true ) {

            $running = $true

        } Else {

            $running = $false

        }
    
    }

    Remove-Job *

}

Write-Host "Encerrando a Download dos Programas"

$fim = Get-Date

Write-Host  "`nInicio:" $inicio
Write-Host  "`nFim:" $fim
Write-Host  "`n"
