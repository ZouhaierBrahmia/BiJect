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
  ├── datasets/                  # All JSON Schema datasets (sanitized industrial + synthetic)  
  │     ├── index.json           # Global index mapping all datasets  
  │     ├── industrial/          # Industrial (sanitized) schemas & instances  
  │     └── synthetic/           # Synthetic datasets (small, medium, large, stress)  
  ├── src/                       # Core BiJect libraries (used in experiments)  
  │     ├── biject-factor.xq     # Factorization (nested → reference-based)  
  │     ├── biject-inline.xq     # Inlining (reference-based → nested)  
  │     └── biject.xq            # Wrapper re-exporting factor & inline  
  ├── demo/                      # Illustrative scripts (used for demonstration only)  
  │     ├── nest-2-ref.xq        # Direct factoring script  
  │     ├── ref-2-nest.xq        # Direct inlining script  
  │     └── biject-unified.xq    # Illustrative unified module  
  ├── examples/                  # Usage examples combining datasets + src/ modules  
  │     ├── roundtrip.xq         # Round-trip test script  
  │     └── input-schema.json    # Sample schema for examples  
  ├── tools/                     # Python utilities for loading datasets, validating schemas, and computing stats  
  ├── requirements.txt           # Python dependencies (e.g., jsonschema) for tools and evaluation scripts  
  ├── INSTALL.md                 # Optional installation instructions  
  ├── CITATION.cff               # Citation file for Zotero/GitHub citation tools  
  ├── README.md                  # Project overview, instructions, metadata  
  └── LICENSE                    # MIT License text  


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
- biject-factor.xq: the Factoring library that converts nested schemas into reference-based schemas.
- biject-inline.xq: the Inlining library that converts reference-based schemas back into nested schemas.
- biject.xq: the Wrapper module that re-exports the above libraries for convenience.

### Demonstration (`demo/`)
- nest-2-ref.xq: the direct factoring script that transforms a nested schema into a reference-based schema.
- ref-2-nest.xq: the direct inlining script that transforms a reference-based schema into a nested schema.
- biject-unified.xq: the illustrative module that unifies the above two direct transformation scripts.

### 🔹 About src/ vs demo/

1. src/

Contains the JSONiq libraries (biject-factor.xq, biject-inline.xq) and the wrapper module (biject.xq).

These were used in our experiments and are the recommended entry point for practical integration in projects.

2. demo/

Contains the illustrative scripts described in Section 7.1 and Appendix A2 of the BiJect article:

- Two direct transformation scripts (nest-2-ref.xq, ref-2-nest.xq).

- One unified illustrative module (biject-unified.xq) exposing both transformations for quick testing.

These scripts are intended for demonstration and educational purposes only, and were not used in the experimental evaluation.


### Tools (`tools/`)
- loader.py: Python utility to iterate over schema/instance pairs from datasets/index.json.
- validate.py: Script to validate instances against schemas (supports nested, reference-based, and inlined schemas).
- stats.py: Summarizes the number of schemas and instances per dataset, useful for quick dataset health checks.
- measure_latency.py: Optional script to measure validation latency on large sets of instances.
- roundtrip_test.py: Automates nested → reference-based → nested round-trip tests, reporting semantic equivalence.

### Examples (`examples/`)
- roundtrip.xq: Demonstrates a full round-trip transformation (nested → reference-based → nested).
- input-schema.json: Sample schema used in round-trip demonstration.

### Getting Started

#### Requirements
- JSONiq engine (tested with [RumbleDB](https://rumbledb.org/)).
- Python 3.9+ (for dataset loaders, validation utilities, and evaluation scripts).

You can install all Python dependencies using the included `requirements.txt`:

pip install -r requirements.txt

#### Example: Run a roundtrip transformation

cd examples
rumble --query roundtrip.xq

#### Example: Validate datasets
cd tools
python loader.py --validate ../datasets/index.json

#### Example: Check dataset stats
python loader.py --stats ../datasets/index.json

## Citation
If you use the BiJect dataset or libraries, please cite the following (preprint / under preparation):

@article{BrahmiaGrandi2025,  
  author    = {Zouhaier Brahmia and Fabio Grandi},  
  title     = {BiJect: Semantics-Preserving Bidirectional Transformations of JSON Schema Design Styles — Formal Foundations and JSONiq-Based Implementation},  
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
This repository is released as follows:
- Code (in `src/`, `examples/`, `tools/`): MIT License.  
- Datasets (in `datasets/`): CC-BY 4.0 (open datasets for research and teaching).  

© 2025 Zouhaier Brahmia and Fabio Grandi. See `LICENSE.txt` for details.
