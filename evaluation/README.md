# BiJect Evaluation

This folder contains evaluation results and summaries produced by the Python utilities in tools/ (validate.py, stats.py, measure_latency.py, and roundtrip_test.py).
It complements the code by documenting reproducibility of validation, statistics, latency, and round-trip tests.


## Contents

The evaluation/ folder contains a README.md file and two subfolders: results/ and plots/.

1. README.md (this file): instructions and documentation for evaluation.

2. results/ (optional): folder where validation logs, statistics, and latency measurements can be stored.

- validation.log — sample validation output for all schema–instance pairs.

- stats.json — summary of schema/instance counts per dataset.

- latency.json — average validation latency (ms), computed over multiple runs.


3. plots/ (optional): folder where visualizations or charts derived from results can be stored.

- latency_vs_size.png — example plot: a chart showing average validation latency vs. number of instances. It can be generated with matplotlib when running measure_latency.py.



## How Results Were Produced

1. Validation

python ../tools/validate.py --index ../datasets/index.json

Output is redirected to results/validation.log.


2. Dataset Statistics

python ../tools/stats.py --index ../datasets/index.json > results/stats.json


3. Latency Measurement

python ../tools/measure_latency.py --index ../datasets/index.json --repeats 10 > results/latency.json


4. Round-Trip Tests

python ../tools/roundtrip_test.py --index ../datasets/index.json

Round-trip consistency reports can be saved as logs inside results/.


5. Plots

Example: generate a latency plot with matplotlib.

python ../tools/measure_latency.py --index ../datasets/index.json --plot evaluation/plots/latency_vs_size.png



## Metadata
- Authors: Zouhaier Brahmia and Fabio Grandi
- Purpose: Provide reproducible evaluation artifacts and performance evidence for BiJect
- License: MIT License (see ../LICENSE.txt)