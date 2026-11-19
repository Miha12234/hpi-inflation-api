#!/usr/bin/env python3
"""Create a source ZIP without local secrets or runtime files."""

from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile


project = Path(__file__).resolve().parents[1]
archive = project.parent / f"{project.name}.zip"
private_files = {
    Path("config/master.key"),
    Path("config/credentials.yml.enc"),
}
runtime_dirs = {"log", "tmp", "storage"}
excluded_dirs = {".git", ".bundle", "__pycache__"}

with ZipFile(archive, "w", compression=ZIP_DEFLATED) as output:
    for file in sorted(project.rglob("*")):
        if not file.is_file():
            continue
        relative = file.relative_to(project)
        if relative in private_files or excluded_dirs.intersection(relative.parts):
            continue
        if relative.parent == Path(".") and relative.name.startswith(".env"):
            continue
        if relative.parts[:2] == ("config", "credentials") and file.suffix == ".key":
            continue
        if relative.parts[:2] == ("public", "assets"):
            continue
        if relative.parts[0] in runtime_dirs and file.name != ".keep":
            continue
        output.write(file, arcname=f"{project.name}/{relative.as_posix()}")

print(archive)
