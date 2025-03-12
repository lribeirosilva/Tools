

Function DownloadVideoUrl {

	param(
		[Parameter(Mandatory=$true)][string]$url,
        [Parameter(Mandatory=$false)][string]$file_name = "out"
	)


    If( -not (Test-Path "C:\YTcutter") ) { New-Item -ItemType Directory -Path "C:\" -Name "YTcutter" }

    $local = Get-Location
    
    Set-Location "C:\YTcutter"

    winget install "yt-dlp"
    winget install "FFmpeg (Essentials Build)"

    #&yt-dlp.exe $url -o 20250312SVAOdYb.webm
    Start-Process yt-dlp.exe -ArgumentList "$url -o 20250312SVAOdYb.webm" -Wait
    #&ffmpeg.exe -ss 3.5 -t 26.5 -i 20250312SVAOdYb.webm -y -c copy $file_name.mp4
    Start-Process ffmpeg.exe -ArgumentList "-ss 3.5 -t 26.5 -i 20250312SVAOdYb.webm -y -c copy $file_name.mp4 -y" -Wait
    del 20250312SVAOdYb.webm

    If( Test-Path "$file_name.mp4" ) { "Download File: C:\YTcutter\$file_name.mp4" } Else { "Not Download File" }

    Set-Location $local

}

Function CutVideo {

	param(
		[Parameter(Mandatory=$true)][string]$file,
        [Parameter(Mandatory=$true)][string]$start,
        [Parameter(Mandatory=$true)][string]$cut,
        [Parameter(Mandatory=$false)][boolean]$audio = $true,
        [Parameter(Mandatory=$false)][boolean]$only_audio = $false,
        [Parameter(Mandatory=$false)][string]$file_out = "out_cut.mp4"

	)

    #Format $start e $cut = hh:mm:ss.dd

    If( -not (Test-Path $file) ) { 
        "Not Found File..."
        Return
    }

    $local = Get-Location

    Set-Location (Get-ChildItem $file).DirectoryName

    If( $audio ) {

        $argument = "-i $file -ss $start -t $cut -c copy $file_out -y"
        $aux_file = $file_out.Replace(".mp4",".mp3")
        $argument_audio = "-i $file_out -map 0:a -vn -acodec mp3 $aux_file -y"

    } Else {

        $argument = "-i $file -ss $start -t $cut -an $file_out -y"
        $argument_audio = "No"
        
    }

    Start-Process ffmpeg.exe -ArgumentList $argument -Wait

    If( $only_audio ) {

        "Aguardando criação de arquivo de saída"
        While ( -not (Test-Path $file_out) ) { }

        Start-Process ffmpeg.exe -ArgumentList $argument_audio -Wait

    }

    Set-Location $local

}

<#

DownloadVideoUrl https://youtu.be/OdYbYSVAB3g?feature=shared -file_name chico_science

CutVideo -file "C:\ytcutter\out.mp4" -start "3.5" -cut "30" -file_out "out_cut.mp4"
CutVideo -file "C:\ytcutter\out.mp4" -start "3.5" -cut "30" -file_out "out_cut.mp4" -only_audio 1

#>

