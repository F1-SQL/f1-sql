# Legacy table inventory and v2 disposition

This matrix is the starting point for the schema-v2 migration. “Retain” means
the concept remains, “redesign” means the concept remains but keys/types or
grain change, “replace” means a new source-neutral table replaces the legacy
shape, and “retire” means it is outside v2 scope.

| Legacy table | Disposition | v2 direction |
| --- | --- | --- |
| `seasons` | redesign | UTC-safe season dimension with stable season key |
| `meetings` | redesign | Jolpica meeting plus FastF1 event identity and source IDs |
| `circuits` | redesign | bounded coordinates, stable circuit identity, external IDs |
| `locations`, `countries` | retain/redesign | reference dimensions used by circuits and drivers |
| `meetingTypes`, `sessionTypes` | retain/redesign | controlled reference values with checks |
| `sessions` | redesign | explicit meeting/session grain and UTC start/end |
| `drivers` | redesign | source-neutral driver identity and external identifiers |
| `teams` | redesign | source-neutral constructor/team identity and external identifiers |
| `driverMeeting`, `driverSession`, `driverTeam` | replace | participant and assignment facts with event/session grain |
| `laps` | redesign | FastF1 lap facts with documented units and optional fields |
| `stints` | redesign | tyre stint facts tied to session and driver |
| `pitStops` | redesign | Jolpica/FastF1 pit-stop facts with source evidence |
| `weather` | redesign | timestamped session weather with UTC semantics |
| `position` | redesign | retain only supported positional samples; no invented gaps |
| `raceControl` | redesign | structured messages with source and UTC timestamp |
| `intervals` | retire from v2 | continuous interval scope is deferred by ADR 0002 |
| `teamRadio` | retire from v2 | audio/metadata scope is deferred by ADR 0002 |
| `teamColours`, `teamMeetingSessionColour`, `compoundTypes` | retain/redesign | reference and presentation metadata with bounded values |

The legacy `Tables/` and `scripts/` directories remain migration reference
material. They are not v2 DDL and must not be executed by the autonomous build.
Any table not listed here requires an explicit inventory update before it can
enter the v2 schema.
