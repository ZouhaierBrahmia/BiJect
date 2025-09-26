import argparse
from collections import defaultdict
from loader import iter_schema_instance_pairs, list_datasets, load_dataset


def compute_stats(index_file: str, dataset_id: str = None, base_dir: str = None):
    """
    Compute number of schemas and instances per dataset.
    """
    index = load_dataset(index_file)
    datasets = index.get("datasets", {})

    stats = defaultdict(lambda: {"schemas": set(), "instances": 0})

    for schema_path, instance_path in iter_schema_instance_pairs(index_file, dataset_id, base_dir):
        # Find dataset identifier
        ds_key = dataset_id or _infer_dataset_id(schema_path, index_file)
        stats[ds_key]["schemas"].add(schema_path)
        stats[ds_key]["instances"] += 1

    return {k: {"schemas": len(v["schemas"]), "instances": v["instances"]} for k, v in stats.items()}


def _infer_dataset_id(schema_path: str, index_file: str) -> str:
    """
    Try to infer dataset id from schema_path relative to datasets folder.
    (Simplified helper: strips everything before 'datasets/')
    """
    import os
    try:
        rel = os.path.relpath(schema_path, start=os.path.dirname(index_file))
        parts = rel.split(os.sep)
        # e.g., industrial/schema-order.json → industrial
        return parts[0] if parts else "unknown"
    except Exception:
        return "unknown"


def print_stats(index_file: str, dataset_id: str = None, base_dir: str = None):
    stats = compute_stats(index_file, dataset_id, base_dir)
    print("\n📊 Dataset Statistics\n")
    for ds, values in stats.items():
        print(f"- {ds}: {values['schemas']} schema(s), {values['instances']} instance(s)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="BiJect Dataset Stats")
    parser.add_argument("--index", default="datasets/index.json", help="Path to global index.json")
    parser.add_argument("--dataset", help="Specific dataset ID (e.g., industrial, synthetic/medium)")
    parser.add_argument("--base", help="Optional base directory for resolving relative paths")

    args = parser.parse_args()

    print_stats(args.index, dataset_id=args.dataset, base_dir=args.base)
