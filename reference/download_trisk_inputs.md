# Download TRISK input data files from a specified endpoint

This function downloads TRISK input data files from a specified endpoint
URL and saves them to a local folder. It ensures that the local folder
exists before downloading the files. If the folder does not exist, it is
created. Package-level variables for \`endpoint\` and \`s3_prefix\` are
used if not provided as parameters.

## Usage

``` r
download_trisk_inputs(
  local_save_folder,
  endpoint = NULL,
  s3_prefix = NULL,
  skip_confirmation = FALSE
)
```

## Arguments

- local_save_folder:

  Where to download outputs locally.

- endpoint:

  URL of the endpoint (optional; defaults to
  \`TRISK_DATA_INPUT_ENDPOINT\` from the package).

- s3_prefix:

  Prefix for the files in the S3 bucket (optional; defaults to
  \`TRISK_DATA_S3_PREFIX\` from the package).

- skip_confirmation:

  Set to true to allow CI/CD building of vignettes

## Value

TRUE if all files are downloaded successfully, FALSE otherwise.

## Provenance (DL1)

This fetches the public reference \*\*scenarios\*\* dataset only. The
other model inputs - \`assets\`, \`financial_features\`, and
\`ngfs_carbon_prices\` - are \*\*not\*\* downloaded here; they are
institution-specific and must be supplied by the user in the documented
schema. Use \[setup_trisk_inputs()\] to scaffold a folder with the
required files, column schemas, and filled samples for every input, and
see the "Inputs and outputs" vignette for the expected formats.
