# Copyright 2023, UChicago Argonne, LLC All Rights Reserved
# License: L-GPL 3.0
from pathlib import Path
import subprocess
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument(
    "-m",
    "--modify",
    help="Modify the files to have the correct copyright heading",
    action="store_true",
)
args = parser.parse_args()

extensions = {".h": "//", ".C": "//", ".py": "#", ".sh": "#"}
additional_files = {}

exclude_dirs = ["moose", "contrib", "doc"]
exclude_files = []


rootdir = Path(".")


def should_check(path):
    for exclude_dir in exclude_dirs:
        if Path(rootdir) / Path(exclude_dir) in path.parents:
            return False

    if path.name in exclude_files:
        return False

    if path.suffix in extensions:
        return True

    if path.name in additional_files:
        return True

    return False


def generate_copyright_heading(copyright, prefix):
    return (
        prefix
        + " "
        + (prefix + " ").join(
            line.strip() + "\n" for line in copyright.splitlines(True)
        )
    ).replace(prefix + " \n", prefix + "\n")


def has_correct_heading(path, copyright, prefix, modify):
    heading = generate_copyright_heading(copyright, prefix)

    # First check if it has the correct heading
    content = path.read_text()
    correct = content.startswith(heading)

    if not modify:
        return correct

    if correct:
        return True

    # Correct the heading
    with path.open("w", encoding="utf-8") as file:
        file.write(heading)
        for line in content.splitlines(True):
            file.write(line)

    print("Corrected copyright heading for " + str(path))

    return True


files = subprocess.run(
    ["git", "ls-tree", "-r", "HEAD", "--name-only"], capture_output=True, text=True
).stdout

copyright = """Copyright 2023, UChicago Argonne, LLC All Rights Reserved
License: L-GPL 3.0"""
print("The copyright statement is")
print(copyright)

success = True
for file in files.splitlines():
    file_path = Path(file)
    if should_check(file_path):
        if file_path.suffix in extensions:
            prefix = extensions[file_path.suffix]
        elif file_path.name in additional_files:
            prefix = additional_files[file_path.name]
        else:
            sys.exit("Internal error")

        if not has_correct_heading(file_path, copyright, prefix, args.modify):
            print(file)
            success = False

if success:
    print("All files have the correct copyright heading")
else:
    sys.exit("The above files do NOT contain the correct copyright heading")
