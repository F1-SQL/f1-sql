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
        [Parameter(Mandatory = $True, Position = 5, ValueFromPipeline = $false)]
        [System.Int32]
        $round
        )
        
    $global:progressPreference = 'silentlyContinue'
    
    $sourceFiles = "\src\sourceFiles\"
    $sourceFilesFullPath = $rootpath + $sourceFiles
        
    Write-Host "INFO: Getting all of the .csv files from" $sourceFilesFullPath -ForegroundColor Yellow
    $files = Get-ChildItem $sourceFilesFullPath -Filter *.csv | Where-Object -FilterScript { $_.Name -match $replacementChar }
        
    $allFiles = Get-ChildItem $sourceFilesFullPath -Filter *.csv
    $total = $allFiles | Measure-Object | ForEach-Object { $_.Count }  
        
    Write-Host "INFO: A total of" $total ".csv files were found" -ForegroundColor Yellow
    
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
    
        $databaseName = "SequelFormulaNew"
        $svr = Connect-dbaInstance -SqlInstance localhost -Database $databaseName
        $database = Get-DbaDatabase -SqlInstance $svr -Database $databaseName
            
        if ($database) {
    
            Write-Host "INFO: Attempting to create $databaseName database" -ForegroundColor Yellow
    
            if(!$database)
            {
                New-DbaDatabase -SqlInstance $svr -Name $databaseName
            } else
            {
                Write-Host "INFO: Database Already Exists" -ForegroundColor Red
            }
    
            $sourceFilesFullPath = "D:\workspace\Sequel Formula\Sequel-Formula-Files\Australian_Grand_Prix_2024\"
    
            $files = Get-ChildItem $sourceFilesFullPath -Filter *.csv
    
            foreach ($file in $files) {
    
                $fileWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($file)
                        
                try {                
                    Write-Host "INFO: Attempting to import data into" $fileWithoutExtension "from" $file -ForegroundColor Yellow
                    $filePath = $sourceFilesFullPath + $file.Name    
                    Import-DbaCsv -Path $filePath -SqlInstance $svr -Database $databaseName -Table $fileWithoutExtension -Delimiter "," -AutoCreateTable
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
    
    Write-Host "SUCCESS: Database build complete on $instance" -ForegroundColor Green