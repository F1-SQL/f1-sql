# Normalization units and reconciliation tolerances

All normalized timestamps are timezone-aware UTC values. A source timestamp
without an offset is treated as UTC only when the source contract documents it
as UTC; otherwise the adapter must report a source error. Durations are stored
as integer milliseconds, rounded half-up from the source precision.

Cross-source comparisons use these tolerances:

| Value | Tolerance | Rationale |
| --- | ---: | --- |
| lap/result duration | 1 ms | Jolpica text and FastF1 timedeltas have different display precision |
| speed | 0.001 km/h | preserve source precision without false conflicts |
| circuit latitude/longitude | 0.000001 degrees | sub-metre-scale source rounding |

Values outside tolerance produce a warning discrepancy. Identity conflicts,
contradictory classifications, and ambiguous source mappings are errors and
block release. Primary-source choices are implemented by `SourcePolicy` and
follow [ADR 0002](architecture/0002-source-ownership.md).
