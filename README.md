# BiJect: Bidirectional JSON Schema Transformations

BiJect is a research prototype and artifact repository accompanying the article  
*"BiJect: Semantics-Preserving Bidirectional Transformations of JSON Schema Design Styles — Formal Foundations and JSONiq-Based Implementation"*  
by Zouhaier Brahmia and Fabio Grandi.  

BiJect provides:
- JSONiq libraries for performing bidirectional transformations between nested and reference-based JSON Schema designs.
- Industrial-style and synthetic datasets of JSON Schemas and instances.
- Reproducibility materials for evaluation (roundtrip tests, validation drivers, benchmarks).
This enables schema factorization, inlining, and round-trip consistency verification in both industrial and synthetic scenarios.


## Repository Structure

BiJect/
│
├── datasets/                   # All JSON Schema datasets (industrial + synthetic)
│   ├── index.json              # Global index mapping all datasets
│   ├── industrial/             # Industrial (sanitized) schemas & instances
│   └── synthetic/              # Synthetic datasets (small, medium, large, stress)
│
├── src/                        # Core BiJect libraries
│   ├── biject-factor.xq        # Factorization (nested → reference-based)
│   ├── biject-inline.xq        # Inlining (reference-based → nested)
│   └── biject.xq               # Wrapper re-exporting the above
│
├── examples/                   # Example scripts & demo inputs
│   ├── roundtrip.xq            # Round-trip test script
│   └── input-schema.json       # Sample schema for examples
│
├── tools                       # Python utilities for loading datasets, validating schemas, and computing stats.
│
├── requirements.txt            # Python dependencies (e.g., jsonschema) for tools and evaluation scripts
│
├── INSTALL.md                  # Optional installation instructions
│
├── CONTRIBUTING.md             # Optional contribution guidelines
│
├── CITATION.cff                # Citation file for Zotero/GitHub citation tools
│
├── README.md                   # Project overview, instructions, metadata
│
└── LICENSE                     # MIT License text

### Note on the `transform/` Folder

Some artifact repositories organize transformation scripts in a dedicated `transform/` folder. In BiJect, this is **not necessary**, because:

- All core transformation libraries are located in `src/`:
  - `biject-factor.xq` — nested → reference-based  
  - `biject-inline.xq` — reference-based → nested  
  - `biject.xq` — wrapper module that re-exports the above  
- Example usage of transformations is provided in `examples/` (`roundtrip.xq` with `input-schema.json`).  
- Python evaluation scripts in `tools/` handle validation, statistics, and round-trip testing.

This structure keeps the repository simple, avoids redundancy, and makes the roles of each folder clear for users and reviewers.


## Components

### Datasets

BiJect includes two types of datasets:

1. Industrial (sanitized)
- Order, Account, Sensor, SupplyChain, UserProfile schemas.
- Each with 2–3 realistic instances.
- Reflects a microservices e-commerce platform case study (cf. Section 8 of the article).

2. Synthetic
- Small, Medium, Large, and Stress test schemas.
- Designed to test correctness, scalability, and edge cases of the transformation algorithms.

See datasets/README.md for full details.

All datasets are indexed in datasets/index.json for easy programmatic access via the Python loader.


### Libraries (`src/`)
- biject-factor.xq: Converts nested schemas into reference-based schemas (factorization).
- biject-inline.xq: Converts reference-based schemas back into nested schemas (inlining).
- biject.xq: Wrapper module that re-exports the above libraries for convenience.

### Tools (`tools/`)
- loader.py: Python utility to iterate over schema/instance pairs from datasets/index.json.
- validate.py: Script to validate instances against schemas (supports nested, reference-based, and inlined schemas).
- stats.py: Summarizes the number of schemas and instances per dataset, useful for quick dataset health checks.
- measure_latency.py: Optional script to measure validation latency on large sets of instances.
- roundtrip_test.py: Automates nested → reference-based → nested round-trip tests, reporting semantic equivalence.

### Examples (`examples/`)
- roundtrip.xq: Demonstrates a full round-trip transformation (nested → reference-based → nested).
-. input-schema.json: Sample schema used in round-trip demonstration.

### Getting Started

#### Requirements
- JSONiq engine (tested with [RumbleDB](https://rumbledb.org/)).
- Python 3.9+ (for dataset loaders, validation utilities, and evaluation scripts).

You can install all Python dependencies using the included `requirements.txt`:

```bash
pip install -r requirements.txt

#### Example: Run a roundtrip transformation
```bash
cd examples
rumble --query roundtrip.xq

#### Example: Validate datasets
cd tools
python loader.py --validate ../datasets/index.json

#### Example: Check dataset stats
python loader.py --stats ../datasets/index.json

## Citation
If you use the BiJect dataset or libraries, please cite the following (preprint / under preparation):

```bibtex
@article{BrahmiaGrandi2025,
  author    = {Zouhaier Brahmia and Fabio Grandi},
  title     = {BiJect: Bidirectional Transformations of JSON Schemas},
  journal   = {Under preparation},
  year      = {2025},
  note      = {All experimental artifacts, datasets, and scripts are openly available in the BiJect repository.}
}

For automated citation, a CITATION.cff file is provided in the root of the repository.

## Metadata
- Authors: Zouhaier Brahmia and Fabio Grandi
- Purpose: Reproducibility, validation, and performance evaluation of bidirectional JSON Schema transformations
- License: MIT License (see LICENSE.txt)

   
## License
This repository is released under the MIT License.
© 2025 Zouhaier Brahmia and Fabio Grandi. See `LICENSE.txt` for details.
