#Requires -Modules @{ ModuleName="dbatools"; ModuleVersion="2.0.4" }

<#
    .SYNOPSIS
        Build a SQL Server database using Ergast Formula One CSV data.

    .DESCRIPTION
        Performs a backup of a specified type of 1 or more databases on a single SQL Server Instance. These backups may be Full, Differential or Transaction log backups.
        
    .PARAMETER sqlInstance
        The SQL Server instance hosting the databases to be backed up.

    .PARAMETER databaseName
        This is the name of the database you wish to create.

    .PARAMETER cleanInstance
        Removes the database from the instance once complete, this will only be processed if backupDatabase is true.

    .PARAMETER backupDatabase
        Performs a backup of the database

    .NOTES
        Tags: FormulaOne, F1, Database, Data.
        Author: Richard Howell, richinsql.com

        Website: https://richinsql.com
        Copyright: (c) 2022 by Rich In SQL, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://richinsql.com/projects/formula-one-database/

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName f1db -sqlInstance 'loclhost' -downloadFiles $true -cleanInstance $false

        This will perform a full database backup on the databases HR and Finance on SQL Server Instance Server1 to Server1 default backup directory.

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName f1db -sqlInstance 'loclhost' -downloadFiles $true -cleanInstance $true

        Backs up AdventureWorks2014 to sql2016 C:\temp folder.

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName f1db -sqlInstance 'loclhost' -downloadFiles $false -cleanInstance $true

        Performs a full backup of all databases on the sql2016 instance to their own containers under the https://dbatoolsaz.blob.core.windows.net/azbackups/ container on Azure blob storage using the sql credential "dbatoolscred" registered on the sql2016 instance.

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName f1db -sqlInstance 'loclhost' -downloadFiles $false -cleanInstance $false

        Performs a full backup of all databases on the sql2016 instance to the https://dbatoolsaz.blob.core.windows.net/azbackups/ container on Azure blob storage using the Shared Access Signature sql credential "https://dbatoolsaz.blob.core.windows.net/azbackups" registered on the sql2016 instance.
    #>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [System.String]
    $sqlInstance,
    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
    [System.String]
    $databaseName,
    [Parameter(Mandatory=$True, Position=2, ValueFromPipeline=$false)]
    [System.Boolean]
    $cleanInstance,
    [Parameter(Mandatory=$True, Position=3, ValueFromPipeline=$false)]
    [System.Boolean]
    $backupDatabase   
)

$sqlInstance = "localhost"
$databaseName = "f1db"

$currentYear = (Get-Date).Year.ToString()
$sqlVersion = Get-DbaBuildReference -SqlInstance $svr | Select-Object -ExpandProperty NameLevel

$races=@("Bahrain","Saudi Arabia","Australia","Azerbaijan","United States","Monaco","Spain","Canada","Austria","Great Britain","Hungary","Belgium","Italy","Belgium","Japan","Qatar","Austin","Mexico","Brazil","Las Vegas","Abu Dhabi")
$raceName = $races | Out-GridView -PassThru

$raceName = $raceName.Replace(' ','_')
$raceName += "_" + $currentYear

$rootpath = $PSScriptRoot

$sourceFiles = "\sourcefiles\"
$sourceFilesFullPath = $rootpath + $sourceFiles

$archiveFolder = "\archivedfiles\"
$archiveLocation = $rootpath + $archiveFolder
$archiveLocationDate = $archiveLocation + $raceName + "\"

$backupName = $sqlVersion + "_" + $databaseName + "_" + $raceName + ".bak"
$backupFolder = "\backups\"
$backupRaceFolder = $backupFolder + $raceName
$backupLocation = $rootpath + $backupRaceFolder
$backupFullPath = $backupLocation + "\" + $backupName

$sourceLocation = "https://ergast.com/downloads/f1db_csv.zip"

$zipName = 'f1db_csv_' + $raceName + '.zip'
$zipLocation = $rootpath + $sourceFiles 
$zipLocationFull = $zipLocation + $zipName

$replacementChar = "_"

$global:progressPreference = 'silentlyContinue'

if(-Not(Test-Path -Path $archiveLocation))
{
    $rootpath = 'D:\workspace\RichInF1'
} else 
{
    $rootpath = $PSScriptRoot
}

$csvRootPath = $rootpath + "\sourcefiles\"
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

$global:progressPreference = 'silentlyContinue'

if(-Not(Test-Path -Path $archiveLocation))
{
    Write-Host "INFO: Attempting to create the directory $archiveLocation" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $archiveLocation -Force -ErrorAction Stop
} else {
    Write-Host "ERROR: The directory $archiveLocation already exists" -ForegroundColor Gray
}

if(-Not(Test-Path -Path $backupLocation))
{
    Write-Host "INFO: Attempting to create the directory $backupLocation" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $backupLocation -Force -ErrorAction Stop
} else {
    Write-Host "ERROR: The directory $backupLocation already exists" -ForegroundColor Gray
}

if(-Not(Test-Path -Path $archiveLocationDate))
{
    Write-Host "INFO: Attempting to create the directory $archiveLocationDate" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $archiveLocationDate -Force -ErrorAction Stop
} else {
    Write-Host "The directory $archiveLocationDate already exists" -ForegroundColor Gray
}

if(-Not(Test-Path -Path $sourceFilesFullPath))
{
    Write-Host "INFO: Attempting to create the directory $sourceFilesFullPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $sourceFilesFullPath -Force -ErrorAction Stop
} else {
    Write-Host "INFO: The directory $sourceFilesFullPath already exists, skipping creation" -ForegroundColor Yellow
}

$existingFiles = Get-ChildItem -Path $sourceFilesFullPath -Filter *.csv -Recurse

foreach($fileName in $existingFiles)
{
    $file = [io.path]::GetFileNameWithoutExtension($fileName)
    $extension = [io.path]::GetExtension($fileName)
    $newName = $archiveLocationDate + $file + "_" + $raceName +  $extension
    Write-Host "INFO: Moving $filename to the archive" -ForegroundColor Yellow
    Move-Item -Path $filename -Destination $newName -Force
    
    if(Test-Path -Path $filename)
    {
        Write-Host "INFO: $filename archived, deleting" -ForegroundColor Yellow
        Remove-Item -Path $fileName -Force
    }
}

if($downloadFiles -eq $true)
{
    if(-Not(Test-Path $zipLocationFull))
    {
        Write-Host "INFO: Zip file $zipName does not exist" -ForegroundColor Yellow
        Write-Host "INFO: Attempting to download zip file from $sourceLocaiton to $ziplocation" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $sourceLocation -OutFile $zipLocationFull
    } else {
        Write-Host "INFO: Zip file $zipName already exists will not re-download" -ForegroundColor Yellow
    }
}

if(Test-Path $zipLocationFull -PathType Leaf)
{
    Write-Host "INFO: Attempting to extract files from $zipLocationFull into $sourceFilesFullPath" -ForegroundColor Yellow
    Expand-Archive $zipLocationFull -DestinationPath $sourceFilesFullPath    
} else {
    Write-Host "WARN: Zip file does not exist in $zipLocation" -ForegroundColor Red
    Exit 
}

$database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName

if($database)
{
    Write-Host "WARN: Database already exists $databaseName from" $sqlInstance -ForegroundColor Red
    Write-Host "INFO: Attempting to drop $databaseName from" $sqlInstance -ForegroundColor Yellow
    Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false
    Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
    New-DbaDatabase -SqlInstance $svr -Name $databaseName
    Write-Host "SUCESS: Database" $databaseName" created" -ForegroundColor Green
} else 
{
    Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
    New-DbaDatabase -SqlInstance $svr -Name $databaseName
    Write-Host "SUCESS: Database" $databaseName" created" -ForegroundColor Green
}

Write-Host "INFO: Getting all of the .csv files from" $sourceFilesFullPath -ForegroundColor Yellow
$files = Get-ChildItem $sourceFilesFullPath -Filter *.csv | Where-Object -FilterScript {$_.Name -match $replacementChar}

$allFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
$total = $allFiles | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "INFO: A total of" $total ".csv files were found" -ForegroundColor Yellow

#Rename the CSV Files to remove the underscores
foreach($file in $files)
{
    try {       

        Write-Host "INFO: Attempting to rename" $file "to match table name" $file.Name.Replace("_","")  -ForegroundColor Yellow
        Rename-Item -path $file -NewName $file.Name.Replace("_","") -Force
        Write-Host "INFO: Renamed" $file.Name "sucessfully to match table name" -ForegroundColor Green

    }
    catch {
        Write-Host "ERROR: Renaming" $file "failed The Error was: $_" -ForegroundColor Red
        Exit
    }
}

$allFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
$total = $files | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "INFO: A total of"$total" .csv files were found that need renaming." -ForegroundColor Yellow

foreach($renamedfile in $allFiles)
{
    try {
        $path = $sourceFilesFullPath + $renamedfile.Name
        Write-Host "INFO: Attempting to replace \N values with empty strings in" $path -ForegroundColor Yellow
        $result = Get-Content $path
        $result | ForEach-Object {$_-replace ('\\N'),''} | Set-Content $path
    }
    catch {
        Write-Host "ERROR: Replacing the \N values in" $path" failed" -ForegroundColor Red
        Exit
    }  
}

$database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName

if($database)
{
    Write-Host "INFO: Creating tables" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_tables.sql' -f $rootpath)
    #Pause the script for 20 seconds to make sure that the build database/table scripts has completed. 
    Start-Sleep -Seconds 20
    
    #Get all of the files again, do this now, as we renamed them earlier
    $files = Get-ChildItem $sourceFilesFullPath -Filter *.csv
    
    #Now we can attempt to import all of the CSV files 
    foreach($file in $files)
    {
        $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
        Write-Host "INFO: Attempting to import data into" $fileWithoutExtension "from" $file -ForegroundColor Yellow
        $filePath = $sourceFilesFullPath + $file.Name    
    
        Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -NoProgress -KeepIdentity
    }
} else {
    
    Write-Host "WARN: Creating tables not possible, $databaseName doesn't exist" -ForegroundColor Red
    Exit
}

#Once complete, add the keys to the tables
if($null -eq $database)
{
    Write-Host "INFO: Creating keys" -ForegroundColor Yellow
    Invoke-DbaQuery -SqlInstance $svr -File ('{0}\f1db_foreign_keys.sql' -f $rootpath)
} 

if(Test-Path -Path $backupFullPath)
{
    Write-Host "WARN: Database backup already exists, removing" -ForegroundColor Red
    Remove-Item -Path $backupFullPath
}

Backup-DbaDatabase -SqlInstance $svr -Database $databaseName -Path $backupLocation -FilePath $backupName -Type Full 
Write-Host "INFO: Database backup has been completed" -ForegroundColor Yellow
Write-Host "SUCCESS: Database backup has been completed" -ForegroundColor Green

Write-Host "SUCCESS: Database build complete" -ForegroundColor Green

if($cleanInstance -eq $True -and $backupDatabase -eq $True)
{
    Write-Host "INFO: Dropping database $databaseName from $sqlInstance" -ForegroundColor Yellow
    Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false 
} else {
    Write-Host "WARN: $databaseName not dropped as database is not set to backup"
}