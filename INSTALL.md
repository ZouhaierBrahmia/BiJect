# BiJect Installation and Setup

This document describes how to set up the environment to use BiJect, including the Python tools, JSONiq engine, and datasets.


## Requirements

1. Python

- Version: 3.9+
- Purpose: Running the evaluation scripts, dataset loaders, validators, and latency measurements.

2. Python Libraries

- jsonschema (for JSON Schema validation)
- Install via pip:

pip install jsonschema


3. JSONiq Engine

- BiJect transformations require a JSONiq engine (tested with RumbleDB).
- Install and verify rumble is available in your PATH.


## Setup Instructions

1. Clone the Repository

git clone <your-repo-url>
cd BiJect


2. Verify Python Environment

python --version
pip show jsonschema


3. Check Datasets

- The global dataset index is located at:

datasets/index.json


- You can list available datasets using:

python tools/loader.py --list


4. Test Transformations

Example round-trip:

cd examples
rumble --query roundtrip.xq


5. Validate Dataset Instances

python tools/validate.py --index datasets/index.json


6. Compute Dataset Statistics

python tools/stats.py --index datasets/index.json


## Notes

- All scripts assume the directory structure of the BiJect repository is preserved.
- Optional tools like measure_latency.py and roundtrip_test.py require no additional setup beyond Python and jsonschema.
- Ensure rumble or your preferred JSONiq engine is installed and accessible from the command line.


## Metadata
- Authors: Zouhaier Brahmia and Fabio Grandi
- Purpose: Simplify environment setup, reproducibility, and usage of BiJect tools
- License: MIT License (see LICENSE.txt)