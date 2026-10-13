#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ROOT
python - <<'PY'
import os
import pathlib
import subprocess
import tempfile

root = pathlib.Path(os.environ['ROOT'])
for profile, layers in [('darwin', ['common', 'darwin']),
                        ('omarchy', ['common', 'omarchy', 'hosts/omarchy'])]:
    with tempfile.TemporaryDirectory(prefix='dotfiles-test-') as home:
        expected = {}
        for layer in layers:
            for package in sorted((root / 'stow' / layer).iterdir()):
                for source in package.rglob('*'):
                    if not source.is_file():
                        continue
                    target = pathlib.Path(home) / source.relative_to(package)
                    assert target not in expected, f'Duplicate ownership: {target}'
                    expected[target] = source
        for repeat in range(2):
            for layer in layers:
                directory = root / 'stow' / layer
                for package in sorted(directory.iterdir()):
                    subprocess.run(['stow', '-R', '--no-folding', '-d', str(directory),
                                    '-t', home, package.name], check=True)
            for target, source in expected.items():
                assert target.is_symlink() and target.resolve() == source.resolve(), target
            assert not any(p.is_symlink() and p.is_dir()
                           for p in pathlib.Path(home).rglob('*')), 'Folded directory'
        print(f'{profile}: {len(expected)} files, two clean Stow passes')
PY
