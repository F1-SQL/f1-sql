# User guide

Install the core package with Python 3.11 or newer:

```sh
python -m pip install .
```

Initialize a local pipeline workspace for a release target:

```sh
f1sql init 2024.1
```

Use `f1sql detect --season 2024` to inspect settled Jolpica rounds. The
command emits JSON decisions and can write GitHub Actions outputs with
`--github-output`.

Release archives contain a manifest, checksums, quality report, source
attribution, and the generated SQL Server backup. Verify an extracted release
with the package's `verify_release` API before restoring it. Restore and
upgrade instructions will be expanded when the SQL Server integration runner
is enabled.

