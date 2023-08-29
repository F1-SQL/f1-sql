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
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $sqlInstance,
        [Parameter(Mandatory=$True, Position=1, ValueFromPipeline=$false)]
        [System.String]
        $databaseName,
        [Parameter(Mandatory=$True, Position=2, ValueFromPipeline=$false)]
        [System.Boolean]
        $cleanInstance,
        [Parameter(Mandatory=$True, Position=3, ValueFromPipeline=$false)]
        [System.Boolean]
        $backupDatabase,
        [Parameter(Mandatory=$True, Position=4, ValueFromPipeline=$false)]
        [System.Boolean]
        $downloadZip   
    )
    
    $currentYear = (Get-Date).Year.ToString()
    $rootpath = $PSScriptRoot
    
    $races=@("Bahrain","Saudi Arabia","Australia","Azerbaijan","United States","Monaco","Spain","Canada","Austria","Great Britain","Hungary","Belgium","Italy","Netherlands","Japan","Qatar","Austin","Mexico","Brazil","Las Vegas","Abu Dhabi")
    $raceName = $races | Out-GridView -PassThru
    
    $raceName = $raceName.Replace(' ','_')
    $raceName += "_" + $currentYear
    
    $sourceFiles = "\src\csv\"
    $sourceFilesFullPath = $rootpath + $sourceFiles

    $supplementaryData = $rootpath + "\src\supplementarydata"

    $archiveFolder = "\src\archivedfiles\"
    $archiveLocation = $rootpath + $archiveFolder
    $archiveLocationDate = $archiveLocation + $raceName + "\"

    $sourceLocation = "https://ergast.com/downloads/f1db_csv.zip"
    
    $zipName = 'SequelFormula_csv_' + $raceName + '.zip'
    $zipLocation = $rootpath + $sourceFiles 
    $zipLocationFull = $zipLocation + $zipName

    if(-Not(Test-Path $zipLocationFull) -and $downloadZip -eq $true)
    {
        Write-Host "INFO: Zip file $zipName does not exist" -ForegroundColor Yellow
        Write-Host "INFO: Attempting to download zip file from $sourceLocaiton to $ziplocation" -ForegroundColor Yellow
        Invoke-WebRequest -Uri $sourceLocation -OutFile $zipLocationFull
    } else {
        Write-Host "INFO: Zip file $zipName already exists will not re-download" -ForegroundColor Yellow
    } 

    if(Test-Path $zipLocationFull -PathType Leaf)
    {
        Write-Host "INFO: Attempting to extract files from $zipLocationFull into $sourceFilesFullPath" -ForegroundColor Yellow
        Expand-Archive $zipLocationFull -DestinationPath $sourceFilesFullPath -Force    
    } else {
        Write-Host "WARN: Zip file does not exist in $zipLocation" -ForegroundColor Red
        Exit 
    }
    
    $replacementChar = "_"

    Write-Host "INFO: Getting all of the .csv files from" $sourceFilesFullPath -ForegroundColor Yellow
    $files = Get-ChildItem $sourceFilesFullPath -Filter *.csv | Where-Object -FilterScript {$_.Name -match $replacementChar}
    
    $allFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
    $total = $allFiles | Measure-Object | ForEach-Object{$_.Count}  
    
    Write-Host "INFO: A total of" $total ".csv files were found" -ForegroundColor Yellow
    
    foreach($file in $files)
    {
        try {     
            
            Write-Host "INFO: Attempting to rename" $file "to match table name" $file.Name.Replace("_","")  -ForegroundColor Yellow
            Rename-Item -path $file -NewName $file.Name.Replace("_","") -Force
            Write-Host "SUCCESS: Renamed" $file.Name "sucessfully to match table name" -ForegroundColor Green
    
        }
        catch {
            Write-Host "ERROR: Renaming" $file "failed The Error was: $_" -ForegroundColor Red
            Exit
        }
    }

    $allFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
    $total = $files | Measure-Object | ForEach-Object{$_.Count}  
    
    Write-Host "INFO: A total of $total .csv files were found that need \N values removing." -ForegroundColor Yellow
    
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
    
    $global:progressPreference = 'silentlyContinue'
    
    if(-Not(Test-Path -Path $archiveLocation))
    {
        Write-Host "INFO: Attempting to create the directory $archiveLocation" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $archiveLocation -Force -ErrorAction Stop
    } else {
        Write-Host "ERROR: The directory $archiveLocation already exists" -ForegroundColor Gray
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

    foreach($instance in $sqlInstance)
    {
    
        Write-Host "INFO: Atempting to open a connection to $instance ..." -ForegroundColor Yellow
        $svr = Connect-dbaInstance -SqlInstance $instance
        
        $version = Get-DbaBuildReference -SqlInstance $svr | Select-Object -ExpandProperty NameLevel        
        
        $tableFolder = "\src\tables\sql-" + $version
        $tableFilesFullPath = $rootpath + $tableFolder
        
        $backupName = $version + "_" + $databaseName + "_" + $raceName + ".bak"
        $backupCompressName = $version + "_" + $databaseName + "_" + $raceName + '.7zip'
        $backupFolder = "\backups\"
        $backupLocation = $rootpath + $backupFolder
        $backupFullPath = $backupLocation + "\" + $backupName  

        if(-Not(Test-Path -Path $tableFilesFullPath))
        {
            Write-Host "INFO: Attempting to create the directory $tableFilesFullPath" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $tableFilesFullPath -Force -ErrorAction Stop
        } else {
            Write-Host "ERROR: The directory $tableFilesFullPath already exists" -ForegroundColor Gray
        }

        if(Test-Path -Path $tableFilesFullPath)
        {
            $tableFiles = Get-ChildItem -Path $tableFilesFullPath -Filter *.sql 
        }
    
        foreach($tablefile in $tableFiles)
        {
            try {       
        
                Write-Host "INFO: Attempting to delete" $tablefile.Name -ForegroundColor Yellow
                Remove-Item -Path $tablefile.FullName -Force
                Write-Host "SUCCESS: Deleted" $tablefile.Name -ForegroundColor Green
        
            }
            catch {
                Write-Host "ERROR: Unable to delete" $tablefile.FullName "the Error was: $_" -ForegroundColor Red
                Exit
            }
        }
        
        if(-Not(Test-Path -Path $backupLocation))
        {
            Write-Host "INFO: Attempting to create the directory $backupLocation" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $backupLocation -Force -ErrorAction Stop
        } else {
            Write-Host "ERROR: The directory $backupLocation already exists" -ForegroundColor Gray
        }       
        
        $database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName
        
        if($database)
        {
            Write-Host "WARN: Database already exists $databaseName from" $instance -ForegroundColor Red
            Write-Host "INFO: Attempting to drop $databaseName from" $instance -ForegroundColor Yellow
            Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false
            Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
            New-DbaDatabase -SqlInstance $svr -Name $databaseName
            Write-Host "SUCCESS: Database" $databaseName" created" -ForegroundColor Green
        } else 
        {
            Write-Host "INFO: Attempting to create $databaseName" -ForegroundColor Yellow
            New-DbaDatabase -SqlInstance $svr -Name $databaseName
            Write-Host "SUCCESS: Database" $databaseName" created" -ForegroundColor Green
        }
        
        $database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName
        
        if($database)
        {
            Write-Host "INFO: Creating tables" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\SequelFormula_tables.sql' -f $rootpath)
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

        if($supplementaryData)
        {
            $supplementaryDataFiles = Get-ChildItem -Path $supplementaryData -Filter *.csv  
            
            foreach($supplementaryDataFile in $supplementaryDataFiles)
            {
                $supplementaryDataWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($supplementaryDataFile)
                Write-Host "INFO: Attempting to import data from " $supplementaryDataFile.FullName " into " $supplementaryDataWithoutExtension -ForegroundColor Yellow
                Import-DbaCsv -Path $supplementaryDataFile.FullName -SqlInstance $svr -Database $databaseName -Table $supplementaryDataWithoutExtension -Delimiter "," -NoProgress
            }
            
        } else {
            Write-Host "WARN: No supplementary data to import" -ForegroundColor Red
        }    

        if($database)
        {
            Write-Host "INFO: Running data quality fixes" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\SequelFormula_data_quality.sql' -f $rootpath)
        } 

        if($database)
        {
            Write-Host "INFO: Performing Data Updates" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\SequelFormula_data_updates.sql' -f $rootpath)
        } 

        if($database)
        {
            Write-Host "INFO: Creating keys" -ForegroundColor Yellow
            Invoke-DbaQuery -SqlInstance $svr -Database $databaseName -File ('{0}\src\SequelFormula_foreign_keys.sql' -f $rootpath)
        }    
        
        $options = New-DbaScriptingOption
        $options.ScriptSchema = $true
        $options.IncludeDatabaseContext  = $false
        $options.IncludeHeaders = $false
        $Options.NoCommandTerminator = $false
        $options.DriPrimaryKey = $true
        $Options.ScriptBatchTerminator = $true
        $options.DriAllConstraints = $false
        $Options.AnsiFile = $true

        try {        
            Get-DbaDbTable -SqlInstance $svr -Database $databaseName | ForEach-Object { Export-DbaScript -InputObject $_ -FilePath (Join-Path $tableFilesFullPath -ChildPath "$($_.Name).sql") -ScriptingOptionsObject $options }
        }
        catch {
            Write-Error -Message "Unable to export tables to '$tablePath'. Error was: $error" -ErrorAction Stop
            Add-Content -Path $logFullPath -Value "$(Get-Date -f yyyy-MM-dd-HH-mm) - Unable to export tables to '$tablePath'. Error was: $error"
        }       
        
        if($backupDatabase -eq $True)
        {
            Write-Host "INFO: Attempting to create a database backup." -ForegroundColor Yellow
            
            if(Test-Path -Path $backupFullPath)
            {
                Write-Host "WARN: Database backup already exists, removing" -ForegroundColor Red
                Remove-Item -Path $backupFullPath
            } 
                   
            Backup-DbaDatabase -SqlInstance $svr -Database $databaseName -Path $backupLocation -FilePath $backupName -Type Full 

            Write-Host "INFO: Attempting to 7zip the backup" -ForegroundColor Yellow
            try
            {
                Compress-7Zip -Path $backupFullPath -Filter *.bak -ArchiveFileName $backupCompressName -CompressionLevel Ultra
            }
            catch {
                Write-Host "ERROR: Compressing backup failed" -ForegroundColor Red
            }

            Write-Host "SUCCESS: Database backup has been completed." -ForegroundColor Green

        } else {
            Write-Host "WARN: No backup has been taken as backupDatabase is set to False." -ForegroundColor Red
        }        
        
        if($cleanInstance -eq $True -and $backupDatabase -eq $True)
        {
            Write-Host "INFO: Dropping database $databaseName from $instance" -ForegroundColor Yellow
            Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false 
        } else {
            Write-Host "WARN: $databaseName not dropped as database is not set to backup" -ForegroundColor Red
        }

        Write-Host "SUCCESS: Database build complete on $instance" -ForegroundColor Green
    }

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