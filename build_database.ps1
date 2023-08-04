[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$false)]
    [System.String]
    $databaseName,
    [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
    [System.String]
    $sqlInstance,
    [Parameter(Mandatory=$True, Position=2, ValueFromPipeline=$false)]
    [System.Boolean]
    $downloadFiles   
)

$raceName = Read-Host -Prompt "Please tell me the name of this race E.G. Silverstone 2023"
$raceName = $raceName.Replace(' ','_')

$runDate = (Get-Date).Date.ToString("yyyy-MM-dd")
$rootpath = $PSScriptRoot

$sourceFiles = "\sourcefiles\"
$sourceFilesFullPath = $rootpath + $sourceFiles

$archiveFolder = "\archivedfiles\"
$archiveLocation = $rootpath + $archiveFolder
$archiveLocationDate = $archiveLocation + $runDate + "\"

$backupName = $databaseName + "_" + $raceName + "_" + $runDate + ".bak"
$backupFolder = "\backups\"
$backupLocation = $rootpath + $backupFolder

$sourceLocation = "https://ergast.com/downloads/f1db_csv.zip"

$zipName = 'f1db_csv_' + $runDate + '.zip'
$zipLocation = $rootpath + $sourceFiles 
$zipLocationFull = $zipLocation + $zipName

$replacementChar = "_"

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

$existingFiles = Get-ChildItem -Path $sourceFilesFullPath -Recurse

foreach($fileName in $existingFiles)
{
    $file = [io.path]::GetFileNameWithoutExtension($fileName)
    $extension = [io.path]::GetExtension($fileName)
    $newName = $archiveLocationDate + $file + "_" + $raceName + "_" + $runDate + $extension
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
    Write-Host "INFO: Attempting to download zip file from $sourceLocaiton to $ziplocation" -ForegroundColor Yellow
    Invoke-WebRequest -Uri $sourceLocation -OutFile $zipLocationFull
}

if(Test-Path $zipLocationFull -PathType Leaf)
{
    Write-Host "INFO: Attempting to extract files from $zipLocationFull into $sourceFilesFullPath" -ForegroundColor Yellow
    Expand-Archive $zipLocationFull -DestinationPath $sourceFilesFullPath
    Write-Host "INFO: Deleting $zipLocationFull" -ForegroundColor Yellow
    Remove-Item $zipLocationFull -Force
} else {
    Write-Host "WARN: Zip file does not exist in $zipLocation" -ForegroundColor Red
    Exit 
}

$svr = Connect-dbaInstance -SqlInstance $sqlInstance
$database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName

if($null -ne $database)
{
    Write-Host "INFO: Atempting to open a connection to $sqlInstance ..." -ForegroundColor Yellow
    Write-Host "WARN: Database already exists $databaseName from" $sqlInstance -ForegroundColor Red
    Write-Host "INFO: Attempting to drop $databaseName from" $sqlInstance -ForegroundColor Yellow
    Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false
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

if($null -ne $database)
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

Write-Host "SUCCESS: Database build has been completed" -ForegroundColor Green

Backup-DbaDatabase -SqlInstance $svr -Database $databaseName -Path $backupLocation -FilePath $backupName -CompressBackup -Type Full