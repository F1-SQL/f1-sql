# Offline pipeline contract

`f1sql.pipeline.run_offline_fixture_pipeline` is the CI acceptance path for a
single representative round. It performs these stages in order:

1. normalize Jolpica results and FastF1 session records into a
   `NormalizationBundle`;
2. construct the deterministic foreign-key-safe `LoadPlan`;
3. reconcile FastF1 session results with Jolpica classifications;
4. run fail-closed quality rules, explicit coverage expectations, and
   normalized-to-load-plan row-count reconciliation; and
5. package normalized data, the load plan, raw fixture snapshots, provenance,
   and release documents.

Packaging is never attempted when the quality report contains an error. The
offline path intentionally does not claim to create a SQL Server backup; live
SQL execution, backup, restore, and `DBCC CHECKDB` remain integration gates.
