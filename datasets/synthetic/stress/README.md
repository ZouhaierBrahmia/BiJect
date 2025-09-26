# Synthetic Stress Dataset

This folder contains the **stress synthetic JSON Schemas and instances**, specifically
crafted to push the BiJect libraries to their limits.

## Contents

| Schema ID  | File Path      | Instances                       |
|------------|----------------|---------------------------------|
| schema1    | schema1.json   | instance1.json, instance2.json  |

## Notes

- Artificial edge cases with **deeply nested structures**, **extensive reuse**, and
  potential for **cyclic references**.
- Designed to evaluate the robustness, cycle detection, and max-depth limits of the
  BiJect factorization and inlining algorithms.
- Useful for performance profiling and failure-mode testing.

## Metadata

- **Author:** BiJect Artifact Team
- **Purpose:** Reproducibility, validation, and performance evaluation of bidirectional JSON Schema transformations
- **License:** MIT License
