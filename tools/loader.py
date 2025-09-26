import json
import os
import argparse
from typing import Iterator, Tuple, Dict, Any


def load_dataset(index_file: str) -> Dict[str, Any]:
    """Load the dataset index.json file."""
    with open(index_file, "r", encoding="utf-8") as f:
        return json.load(f)


def iter_schema_instance_pairs(
    index_file: str, dataset_id: str = None, base_dir: str = None
) -> Iterator[Tuple[str, str]]:
    """
    Yield (schema_path, instance_path) pairs from the dataset index.

    Parameters:
        index_file: Path to index.json.
        dataset_id: Optional dataset identifier:
            - "industrial"
            - "synthetic/medium"
            - "synthetic/medium/schema1"
            If None, iterate over all datasets.
        base_dir: Optional base directory for resolving relative paths.
    """
    if base_dir is None:
        base_dir = os.path.dirname(os.path.abspath(index_file))

    index = load_dataset(index_file)
    datasets = index.get("datasets", {})

    def recurse(current, prefix=""):
        for key, value in current.items():
            if "schemas" in value:
                for schema_entry in value["schemas"]:
                    schema_id = schema_entry.get("id", os.path.basename(schema_entry["path"]))
                    full_id = f"{prefix}{key}/{schema_id}"
                    yield full_id, [schema_entry]
                yield f"{prefix}{key}", value["schemas"]
            else:
                yield from recurse(value, prefix=f"{prefix}{key}/")

    for ds_id, schemas in recurse(datasets):
        if dataset_id is None or ds_id == dataset_id:
            for schema_entry in schemas:
                schema_path = os.path.join(base_dir, schema_entry["path"])
                for instance_rel in schema_entry.get("instances", []):
                    instance_path = os.path.join(base_dir, instance_rel)
                    yield schema_path, instance_path


def list_datasets(index_file: str) -> None:
    """List all available dataset IDs (categories and schema-level)."""
    index = load_dataset(index_file)
    datasets = index.get("datasets", {})

    def recurse(current, prefix=""):
        for key, value in current.items():
            if "schemas" in value:
                for schema_entry in value["schemas"]:
                    schema_id = schema_entry.get("id", os.path.basename(schema_entry["path"]))
                    print(f"{prefix}{key}/{schema_id}")
                print(f"{prefix}{key}")
            else:
                recurse(value, prefix=f"{prefix}{key}/")

    recurse(datasets)


def print_pairs(index_file: str, dataset_id: str = None, base_dir: str = None, as_json: bool = False) -> None:
    """Print all (schema, instance) pairs, either as text or JSON."""
    pairs = [
        {"schema": schema_path, "instance": instance_path}
        for schema_path, instance_path in iter_schema_instance_pairs(index_file, dataset_id, base_dir)
    ]

    if as_json:
        print(json.dumps(pairs, indent=2))
    else:
        for p in pairs:
            print(f"{p['schema']}  <--->  {p['instance']}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="BiJect Dataset Loader")
    parser.add_argument("--index", default="datasets/index.json", help="Path to global index.json")
    parser.add_argument("--list", action="store_true", help="List available dataset IDs (categories and schemas)")
    parser.add_argument("--dataset", help="Specific dataset ID (e.g., industrial, synthetic/medium, synthetic/medium/schema1)")
    parser.add_argument("--pairs", action="store_true", help="Print schema-instance pairs")
    parser.add_argument("--json", action="store_true", help="When used with --pairs, output pairs in JSON")

    args = parser.parse_args()

    if args.list:
        print("Available dataset IDs:\n")
        list_datasets(args.index)
    elif args.pairs:
        print_pairs(args.index, dataset_id=args.dataset, as_json=args.json)
    else:
        print("No action specified. Use --list or --pairs. See --help for details.")
