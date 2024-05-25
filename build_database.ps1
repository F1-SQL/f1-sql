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

    .PARAMETER schemaLocation
        The location of the database schema

    .PARAMETER fileLocation
        The location of the CSV files that you want to import
        
    .PARAMETER round
        The round that you are running the script for, this is taken from the calendar JSON

    .NOTES
        Tags: FormulaOne, F1, Database, Data.
        Author: Richard Howell, f1-sql.com

        Website: https://f1-sql.com
        Copyright: (c) 2024 by F1 SQL, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://f1-sql.com

    .EXAMPLE
        PS C:\> .\build_database.ps1 -databaseName F1SQL -sqlInstance localhost -cleanInstance $false -backupDatabase $false -fileLocation "D:\f1-sql\f1-sql-Files" -schemaLocation "D:\f1-sql\f1-sql-Database" -round 3        
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

    Write-Host "INFO: Attempting to start SQL Server services" -ForegroundColor Yellow
    try {
        Get-Service | Where-Object { ($_.Name -like "*SQLEXPRESS*") -and ($_.Status -eq "Stopped") -and ($_.Name -NotLike "*TELEMETRY*") -and ($_.Name -NotLike "*Agent*") } | Start-Service
    } catch {
        Write-Host "ERROR: Some of the SQL Server services failed to start" -ForegroundColor Red
        Exit
    }

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
        Write-Host "ERROR: Issue converting race calendar to a JSON object" -ForegroundColor Red
        Exit
    }

    #Get the Race Details from the JSON file.
    Write-Host "INFO: Getting the details from the race calendar JSON based on the round number provided" -ForegroundColor Yellow
    $selectedRace = $raceCalendar.Formula1RaceCalendar | Where-Object { $_.Round -eq $round }

    Write-Host "INFO: Getting the race name from the JSON" -ForegroundColor Yellow
    foreach ($race in $selectedRace) {
        $raceName = $race.RaceName
    }

    Write-Host "INFO: $raceName has been deleted based on the round number provided" -ForegroundColor Yellow

    Write-Host "INFO: Replacing spaces in race name with underscores" -ForegroundColor Yellow
    $raceName = $raceName.Replace(' ', '_')

    Write-Host "INFO: Building race name and year ($currentYear)" -ForegroundColor Yellow
    $raceName += "_" + $currentYear
    
    $staticFilesFullPath = $fileLocation + "\static\"

    $sourceFilesFullPath = -join($fileLocation,"\",$raceName,"\")

    $backupFolder = "\backups\"
    $backupLocation = -join($rootpath,$backupFolder,$raceName,"\")
    
    $scriptFolder = "\scripts\"
    $scriptLocation = -join($schemaLocation,$scriptFolder)
    
    if($backupDatabase -eq $true) {
        if (-Not(Test-Path -Path $backupLocation)) {
            Write-Host "INFO: Attempting to create the directory $backupLocation" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $backupLocation -Force -ErrorAction Stop
            Write-Host "SUCCESS: Directory $backupLocation created successfully" -ForegroundColor Green
        }
        else {
            Write-Host "WARN: The directory $backupLocation already exists" -ForegroundColor Magenta
        }
    } else {
        Write-Host "WARN: Backup directory check skipped" -ForegroundColor Magenta
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
            Write-Host "WARN: Database already exists $databaseName from $instance" -ForegroundColor Magenta
            Write-Host "INFO: Attempting to drop $databaseName from $instance" -ForegroundColor Yellow
            Remove-DbaDatabase -SqlInstance $sqlInstance -Database $databaseName -Confirm:$false
            Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
            New-DbaDatabase -SqlInstance $sqlInstance -Name $databaseName
            Write-Host "SUCCESS: Database $databaseName created" -ForegroundColor Green
        }
        else {
            Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
            New-DbaDatabase -SqlInstance $sqlInstance -Name $databaseName
            Write-Host "SUCCESS: Database $databaseName created" -ForegroundColor Green
        }

        Write-Host "INFO: Atempting to open a connection to $instance ..." -ForegroundColor Yellow
        $svr = Connect-dbaInstance -SqlInstance $sqlInstance -Database $databaseName             
        $sqlVersion = Get-DbaBuildReference -SqlInstance $svr -Update | Select-Object -ExpandProperty NameLevel

        Write-Host "INFO: Getting $databaseName from $instance" -ForegroundColor Yellow
        $database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName

        if($database)
        {
            Write-Host "INFO: Beginning loop of race file import" -ForegroundColor Yellow
            foreach ($csvFile in $csvFiles) {
    
                $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($csvFile)
                        
                try {                
                    Write-Host "INFO: Attempting to import data into" $fileWithoutExtension "from" $csvFile -ForegroundColor Yellow
                    $filePath = $sourceFilesFullPath + $csvFile.Name
                    
                    [int]$LinesInFile = 0
                    $reader = New-Object IO.StreamReader $filePath
                    
                    # Skip the first line (header)
                    $reader.ReadLine() | Out-Null
                    
                    # Count the remaining lines
                    while($null -ne $reader.ReadLine()) {
                        $LinesInFile++
                    }
                    
                    # Close the reader
                    $reader.Close()
                    
                    $result = Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -AutoCreateTable -NoProgress
                    $rowCount = $result.RowsCopied

                    if($rowCount -eq $LinesInFile)
                    {
                        Write-Host "SUCCESS: Imported $fileWithoutExtension from $csvFile successfully" -ForegroundColor Green

                    } else 
                    {
                        Write-Host "ERROR: Imported $fileWithoutExtension from $csvFile successfully" -ForegroundColor Red
                        Exit
                    }
                    
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
                    
                    [int]$LinesInFile = 0
                    $reader = New-Object IO.StreamReader $filePath
                    
                    # Skip the first line (header)
                    $reader.ReadLine() | Out-Null
                    
                    # Count the remaining lines
                    while($null -ne $reader.ReadLine()) {
                        $LinesInFile++
                    }
                    
                    # Close the reader
                    $reader.Close()                    

                    $result = Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -AutoCreateTable
                    $rowCount = $result.RowsCopied
                    
                    if($rowCount -eq $LinesInFile)
                    {
                        Write-Host "SUCCESS: Imported $fileWithoutExtension from $staticFile successfully" -ForegroundColor Green

                    } else 
                    {
                        Write-Host "ERROR: Imported $fileWithoutExtension from $staticFile successfully" -ForegroundColor Red
                        Exit
                    }
                }
                catch {
                    Write-Host "ERROR: Importing data into" $fileWithoutExtension "from" $staticFile -ForegroundColor Red
                    Exit
                }
            } #Static File Import Loop Ends Here 
            
            Write-Host "INFO: Getting all the tables from $databaseName on $instance" -ForegroundColor Yellow
            $tables = Get-DbaDbTable -SqlInstance $svr -Database $databaseName            

            $tableCount = $tables | Measure-Object
            $tableCount = $tableCount.Count

            Write-Host "INFO: $tableCount tables were created" -ForegroundColor Yellow

            if($tableCount -eq $totalFilesFound)
            {
                Write-Host "SUCCESS: All CSV files have been imported" -ForegroundColor Green
            } else {
                Write-Host "ERROR: Not all CSV Files have been imported" -ForegroundColor Red
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
            $circuitJsonData = Get-Content -Raw -Path $circuitJsonFullPath | ConvertFrom-Json
            $circuitSortedItems = $circuitJsonData.items | Sort-Object order

            foreach ($circuitItem in $circuitSortedItems) {
                $filename = $circuitItem.filename 
                $fullPath = -join($scriptLocation,$filename)
                
                try {                    
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop 
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green                  
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $driversJsonFullPath = -join($scriptLocation,"drivers\","drivers.json")
            $driversJsonData = Get-Content -Raw -Path $driversJsonFullPath | ConvertFrom-Json
            $driversSortedItems = $driversJsonData.items | Sort-Object order

            
            foreach ($driversItem in $driversSortedItems) {
                $filename = $driversItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green                                
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }

            }

            $intervalsJsonFullPath = -join($scriptLocation,"intervals\","intervals.json")
            $intervalsJsonData = Get-Content -Raw -Path $intervalsJsonFullPath | ConvertFrom-Json
            $intervalSortedItems = $intervalsJsonData.items | Sort-Object order

            
            foreach ($intervalsItem in $intervalSortedItems) {
                $filename = $intervalsItem.filename 
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop   
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green             
                    
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $lapsJsonFullPath = -join($scriptLocation,"laps\","laps.json")
            $lapsJsonData = Get-Content -Raw -Path $lapsJsonFullPath | ConvertFrom-Json
            $lapsSortedItems = $lapsJsonData.items | Sort-Object order

            
            foreach ($lapsItem in $lapsSortedItems) {
                $filename = $lapsItem.filename    
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green                                   
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $meetingsJsonFullPath = -join($scriptLocation,"meetings\","meetings.json")
            $meetingsJsonData = Get-Content -Raw -Path $meetingsJsonFullPath | ConvertFrom-Json
            $meetingsSortedItems = $meetingsJsonData.items | Sort-Object order

            foreach ($meetingsItem in $meetingsSortedItems) {
                $filename = $meetingsItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow  
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop  
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green                                   
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $pitStopsJsonFullPath = -join($scriptLocation,"pitStops\","pitStops.json")
            $pitStopsJsonData = Get-Content -Raw -Path $pitStopsJsonFullPath | ConvertFrom-Json
            $pitStopsSortedItems = $pitStopsJsonData.items | Sort-Object order
            
            foreach ($pitStopsItem in $pitStopsSortedItems) {
                $filename = $pitStopsItem.filename 
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop  
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green                  
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $positionJsonFullPath = -join($scriptLocation,"position\","position.json")
            $positionJsonData = Get-Content -Raw -Path $positionJsonFullPath | ConvertFrom-Json
            $positionSortedItems = $positionJsonData.items | Sort-Object order
            
            foreach ($positionItem in $positionSortedItems) {
                $filename = $positionItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $sessionsJsonFullPath = -join($scriptLocation,"sessions\","sessions.json")
            $sessionsJsonData = Get-Content -Raw -Path $sessionsJsonFullPath | ConvertFrom-Json
            $sessionsSortedItems = $sessionsJsonData.items | Sort-Object order
            
            foreach ($sessionsItem in $sessionsSortedItems) {
                $filename = $sessionsItem.filename  
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $stintsJsonFullPath = -join($scriptLocation,"stints\","stints.json")
            $stintsJsonData = Get-Content -Raw -Path $stintsJsonFullPath | ConvertFrom-Json
            $stintsSortedItems = $stintsJsonData.items | Sort-Object order
            
            foreach ($stintsItem in $stintsSortedItems) {
                $filename = $stintsItem.filename
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green
                    
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $weatherJsonFullPath = -join($scriptLocation,"weather\","weather.json")
            $weatherJsonData = Get-Content -Raw -Path $weatherJsonFullPath | ConvertFrom-Json
            $weatherSortedItems = $weatherJsonData.items | Sort-Object order
            
            foreach ($weatherItem in $weatherSortedItems) {
                $filename = $weatherItem.filename
                $fullPath = -join($scriptLocation,$filename)                
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green
                    
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $teamRadioJsonFullPath = -join($scriptLocation,"teamRadio\","teamRadio.json")
            $teamRadioJsonData = Get-Content -Raw -Path $teamRadioJsonFullPath | ConvertFrom-Json
            $teamRadioSortedItems = $teamRadioJsonData.items | Sort-Object order
            
            foreach ($teamRadioItem in $teamRadioSortedItems) {
                $filename = $teamRadioItem.filename
                $fullPath = -join($scriptLocation,$filename)                
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green
                    
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            } 
            
            $raceControlJsonFullPath = -join($scriptLocation,"raceControl\","raceControl.json")
            $raceControlJsonData = Get-Content -Raw -Path $raceControlJsonFullPath | ConvertFrom-Json
            $raceControlSortedItems = $raceControlJsonData.items | Sort-Object order
            
            foreach ($raceControlItem in $raceControlSortedItems) {
                $filename = $raceControlItem.filename
                $fullPath = -join($scriptLocation,$filename)                
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green
                    
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            }

            $cleanJsonFullPath = -join($scriptLocation,"cleanup\","cleanup.json")
            $cleanJsonData = Get-Content -Raw -Path $cleanJsonFullPath | ConvertFrom-Json
            $cleanSortedItems = $cleanJsonData.items | Sort-Object order
            
            foreach ($cleanItem in $cleanSortedItems) {
                $filename = $cleanItem.filename
                $fullPath = -join($scriptLocation,$filename)
                
                try {
                    Write-Host "INFO: Attempting to execute $filename" -ForegroundColor Yellow
                    Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File $fullPath -ErrorAction Stop
                    Write-Host "SUCCESS: $filename executed" -ForegroundColor Green
                    
                }
                catch {
                    $_ | Format-List * -Force | Out-String
                }
            } 

            if ($backupDatabase -eq $True) {

                Write-Host "INFO: backupDatabase is set to true, attempting backup routine." -ForegroundColor Yellow
                
                $backupName = -join($sqlVersion,"_",$databaseName,"_",$raceName,".bak")
                Write-Host "INFO: Using $backupName" -ForegroundColor Yellow
                $backupCompressName = -join($sqlVersion,"_",$databaseName,"_",$raceName,".7zip")
                Write-Host "INFO: Using $backupCompressName for zip filename" -ForegroundColor Yellow                
                $backupFullPath = -join($backupLocation,$backupName)
                Write-Host "INFO: Saving backups to $backupLocation" -ForegroundColor Yellow
                Write-Host "INFO: Backups path is $backupFullPath" -ForegroundColor Yellow
                
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
                    $compressedPath = -join($backupLocation,$backupCompressName)
                    Write-Host "INFO: Attempting to 7zip the backup" -ForegroundColor Yellow
                    Compress-7Zip -Path $backupLocation -Filter *.bak -ArchiveFileName $compressedPath -CompressionLevel Ultra                
                    Write-Host "SUCCESS: Compressed backup sucessfully" -ForegroundColor Green             
                    Write-Host "SUCCESS: Compressed backup is available in $compressedPath" -ForegroundColor Green
                    Remove-Item -Path $backupFullPath -Force
                }
                catch {
                    Write-Host "ERROR: Compressing backup failed" -ForegroundColor Red
                    Exit
                }        
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

        Write-Host "SUCCESS: Database build complete on $instance" -ForegroundColor Green

    } #SQL Instance Loop Ends Here

    Write-Host "END: Sequel Formula has completed" -ForegroundColor Green
    
    Write-Host "INFO: Attempting to stop SQL Server services" -ForegroundColor Yellow
    try {
        Get-Service | Where-Object { ($_.Name -like "*SQLEXPRESS*") -and ($_.Status -eq "Running") -and ($_.Name -NotLike "*TELEMETRY*") -and ($_.Name -NotLike "*Agent*") } | Stop-Service
    } catch {
        Write-Host "ERROR: Some of the SQL Server services failed to stop" -ForegroundColor Red        
    }