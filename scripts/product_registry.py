#!/usr/bin/env python3
"""Validate the product registry and render its human-facing catalog views."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "products.json"
README = ROOT / "README.md"
AGENTS = ROOT / "AGENTS.md"
README_BEGIN = "<!-- BEGIN GENERATED PRODUCT CATALOG -->"
README_END = "<!-- END GENERATED PRODUCT CATALOG -->"
AGENTS_BEGIN = "<!-- BEGIN GENERATED PRODUCT TABLE -->"
AGENTS_END = "<!-- END GENERATED PRODUCT TABLE -->"
SEMVER = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+(?:[.-][0-9A-Za-z.-]+)?$")
NAME = re.compile(r"^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$")


class RegistryError(RuntimeError):
    pass


def load_registry() -> list[dict]:
    try:
        data = json.loads(REGISTRY.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise RegistryError(f"cannot read products.json: {exc}") from exc
    if data.get("$schema") != "./schema/products.schema.json":
        raise RegistryError("products.json $schema must be ./schema/products.schema.json")
    if data.get("schema_version") != "1":
        raise RegistryError("products.json schema_version must be '1'")
    unknown = set(data) - {"$schema", "schema_version", "products"}
    if unknown:
        raise RegistryError(f"products.json has unknown fields: {', '.join(sorted(unknown))}")
    if not (ROOT / "schema" / "products.schema.json").is_file():
        raise RegistryError("schema/products.schema.json is missing")
    products = data.get("products")
    if not isinstance(products, list) or not products:
        raise RegistryError("products.json products must be a non-empty array")
    return products


def frontmatter_value(path: Path, key: str) -> str:
    text = path.read_text(encoding="utf-8")
    match = re.search(
        rf"(?m)^\s*{re.escape(key)}:\s*[\"']?([^\"'\s]+)[\"']?\s*$", text
    )
    if not match:
        raise RegistryError(f"missing {key} in {path.relative_to(ROOT)}")
    return match.group(1)


def primary_version(product: dict) -> str:
    path = (
        ROOT
        / product["repo_dir"]
        / "skills"
        / product["primary_skill"]
        / "SKILL.md"
    )
    return frontmatter_value(path, "version")


def read_gitmodules() -> dict[str, str]:
    path = ROOT / ".gitmodules"
    if not path.exists():
        return {}
    result = subprocess.run(
        ["git", "config", "--file", str(path), "--get-regexp", r"^submodule\..*\.(path|url)$"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    records: dict[str, dict[str, str]] = {}
    for line in result.stdout.splitlines():
        key, value = line.split(None, 1)
        match = re.match(r"submodule\.(.+)\.(path|url)$", key)
        if match:
            records.setdefault(match.group(1), {})[match.group(2)] = value
    return {record.get("path", name): record.get("url", "") for name, record in records.items()}


def generated_blocks(products: list[dict]) -> tuple[str, str]:
    readme_lines = [
        README_BEGIN,
        "| Skill product | Version | Type | 说明 | Repo | Install |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    agent_lines = [
        AGENTS_BEGIN,
        "| Product / primary skill | Type | Repo/dir | Entrypoints | Install |",
        "| --- | --- | --- | ---: | --- |",
    ]
    for product in products:
        version = primary_version(product)
        repo = product["repository"]
        readme_lines.append(
            f"| **`{product['primary_skill']}`** | `{version}` | `{product['type']}` | "
            f"{product['purpose']} | [{repo}](https://github.com/{repo}) | "
            f"`{product.get('catalog_install', product['install'])}` |"
        )
        agent_lines.append(
            f"| `{product['primary_skill']}` | `{product['type']}` | `{product['repo_dir']}` | "
            f"{len(product['entrypoints'])} | `{product['install']}` |"
        )
    readme_lines.append(README_END)
    agent_lines.append(AGENTS_END)
    return "\n".join(readme_lines), "\n".join(agent_lines)


def replace_block(path: Path, begin: str, end: str, replacement: str) -> bool:
    text = path.read_text(encoding="utf-8")
    pattern = re.compile(re.escape(begin) + r".*?" + re.escape(end), re.DOTALL)
    if not pattern.search(text):
        raise RegistryError(f"generated markers missing in {path.name}: {begin} / {end}")
    updated = pattern.sub(replacement, text, count=1)
    if updated == text:
        return False
    path.write_text(updated, encoding="utf-8")
    return True


def validate(products: list[dict]) -> list[str]:
    errors: list[str] = []
    required = {
        "id",
        "repo_dir",
        "repository",
        "type",
        "primary_skill",
        "entrypoints",
        "entrypoint_version_policy",
        "status",
        "purpose",
        "install",
    }
    allowed = required | {"catalog_install"}
    ids: set[str] = set()
    repo_dirs: set[str] = set()
    all_entrypoints: set[str] = set()
    gitmodules = read_gitmodules()

    for index, product in enumerate(products):
        label = product.get("id", f"products[{index}]")
        missing = sorted(required - product.keys())
        unknown = sorted(product.keys() - allowed)
        if missing:
            errors.append(f"{label}: missing fields: {', '.join(missing)}")
            continue
        if unknown:
            errors.append(f"{label}: unknown fields: {', '.join(unknown)}")
        product_id = product["id"]
        repo_dir = product["repo_dir"]
        primary = product["primary_skill"]
        entrypoints = product["entrypoints"]
        if not NAME.fullmatch(product_id) or not NAME.fullmatch(primary):
            errors.append(f"{label}: invalid id or primary_skill")
        if product_id in ids:
            errors.append(f"{label}: duplicate product id")
        ids.add(product_id)
        if repo_dir in repo_dirs:
            errors.append(f"{label}: duplicate repo_dir {repo_dir}")
        repo_dirs.add(repo_dir)
        if repo_dir != f"{product_id}-skill":
            errors.append(f"{label}: repo_dir must be {product_id}-skill")
        if product["repository"] != f"kedoupi/{repo_dir}":
            errors.append(f"{label}: repository must be kedoupi/{repo_dir}")
        if product["type"] not in {"single", "family"}:
            errors.append(f"{label}: type must be single or family")
        if product["status"] not in {"incubating", "published", "deprecated", "retired"}:
            errors.append(f"{label}: invalid status {product['status']}")
        if not isinstance(product["purpose"], str) or len(product["purpose"].strip()) < 10:
            errors.append(f"{label}: purpose must be at least 10 characters")
        if not isinstance(product["install"], str) or not product["install"].startswith("npx skills add "):
            errors.append(f"{label}: install must start with 'npx skills add '")
        if not isinstance(entrypoints, list) or not entrypoints:
            errors.append(f"{label}: entrypoints must be a non-empty list")
            continue
        if len(entrypoints) != len(set(entrypoints)):
            errors.append(f"{label}: duplicate entrypoints")
        if primary not in entrypoints:
            errors.append(f"{label}: primary_skill must be listed in entrypoints")
        if product["type"] == "single" and entrypoints != [primary]:
            errors.append(f"{label}: single product must expose only its primary skill")
        if product["type"] == "family" and len(entrypoints) < 2:
            errors.append(f"{label}: family product must expose at least two entrypoints")
        overlap = all_entrypoints.intersection(entrypoints)
        if overlap:
            errors.append(f"{label}: entrypoints already owned: {', '.join(sorted(overlap))}")
        all_entrypoints.update(entrypoints)

        repo_path = ROOT / repo_dir
        if not repo_path.is_dir():
            errors.append(f"{label}: repo directory missing: {repo_dir}")
            continue
        actual = sorted(
            path.parent.name
            for path in (repo_path / "skills").glob("*/SKILL.md")
            if path.is_file()
        )
        expected = sorted(entrypoints)
        if actual != expected:
            errors.append(
                f"{label}: entrypoints differ; registry={','.join(expected)} disk={','.join(actual)}"
            )
        versions: dict[str, str] = {}
        for entrypoint in entrypoints:
            skill_md = repo_path / "skills" / entrypoint / "SKILL.md"
            if not skill_md.is_file():
                continue
            try:
                declared_name = frontmatter_value(skill_md, "name")
                version = frontmatter_value(skill_md, "version")
            except RegistryError as exc:
                errors.append(str(exc))
                continue
            if declared_name != entrypoint:
                errors.append(f"{label}: {entrypoint}/SKILL.md declares name {declared_name}")
            if not SEMVER.fullmatch(version):
                errors.append(f"{label}: invalid version {version} for {entrypoint}")
            versions[entrypoint] = version
        if product["entrypoint_version_policy"] == "lockstep" and versions:
            primary_ver = versions.get(primary)
            stale = sorted(name for name, version in versions.items() if version != primary_ver)
            if stale:
                errors.append(
                    f"{label}: lockstep entrypoints differ from {primary} {primary_ver}: {', '.join(stale)}"
                )
        elif product["entrypoint_version_policy"] not in {"lockstep", "independent"}:
            errors.append(f"{label}: invalid entrypoint_version_policy")

        module_url = gitmodules.get(repo_dir)
        if not module_url:
            errors.append(f"{label}: {repo_dir} missing from .gitmodules")
        elif not module_url.rstrip("/").endswith(f"/{repo_dir}.git"):
            errors.append(f"{label}: .gitmodules URL does not match {repo_dir}: {module_url}")

    disk_dirs = sorted(path.name for path in ROOT.glob("*-skill") if path.is_dir())
    if disk_dirs != sorted(repo_dirs):
        errors.append(
            f"registry/disk product dirs differ; registry={','.join(sorted(repo_dirs))} disk={','.join(disk_dirs)}"
        )
    return errors


def check_catalog(products: list[dict]) -> list[str]:
    expected_readme, expected_agents = generated_blocks(products)
    errors: list[str] = []
    for path, begin, end, expected in (
        (README, README_BEGIN, README_END, expected_readme),
        (AGENTS, AGENTS_BEGIN, AGENTS_END, expected_agents),
    ):
        text = path.read_text(encoding="utf-8")
        match = re.search(re.escape(begin) + r".*?" + re.escape(end), text, re.DOTALL)
        if not match:
            errors.append(f"{path.name}: generated catalog markers missing")
        elif match.group(0) != expected:
            errors.append(f"{path.name}: generated product catalog is stale")
    return errors


def command_check(products: list[dict]) -> int:
    print("check-catalog")
    print(f"root: {ROOT}")
    print()
    errors = validate(products)
    catalog_errors = check_catalog(products) if not errors else []
    if errors:
        for error in errors:
            print(f"  [FAIL] {error}")
    else:
        print(f"  [OK]   products.json covers {len(products)} product repos")
        print(
            f"  [OK]   registry covers {sum(len(p['entrypoints']) for p in products)} installable entrypoints"
        )
        print("  [OK]   product types and entrypoint version policies are valid")
        print("  [OK]   registry matches disk and .gitmodules")
    if catalog_errors:
        for error in catalog_errors:
            print(f"  [FAIL] {error}")
    elif not errors:
        print("  [OK]   README.md generated catalog is current")
        print("  [OK]   AGENTS.md generated product table is current")
    failures = len(errors) + len(catalog_errors)
    print()
    print(f"product skills checked: {len(products)}")
    print(f"Results: {6 if not failures else 0} ok, {failures} fail")
    if failures:
        print("", file=sys.stderr)
        print("Fix registry/package drift, then run: bash scripts/render-catalog", file=sys.stderr)
        return 1
    return 0


def command_render(products: list[dict], check: bool) -> int:
    errors = validate(products)
    if errors:
        for error in errors:
            print(f"[FAIL] {error}", file=sys.stderr)
        return 1
    expected_readme, expected_agents = generated_blocks(products)
    if check:
        errors = check_catalog(products)
        if errors:
            for error in errors:
                print(f"[FAIL] {error}", file=sys.stderr)
            return 1
        print("Generated product catalog is current.")
        return 0
    changed = []
    if replace_block(README, README_BEGIN, README_END, expected_readme):
        changed.append("README.md")
    if replace_block(AGENTS, AGENTS_BEGIN, AGENTS_END, expected_agents):
        changed.append("AGENTS.md")
    print("Updated: " + (", ".join(changed) if changed else "nothing (already current)"))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("check")
    render = sub.add_parser("render")
    render.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        products = load_registry()
    except RegistryError as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 1
    if args.command == "check":
        return command_check(products)
    return command_render(products, args.check)


if __name__ == "__main__":
    raise SystemExit(main())
