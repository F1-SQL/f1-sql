# ADR 0002: Source ownership and reconciliation

* Status: Accepted
* Date: 2026-07-17

## Context

Jolpica-F1 and FastF1 overlap in some domains but have different strengths.
Selecting records opportunistically would make corrections unpredictable and
could change a release merely because a provider became available first.

## Decision

Each domain has one primary source. Secondary sources validate or enrich the
primary record but do not silently replace it.

| Domain | Primary source | Secondary purpose |
| --- | --- | --- |
| Seasons, rounds, races, circuits | Jolpica-F1 | FastF1 schedule validation |
| Drivers, constructors, championship entries | Jolpica-F1 | FastF1 display enrichment |
| Race, sprint, qualifying results and standings | Jolpica-F1 | FastF1 consistency checks |
| Meetings, sessions, actual session timing | FastF1 | Jolpica schedule comparison |
| Lap/sector timing, speeds, tyres, stints | FastF1 | Jolpica race-lap validation |
| Detailed pit timing | FastF1 | Jolpica official stop comparison |
| Weather, track/session status, race control | FastF1 | No Jolpica equivalent |

Jolpica-F1 provides historical championship coverage. Rich FastF1 timing data
will be considered available from 2018 onward. Earlier rows must expose their
coverage explicitly rather than fabricate or infer missing rich data.

The initial v2 scope excludes high-frequency telemetry. Continuous intervals,
continuous running position, and team radio will not be reproduced through
FastF1's legacy low-level API. They may be redesigned or reintroduced later if
an additional stable source is approved in a separate decision record.

## Identity rules

* Driver numbers are event/session attributes, not driver identities.
* Jolpica `driverId`, `constructorId`, and `circuitId` values are retained as
  stable external identifiers.
* Meetings use season and championship round as their durable natural key.
* Sessions use meeting plus normalized session type as their durable key.
* Provider-specific numeric keys are stored as external identifiers with
  provenance, not assumed to be universal identifiers.

## Reconciliation rules

1. Preserve raw values and source provenance before normalization.
2. Normalize timestamps to UTC and durations to a documented unit.
3. Record cross-source discrepancies in the quality report.
4. Fail the release for identity ambiguity, missing official race results, or
   contradictions in winner, round, or participant mappings.
5. Permit documented tolerances for provider-specific timing precision and
   data that is explicitly optional.
