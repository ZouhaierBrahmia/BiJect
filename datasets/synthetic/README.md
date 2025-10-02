# Synthetic Datasets

This folder contains **synthetically generated JSON Schemas and instances** designed to systematically evaluate BiJect’s bidirectional transformations.  
Unlike the **industrial dataset**, these are controlled, artificial testbeds where complexity is scaled gradually or designed to stress-test transformation behavior.

---

## 📂 Subfolders

- `small/` — minimal toy examples (schemas with a handful of fields).  
- `medium/` — moderately complex schemas (nested objects, arrays, references).  
- `large/` — larger schemas with more attributes and structural depth.  
- `stress/` — edge-case schemas explicitly crafted to push transformation algorithms to their limits.

Each subfolder contains:
- `schema1.json` — the synthetic schema definition.  
- `instance1.json`, `instance2.json` — two representative JSON documents conforming to the schema.  

---

## 🎯 Goals

- Provide a **progressive difficulty scale** for algorithm testing (from `small` to `large`).  
- Enable **stress-testing** with artificial corner cases (e.g., recursive references, empty objects, overlapping patterns).  
- Facilitate **performance benchmarking** across schema sizes.  

---

## 🔍 Dataset Statistics

- **Small**: 1 schema, 2 instances  
- **Medium**: 1 schema, 2 instances  
- **Large**: 1 schema, 2 instances  
- **Stress**: 1 schema, 2 instances  

**Total**: 4 schemas, 8 instances  

---

## ▶️ Usage

You can explore or validate synthetic datasets with the BiJect loader (`loader.py`):

### Validate all synthetic datasets
python loader.py --index datasets/index.json --dataset synthetic

### Validate only one synthetic subset
python loader.py --index datasets/index.json --dataset synthetic/small  
python loader.py --index datasets/index.json --dataset synthetic/medium  
python loader.py --index datasets/index.json --dataset synthetic/large  
python loader.py --index datasets/index.json --dataset synthetic/stress

### Quick dataset health check
python loader.py --index datasets/index.json --dataset synthetic --stats

## Metadata:
- Authors: Zouhaier Brahmia and Fabio Grandi
- Purpose: Reproducibility, validation, and performance evaluation of bidirectional JSON Schema transformations
- License: CC-BY 4.0 (open dataset for research and teaching)