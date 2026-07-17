# Legacy data provenance audit

* Status: Required before the first public v2 release
* Created: 2026-07-17

## Purpose

The repository contains historical data gathered under earlier Ergast and
OpenF1-based workflows. Changing the repository's software licence does not
relicense that third-party material. These paths are retained during the
rebuild but are not approved as v2 release inputs until their provenance and
applicable terms have been reviewed.

## Inventory

| Path | Likely role/origin | v2 status | Required action |
| --- | --- | --- | --- |
| `src/archived/` | Legacy scripts, reference data, and old race exports | Excluded | Identify source and historic terms by dataset |
| `src/files/` | Processed OpenF1-era CSV data and static lookups | Excluded | Separate authored lookup data from downloaded data |
| `src/sourceFiles/` | Compressed historic race source exports | Excluded | Identify Ergast/source terms and release provenance |
| Future `data/raw/` | Immutable source responses | Source-specific | Record endpoint, retrieval time, terms, and hash |
| Future `data/normalized/` | F1 SQL normalized v2 records | Conditional | Include only records with approved provenance |

## Audit record requirements

For every dataset admitted to the v2 build, record:

* provider and source URL or API endpoint;
* retrieval or creation date;
* applicable terms and licence at retrieval time;
* whether the file is raw source material or an F1 SQL transformation;
* checksum and storage location;
* permitted distribution scope; and
* attribution text required in a public release.

The eventual machine-readable inventory should be validated by CI. A missing
or unapproved provenance record must block public packaging.
