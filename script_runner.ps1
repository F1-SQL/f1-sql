<#
    .SYNOPSIS
        Runs the SQL Server database build.

    .DESCRIPTION
        Gets the race round, race name and required dates so that the build database processes can be run.

    .PARAMETER fileLocation
        The location of the f1 sql files
        
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

$currentDate = (Get-Date)
$today = $currentDate.Date
$dayOfWeek = [int]$currentDate.DayOfWeek

if ($dayOfWeek -eq 0) {
    $dayOfWeek = 7
}

$daysToPreviousFriday = $dayOfWeek + 2
$daysToPreviousSunday = $dayOfWeek

$fridayDate = $currentDate.AddDays(-$daysToPreviousFriday).Date
$sundayDate = $currentDate.AddDays(-$daysToPreviousSunday).Date

$fileLocation = "D:\workspace\F1-SQL\f1-sql\"
$scriptName = "build_database.ps1"
$jsonPath = -join($fileLocation,"\raceCalendar.json")

if(Test-Path $fileLocation)
{
    Write-Host "$fileLocation Exists" -ForegroundColor Green
    if(Test-Path $jsonPath -PathType Leaf)
    {
        Write-Host "Race Calendar Exists" -ForegroundColor Green
        $raceCalendarStr = Get-Content $jsonPath | Out-String
        try {
            $raceCalendar = $raceCalendarStr | ConvertFrom-Json
        }
        catch {
            Write-Host "There was an error processing the JSON" -ForegroundColor Red
            Exit
        }        
        $selectedRace = $raceCalendar.Formula1RaceCalendar | Where-Object { $_.Date -ge $fridayDate.ToString("yyyy-MM-dd") -and $_.Date -le $sundayDate.ToString("yyyy-MM-dd") }
        
        foreach ($race in $selectedRace) {
            $raceDateStr = $race.Date
            $raceDate = [datetime]$raceDateStr
            $round = $race.Round   
            $raceName = $race.RaceName 
        }

        $mondayAfterRace = $raceDate.AddDays(1).Date

        if($today -eq $mondayAfterRace)
        {
            Write-Host "Let's Begin"  
            $commandPath = -join($fileLocation,$scriptName)
            Invoke-Expression "$commandPath -databaseName SequelFormula -sqlInstance 'RIS-001\SQLEXPRESS16','RIS-001\SQLEXPRESS17','RIS-001\SQLEXPRESS19','RIS-001\SQLEXPRESS22' -cleanInstance $true -backupDatabase $true -downloadzip $true -round $round" 
        } else 
        {
            Write-Host "$today isn't the Monday after the race"
            Exit
        }
    }else {
        Write-Host "Race Calendar Doesn't Exist" -ForegroundColor Red
        Exit
    }
} else {
    Write-Host "Location Provided Doesn't Exist" -ForegroundColor Red
    Exit
}