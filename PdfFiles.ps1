

#Global
 $iTextSharp = @{
    package = @{
        name = 'iTextSharp'       
        version = '5.5.13.1'
        location = 'https://globalcdn.nuget.org/packages/itextsharp.5.5.13.1.nupkg?packageVersion=5.5.13.1'
        dll = $env:windir + '\System32\itextsharp.dll'
        dependency  = @(
            'BouncyCastle.Cryptography'
        )
        provider  = @{
            name = 'NuGet'
            location = 'https://www.nuget.org/api/v2'
        }
    }
}

#Register Packages iTextSharp and dependency
Function Register-iTextSharp {
    [alias('Register-PDF')]
    [CmdletBinding()]
    param()

    #Registrar Provedor
    If ((Get-PackageSource -ProviderName $iTextSharp.package.provider.name -Name MyNuGet).length -le 0 ) {
        try { Register-PackageSource -Name MyNuGet -Location $iTextSharp.package.provider.location -ProviderName $iTextSharp.package.provider.name -Trusted } catch { }
    }

    
    #Find-Package BouncyCastle.Cryptography
    foreach( $dependency in $iTextSharp.package.dependency ) {
        If ((Get-Package -ProviderName $iTextSharp.package.provider.name -Name $dependency ).length -le 0 ) {
            try { Install-Package $dependency } catch { }
        }
    }

    #Find-Package iTextSharp -AllVersions
    If ((Get-Package -ProviderName $iTextSharp.package.provider.name -Name $iTextSharp.package.name ).length -le 0 ) {
        try { Install-Package $iTextSharp.package.name -RequiredVersion $iTextSharp.package.version } catch { }
    }

    Return $true

}

#Install iTextSharp DLL
Function Install-iTextSharpDll {

    If( -not (Test-Path $iTextSharp.package.dll) ) {

        $location = Get-Location
        try { 
            If( -not (Test-Path ".\temp") ) {
                New-Item -Name "temp" -Path ".\" -ItemType directory }
            }
        catch {  }
        Set-Location ".\temp"

        $filenupkg = ".\" + $iTextSharp.package.name
        $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36"

        $result_session = Invoke-WebRequest -UseBasicParsing -Uri $iTextSharp.package.location `
        -WebSession $session `
        -Headers @{
        "Referer"="https://www.nuget.org/"
          "Upgrade-Insecure-Requests"="1"
          "sec-ch-ua"="`"Not(A:Brand`";v=`"99`", `"Google Chrome`";v=`"133`", `"Chromium`";v=`"133`""
          "sec-ch-ua-mobile"="?0"
          "sec-ch-ua-platform"="`"Windows`""
        } `
        -OutFile $filenupkg

        Rename-Item -Path $filenupkg -NewName "$filenupkg.zip"
        Expand-ZIPFile -file "$filenupkg.zip" -destination "."

        If( Test-Path ".\lib\itextsharp.dll" ) {

            Move-Item ".\lib\itextsharp.dll" -Destination $iTextSharp.package.dll -Force

        }

        Set-Location $location
        Remove-item -Path ".\temp" -Force -Recurse
    }

    Return $true

}

#Remove iTextSharp DLL
Function Remove-iTextSharpDll {

    If( Test-Path $iTextSharp.package.dll ) {
        Remove-Item $iTextSharp.package.dll  -Force
    }

    Return $true

}



#Function de Convert

Function Convert-PDFtoText {
	param(
		[Parameter(Mandatory=$true)][string]$in_file,
        [Parameter(Mandatory=$false)][string]$out_file = "out.txt"
	)

    $null =  Install-iTextSharpDll

    Add-Type -Path $iTextSharp.package.dll
	
	$pdf = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList $in_file

    $text = New-Object -TypeName System.Collections.ArrayList
    #$arrlist = [System.Collections.Arraylist]@("PowerShell", "Azure")

	for ($page = 1; $page -le $pdf.NumberOfPages; $page++){

		try { $aux_text=[iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($pdf,$page) } catch { }      

		$text.Add($aux_text)

	}	
	$pdf.Close()

    $text > $out_file

    Return $text
}

Function Extract-Text {

    param(
		[Parameter(Mandatory=$true)][string]$in_file,
        [Parameter(Mandatory=$true)][string]$begin,
        [Parameter(Mandatory=$true)][string]$end,
        [Parameter(Mandatory=$false)][string]$id,
        [Parameter(Mandatory=$false)][string]$out_file = "out_ext.txt"
	)

    Extract-Json -in_file $in_file -begin $begin -end $end -id $id -out_file $out_file -txt True

}

Function Extract-Json {

    param(
		[Parameter(Mandatory=$true)][string]$in_file,
        [Parameter(Mandatory=$true)][string]$begin,
        [Parameter(Mandatory=$true)][string]$end,
        [Parameter(Mandatory=$false)][string]$id = "All",
        [Parameter(Mandatory=$false)][string]$out_file = "out_ext.txt",
        [Parameter(Mandatory=$false)][string]$txt = $false
	)

    If( $id -eq "" ) { $id -eq "All"}

    $result = $false

    $json = New-Object -TypeName System.Collections.ArrayList
    $text = New-Object -TypeName System.Collections.ArrayList

    $id_key = 0

    Get-Content $in_file | ForEach-Object {

        if ($_ -eq $begin) {
            $result = $true
        }
        if ($_ -eq $end) {
            $result = $false
        }

        $aux_text = ("$_").Trim()

        if ($result -and ($aux_text.Contains($id) -or ($id -eq "All") ) ) {
            
            If( ($id -eq "All") ) {

                If ($aux_text -ne $begin) {

                    $a = @{ id = $id_key
                            key = $aux_text.Substring(0,10)
                            value = $aux_text.Substring(11, $aux_text.length-11) 
                    }

                    $b = $json.Add($a)
                    $b = $text.Add($aux_text)

                    $id_key++
                }

            } Else {

                    $b = $text.Add($aux_text)

                    $x = $aux_text -split " "
                   
                    ForEach( $i in $x ) {
                                         
                        If( $i -ne $id ) {

                            $a = @{ id = $id_key
                                    key = $i
                                    value = ""
                            }

                            $b = $json.Add($a)
                            

                            $id_key++

                        }
                    }
            }

        }
    }
   
    If( $txt -eq $true ) {

        $text > $outfile

        Return $text

    } Else {

        $aux_json = ConvertTo-Json $json

        $aux_json > $out_file

        Return $aux_json
    }

}

Function Merge-PDF {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][Object[]] $in_files,
        [Parameter(Mandatory=$true)][string] $out_folder,
        [Parameter(Mandatory=$false)][string] $out_file = "out_merge.pdf"
    )

    $i = $outfolder.count-1
    If( $out_folder[$i] -ne "\" ) { $out_folder+="\" }

    $test = $out_folder + $out_file

    $pdfs = New-Object -TypeName System.Collections.ArrayList

    ForEach( $file in $in_files ) {
    
        If( $file -eq $test ) { 
            $null = Remove-Item $file -force
        } Else {
           $null = $pdfs.Add($file)
        }
    }

    $null = Install-iTextSharpDll

    Add-Type -Path $iTextSharp.package.dll

    $output = [System.IO.Path]::Combine($out_folder, "$out_file");
    $fileStream = New-Object System.IO.FileStream($output, [System.IO.FileMode]::OpenOrCreate);
    $document = New-Object iTextSharp.text.Document;
    $pdfCopy = New-Object iTextSharp.text.pdf.PdfCopy($document, $fileStream);
    $document.Open();

    foreach ($pdf in $pdfs) {
        $reader = New-Object iTextSharp.text.pdf.PdfReader($pdf);
        $null = $pdfCopy.AddDocument($reader);
        $reader.Dispose();  
    }

    $pdfCopy.Dispose();
    $document.Dispose();
    $fileStream.Dispose();

}


<# Test 

Register-iTextSharp
Install-iTextSharpDll
Remove-iTextSharpDll
Unregister-iTextSharp
Merge-PDF @((Get-ChildItem *.pdf | Sort-Object -Descending ).FullName ) -out_folder "C:\tools\demo\" -out_file out_file.pdf
Convert-PDFToText -in_file "c:\tools\teste 1.pdf"
Extract-Text -in_file "C:\Tools\out.txt" -begin "TITULO 2" -end "…." -id "###"
Extract-Text -in_file "C:\Tools\out.txt" -begin "TITULO 1" -end "…."

Extract-Json -in_file "C:\Tools\out.txt" -begin "TITULO 2" -end "…." -id "###"
Extract-Json -in_file "C:\Tools\out.txt" -begin "TITULO 1" -end "…."

#>

