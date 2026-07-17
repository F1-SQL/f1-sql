# Data and software attribution

F1 SQL is an unofficial, community-maintained project. It builds a Microsoft
SQL Server database from openly accessible Formula One data sources.

## Jolpica-F1

Championship, schedule, circuit, driver, constructor, result, qualifying,
sprint, lap, pit-stop, status, and standings data may be obtained from the
[Jolpica-F1 API](https://api.jolpi.ca/ergast/).

Jolpica-F1 API data is made available for non-commercial use under
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
Jolpica-F1 is a volunteer-run project and does not guarantee availability or
correctness. Use of its API is also subject to its
[terms of use](https://github.com/jolpica/jolpica-f1/blob/main/TERMS.md).

F1 SQL transforms this material into a relational schema. Each release must
identify the source endpoints, retrieval time, transformations, and source
fingerprints in its build manifest.

## FastF1

Session timing, lap, tyre, stint, weather, status, and race-control data may be
processed with [FastF1](https://github.com/theOehrly/Fast-F1), which is
licensed under the MIT License.

FastF1's software licence does not grant additional rights over data obtained
from upstream Formula One services. Generated F1 SQL data remains subject to
`LICENSE-DATA` and any applicable upstream terms.

## Formula One marks

F1 SQL is not associated with Formula 1, the FIA, or their affiliated
companies. All Formula One-related marks belong to their respective owners.

## Images

The repository banner uses a photograph credited in the README. That image is
not relicensed under Apache-2.0, CC BY 4.0, or CC BY-NC-SA 4.0 unless its own
licence expressly says so.
