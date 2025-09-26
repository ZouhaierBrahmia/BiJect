import os
import json
from loader import iter_schema_instance_pairs
from subprocess import run, PIPE

# Adjust these paths to your environment
RUMBLE_CMD = "rumble"  # JSONiq engine command
SRC_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "src"))
EXAMPLES_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "examples"))

def run_roundtrip(schema_file: str, instance_file: str):
    """
    Run the full nested -> reference-based -> nested roundtrip for one schema.
    Assumes you have `biject-factor.xq` and `biject-inline.xq` in src/ and a roundtrip.xq script in examples/.
    """

    # Execute the roundtrip XQuery script
    cmd = [RUMBLE_CMD, "--query", os.path.join(EXAMPLES_DIR, "roundtrip.xq"),
           "--variable", f"input-schema {schema_file}",
           "--variable", f"input-instance {instance_file}"]

    result = run(cmd, stdout=PIPE, stderr=PIPE, text=True)

    if result.returncode != 0:
        print(f"❌ ERROR running roundtrip for {instance_file}")
        print(result.stderr)
        return False
    else:
        # Optionally, parse result.stdout if the script prints equivalence info
        print(f"✅ SUCCESS: {instance_file} passed roundtrip")
        return True


def run_all_roundtrips(index_file: str, base_dir: str = None):
    for schema_file, instance_file in iter_schema_instance_pairs(index_file, base_dir=base_dir):
        run_roundtrip(schema_file, instance_file)


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="BiJect Roundtrip Test")
    parser.add_argument("--index", default="datasets/index.json", help="Path to global index.json")
    parser.add_argument("--base", help="Optional base directory for resolving paths")

    args = parser.parse_args()

    print("\n🔁 Running nested -> reference-based -> nested roundtrip tests...\n")
    run_all_roundtrips(args.index, base_dir=args.base)
