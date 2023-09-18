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
        PS C:\> .\build_database.ps1 -databaseName SequelFormula -sqlInstance 'loclhost' -downloadFiles $true -cleanInstance $false

        This will perform a full database backup on the databases HR and Finance on SQL Server Instance Server1 to Server1 default backup directory.

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName SequelFormula -sqlInstance 'loclhost' -downloadFiles $true -cleanInstance $true

        Backs up AdventureWorks2014 to sql2016 C:\temp folder.

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName SequelFormula -sqlInstance 'loclhost' -downloadFiles $false -cleanInstance $true

        Performs a full backup of all databases on the sql2016 instance to their own containers under the https://dbatoolsaz.blob.core.windows.net/azbackups/ container on Azure blob storage using the sql credential "dbatoolscred" registered on the sql2016 instance.

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName SequelFormula -sqlInstance 'loclhost' -downloadFiles $false -cleanInstance $false

        Performs a full backup of all databases on the sql2016 instance to the https://dbatoolsaz.blob.core.windows.net/azbackups/ container on Azure blob storage using the Shared Access Signature sql credential "https://dbatoolsaz.blob.core.windows.net/azbackups" registered on the sql2016 instance.
    #>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string[]]
    $sqlInstance,
    [Parameter(Mandatory = $True, Position = 1, ValueFromPipeline = $false)]
    [System.String]
    $databaseName,
    [Parameter(Mandatory = $True, Position = 2, ValueFromPipeline = $false)]
    [System.Boolean]
    $cleanInstance,
    [Parameter(Mandatory = $True, Position = 3, ValueFromPipeline = $false)]
    [System.Boolean]
    $backupDatabase,
    [Parameter(Mandatory = $True, Position = 4, ValueFromPipeline = $false)]
    [System.Boolean]
    $downloadZip
    )
    
$global:progressPreference = 'silentlyContinue'

$todayDate = (Get-Date).Date

$currentYear = (Get-Date).Year.ToString()
$rootpath = $PSScriptRoot
    
$races = @("Bahrain", "Saudi Arabia", "Australia", "Azerbaijan", "United States", "Monaco", "Spain", "Canada", "Austria", "Great Britain", "Hungary", "Belgium", "Italy", "Netherlands", "Japan", "Qatar", "Austin", "Mexico", "Brazil", "Las Vegas", "Abu Dhabi")
$raceName = $races | Out-GridView -PassThru

$jsonData = $rootpath + "\src\raceCalendar.json"
$raceCalendar = $jsonData | ConvertFrom-Json

foreach ($race in $raceCalendar.Formula1RaceCalendar) {
    $raceName = $race.RaceName
    $raceDate = [DateTime]::ParseExact($race.Date, "yyyy-MM-dd", $null)   
}
    
$raceName = $raceName.Replace(' ', '_')
$raceName += "_" + $currentYear
    
$sourceFiles = "\src\sourceFiles\"
$sourceFilesFullPath = $rootpath + $sourceFiles

$supplementaryData = $rootpath + "\src\supplementarydata"

$archiveFolder = "\src\sourceFiles\archivedfiles\"
$archiveLocation = $rootpath + $archiveFolder
$archiveLocationDate = $archiveLocation + $raceName + "\"

$sourceLocation = "https://ergast.com/downloads/f1db_csv.zip"
    
$zipName = 'SequelFormula_csv_' + $raceName + '.zip'
$zipLocation = $rootpath + $sourceFiles 
$zipLocationFull = $zipLocation + $zipName

$replacementChar = "_"

if (-Not(Test-Path $zipLocationFull) -and $downloadZip -eq $true) {
    Write-Host "INFO: Zip file $zipName does not exist" -ForegroundColor Yellow
    Write-Host "INFO: Attempting to download zip file from $sourceLocaiton to $ziplocation" -ForegroundColor Yellow
    Invoke-WebRequest -Uri $sourceLocation -OutFile $zipLocationFull
}
else {
    Write-Host "INFO: Zip file $zipName already exists will not re-download" -ForegroundColor Yellow
} 

if (Test-Path $zipLocationFull -PathType Leaf) {
    Write-Host "INFO: Attempting to extract files from $zipLocationFull into $sourceFilesFullPath" -ForegroundColor Yellow
    Expand-Archive $zipLocationFull -DestinationPath $sourceFilesFullPath -Force    
}
else {
    Write-Host "ERROR: Zip file does not exist in $zipLocation" -ForegroundColor Red
    Exit 
}
    
Write-Host "INFO: Getting all of the .csv files from" $sourceFilesFullPath -ForegroundColor Yellow
$files = Get-ChildItem $sourceFilesFullPath -Filter *.csv | Where-Object -FilterScript { $_.Name -match $replacementChar }
    
$allFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
$total = $allFiles | Measure-Object | ForEach-Object { $_.Count }  
    
Write-Host "INFO: A total of" $total ".csv files were found" -ForegroundColor Yellow
    
foreach ($file in $files) {
    try {     
            
        Write-Host "INFO: Attempting to rename" $file "to match table name" $file.Name.Replace("_", "")  -ForegroundColor Yellow
        Rename-Item -path $file -NewName $file.Name.Replace("_", "") -Force
        Write-Host "SUCCESS: Renamed" $file.Name "sucessfully to match table name" -ForegroundColor Green
    
    }
    catch {
        Write-Host "ERROR: Renaming" $file "failed The Error was: $_" -ForegroundColor Red
        Exit
    }
}

$allFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
$total = $files | Measure-Object | ForEach-Object { $_.Count }  
    
Write-Host "INFO: A total of $total .csv files were found that need \N values removing." -ForegroundColor Yellow
    
foreach ($renamedfile in $allFiles) {
    try {
        $path = $sourceFilesFullPath + $renamedfile.Name
        Write-Host "INFO: Attempting to replace \N values with empty strings in" $path -ForegroundColor Yellow
        $result = Get-Content $path
        $result | ForEach-Object { $_ -replace ('\\N'), '' } | Set-Content $path
    }
    catch {
        Write-Host "ERROR: Replacing the \N values in" $path" failed" -ForegroundColor Red
        Exit
    }  
} 
    
if (-Not(Test-Path -Path $archiveLocation)) {
    Write-Host "INFO: Attempting to create the directory $archiveLocation" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $archiveLocation -Force -ErrorAction Stop
}
else {
    Write-Host "WARN: The directory $archiveLocation already exists" -ForegroundColor Magenta
}
    
if (-Not(Test-Path -Path $archiveLocationDate)) {
    Write-Host "INFO: Attempting to create the directory $archiveLocationDate" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $archiveLocationDate -Force -ErrorAction Stop
}
else {
    Write-Host "WARN: The directory $archiveLocationDate already exists" -ForegroundColor Magenta
}

if (-Not(Test-Path -Path $sourceFilesFullPath)) {
    Write-Host "INFO: Attempting to create the directory $sourceFilesFullPath" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $sourceFilesFullPath -Force -ErrorAction Stop
}
else {
    Write-Host "WARN: The directory $sourceFilesFullPath already exists, skipping creation" -ForegroundColor Magenta
}

$existingFiles = Get-ChildItem -Path $sourceFilesFullPath -Filter *.csv

foreach ($instance in $sqlInstance) {
    
    Write-Host "INFO: Atempting to open a connection to $instance ..." -ForegroundColor Yellow
    $svr = Connect-dbaInstance -SqlInstance $instance
        
    $version = Get-DbaBuildReference -SqlInstance $svr | Select-Object -ExpandProperty NameLevel        
        
    $backupName = $version + "_" + $databaseName + "_" + $raceName + ".bak"
    $backupFolder = "\backups\"
    $backupCompressName = $version + "_" + $databaseName + "_" + $raceName + '.7zip'
    $backupLocation = $rootpath + $backupFolder + $raceName + "\"
    $backupFullPath = $backupLocation + $backupName          
        
    if (-Not(Test-Path -Path $backupLocation)) {
        Write-Host "INFO: Attempting to create the directory $backupLocation" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $backupLocation -Force -ErrorAction Stop
    }
    else {
        Write-Host "WARN: The directory $backupLocation already exists" -ForegroundColor Magenta
    }       
        
    $database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName
        
    if ($database) {
        Write-Host "WARN: Database already exists $databaseName from" $instance -ForegroundColor Magenta
        Write-Host "INFO: Attempting to drop $databaseName from" $instance -ForegroundColor Yellow
        Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false
        Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
        New-DbaDatabase -SqlInstance $svr -Name $databaseName
        Write-Host "SUCCESS: Database" $databaseName" created" -ForegroundColor Green
    }
    else {
        Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
        New-DbaDatabase -SqlInstance $svr -Name $databaseName
        Write-Host "SUCCESS: Database" $databaseName" created" -ForegroundColor Green
    }
        
    $database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName
        
    if ($database) {

        $tableFolder = "\src\tables\"
        $tableLocation = $rootpath + $tableFolder
        $tableFiles = Get-ChildItem $tableLocation -Filter *.sql

        if($tableFiles.Length -gt 0)
        {
            foreach ($tableFile in $tableFiles) {
    
                try {                
                    Write-Host "INFO: Attempting to create $tableFile" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $tableFile                
                }
                catch {
                    Write-Host "ERROR: Creating $tableFile" -ForegroundColor Red
                    Exit
                }
            }
        } else {
            Write-Host "WARN: No files exist in $tableLocation" -ForegroundColor Magenta
            Exit
        }

            
        #Get all of the files again, do this now, as we renamed them earlier
        $files = Get-ChildItem $sourceFilesFullPath -Filter *.csv
            
        #Now we can attempt to import all of the CSV files 
        foreach ($file in $files) {

            $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
            
            try {                
                Write-Host "INFO: Attempting to import data into" $fileWithoutExtension "from" $file -ForegroundColor Yellow
                $filePath = $sourceFilesFullPath + $file.Name    
                Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -NoProgress -KeepIdentity  
            }
            catch {
                Write-Host "ERROR: Importing data into" $fileWithoutExtension "from" $file -ForegroundColor Red
                Exit
            }
        }
    }
    else {
                
        Write-Host "WARN: Creating tables not possible, $databaseName doesn't exist" -ForegroundColor Magenta
        Exit
    }

    if($database)
    {
        $primaryKeyFolder = "\src\constraints\primaryKeys\"
        $primaryKeyLocation = $rootpath + $primaryKeyFolder
        $primaryKeyFiles = Get-ChildItem $primaryKeyLocation -Filter *.sql

        if($primaryKeyFiles.Length -gt 0)
        {
            foreach ($primaryKeyFile in $primaryKeyFiles) {
                Write-Host "INFO: Attempting to apply $primaryKeyFile" -ForegroundColor Yellow
                try {                
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $primaryKeyFile                
                }
                catch {
                    Write-Host "ERROR: Applying $primaryKeyFile" -ForegroundColor Red
                    Exit
                }
            }
        } else {
            Write-Host "WARN: No files exist in $primaryKeyFolder" -ForegroundColor Magenta
        }
    } else {
        Write-Host "ERROR: $database does not exist, cannot proceed" -ForegroundColor Red
        Exit
    }

    if ($supplementaryData) {
        
        $supplementaryDataFiles = Get-ChildItem -Path $supplementaryData -Filter *.csv  

        if($supplementaryData.Length -gt 0)
        {
            foreach ($supplementaryDataFile in $supplementaryDataFiles) {
                $supplementaryDataWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($supplementaryDataFile)
                
                try {                    
                    Write-Host "INFO: Attempting to import data from " $supplementaryDataFile.FullName " into " $supplementaryDataWithoutExtension -ForegroundColor Yellow
                    Import-DbaCsv -Path $supplementaryDataFile.FullName -SqlInstance $svr -Database $databaseName -Table $supplementaryDataWithoutExtension -Delimiter "," -NoProgress
                }
                catch {
                    Write-Host "ERROR: Error applying $supplementaryDataFile" -ForegroundColor Red
                }
            }            
        }
        else {
            Write-Host "WARN: No files exist in $supplementaryData" -ForegroundColor Magenta
        }            
    } else {
        Write-Host "ERROR: Supplementary data folder does not exist" -ForegroundColor Red
    }

    if ($database) {
        $dataQualityFolder = "\src\dataQuality\"
        $dataQualityLocation = $rootpath + $dataQualityFolder
        $dataQualityFiles = Get-ChildItem $dataQualityLocation -Filter *.sql

        if($dataQualityFiles.Length -gt 0)
        {
            foreach ($dataQualityFile in $dataQualityFiles) {
    
                try {                
                    Write-Host "INFO: Attempting to apply $dataQualityFile" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $dataQualityFile
                }
                catch {
                    Write-Host "ERROR: Error applying $dataQualityFile" -ForegroundColor Red
                    Exit
                }
            }
        } else {
            Write-Host "INFO: No files exist in $supplementaryData" -ForegroundColor Yellow
        }
    } 

    if ($database) {

        Write-Host "INFO: Performing Data Updates" -ForegroundColor Yellow

        try {
            Write-Host "INFO: Performing positionText Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\positionText.sql' -f $rootPath)
        }
        catch {
            Exit
        }

        try {            
            Write-Host "INFO: Performing drivers Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\drivers.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {
            Write-Host "INFO: Performing constructors Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\constructors.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {         
            Write-Host "INFO: Performing results Data Updates" -ForegroundColor Yellow   
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\results.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {            
            Write-Host "INFO: Performing sprintResults Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\sprintResults.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {            
            Write-Host "INFO: Performing resultsNew Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\resultsNew.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {
            Write-Host "INFO: Performing tempCircuits Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\tempCircuits.sql' -f $rootPath)
        }
        catch {
            Exit
        }

        try {            
            Write-Host "INFO: Performing circuits Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\circuits.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {            
            Write-Host "INFO: Performing circuitMap Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\circuitMap.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {            
            Write-Host "INFO: Performing constructorResults Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\constructorResults.sql' -f $rootpath)
        }
        catch {
            Exit
        }
        
        try {            
            Write-Host "INFO: Performing driverStandings Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\driverStandings.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {
            Write-Host "INFO: Performing constructorStandings Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\constructorStandings.sql' -f $rootpath)            
        }
        catch {
            Exit
        }

        try {
            Write-Host "INFO: Performing pitStops Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\pitStops.sql' -f $rootpath)            
        }
        catch {
            Exit
        }

        try {
            Write-Host "INFO: Performing qualifying Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\qualifying.sql' -f $rootpath)            
        }
        catch {
            Exit
        }

        try {   
            Write-Host "INFO: Performing lapTimes Data Updates" -ForegroundColor Yellow         
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\lapTimes.sql' -f $rootpath)
        }
        catch {
            Exit
        }

        try {   
            Write-Host "INFO: Performing lapTimes Data Updates" -ForegroundColor Yellow         
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\dataUpdates\resultDriverConstructor.sql' -f $rootpath)
        }
        catch {
            Exit
        }
    } 
    
    Write-Host "INFO: Removing redundant tables" -ForegroundColor Yellow
    Remove-DbaDbTable -SqlInstance $svr -Table 'results','sprintResults','tempCircuits' -Confirm:$false

    Write-Host "INFO: Renaming resultsNew to results" -ForegroundColor Yellow     
    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -Query "EXEC sp_rename 'resultsnew', 'results';"

    Write-Host "INFO: Renaming PK_resultsNew_resultId to PK_results_resultId" -ForegroundColor Yellow     
    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -Query "EXEC sp_rename N'dbo.PK_resultsNew_resultId', N'PK_results_resultId', N'OBJECT'"

    if ($database) {

        Write-Host "INFO: Creating foreign keys" -ForegroundColor Yellow

        $foreignKeyFolder = "\src\constraints\foreignKeys\"
        $foreignKeyLocation = $rootpath + $foreignKeyFolder
        $foreignKeyFiles = Get-ChildItem $foreignKeyLocation -Filter *.sql

        foreach ($foreignKeyFile in $foreignKeyFiles) {

            try {
                Write-Host "INFO: Attempting to apply $foreignKeyFile" -ForegroundColor Yellow
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $foreignKeyFile
            }
            catch {
                Write-Host "ERROR: Applying $foreignKeyFile" -ForegroundColor Red
                Exit
            }
        }
    } 
        
    if ($backupDatabase -eq $True) {

        Write-Host "INFO: backupDatabase is set to true, attempting backup routine." -ForegroundColor Yellow
        
        if (Test-Path -Path $backupFullPath) {
            Write-Host "WARN: Database backup already exists, removing" -ForegroundColor Magenta
            Remove-Item -Path $backupFullPath
        } 
        
        try {            
            Write-Host "INFO: Attempting to create a database backup." -ForegroundColor Yellow
            Backup-DbaDatabase -SqlInstance $svr -Database $databaseName -Path $backupLocation -FilePath $backupName -Type Full 
        }
        catch {
            Write-Host "ERROR: Creating database backup." -ForegroundColor Red
            Exit
        }

        try {
            #https://github.com/thoemmi/7Zip4Powershell 
            $compressedPath = $backupLocation + $backupCompressName
            Write-Host "INFO: Attempting to 7zip the backup" -ForegroundColor Yellow
            Compress-7Zip -Path $backupLocation -Filter *.bak -ArchiveFileName $compressedPath -CompressionLevel Ultra                
            Write-Host "INFO: Compressed backup sucessfully"              
            Remove-Item -Path $backupFullPath -Force
        }
        catch {
            Write-Host "ERROR: Compressing backup failed" -ForegroundColor Red
            Exit
        }

        Write-Host "SUCCESS: Database backup has been completed." -ForegroundColor Green

    }
    else {
        Write-Host "WARN: No backup has been taken as backupDatabase is set to False." -ForegroundColor Magenta
    }        
        
    if ($cleanInstance -eq $True -and $backupDatabase -eq $True) {
        Write-Host "INFO: Dropping database $databaseName from $instance" -ForegroundColor Yellow
        Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false 
    }
    else {
        Write-Host "WARN: $databaseName not dropped as database is not set to backup" -ForegroundColor Magenta
    }
}

foreach ($fileName in $existingFiles) {
    $file = [io.path]::GetFileNameWithoutExtension($fileName)
    $extension = [io.path]::GetExtension($fileName)
    $newName = $archiveLocationDate + $file + "_" + $raceName + $extension
    Write-Host "INFO: Moving $filename to the archive" -ForegroundColor Yellow
    Move-Item -Path $filename -Destination $newName -Force
    
    if (Test-Path -Path $filename) {
        Write-Host "INFO: $filename archived, deleting" -ForegroundColor Yellow
        Remove-Item -Path $fileName -Force
    }
}

Write-Host "SUCCESS: Database build complete on $instance" -ForegroundColor Green