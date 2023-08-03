[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [System.String]
    $databaseName,
    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
    [System.String]
    $sqlInstance,
    [Parameter(Mandatory=$True, Position=2, ValueFromPipeline=$false)]
    [System.String]
    $downloadFiles   
)


$sqlInstance = "localhost"
$databaseName = "f1db"

$testing = 0

if($testing -eq 1)
{
    $rootpath = 'D:\workspace\RichInF1'
} else 
{
    $rootpath = $PSScriptRoot
}

$sourceLocation = 'https://ergast.com/downloads/f1db_csv.zip'
$csvRootPath = $rootpath + "\sourcefiles\"

if($downloadFiles -eq $True)
{
    Write-Host "Attempting to download latest zip file $sourceLocation to $csvRootPath" -ForegroundColor Yellow
    Invoke-WebRequest -Uri $sourceLocation -OutFile $csvRootPath
}

$sqlInstance = "localhost"
$databaseName = "f1db"

$testing = 0

if($testing -eq 1)
{
    $rootpath = 'D:\workspace\RichInF1'
} else 
{
    $rootpath = $PSScriptRoot
}
$csvRootPath = $rootpath + "\sourcefiles\"
$replacementChar = "_"
$zipLocation = $rootpath + '\f1db_csv.zip'
$global:progressPreference = 'silentlyContinue'

if(-Not(Test-Path -Path $csvRootPath))
{
    Write-Host "Attempting to create the directory $csvRootPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $ -Force -ErrorAction Stop
} else {
    Write-Host "The directory $csvRootPath already exists" -ForegroundColor Red
}

Write-Host "Removing an existing files from the source file location" -ForegroundColor Yellow
Get-ChildItem $csvRootPath | Remove-Item -Recurse -Force

Write-Host "Attemptint to download zip file to $ziplocation" -ForegroundColor Yellow
Invoke-WebRequest -Uri https://ergast.com/downloads/f1db_csv.zip -OutFile $zipLocation

Write-Host "Attempting to extract files from $ziplocation into $csvRootPath" -ForegroundColor Yellow
Expand-Archive $zipLocation -DestinationPath $csvRootPath

Write-Host "Deleting $ziplocation" -ForegroundColor Yellow
Remove-Item $zipLocation -Force

Write-Host "Atempting to open a connection to" $sqlInstance" ..." -ForegroundColor Yellow
$svr = Connect-dbaInstance -SqlInstance $sqlInstance

Write-Host "Attempting to drop" $databaseName" from" $sqlInstance -ForegroundColor Yellow
Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false

Write-Host "Getting all of the .csv files from" $csvRootPath -ForegroundColor Yellow
$files = Get-ChildItem $csvRootPath -Filter *.csv | Where-Object -FilterScript {$_.Name -match $replacementChar}

$total = $allFiles | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "A total of" $total ".csv files were found" -ForegroundColor Yellow

#Rename the CSV Files to remove the underscores
foreach($file in $files)
{
    try {       

        Write-Host "Attempting to rename" $file "to match table name" $file.Name.Replace("_","")  -ForegroundColor Yellow
        Rename-Item -path $file -NewName $file.Name.Replace("_","") -Force
        Write-Host "Renamed" $file.Name "sucessfully to match table name" -ForegroundColor Green

    }
    catch {
        Write-Host "Renaming" $file "failed The Error was: $_" -ForegroundColor Red
    }
}

$total = $files | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "A total of"$total" .csv files were found that need renaming." -ForegroundColor Yellow

$allFiles = Get-ChildItem $csvRootPath -Filter *.csv

foreach($renamedfile in $allFiles)
{
    try {
        $path = $csvRootPath + $renamedfile.Name
        Write-Host "Attempting to replace \N values with empty strings in" $path -ForegroundColor Yellow
        $result = Get-Content $path
        $result | ForEach-Object {$_-replace ('\\N'),''} | Set-Content $path
    }
    catch {
        Write-Host "Replacing the \N values in" $path" failed" -ForegroundColor Red
    }  
}

#Check if the database exists
$dbExists = Get-DbaDatabase -SqlInstance $svr -Database $databaseName | Select-Object -Property Name

#If the database doesn't exist and it shouldn't, as we dropped it at the top, create it. 
if($null -eq $dbExists)
{
    Write-Host "Database" $databaseName" doesn't exist attempting to create" -ForegroundColor Yellow
    New-DbaDatabase -SqlInstance $svr -Name $databaseName
    Write-Host "Database" $databaseName" created" -ForegroundColor Green
    
    Write-Host "Creating tables" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_tables.sql' -f $rootpath)

}

#Pause the script for 20 seconds to make sure that the build database/table scripts has completed. 
Start-Sleep -Seconds 20

#Get all of the files again, do this now, as we renamed them earlier

$files = Get-ChildItem $csvRootPath -Filter *.csv

#Now we can attempt to import all of the CSV files 
foreach($file in $files)
{
    $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
    Write-Host "Attempting to import data into" $fileWithoutExtension "from" $file -ForegroundColor Yellow
    $filePath = $csvRootPath + $file.Name    

    Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -NoProgress -KeepIdentity
}

#Once complete, add the keys to the tables
if($null -eq $dbExists)
{
    Write-Host "Creating keys" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_foreign_keys.sql' -f $rootpath)
}