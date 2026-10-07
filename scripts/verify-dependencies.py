#!/usr/bin/env python3
"""Read-only verification of installed dependencies against the committed pins.

Usage: python3 scripts/verify-dependencies.py /path/to/repository
Requires Python's standard library and Git. Performs no builds, network access,
installs, or source mutations. Generated ignored .lake outputs are not verified.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

PATCH_PATH = 'lean/patches/fixed-point-theorems-lean4341.patch'
PATCH_SHA256 = 'd70872e41e80b25191538d1659c4aa3a001349b5bd16f806c9e3833a502516e5'
FIXED_POINT = 'fixed-point-theorems'


def git(path: Path, *args: str) -> bytes:
    env = os.environ.copy()
    env['GIT_OPTIONAL_LOCKS'] = '0'
    result = subprocess.run(
        ['git', '--no-pager', '-c', 'core.fsmonitor=false', '-C', str(path), *args],
        stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env, check=False,
    )
    if result.returncode:
        raise RuntimeError(f'git {args[0]} failed in {path}: '
                           f'{result.stderr.decode(errors="replace").strip()}')
    return result.stdout


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('root', type=Path, help='Repository root containing lake-manifest.json')
    args = parser.parse_args()
    root = args.root.resolve()
    manifest_path = root / 'lake-manifest.json'
    manifest_bytes = manifest_path.read_bytes()
    committed_manifest = git(root, 'show', 'HEAD:lake-manifest.json')
    if manifest_bytes != committed_manifest:
        raise RuntimeError('Working manifest differs from HEAD; dependency pins are not the committed pins.')
    toolchain = (root / 'lean-toolchain').read_bytes()
    if toolchain != git(root, 'show', 'HEAD:lean-toolchain'):
        raise RuntimeError('Working Lean toolchain differs from HEAD.')
    manifest = json.loads(manifest_bytes)
    patch = (root / PATCH_PATH).read_bytes()
    if hashlib.sha256(patch).hexdigest() != PATCH_SHA256:
        raise RuntimeError('Compatibility patch does not match the audited upstream SHA-256.')
    if patch != git(root, 'show', f'HEAD:{PATCH_PATH}'):
        raise RuntimeError('Working compatibility patch differs from HEAD.')
    packages_dir = (root / manifest['packagesDir']).resolve()
    packages = manifest['packages']
    if len(packages) != 9:
        raise RuntimeError(f'Expected nine pinned packages; found {len(packages)}.')
    seen = set()
    errors = []
    for package in packages:
        name = package['name']
        if name.startswith('«') and name.endswith('»'):
            name = name[1:-1]
        if name in seen or Path(name).name != name:
            raise RuntimeError(f'Duplicate or invalid package name: {name!r}')
        seen.add(name)
        if package['type'] != 'git':
            raise RuntimeError(f'{name}: expected a Git dependency')
        revision = package['rev']
        if len(revision) != 40 or any(c not in '0123456789abcdef' for c in revision):
            raise RuntimeError(f'{name}: revision is not a full lowercase Git commit hash')
        path = (packages_dir / name).resolve()
        try:
            actual_root = Path(git(path, 'rev-parse', '--show-toplevel').decode().strip()).resolve()
            if actual_root != path:
                raise RuntimeError(f'{name}: resolved to parent Git root {actual_root}')
            head = git(path, 'rev-parse', 'HEAD').decode().strip()
            if head != revision:
                raise RuntimeError(f'{name}: HEAD {head} differs from pinned {revision}')
            index_flags = git(path, 'ls-files', '-v', '-z')
            hidden_entries = [entry for entry in index_flags.split(b'\0')
                              if entry and (entry[:1].islower() or entry[:1] == b'S')]
            if hidden_entries:
                raise RuntimeError(f'{name}: assume-unchanged or skip-worktree index entries: {hidden_entries!r}')
            # Reject staged changes, including an intentionally staged patch: the
            # post-update hook applies its allowed patch only to the working tree.
            staged = git(path, 'diff', '--cached', '--name-only', '--no-ext-diff', '--no-textconv', '-z')
            if staged:
                raise RuntimeError(f'{name}: unexpected staged changes: {staged!r}')
            untracked = git(path, 'ls-files', '--others', '--exclude-standard', '-z')
            if untracked:
                raise RuntimeError(f'{name}: unexpected untracked files: {untracked!r}')
            ignored = git(path, 'ls-files', '--others', '--ignored', '--exclude-standard', '-z')
            source_overrides = []
            for raw in ignored.split(b'\0'):
                if not raw:
                    continue
                rel = Path(os.fsdecode(raw))
                if rel.parts[0] == '.lake':
                    continue
                if rel.suffix == '.lean' or rel.name in {'lean-toolchain', 'lake-manifest.json', 'lakefile.toml'}:
                    source_overrides.append(str(rel))
            if source_overrides:
                raise RuntimeError(f'{name}: ignored source/configuration overrides: {source_overrides}')
            delta = git(path, 'diff', 'HEAD', '--binary', '--no-ext-diff', '--no-textconv',
                        '--no-renames', '--no-color', '--no-relative', '--src-prefix=a/',
                        '--dst-prefix=b/', '--unified=3', '--abbrev=7',
                        '--diff-algorithm=myers', '--indent-heuristic', '--')
            expected = b''
            if delta != expected:
                raise RuntimeError(f'{name}: working delta is not the exact allowed delta '
                                   f'(actual SHA-256 {hashlib.sha256(delta).hexdigest()}, '
                                   f'expected {hashlib.sha256(expected).hexdigest()})')
            label = 'clean'
            print(f'PASS {name}: {head} ({label})')
        except (RuntimeError, OSError) as exc:
            errors.append(str(exc))
    for error in errors:
        print(f'FAIL {error}', file=sys.stderr)
    if errors:
        return 1
    print('PASS all nine source dependencies match committed pins and allowed changes.')
    print('Scope: generated ignored .lake build artifacts are reused and not source-verified here.')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (RuntimeError, OSError, KeyError, ValueError) as exc:
        print(f'FAIL {exc}', file=sys.stderr)
        raise SystemExit(1)
