#!/usr/bin/env python3
"""Update forks.yaml for coauthor-orchestrator (stdlib only)."""
from __future__ import annotations

import argparse
import datetime as dt
from pathlib import Path


def load_forks(path: Path) -> dict:
    if not path.exists():
        return {"forks": []}
    forks: list[dict] = []
    current: dict | None = None
    for line in path.read_text().splitlines():
        stripped = line.strip()
        if stripped == "forks: []":
            return {"forks": []}
        if stripped.startswith("- name:"):
            if current:
                forks.append(current)
            current = {"name": stripped.split(":", 1)[1].strip()}
            continue
        if current is not None and ":" in stripped:
            key, val = stripped.split(":", 1)
            key = key.strip()
            val = val.strip()
            if val == "true":
                current[key] = True
            elif val == "false":
                current[key] = False
            else:
                current[key] = val.strip('"')
    if current:
        forks.append(current)
    return {"forks": forks}


def dump_forks(path: Path, data: dict) -> None:
    lines = ["forks:"]
    for entry in data.get("forks", []):
        lines.append(f"  - name: {entry['name']}")
        for key in sorted(entry.keys()):
            if key == "name":
                continue
            val = entry[key]
            if isinstance(val, bool):
                lines.append(f"    {key}: {'true' if val else 'false'}")
            else:
                lines.append(f"    {key}: {val}")
    path.write_text("\n".join(lines) + "\n")


def find_entry(forks: list, name: str) -> dict | None:
    for entry in forks:
        if entry.get("name") == name:
            return entry
    return None


def cmd_ensure(args: argparse.Namespace) -> None:
    path = Path(args.orch_root) / "forks.yaml"
    data = load_forks(path)
    entry = find_entry(data["forks"], args.name)
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    if entry is None:
        entry = {
            "name": args.name,
            "upstream": args.upstream,
            "fork": args.fork,
            "sandbox": args.sandbox,
            "agentic_bootstrapped": False,
            "created_at": now,
        }
        data["forks"].append(entry)
    else:
        entry["upstream"] = args.upstream
        entry["fork"] = args.fork
        entry["sandbox"] = args.sandbox
        entry.setdefault("agentic_bootstrapped", False)
    dump_forks(path, data)


def cmd_mark_bootstrapped(args: argparse.Namespace) -> None:
    path = Path(args.orch_root) / "forks.yaml"
    data = load_forks(path)
    entry = find_entry(data["forks"], args.name)
    if entry is None:
        raise SystemExit(f"fork not in registry: {args.name}")
    entry["agentic_bootstrapped"] = True
    entry["bootstrapped_at"] = dt.datetime.now(dt.timezone.utc).isoformat()
    dump_forks(path, data)


def cmd_update_task(args: argparse.Namespace) -> None:
    path = Path(args.orch_root) / "forks.yaml"
    data = load_forks(path)
    entry = find_entry(data["forks"], args.name)
    if entry is None:
        raise SystemExit(f"fork not in registry: {args.name}")
    entry["last_branch"] = args.branch
    entry["last_commit"] = args.commit
    entry["last_task"] = args.task
    entry["updated_at"] = dt.datetime.now(dt.timezone.utc).isoformat()
    dump_forks(path, data)


def cmd_is_bootstrapped(args: argparse.Namespace) -> None:
    path = Path(args.orch_root) / "forks.yaml"
    data = load_forks(path)
    entry = find_entry(data["forks"], args.name)
    if entry and entry.get("agentic_bootstrapped"):
        raise SystemExit(0)
    raise SystemExit(1)


def main() -> None:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)

    e = sub.add_parser("ensure")
    e.add_argument("--orch-root", required=True)
    e.add_argument("--name", required=True)
    e.add_argument("--upstream", required=True)
    e.add_argument("--fork", required=True)
    e.add_argument("--sandbox", required=True)
    e.set_defaults(func=cmd_ensure)

    b = sub.add_parser("mark-bootstrapped")
    b.add_argument("--orch-root", required=True)
    b.add_argument("--name", required=True)
    b.set_defaults(func=cmd_mark_bootstrapped)

    t = sub.add_parser("update-task")
    t.add_argument("--orch-root", required=True)
    t.add_argument("--name", required=True)
    t.add_argument("--branch", required=True)
    t.add_argument("--commit", required=True)
    t.add_argument("--task", required=True)
    t.set_defaults(func=cmd_update_task)

    i = sub.add_parser("is-bootstrapped")
    i.add_argument("--orch-root", required=True)
    i.add_argument("--name", required=True)
    i.set_defaults(func=cmd_is_bootstrapped)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
