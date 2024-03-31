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
        Author: Richard Howell, sequelformula.com

        Website: https://sequelformula.com
        Copyright: (c) 2022 by Sequel Formula, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://sequelformula.com/projects/formula-one-database/

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName SequelFormulaDevTest -sqlInstance localhost -cleanInstance $false -backupDatabase $false -fileLocation "D:\Sequel Formula\Sequel-Formula-Files" -schemaLocation "D:\Sequel Formula\Sequel-Formula-Database" -round 3

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
        [System.String]
        $schemaLocation,
        [Parameter(Mandatory = $True, Position = 4, ValueFromPipeline = $false)]
        [System.String]
        $fileLocation,
        [Parameter(Mandatory = $True, Position = 5, ValueFromPipeline = $false)]
        [System.Int32]
        $round
        )
        
    $global:progressPreference = 'silentlyContinue' 

    $currentYear = (Get-Date).Year.ToString()
    $rootpath = $PSScriptRoot
    
    Write-Host "INFO: Using $fileLocation" -ForegroundColor Yellow

    $jsonData = -join($fileLocation,"\raceCalendar.json")

    Write-Host "INFO: Using $jsonData" -ForegroundColor Yellow

    $raceCalendarStr = Get-Content $jsonData | Out-String

    try {
        $raceCalendar = $raceCalendarStr | ConvertFrom-Json
    }
    catch {
        Write-Host "ERROR: Issue converting to a JSON Object" -ForegroundColor Red
        Exit
    }

    #Get the Race Details from the JSON file.
    Write-Host "INFO: Getting the details from the JSON based on the round number" -ForegroundColor Yellow
    $selectedRace = $raceCalendar.Formula1RaceCalendar | Where-Object { $_.Round -eq $round }

    Write-Host "INFO: Getting the race name from the JSON" -ForegroundColor Yellow
    foreach ($race in $selectedRace) {
        $raceName = $race.RaceName
    }

    Write-Host "INFO: Replacing spaces in race name with _" -ForegroundColor Yellow
    $raceName = $raceName.Replace(' ', '_')
    Write-Host "INFO: Building race name and year ($currentYear)" -ForegroundColor Yellow
    $raceName += "_" + $currentYear
    
    $staticFilesFullPath = $fileLocation + "\static\"

    $sourceFilesFullPath = -join($fileLocation,"\",$raceName,"\")

    $backupFolder = "\backups\"
    $backupLocation = $rootpath + $backupFolder + $raceName + "\"  
    
    $scriptFolder = "\scripts\"
    $scriptLocation = -join($schemaLocation,$scriptFolder)
    
    #Create the folders required for the script to run
    if (-Not(Test-Path -Path $backupLocation)) {
        Write-Host "INFO: Attempting to create the directory $backupLocation" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $backupLocation -Force -ErrorAction Stop
        Write-Host "SUCCESS: Directory $backupLocation created successfully" -ForegroundColor Green
    }
    else {
        Write-Host "WARN: The directory $backupLocation already exists" -ForegroundColor Magenta
    }

    Write-Host "INFO: Getting all of the .csv files from" $sourceFilesFullPath -ForegroundColor Yellow    
    $csvFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
    $staticFiles = Get-ChildItem $staticFilesFullPath -Filter *.csv 
    
    $csvFileCount = $csvFiles | Measure-Object | ForEach-Object { $_.Count } 
    $staticFileCount = $staticFiles | Measure-Object | ForEach-Object { $_.Count }  

    $totalFilesFound = $csvFileCount + $staticFileCount    

    Write-Host "INFO: A total of" $totalFilesFound ".csv files were found" -ForegroundColor Yellow    
    
    foreach ($instance in $sqlInstance) {
        
        $database = Get-DbaDatabase -SqlInstance $sqlInstance -Database $databaseName

        if ($database) {
            Write-Host "WARN: Database already exists $databaseName from" $instance -ForegroundColor Magenta
            Write-Host "INFO: Attempting to drop $databaseName from" $instance -ForegroundColor Yellow
            Remove-DbaDatabase -SqlInstance $sqlInstance -Database $databaseName -Confirm:$false
            Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
            New-DbaDatabase -SqlInstance $sqlInstance -Name $databaseName
            Write-Host "SUCCESS: Database" $databaseName" created" -ForegroundColor Green
        }
        else {
            Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
            New-DbaDatabase -SqlInstance $sqlInstance -Name $databaseName
            Write-Host "SUCCESS: Database" $databaseName" created" -ForegroundColor Green
        }

        Write-Host "INFO: Atempting to open a connection to $instance ..." -ForegroundColor Yellow
        $svr = Connect-dbaInstance -SqlInstance $sqlInstance -Database $databaseName            
        $sqlVersion = Get-DbaBuildReference -SqlInstance $svr | Select-Object -ExpandProperty NameLevel

        $database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName

        if($database)
        {
            Write-Host "INFO: Beginning loop of race file import" -ForegroundColor Yellow
            foreach ($csvFile in $csvFiles) {
    
                $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($csvFile)
                        
                try {                
                    Write-Host "INFO: Attempting to import data into" $fileWithoutExtension "from" $csvFile -ForegroundColor Yellow
                    $filePath = $sourceFilesFullPath + $csvFile.Name    
                    Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -AutoCreateTable
                }
                catch {
                    Write-Host "ERROR: Importing data into" $fileWithoutExtension "from" $csvFile -ForegroundColor Red
                    Exit
                }
            } #Race CSV Loop Ends Here
    
            Write-Host "INFO: Beginning loop of static file import" -ForegroundColor Yellow
            foreach ($staticFile in $staticFiles) {
    
                $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
                        
                try {                
                    Write-Host "INFO: Attempting to import data into" $fileWithoutExtension "from" $staticFile -ForegroundColor Yellow
                    $filePath = $staticFilesFullPath + $staticFile.Name    
                    Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -AutoCreateTable
                }
                catch {
                    Write-Host "ERROR: Importing data into" $fileWithoutExtension "from" $staticFile -ForegroundColor Red
                    Exit
                }
            } #Static File Import Loop Ends Here 
            
            $tables = Get-DbaDbTable -SqlInstance $svr -Database $databaseName            

            $tableCount = $tables | Measure-Object
            $tableCount = $tableCount.Count

            Write-Host "INFO: $tableCount tables were created " $staticFile -ForegroundColor Yellow

            if($tableCount -lt 19)
            {
                Write-Host "ERROR: Not all tables has imported" -ForegroundColor Red
            } else {
                Write-Host "SUCCESS: All tables have been imported" -ForegroundColor Green
            }

            $properCaseFunctionsPath = -join($schemaLocation,$scriptFolder,"functions/","ProperCaseFunction.sql")
            $splitStringFunctionsPath = -join($schemaLocation,$scriptFolder,"functions/","SplitString.sql")

            try {     
                Write-Host "INFO: Creating function $properCaseFunctionPath" -ForegroundColor Yellow           
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $properCaseFunctionsPath     
                Write-Host "SUCCESS: Function $properCaseFunctionPath created successfully" -ForegroundColor Green  
            }
            catch {
                Write-Host "ERROR: Something went wrong creating $properCaseFunctionPath" -ForegroundColor Red
            }

            try {
                Write-Host "INFO: Creating function $splitStringFunctionsPath" -ForegroundColor Yellow  
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $splitStringFunctionsPath 
                Write-Host "SUCCESS: Function $splitStringFunctionsPath created successfully" -ForegroundColor Green                  
            }
            catch {
                Write-Host "ERROR: Something went wrong creating $splitStringFunctionsPath" -ForegroundColor Red  
            }
            
            $circuitJsonPath = -join($schemaLocation,$scriptFolder)
            $circuitJsonFullPath = -join($circuitJsonPath,"circuits\","circuits.json")

            # Read the JSON file
            $circuitJsonData = Get-Content -Raw -Path $circuitJsonFullPath | ConvertFrom-Json

            # Sort the items based on the "order" property
            $circuitSortedItems = $circuitJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($circuitItem in $circuitSortedItems) {
                $filename = $circuitItem.filename 
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                  
            }

            ##

            $driversJsonFullPath = -join($scriptLocation,"drivers\","drivers.json")
            $driversJsonData = Get-Content -Raw -Path $driversJsonFullPath | ConvertFrom-Json
            $driversSortedItems = $driversJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($driversItem in $driversSortedItems) {
                $filename = $driversItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                 
            }

            ##

            $intervalsJsonFullPath = -join($scriptLocation,"intervals\","intervals.json")
            $intervalsJsonData = Get-Content -Raw -Path $intervalsJsonFullPath | ConvertFrom-Json
            $intervalSortedItems = $intervalsJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($intervalsItem in $intervalSortedItems) {
                $filename = $intervalsItem.filename 
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                  
            }

            ##

            $lapsJsonFullPath = -join($scriptLocation,"laps\","laps.json")
            $lapsJsonData = Get-Content -Raw -Path $lapsJsonFullPath | ConvertFrom-Json
            $lapsSortedItems = $lapsJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($lapsItem in $lapsSortedItems) {
                $filename = $lapsItem.filename    
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath               
            }

            ##

            $meetingsJsonFullPath = -join($scriptLocation,"meetings\","meetings.json")

            $meetingsJsonData = Get-Content -Raw -Path $meetingsJsonFullPath | ConvertFrom-Json

            $meetingsSortedItems = $meetingsJsonData.items | Sort-Object order

            foreach ($meetingsItem in $meetingsSortedItems) {
                $filename = $meetingsItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                 
            }

            ##

            $pitStopsJsonFullPath = -join($scriptLocation,"pitStops\","pitStops.json")
            $pitStopsJsonData = Get-Content -Raw -Path $pitStopsJsonFullPath | ConvertFrom-Json
            $pitStopsSortedItems = $pitStopsJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($pitStopsItem in $pitStopsSortedItems) {
                $filename = $pitStopsItem.filename 
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                  
            }

            ##

            $positionJsonFullPath = -join($scriptLocation,"position\","position.json")
            $positionJsonData = Get-Content -Raw -Path $positionJsonFullPath | ConvertFrom-Json
            $positionSortedItems = $positionJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($positionItem in $positionSortedItems) {
                $filename = $positionItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                 
            }

            ##

            $sessionsJsonFullPath = -join($scriptLocation,"sessions\","sessions.json")
            $sessionsJsonData = Get-Content -Raw -Path $sessionsJsonFullPath | ConvertFrom-Json
            $sessionsSortedItems = $sessionsJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($sessionsItem in $sessionsSortedItems) {
                $filename = $sessionsItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                 
            }
            
            ##

            $stintsJsonFullPath = -join($scriptLocation,"stints\","stints.json")
            $stintsJsonData = Get-Content -Raw -Path $stintsJsonFullPath | ConvertFrom-Json
            $stintsSortedItems = $stintsJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($stintsItem in $stintsSortedItems) {
                $filename = $stintsItem.filename
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath                   
            }

            ##

            $weatherJsonFullPath = -join($scriptLocation,"weather\","weather.json")
            $weatherJsonData = Get-Content -Raw -Path $weatherJsonFullPath | ConvertFrom-Json
            $weatherSortedItems = $weatherJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($weatherItem in $weatherSortedItems) {
                $filename = $weatherItem.filename
                $fullPath = -join($scriptLocation,$filename)
                Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath               
            }           

            ##

            $cleanJsonFullPath = -join($scriptLocation,"cleanup\","cleanup.json")
            $cleanJsonData = Get-Content -Raw -Path $cleanJsonFullPath | ConvertFrom-Json
            $cleanSortedItems = $cleanJsonData.items | Sort-Object order

            # Loop over the sorted items and retrieve the filename
            foreach ($cleanItem in $cleanSortedItems) {
                $filename = $cleanItem.filename
                $fullPath = -join($scriptLocation,$filename)
                Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath               
            } 

            ##

            if ($backupDatabase -eq $True) {

                Write-Host "INFO: backupDatabase is set to true, attempting backup routine." -ForegroundColor Yellow
                
                $backupName = $sqlVersion + "_" + $databaseName + "_" + $raceName + ".bak"
                $backupCompressName = $sqlVersion + "_" + $databaseName + "_" + $raceName + '.7zip'  
                $backupFullPath = $backupLocation + $backupName              
                
                if (Test-Path -Path $backupFullPath) {
                    Write-Host "WARN: Database backup already exists, removing" -ForegroundColor Magenta
                    Remove-Item -Path $backupFullPath
                } 
                
                try {            
                    Write-Host "INFO: Attempting to create a database backup." -ForegroundColor Yellow
                    Backup-DbaDatabase -SqlInstance $svr -Database $databaseName -Path $backupLocation -FilePath $backupName -Type Full -IgnoreFileChecks
                    Write-Host "SUCCESS: Database backed up sucessfully" -ForegroundColor Green   
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
                    Write-Host "SUCCESS: Compressed backup sucessfully" -ForegroundColor Green             
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
            
            if ($cleanInstance -eq $True) {
                Write-Host "INFO: Dropping database $databaseName from $instance" -ForegroundColor Yellow
                Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false 
                Write-Host "SUCCESS: Database $databaseName dropped" -ForegroundColor Green
            }
            else {
                Write-Host "WARN: $databaseName not dropped as cleanInstance is not set to true" -ForegroundColor Magenta
            }
        }
    } #SQL Instance Loop Ends Here
    
    Write-Host "SUCCESS: Database build complete on $instance" -ForegroundColor Green