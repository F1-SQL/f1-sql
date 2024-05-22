<#
    .SYNOPSIS
        Download the CSV files that are required to build the Sequel Formula database

    .DESCRIPTION
        Download the CSV files that are required to build the Sequel Formula database
        
    .PARAMETER sourceFilesFullPath
        The path to the location where the files should be downloaded.

    .PARAMETER calendarPath
        The path to the location of the JSON calendar.

    .PARAMETER round
        The round

    .NOTES
        Tags: FormulaOne, F1, Database, Data.
        Author: Richard Howell, f1-sql.com

        Website: https://f1-sql.com
        Copyright: (c) 2024 by F1 SQL, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT

    .LINK
        https://f1-sql.com/projects/formula-one-database/

    .EXAMPLE
        PS C:\> .\file-downloader.ps1 -sourceFilesFullPath "C:\f1-sql\f1-sql-Files\" -calendarPath "C:\f1-sql\f1-sql\src\raceCalendar.json" -round 01

        This will download the files for round 01 to the location provided using the specified calendar to get the round information.

    #>

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]
    $sourceFilesFullPath, 
    [Parameter(Mandatory = $True, Position = 2, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]
    $calendarPath,    
    [Parameter(Mandatory = $True, Position = 3, ValueFromPipeline = $false)]
    [System.Int32]
    $round
    )
    
$global:progressPreference = 'silentlyContinue'

$openf1_base_url = 'https://api.openf1.org/v1/'
$currentYear = (Get-Date).Year

$jsonData = $calendarPath
$raceCalendarStr = Get-Content $jsonData | Out-String

try {
    $raceCalendar = $raceCalendarStr | ConvertFrom-Json
}
catch {
    Write-Host "ERROR: Issue converting to a JSON Object" -ForegroundColor Red
    Exit
}

Write-Host "INFO: Getting the details from the JSON based on the round number"
$selectedRace = $raceCalendar.Formula1RaceCalendar | Where-Object { $_.Round -eq $round }

Write-Host "INFO: Getting the race name from the JSON" -ForegroundColor Yellow
foreach ($race in $selectedRace) {
    $raceName = $race.RaceName
}

$raceName = $raceName.replace(' ','_')

Write-Host "INFO: Creating the path for the selected race" -ForegroundColor Yellow
$path = -join($sourceFilesFullPath,"/",$raceName,"_",$currentYear)

if(!(Test-Path -Path $path))
{
    Write-Host "INFO: Creating the directory for the selected race" -ForegroundColor Yellow
    New-Item -Path $sourceFilesFullPath -Name $raceName -ItemType Directory -Force
} else {
    Write-Host "SKIP: Not creating directory for the selected race as it already exists" -ForegroundColor Red
}

$meetingPath = -join($path,"/","meetings",".csv")
$meetingsCSV = -join($openf1_base_url,"meetings?csv=true")

Write-Host "INFO: Attempting to download $meetingCSV to $meetingPath" -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $meetingsCSV -OutFile $meetingPath
    Write-Host "SUCESS: Attempting to download $meetingCSV to $meetingPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Downloading $meetingCSV to $meetingPath." -ForegroundColor Red
}

$driversPath = -join($path,"/","drivers",".csv")
$driversCSV = -join($openf1_base_url,"drivers?csv=true")

Write-Host "INFO: Attempting to download $driversCSV to $driversPath" -ForegroundColor Yellow

try {
    
    Invoke-WebRequest -Uri $driversCSV -OutFile $driversPath
    Write-Host "SUCESS: Attempting to download $driversCSV to $driversCSV" -ForegroundColor Green

} catch {
    Write-Host "ERROR: Downloading $driversCSV to $driversPath" -ForegroundColor Red
}

$lapsPath = -join($path,"/","laps",".csv")
$lapsCSV = -join($openf1_base_url,"laps?csv=true")

Write-Host "INFO: Attempting to download $lapsCSV to $lapsPath" -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $lapsCSV -OutFile $lapsPath
    Write-Host "SUCESS: Attempting to download $lapsCSV to $lapsPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Downloading $lapsCSV to $lapsPath" -ForegroundColor Red
}

$intervalsPath = -join($path,"/","intervals",".csv")
$intervalsCSV = -join($openf1_base_url,"intervals?csv=true")

Write-Host "INFO: Attempting to download $intervalsCSV to $intervalsPath" -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $intervalsCSV -OutFile $intervalsPath
    Write-Host "SUCESS: Attempting to download $intervalsCSV to $intervalsPath" -ForegroundColor Green
    
}
catch {
    Write-Host "ERROR: Downloading $intervalsCSV to $intervalsPath" -ForegroundColor Red
}

$sessionsPath = -join($path,"/","sessions",".csv")
$sessionsCSV = -join($openf1_base_url,"sessions?csv=true")

Write-Host "INFO: Attempting to download $sessionsCSV to $sessionsPath" -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $sessionsCSV -OutFile $sessionsPath
    Write-Host "SUCESS: Attempting to download $sessionsCSV to $sessionsPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Downloading $sessionsCSV to $sessionsPath" -ForegroundColor Red
}

$pitPath = -join($path,"/","pitStops",".csv")
$pitCSV = -join($openf1_base_url,"pit?csv=true")

Write-Host "INFO: Attempting to download $pitCSV to $pitPath" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $pitCSV -OutFile $pitPath
    Write-Host "SUCESS: Attempting to download $pitCSV to $pitPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Downloading $pitCSV to $pitPath" -ForegroundColor Red
}

$positionPath = -join($path,"/","position",".csv")
$positionCSV = -join($openf1_base_url,"position?csv=true")

Write-Host "INFO: Attempting to download $positionCSV to $positionPath" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $positionCSV -OutFile $positionPath
    Write-Host "SUCESS: Attempting to download $positionCSV to $positionPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Downloading $positionCSV to $positionPath" -ForegroundColor Red
}

$stintsPath = -join($path,"/","stints",".csv")
$stintsCSV = -join($openf1_base_url,"stints?csv=true")

Write-Host "INFO: Attempting to download $stintsCSV to $stintsPath" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $stintsCSV -OutFile $stintsPath
    Write-Host "SUCESS: Attempting to download $stintsCSV to $stintsPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Downloading $stintsCSV to $stintsPath" -ForegroundColor Red    
}

$weatherPath = -join($path,"/","weather",".csv")
$weatherCSV = -join($openf1_base_url,"weather?csv=true")

Write-Host "INFO: Attempting to download $weatherCSV to $weatherPath" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $weatherCSV -OutFile $weatherPath 
    Write-Host "SUCESS: Attempting to download $weatherCSV to $weatherPath" -ForegroundColor Green        
}
catch {
    Write-Host "ERROR: Downloading $weatherCSV to $weatherPath" -ForegroundColor Red    
}

$carDataPath = -join($path,"/","carData",".csv")
$carDataCSV = -join($openf1_base_url,"car_data?csv=true")

Write-Host "INFO: Attempting to download $carDataCSV to $carDataPath" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $carDataCSV -OutFile $carDataPath 
    Write-Host "SUCESS: Attempting to download $carDataCSV to $carDataPath" -ForegroundColor Green        
}
catch {
    Write-Host "ERROR: Downloading $carDataCSV to $carDataPath" -ForegroundColor Red    
}

$raceControlPath = -join($path,"/","raceControl",".csv")
$raceControlCSV = -join($openf1_base_url,"race_control?csv=true")

Write-Host "INFO: Attempting to download $raceControlCSV to $raceControlPath" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $raceControlCSV -OutFile $raceControlPath 
    Write-Host "SUCESS: Attempting to download $raceControlCSV to $raceControlPath" -ForegroundColor Green        
}
catch {
    Write-Host "ERROR: Downloading $raceControlCSV to $raceControlPath" -ForegroundColor Red    
}

$teamRadioPath = -join($path,"/","teamRadio",".csv")
$teamRadioCSV = -join($openf1_base_url,"team_radio?csv=true")

Write-Host "INFO: Attempting to download $teamRadioCSV to $teamRadioPath" -ForegroundColor Yellow

try {
    Invoke-WebRequest -Uri $teamRadioCSV -OutFile $teamRadioPath 
    Write-Host "SUCESS: Attempting to download $teamRadioCSV to $teamRadioPath" -ForegroundColor Green        
}
catch {
    Write-Host "ERROR: Downloading $teamRadioCSV to $teamRadioPath" -ForegroundColor Red    
}

$allFiles = Get-ChildItem $path -Filter *.csv
$total = $allFiles | Measure-Object | ForEach-Object { $_.Count }  

if($total -ne 9)
{
    Write-Host "Error: $total Files were downloaded to $path" -ForegroundColor Red
} else {    
    Write-Host "Success: $total Files were downloaded to $path" -ForegroundColor Green    
}