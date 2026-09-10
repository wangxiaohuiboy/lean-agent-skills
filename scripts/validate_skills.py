#!/usr/bin/env python3
"""Check every skill in this repo without third-party dependencies.

Verifies the frontmatter, the naming rules, and that files a SKILL.md points at
actually exist. Run from anywhere:  python3 scripts/validate_skills.py
"""

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS = REPO / "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
PLACEHOLDER_RE = re.compile(
    r"\[TODO|Replace this placeholder|Replace with actual|\bFIXME:", re.IGNORECASE
)
REFERENCE_RE = re.compile(r"`((?:references|assets|scripts)/[^`\s]+)`")

MIN_DESCRIPTION = 40
MAX_DESCRIPTION = 600


def parse_frontmatter(text, path):
    if not text.startswith("---\n"):
        raise ValueError(f"{path}: file must start with a --- frontmatter block")
    end = text.find("\n---", 4)
    if end == -1:
        raise ValueError(f"{path}: frontmatter block is not closed")
    fields = {}
    for line in text[4:end].splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(f"{path}: frontmatter line is not key: value -> {line!r}")
        key, value = line.split(":", 1)
        value = value.strip().strip('"').strip("'")
        fields[key.strip()] = value
    return fields, text[end + 4 :]


def check_skill(skill_dir, errors):
    name = skill_dir.name
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        errors.append(f"{name}: SKILL.md is missing")
        return

    text = skill_md.read_text(encoding="utf-8")
    try:
        fields, body = parse_frontmatter(text, skill_md.relative_to(REPO))
    except ValueError as exc:
        errors.append(str(exc))
        return

    for required in ("name", "description"):
        if not fields.get(required):
            errors.append(f"{name}: frontmatter is missing `{required}`")

    if fields.get("name") != name:
        errors.append(f"{name}: frontmatter name {fields.get('name')!r} does not match the folder name")

    if not NAME_RE.match(name) or len(name) > 64:
        errors.append(f"{name}: folder name must be lowercase kebab-case, at most 64 characters")

    description = fields.get("description", "")
    if not MIN_DESCRIPTION <= len(description) <= MAX_DESCRIPTION:
        errors.append(
            f"{name}: description is {len(description)} characters, "
            f"expected {MIN_DESCRIPTION}-{MAX_DESCRIPTION}"
        )

    if PLACEHOLDER_RE.search(text):
        errors.append(f"{name}: still contains scaffold placeholder text")

    if not body.strip():
        errors.append(f"{name}: SKILL.md has no body")

    for rel in set(REFERENCE_RE.findall(body)):
        if not (skill_dir / rel).is_file():
            errors.append(f"{name}: SKILL.md references {rel}, which does not exist")

    if not (skill_dir / "agents" / "openai.yaml").is_file():
        errors.append(f"{name}: agents/openai.yaml is missing")


def main():
    if not SKILLS.is_dir():
        print(f"no skills directory at {SKILLS}", file=sys.stderr)
        return 1

    skill_dirs = sorted(d for d in SKILLS.iterdir() if d.is_dir())
    if not skill_dirs:
        print("no skills found", file=sys.stderr)
        return 1

    errors = []
    for skill_dir in skill_dirs:
        check_skill(skill_dir, errors)

    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        print(f"\n{len(errors)} problem(s) in {len(skill_dirs)} skills", file=sys.stderr)
        return 1

    print(f"all {len(skill_dirs)} skills valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())
