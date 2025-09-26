# Industrial Dataset (Sanitized)

This folder contains the **sanitized industrial-style schemas and instances** used in the BiJect evaluation.  
They are inspired by real-world API-centric microservices (e-commerce, IoT, and supply chain) but stripped of any confidential or proprietary data.  

The dataset reflects the scenario described in **Section 8 (Industrial Case Study)** of the BiJect article:  
- JSON Schema is used to validate data exchanged between services such as **user profiles, product catalogs, orders, payments, and sensors**.  
- Schemas originally contained **deeply nested and repetitive structures** (e.g., duplicated address/contact details).  
- BiJect’s bidirectional transformations (factorization ↔ inlining) were applied to evaluate **maintainability, validation performance, and deployment robustness**.

---

## 📂 Contents

- `index.json` — dataset index, mapping schemas to their example instances.  
- `schema-order.json` — purchase orders (items, prices, customer references).  
- `schema-account.json` — user accounts (authentication, profile, preferences).  
- `schema-sensor.json` — IoT sensor readings (time series, thresholds, metadata).  
- `schema-supplychain.json` — supply chain events (shipments, deliveries, tracking).  
- `schema-userprofile.json` — user/customer profiles (name, contact, address).  
- `instances/` — example JSON documents (3 per schema).

---

## 📑 Instances

Each schema has three representative instances:

- **Order**  
  - `order1.json`: simple single-item order  
  - `order2.json`: multi-item order with discounts  
  - `order3.json`: bulk order with nested shipping details  

- **Account**  
  - `account1.json`: basic account with username/email  
  - `account2.json`: account with profile and preferences  
  - `account3.json`: account with extended authentication fields  

- **Sensor**  
  - `sensor1.json`: temperature reading with timestamp  
  - `sensor2.json`: sensor with thresholds and alerts  
  - `sensor3.json`: sensor with nested metadata and calibration data  

- **Supply Chain**  
  - `supplychain1.json`: simple shipment event  
  - `supplychain2.json`: delivery with tracking data  
  - `supplychain3.json`: multi-stage logistics chain  

- **User Profile**  
  - `userprofile1.json`: basic profile with address  
  - `userprofile2.json`: profile with multiple contact methods  
  - `userprofile3.json`: supplier profile with billing + shipping addresses  

---

## 🔍 Dataset Statistics

- **Schemas**: 5  
- **Instances**: 15 (3 per schema)  

---

## ▶️ Usage

You can explore or validate the dataset using the BiJect loader utility (`loader.py`):

### List available schema IDs
```bash
python loader.py --index datasets/index.json --list

### Validate all instances against schemas
python loader.py --index datasets/index.json --dataset industrial

### Print schema-instance pairs
python loader.py --index datasets/index.json --dataset industrial --pairs

### Quick dataset health check
python loader.py --index datasets/index.json --dataset industrial --stats



## ✍️ Metadata:
   - Author: BiJect Artifact Team
   - Purpose: Reproducibility, validation, and performance evaluation of bidirectional JSON Schema transformations
   - License: CC-BY 4.0 (open dataset for research and teaching)