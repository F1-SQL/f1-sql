<#
    .SYNOPSIS
        Runs the SQL Server database build.

    .DESCRIPTION
        Gets the race round, race name and required dates so that the build database processes can be run.

    .PARAMETER fileLocation
        The location of the project files
        
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
        PS C:\> .\script_runner.ps1 -fileLocation "D:\f1-sql\f1-sql-files"        
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 4, ValueFromPipeline = $false)]
        [System.String]
        $fileLocation
        )

$logName = 'F1SQL-RunnerLog-'
$logFileName = $logName + (Get-Date -f yyyy-MM-dd-HH-mm) + ".log"
$logFullPath =  -join($fileLocation,'logs\',$logFileName)
$logFileLimit = (Get-Date).AddDays(-15)

if(-Not(Test-Path -Path $logFullPath -PathType Leaf))
{
    try 
    {
        $null =  New-Item -ItemType File -Path $logFullPath -Force -ErrorAction Stop
        Add-Content -Path $logFullPath -Value "$(Get-Date -f yyyy-MM-dd-HH-mm) - The log file '$logFileName' has been created"
    }
    catch 
    {
        Add-Content -Path $logFullPath -Value "$(Get-Date -f yyyy-MM-dd-HH-mm) - Unable to log file in '$logFullPath'. The Error was: $error"
    }
}

try {
    Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Attempting to delete old log files"
    Get-ChildItem -Path $logFullPath -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $logFileLimit } | Remove-Item -Force
    Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Old log files deleted"

}
catch {
    Add-Content -Path $logFullPath -Value "$(Get-Date -f yyyy-MM-dd-HH-mm) - Unable to delete old log files from '$logFullPath'. The Error was: $error"
}

Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Attempting to delete old log files"
$currentDate = (Get-Date)
Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Attempting to delete old log files"
$today = $currentDate.Date
Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Attempting to delete old log files"
$dayOfWeek = [int]$currentDate.DayOfWeek

if ($dayOfWeek -eq 0) {
    $dayOfWeek = 7
}

$daysToPreviousFriday = $dayOfWeek + 2
$daysToPreviousSunday = $dayOfWeek

Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Getting the friday of the previous week"
$fridayDate = $currentDate.AddDays(-$daysToPreviousFriday).Date
Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $fridayDate found, for the previous Sunday."
Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Getting Sunday of the previous week"
$sundayDate = $currentDate.AddDays(-$daysToPreviousSunday).Date
Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $sundayDate found, for the previous Sunday."

$scriptName = "build_database.ps1"
$raceCalendarPath = -join($fileLocation,"\raceCalendar.json")

if(Test-Path $fileLocation)
{
    Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $fileLocation Exists"
    if(Test-Path $raceCalendarPath -PathType Leaf)
    {
        Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $raceCalendarPath Exists"
        $raceCalendarStr = Get-Content $raceCalendarPath | Out-String
        try {
            $raceCalendar = $raceCalendarStr | ConvertFrom-Json
        }
        catch {
            Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - There was an error processing the JSON, The Error was: $error"
            Exit
        }

        $selectedRace = $raceCalendar.Formula1RaceCalendar | Where-Object { $_.Date -ge $fridayDate.ToString("yyyy-MM-dd") -and $_.Date -le $sundayDate.ToString("yyyy-MM-dd") }
        
        foreach ($race in $selectedRace) {
            Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Getting parameters from JSON"
            $raceDateStr = $race.Date
            $raceDate = [datetime]$raceDateStr
            $round = $race.Round   
            $processDate = $race.ProcessDate
        }

        Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $raceDate found, looks like this is round $round"

        if($today -eq $processDate)
        {
            Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Process date is today, attempting to begin"
            Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Attempting to download files" 
            $raceFilesPath = -join($fileLocation,"\src\files")
            $fileDownloaderPath -join($fileLocation,"file-downloader.ps1")
            
            Invoke-Expression "$fileDownloaderPath -sourceFilesFullPath $raceFilesPath -calendarPath $raceCalendarPath -round $round"
            Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - Running database builder" 
            $buildCommandPath = -join($fileLocation,$scriptName)
            Invoke-Expression "$buildCommandPath -databaseName SequelFormula -sqlInstance 'RIS-001\SQLEXPRESS16','RIS-001\SQLEXPRESS17','RIS-001\SQLEXPRESS19','RIS-001\SQLEXPRESS22' -cleanInstance $true -backupDatabase $true -downloadzip $true -round $round" 
        } else 
        {
            Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $today isn't the process date, ending"
            Exit
        }
    }else {
        Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $jsonPath doesn't exist"
        Exit
    }
} else {
    Add-Content -Path $logFullPath -Value "$(Get-Date -f "yyyy-MM-dd-HH-mm") - $fileLocation provided doesn't exist"
    Exit
}