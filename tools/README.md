# BiJect Tools

This folder contains Python utilities for working with the BiJect datasets, validating JSON Schema instances, measuring performance, and automating round-trip tests.

For installation and setup instructions, please see INSTALL.md.

## Contents
File	                 |   Purpose
-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------
loader.py	             |   Iterate over schema/instance pairs from datasets/index.json, list datasets, print pairs, and optionally validate instances.
validate.py	             |   Standalone script to validate instances against schemas (supports nested, reference-based, and inlined schemas).
stats.py	             |   Summarize the number of schemas and instances per dataset. Useful for quick dataset health checks.
measure_latency.py	     |   Measure average JSON Schema validation latency for all schema/instance pairs. Supports multiple repetitions and outputs results as JSON.
roundtrip_test.py	     |   Automate nested → reference-based → nested round-trip transformations, reporting semantic equivalence between the original and final schemas.                      
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## Usage Examples

> **Note:** All commands below assume you are in the `tools/` folder.  
> Adjust paths (e.g., `../datasets/index.json`) if running from another location.


1. List available datasets  
python loader.py --list

Example output:  
industrial  
industrial/order  
synthetic/small  
synthetic/small/schema1  
...

2. Print schema-instance pairs  
python loader.py --pairs --dataset industrial

Or as JSON:  
python loader.py --pairs --dataset industrial --json

3. Validate all instances in a dataset  
python loader.py --dataset synthetic/medium

This will print success/failure for each schema-instance pair.

4. Compute dataset statistics  
python stats.py --index ../datasets/index.json

Sample output:  
Dataset: industrial  
  Schemas: 5  
  Instances: 15  

Dataset: synthetic/small  
  Schemas: 1  
  Instances: 2  
...

5. Measure validation latency  
python measure_latency.py --index ../datasets/index.json --repeats 10

6. Run round-trip transformation tests  
python roundtrip_test.py --index ../datasets/index.json

## Requirements

- Python 3.9+
- Dependencies listed in requirements.txt

To install dependencies:   
pip install -r requirements.txt

## Testing

To quickly check that all tools run without error:  
python validate.py --index ../datasets/index.json  
python stats.py --index ../datasets/index.json

## Metadata
- Authors: Zouhaier Brahmia and Fabio Grandi
- Purpose: Reproducibility, validation, performance evaluation, and round-trip consistency verification of bidirectional JSON Schema transformations
- License: MIT License (see ../LICENSE.txt)
