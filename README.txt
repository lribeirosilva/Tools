1-Para executar os scripts é necessário que esteja na janela 
do powershell 5(powershell padrão windows) como Administrador

2-Habilitar execução de script comando:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

OBS: Na pergunta selecionar SIM

3-Criar a pasta em Temp (C:\Temp) e copiar os scripts desejados para essa pasta.

4-No powershell acessar a pasta C:\Temp onde foram copiados os scripts, comando:
Set-Location C:\Temp

5-Executar os scripts conforme necessidade. Exemplo:
7zipTools.ps1

NOTAS: 
- Os scripts sofrem alterações com frequência, por exemplo no link para download das instalações,
logo mensamente sofre alterações.

- Os scripts DownloadTools.ps1 e InstallTools.ps1 auxiliam na instalação em massa.
Eles verificam os scripts na pasta C:\Temp e faz o download e instalação respectivamente dos
programas.

