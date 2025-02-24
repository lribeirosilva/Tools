
#Global
 $WebScraping = @{
    package = @{
        name = 'WebScraping'       
        version = '133.0.6943.126'
        testing = 'https://googlechromelabs.github.io/chrome-for-testing/'
        location = (Get-InstalledModule -Name Selenium).installedlocation 
        dependency  = @()
        provider  = @{
            name = 'PSGallery'
            location = 'https://www.powershellgallery.com/api/v2'
        }
    }
}

https://storage.googleapis.com/chrome-for-testing-public/135.0.7023.0/win64/chrome-win64.zip
https://storage.googleapis.com/chrome-for-testing-public/135.0.7023.0/win64/chromedriver-win64.zip

Import-Module Selenium
remove-module selenium

Add-Type -Path $FullPath + './assemblies/WebDriver.dll'
Add-Type -Path $FullPath + './assemblies/WebDriver.Support.dll'


# import Selenium and its types
$FullPath = (Get-InstalledModule -Name Selenium).installedlocation
Import-Module "${FullPath}\Selenium.psd1"
Remove-Module selenium

# start a driver in headless mode and visit
# the target page
$Driver = Start-SeChrome
Enter-SeUrl "https://scrapingclub.com/exercise/list_infinite_scroll/" -Driver $Driver

# where to store the scraped data
$Products = New-Object Collections.Generic.List[PSCustomObject]

# get all HTML products on the page
$HTMLProducts = Find-SeElement -Driver $Driver -CssSelector ".post"

# iterate over the list of HTML product elements
# and scrape data from them
foreach ($HTMLProduct in $HTMLProducts) {
  $NameElement = $HTMLProduct.FindElement([OpenQA.Selenium.By]::CssSelector("h4"))
  $PriceElement = $HTMLProduct.FindElement([OpenQA.Selenium.By]::CssSelector("h5"))
  $Name = $NameElement.Text
  $Price = $PriceElement.Text

  # create an object containing the scraped
  # data and add it to the list
  $Product = [PSCustomObject] @{
    "Name"  = $Name
    "Price" = $Price
  }
  $Products.Add($Product)
}

# log the scraped data
$Products

# close the browser and release its resources
Stop-SeDriver -Driver $Driver

