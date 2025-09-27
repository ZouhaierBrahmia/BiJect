# Synthetic Large Dataset

This folder contains the **large synthetic JSON Schemas and instances**, intended
to stress-test the BiJect transformation libraries under complex reuse scenarios.

## Contents

| Schema ID  | File Path      | Instances                       |
|------------|----------------|---------------------------------|
| schema1    | schema1.json   | instance1.json, instance2.json  |

## Notes

- Large-scale schema with **many entities and nested substructures**.
- Extensive reuse of shared structures: User, Supplier, Order, Product, Inventory, etc.
- Designed to push factorization and inlining algorithms in realistic enterprise-like scenarios.

## Metadata

- Authors: Zouhaier Brahmia and Fabio Grandi
- Purpose: Reproducibility, validation, and performance evaluation of bidirectional JSON Schema transformations
- License: CC-BY 4.0 (open dataset for research and teaching)
