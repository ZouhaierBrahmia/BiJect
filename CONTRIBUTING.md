# Contributing to BiJect

Thank you for your interest in contributing to BiJect! 🎉
This document provides simple guidelines for extending or improving the repository.


## Getting Started

1. Fork the repository and clone it locally.
2. Install dependencies:
pip install -r requirements.txt

3. Make sure you are using Python 3.9+.


## Coding Guidelines

- Follow PEP 8 coding style for Python scripts.
- Use type hints where possible:
def foo(path: str) -> dict:
    ...

- Add docstrings to functions and classes:
def validate_pairs(...):
    """Validate instance files against their schemas using Draft-07."""


## Extending tools/

When adding new utilities under tools/:
- Keep the command-line interface consistent with existing scripts (use argparse).
- Ensure new scripts can be run independently with python script.py --help.
- Document the script in tools/README.md.


## Testing

- Use the datasets in datasets/ for testing.
- Always check both industrial and synthetic subsets.
- Run the round-trip tests to ensure semantic correctness:
python tools/roundtrip_test.py --index datasets/index.json


## Submitting Changes

1. Create a new branch (feature/my-feature or fix/bug-name).
2. Commit with clear messages:
git commit -m "Add latency measurement utility"

3. Push your branch and open a Pull Request.
4. Clearly describe:
- The purpose of your change
- Any datasets/scripts used for testing


## License
By contributing, you agree that your code will be released under the repository’s MIT License.



