![](images/git-banner.png)

# Formula One Database
The Formula One Microsoft SQL Server database is developed and maintained for education and demonstration purposes using open source Formula One Data freely available from the [Ergast API](https://ergast.com/mrd/) 

* Open Source
* Free
 ## Source Of Data

Data used in this project was obtained from the [Ergast database image project](https://ergast.com/mrd/db/). 

**07/08/2023** - This includes data from the 2023 Belgian GP.

If any data is missing or incorrect please submit an issue and it can be updated or feel free to submit a pull request.

## Getting Started

First, you are going to need to clone the repo.

`git clone https://github.com/RichInSQL/RichInF1.git`

Alternatively you can download the latest release. 

Once you have the repo cloned navigate to the backups folder in the root of the download and restore a backup to your version of SQL Server, it is that simple.

## Example Queries

Example queries that you can run against the dataset are provided in the `example_queries` folder within the repo.

If you would like to contribute to building a collection of queries for this dataset, please open a Pull Request.

## Database Relationship Diagram

![DatabaseDiagram](/images/ergast_db.png)
*This image is provided by Ergast and is published here for continuity*

## Database Documentation

This documentation is taken from [https://ergast.com/docs/f1db_user_guide.txt](https://ergast.com/docs/f1db_user_guide.txt) and placed here for reference, it has been modified to match the Microsoft SQL Server definitions.


| List of Tables       |
|----------------------|
| circuits             |
| constructorResults   |
| constructorStandings |
| constructors         |
| driverStandings      |
| drivers              |
| lapTimes             |
| pitStops             |
| qualifying           |
| races                |
| results              |
| seasons              |
| status               |

| General Notes                                                    |
|------------------------------------------------------------------|
| Dates, times and durations are in ISO 8601 format                |
| Dates and times are UTC                                          |
| Strings use UTF-8 encoding                                       |
| Primary keys are for internal use only                           |
| Fields ending with "Ref" are UNIQUEque identifiers for external use |
| A grid position of '0' is used for starting from the pitlane     |
| Labels used in the positionText fields:                          |
|   "D" - disqualified                                             |
|   "E" - excluded                                                 |
|   "F" - failed to qualify                                        |
|   "N" - not classified                                           |
|   "R" - retired                                                  |
|   "W" - withdrew                                                 |

## Circuits table

| Field      | Type         | Null | Key | Default | Extra          | Description               |
|------------|--------------|------|-----|---------|----------------|---------------------------|
| circuitId  | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key               |
| circuitRef | varchar(255) | NO   |     |         |                | UNIQUEque circuit identifier |
| name       | varchar(255) | NO   |     |         |                | Circuit name              |
| location   | varchar(255) | YES  |     | NULL    |                | Location name             |
| country    | varchar(255) | YES  |     | NULL    |                | Country name              |
| lat        | float        | YES  |     | NULL    |                | Latitude                  |
| lng        | float        | YES  |     | NULL    |                | Longitude                 |
| alt        | int          | YES  |     | NULL    |                | Altitude (metres)         |
| url        | varchar(255) | NO   | UNIQUE |         |                | Circuit Wikipedia page    |

## constructor_results table

| Field                | Type         | Null | Key | Default | Extra          | Description                            |
|----------------------|--------------|------|-----|---------|----------------|----------------------------------------|
| constructorResultsId | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                            |
| raceId               | int          | NO   |     | 0       |                | Foreign key link to races table        |
| constructorId        | int          | NO   |     | 0       |                | Foreign key link to constructors table |
| points               | float        | YES  |     | NULL    |                | Constructor points for race            |
| status               | varchar(255) | YES  |     | NULL    |                | "D" for disqualified (or null)         |

## constructor_standings table

| Field                  | Type         | Null | Key | Default | Extra          | Description                              |
|------------------------|--------------|------|-----|---------|----------------|------------------------------------------|
| constructorStandingsId | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                              |
| raceId                 | int          | NO   |     | 0       |                | Foreign key link to races table          |
| constructorId          | int          | NO   |     | 0       |                | Foreign key link to constructors table   |
| points                 | float        | NO   |     | 0       |                | Constructor points for season            |
| position               | int          | YES  |     | NULL    |                | Constructor standings position (integer) |
| positionText           | varchar(255) | YES  |     | NULL    |                | Constructor standings position (string)  |
| wins                   | int          | NO   |     | 0       |                | Season win count                         |

## constructors table

| Field          | Type         | Null | Key | Default | Extra          | Description                   |
|----------------|--------------|------|-----|---------|----------------|-------------------------------|
| constructorId  | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                   |
| constructorRef | varchar(255) | NO   |     |         |                | UNIQUEque constructor identifier |
| name           | varchar(255) | NO   | UNIQUE |         |                | Constructor name              |
| nationality    | varchar(255) | YES  |     | NULL    |                | Constructor nationality       |
| url            | varchar(255) | NO   |     |         |                | Constructor Wikipedia page    |

## driver_standings table

| Field             | Type         | Null | Key | Default | Extra          | Description                         |
|-------------------|--------------|------|-----|---------|----------------|-------------------------------------|
| driverStandingsId | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                         |
| raceId            | int          | NO   |     | 0       |                | Foreign key link to races table     |
| driverId          | int          | NO   |     | 0       |                | Foreign key link to drivers table   |
| points            | float        | NO   |     | 0       |                | Driver points for season            |
| position          | int          | YES  |     | NULL    |                | Driver standings position (integer) |
| positionText      | varchar(255) | YES  |     | NULL    |                | Driver standings position (string)  |
| wins              | int          | NO   |     | 0       |                | Season win count                    |

## drivers table

| Field       | Type         | Null | Key | Default | Extra          | Description              |
|-------------|--------------|------|-----|---------|----------------|--------------------------|
| driverId    | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key              |
| driverRef   | varchar(255) | NO   |     |         |                | UNIQUEque driver identifier |
| number      | int          | YES  |     | NULL    |                | Permanent driver number  |
| code        | varchar(3)   | YES  |     | NULL    |                | Driver code e.g. "ALO"   |
| forename    | varchar(255) | NO   |     |         |                | Driver forename          |
| surname     | varchar(255) | NO   |     |         |                | Driver surname           |
| dob         | date         | YES  |     | NULL    |                | Driver date of birth     |
| nationality | varchar(255) | YES  |     | NULL    |                | Driver nationality       |
| url         | varchar(255) | NO   | UNIQUE |         |                | Driver Wikipedia page    |

## lap_times table

| Field        | Type         | Null | Key | Default | Extra | Description                       |
|--------------|--------------|------|-----|---------|-------|-----------------------------------|
| raceId       | int          | NO   | PRI | NULL    |       | Foreign key link to races table   |
| driverId     | int          | NO   | PRI | NULL    |       | Foreign key link to drivers table |
| lap          | int          | NO   | PRI | NULL    |       | Lap number                        |
| position     | int          | YES  |     | NULL    |       | Driver race position              |
| time         | varchar(255) | YES  |     | NULL    |       | Lap time e.g. "1:43.762"          |
| milliseconds | int          | YES  |     | NULL    |       | Lap time in milliseconds          |

## pit_stops table

| Field        | Type         | Null | Key | Default | Extra | Description                       |
|--------------|--------------|------|-----|---------|-------|-----------------------------------|
| raceId       | int          | NO   | PRI | NULL    |       | Foreign key link to races table   |
| driverId     | int          | NO   | PRI | NULL    |       | Foreign key link to drivers table |
| stop         | int          | NO   | PRI | NULL    |       | Stop number                       |
| lap          | int          | NO   |     | NULL    |       | Lap number                        |
| time         | time         | NO   |     | NULL    |       | Time of stop e.g. "13:52:25"      |
| duration     | varchar(255) | YES  |     | NULL    |       | Duration of stop e.g. "21.783"    |
| milliseconds | int          | YES  |     | NULL    |       | Duration of stop in milliseconds  |

## qualifying table

| Field         | Type         | Null | Key | Default | Extra          | Description                            |
|---------------|--------------|------|-----|---------|----------------|----------------------------------------|
| qualifyId     | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                            |
| raceId        | int          | NO   |     | 0       |                | Foreign key link to races table        |
| driverId      | int          | NO   |     | 0       |                | Foreign key link to drivers table      |
| constructorId | int          | NO   |     | 0       |                | Foreign key link to constructors table |
| number        | int          | NO   |     | 0       |                | Driver number                          |
| position      | int          | YES  |     | NULL    |                | Qualifying position                    |
| q1            | varchar(255) | YES  |     | NULL    |                | Q1 lap time e.g. "1:21.374"            |
| q2            | varchar(255) | YES  |     | NULL    |                | Q2 lap time                            |
| q3            | varchar(255) | YES  |     | NULL    |                | Q3 lap time                            |

## races table

| Field       | Type         | Null | Key | Default    | Extra          | Description                        |
|-------------|--------------|------|-----|------------|----------------|------------------------------------|
| raceId      | int          | NO   | PRI | NULL       | IDENTITY(1,1)  | Primary key                        |
| year        | int          | NO   |     | 0          |                | Foreign key link to seasons table  |
| round       | int          | NO   |     | 0          |                | Round number                       |
| circuitId   | int          | NO   |     | 0          |                | Foreign key link to circuits table |
| name        | varchar(255) | NO   |     |            |                | Race name                          |
| date        | date         | NO   |     | 0000-00-00 |                | Race date e.g. "1950-05-13"        |
| time        | time         | YES  |     | NULL       |                | Race start time e.g."13:00:00"     |
| url         | varchar(255) | YES  | UNIQUE | NULL       |                | Race Wikipedia page                |
| fp1_date    | date         | YES  |     | NULL       |                | FP1 date                           |
| fp1_time    | time         | YES  |     | NULL       |                | FP1 start time                     |
| fp2_date    | date         | YES  |     | NULL       |                | FP2 date                           |
| fp2_time    | time         | YES  |     | NULL       |                | FP2 start time                     |
| fp3_date    | date         | YES  |     | NULL       |                | FP3 date                           |
| fp3_time    | time         | YES  |     | NULL       |                | FP3 start time                     |
| quali_date  | date         | YES  |     | NULL       |                | Qualifying date                    |
| quali_time  | time         | YES  |     | NULL       |                | Qualifying start time              |
| sprint_date | date         | YES  |     | NULL       |                | Sprint date                        |
| sprint_time | time         | YES  |     | NULL       |                | Sprint start time                  |

## results table

| Field           | Type         | Null | Key | Default | Extra          | Description                                 |
|-----------------|--------------|------|-----|---------|----------------|---------------------------------------------|
| resultId        | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                                 |
| raceId          | int          | NO   |     | 0       |                | Foreign key link to races table             |
| driverId        | int          | NO   |     | 0       |                | Foreign key link to drivers table           |
| constructorId   | int          | NO   |     | 0       |                | Foreign key link to constructors table      |
| number          | int          | YES  |     | NULL    |                | Driver number                               |
| grid            | int          | NO   |     | 0       |                | Starting grid position                      |
| position        | int          | YES  |     | NULL    |                | Official classification, if applicable      |
| positionText    | varchar(255) | NO   |     |         |                | Driver position string e.g. "1" or "R"      |
| positionOrder   | int          | NO   |     | 0       |                | Driver position for ordering purposes       |
| points          | float        | NO   |     | 0       |                | Driver points for race                      |
| laps            | int          | NO   |     | 0       |                | Number of completed laps                    |
| time            | varchar(255) | YES  |     | NULL    |                | Finishing time or gap                       |
| milliseconds    | int          | YES  |     | NULL    |                | Finishing time in milliseconds              |
| fastestLap      | int          | YES  |     | NULL    |                | Lap number of fastest lap                   |
| rank            | int          | YES  |     | 0       |                | Fastest lap rank, compared to other drivers |
| fastestLapTime  | varchar(255) | YES  |     | NULL    |                | Fastest lap time e.g. "1:27.453"            |
| fastestLapSpeed | varchar(255) | YES  |     | NULL    |                | Fastest lap speed (km/h) e.g. "213.874"     |
| statusId        | int          | NO   |     | 0       |                | Foreign key link to status table            |

## sprint_results table

| Field           | Type         | Null | Key | Default | Extra          | Description                                 |
|-----------------|--------------|------|-----|---------|----------------|---------------------------------------------|
| sprintResultId  | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                                 |
| raceId          | int          | NO   |     | 0       |                | Foreign key link to races table             |
| driverId        | int          | NO   |     | 0       |                | Foreign key link to drivers table           |
| constructorId   | int          | NO   |     | 0       |                | Foreign key link to constructors table      |
| number          | int          | YES  |     | NULL    |                | Driver number                               |
| grid            | int          | NO   |     | 0       |                | Starting grid position                      |
| position        | int          | YES  |     | NULL    |                | Official classification, if applicable      |
| positionText    | varchar(255) | NO   |     |         |                | Driver position string e.g. "1" or "R"      |
| positionOrder   | int          | NO   |     | 0       |                | Driver position for ordering purposes       |
| points          | float        | NO   |     | 0       |                | Driver points for race                      |
| laps            | int          | NO   |     | 0       |                | Number of completed laps                    |
| time            | varchar(255) | YES  |     | NULL    |                | Finishing time or gap                       |
| milliseconds    | int          | YES  |     | NULL    |                | Finishing time in milliseconds              |
| fastestLap      | int          | YES  |     | NULL    |                | Lap number of fastest lap                   |
| fastestLapTime  | varchar(255) | YES  |     | NULL    |                | Fastest lap time e.g. "1:27.453"            |
| statusId        | int          | NO   |     | 0       |                | Foreign key link to status table            |

## seasons table

| Field | Type         | Null | Key | Default | Extra | Description           |
|-------|--------------|------|-----|---------|-------|-----------------------|
| year  | int          | NO   | PRI | 0       |       | Primary key e.g. 1950 |
| url   | varchar(255) | NO   | UNIQUE |         |       | Season Wikipedia page |

## status table

| Field    | Type         | Null | Key | Default | Extra          | Description                     |
|----------|--------------|------|-----|---------|----------------|---------------------------------|
| statusId | int          | NO   | PRI | NULL    | IDENTITY(1,1)  | Primary key                     |
| status   | varchar(255) | NO   |     |         |                | Finishing status e.g. "Retired" |
