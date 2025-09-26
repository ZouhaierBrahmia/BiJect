import os
import json
import time
from loader import iter_schema_instance_pairs
from jsonschema import Draft7Validator, exceptions

def measure_latency(schema_file: str, instance_file: str) -> float:
    """
    Validate one instance against one schema and return the validation time in milliseconds.
    """
    with open(schema_file, "r", encoding="utf-8") as sf:
        schema = json.load(sf)
    with open(instance_file, "r", encoding="utf-8") as inf:
        instance = json.load(inf)

    validator = Draft7Validator(schema)

    start = time.perf_counter()
    try:
        validator.validate(instance)
    except exceptions.ValidationError as e:
        print(f"❌ Validation failed for {instance_file} against {schema_file}")
        print(f"   Reason: {e.message}")
        return None
    end = time.perf_counter()
    elapsed_ms = (end - start) * 1000
    return elapsed_ms

def benchmark_dataset(index_file: str, base_dir: str = None, repeats: int = 5):
    """
    Measure average validation latency per schema/instance pair.
    Repeats validation 'repeats' times for better timing stability.
    """
    results = []

    for schema_file, instance_file in iter_schema_instance_pairs(index_file, base_dir=base_dir):
        times = []
        for _ in range(repeats):
            elapsed = measure_latency(schema_file, instance_file)
            if elapsed is not None:
                times.append(elapsed)
        avg_time = sum(times) / len(times) if times else None
        results.append({
            "schema": schema_file,
            "instance": instance_file,
            "avg_latency_ms": avg_time
        })
        print(f"{schema_file} <---> {instance_file} : {avg_time:.3f} ms" if avg_time is not None else "Failed validation")

    return results

def save_results(results, output_file="latency_results.json"):
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    print(f"\n✅ Results saved to {output_file}")

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Measure JSON Schema Validation Latency")
    parser.add_argument("--index", default="datasets/index.json", help="Path to global index.json")
    parser.add_argument("--base", help="Optional base directory for resolving paths")
    parser.add_argument("--repeats", type=int, default=5, help="Number of repetitions per pair")
    parser.add_argument("--output", default="latency_results.json", help="Output JSON file for results")

    args = parser.parse_args()

    print("\n⏱️ Measuring JSON Schema validation latency...\n")
    results = benchmark_dataset(args.index, base_dir=args.base, repeats=args.repeats)
    save_results(results, output_file=args.output)
