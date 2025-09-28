# BiJect Datasets

This folder contains the datasets used in the evaluation of **BiJect**, our framework for bidirectional JSON Schema transformations.  
The datasets are divided into two main categories:

1. **Industrial datasets** — sanitized real-world JSON Schemas and instances.  
2. **Synthetic datasets** — controlled, artificial testbeds (small, medium, large, stress).  

A global index (`index.json`) describes all available schemas and their associated instances in a uniform structure.

---

## 📂 Directory Structure

datasets/  
  ├── industrial/  
  │      ├── schema-order.json  
  │      ├── schema-account.json  
  │      ├── schema-sensor.json  
  │      ├── schema-supplychain.json  
  │      ├── schema-userprofile.json  
  │      ├── instances/  
  │      │        ├── order1.json ... order3.json  
  │      │        ├── account1.json ... account3.json  
  │      │        ├── sensor1.json ... sensor3.json  
  │      │        ├── supplychain1.json ... supplychain3.json  
  │      │        └── userprofile1.json ... userprofile3.json  
  │      └── index.json  
  │  
  ├── synthetic/  
  │      ├── small/  
  │      │       ├── schema1.json  
  │      │       ├── instance1.json  
  │      │       └── instance2.json  
  │      ├── medium/  
  │      │       ├── schema1.json  
  │      │       ├── instance1.json  
  │      │       └── instance2.json  
  │      ├── large/  
  │      │       ├── schema1.json  
  │      │       ├── instance1.json  
  │      │       └── instance2.json  
  │      ├── stress/  
  │      │       ├── schema1.json  
  │      │       ├── instance1.json  
  │      │       └── instance2.json  
  │      └── index.json  
  │  
  └── index.json   # global index across all datasets  

---

## 📂 Contents

- `industrial/`  
  - `index.json` (local index for industrial subset)  
  - `schema-*.json` (schemas)  
  - `instances/` (corresponding JSON instances)  

- `synthetic/`  
  - `small/`, `medium/`, `large/`, `stress/`  
  - Each subfolder contains one schema (`schema1.json`) and two instances (`instance1.json`, `instance2.json`).  

- `index.json` (global index across all datasets)  

---

## 🎯 Goals

- Ensure **reproducibility** of all experiments in the article.  
- Provide both **realistic industrial schemas** and **synthetic benchmarks** to validate transformations.  
- Support **scalability analysis** and **stress-testing** of BiJect algorithms.  

---

## 🔍 Dataset Statistics (Global)

| Category      | # Schemas | # Instances |
|---------------|-----------|-------------|
| Industrial    | 5         | 15          |
| Synthetic     | 4         | 8           |
| **Total**     | **9**     | **23**      |

---

## ▶️ Usage

All datasets can be explored or validated using the BiJect Python loader (`loader.py`).  

### Validate everything
python loader.py --index datasets/index.json

### Validate only industrial datasets
python loader.py --index datasets/index.json --dataset industrial

### Validate only synthetic datasets
python loader.py --index datasets/index.json --dataset synthetic

### Validate a specific synthetic subset
python loader.py --index datasets/index.json --dataset synthetic/medium

### Quick dataset health check
python loader.py --index datasets/index.json --stats

## ✍️ Metadata:
- Authors: Zouhaier Brahmia and Fabio Grandi
- Purpose: Reproducibility, validation, and performance evaluation of bidirectional JSON Schema transformations
- License: CC-BY 4.0 (open dataset for research and teaching)