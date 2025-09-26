import json
import argparse
from jsonschema import Draft7Validator, exceptions
from loader import iter_schema_instance_pairs


def validate_pairs(index_file: str, dataset_id: str = None, base_dir: str = None) -> None:
    """Validate all instance files against their schemas using Draft-07."""
    for schema_path, instance_path in iter_schema_instance_pairs(index_file, dataset_id, base_dir):
        try:
            with open(schema_path, "r", encoding="utf-8") as sf:
                schema = json.load(sf)
            with open(instance_path, "r", encoding="utf-8") as inf:
                instance = json.load(inf)

            validator = Draft7Validator(schema)
            validator.validate(instance)
            print(f"✅ VALID: {instance_path} conforms to {schema_path}")

        except exceptions.ValidationError as e:
            print(f"❌ INVALID: {instance_path} does not conform to {schema_path}")
            print(f"   Reason: {e.message}")

        except FileNotFoundError as e:
            print(f"⚠️  FILE NOT FOUND: {e.filename}")

        except json.JSONDecodeError as e:
            print(f"⚠️  INVALID JSON in file {e.doc[:40]}... (line {e.lineno}, col {e.colno})")

        except Exception as e:
            print(f"⚠️  ERROR while processing {instance_path}: {str(e)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="BiJect Schema Validator")
    parser.add_argument("--index", default="datasets/index.json", help="Path to global index.json")
    parser.add_argument("--dataset", help="Specific dataset ID (e.g., industrial, synthetic/medium, synthetic/medium/schema1)")
    parser.add_argument("--base", help="Optional base directory for resolving relative paths")

    args = parser.parse_args()

    print(f"Running validation for dataset: {args.dataset or 'ALL'}\n")
    validate_pairs(args.index, dataset_id=args.dataset, base_dir=args.base)
