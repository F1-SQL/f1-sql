$rootpath = $PSScriptRoot
$csvRootPath = $PSScriptRoot + "\sourcefiles\"
$sqlInstance = "localhost"
$databaseName = "f1db"
$replacementChar = "_"

Write-Host "Atempting to open a connection to" $sqlInstance" ..." -ForegroundColor Yellow
$svr = Connect-dbaInstance -SqlInstance $sqlInstance

Write-Host "Attempting to drop" $databaseName" from" $sqlInstance -ForegroundColor Yellow
Remove-DbaDatabase -SqlInstance $svr -Database $databaseName -Confirm:$false

Write-Host "Getting all of the .csv files from" $csvRootPath -ForegroundColor Yellow

$allFiles = Get-ChildItem $csvRootPath -Filter *.csv

$files = Get-ChildItem $csvRootPath -Filter *.csv | Where-Object -FilterScript {$_.Name -match $replacementChar}

$total = $allFiles | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "A total of" $total ".csv files were found" -ForegroundColor Yellow

#Rename the CSV Files to remove the underscores
foreach($file in $files)
{
    try {       

        Write-Host "Attempting to rename" $file "to match table name" $file.Name.Replace("_","")  -ForegroundColor Yellow
        Rename-Item $path -NewName $path.Replace("_","") -Force
        Write-Host "Renamed" $file.Name "sucessfully to match table name" -ForegroundColor Green

    }
    catch {
        Write-Host "Renaming"$path"failed The Error was: $_" -ForegroundColor Red
    }
}

$total = $files | Measure-Object | ForEach-Object{$_.Count}  

Write-Host "A total of"$total" .csv files were found that need renaming." -ForegroundColor Yellow

foreach($file in $allFiles)
{
    try {
        $path = $csvRootPath + $file.Name
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