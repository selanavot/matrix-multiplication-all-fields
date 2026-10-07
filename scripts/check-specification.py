#!/usr/bin/env python3
"""Check protected sources against the exact module-only port of the baseline."""
from pathlib import Path
import subprocess
from specification import module_port

ROOT = Path(__file__).resolve().parents[1]
BASELINE = 'd2336fc571f1f8cdabf0c6d3a2d3ef1ec3327653'
PREFIX = 'lean/OAI/LinearAlgebra/MatrixMultiplication/'
FILES = ['Model.lean', 'Arithmetic/Complexity.lean', 'Arithmetic/Programs.lean',
         'Arithmetic/RecursiveBlockPrograms.lean', 'Arithmetic/Padding.lean',
         'Arithmetic/LowerBound.lean', 'Arithmetic/Exponent.lean',
         'Tensor/ComplexTensor.lean', 'Tensor/ComplexTensorFlattening.lean',
         'Tensor/ComplexMatrixTensor.lean', 'Polynomial/ExpressionFamily.lean']

def verify():
    for name in FILES:
        original = subprocess.check_output(['git', 'show', f'{BASELINE}:{PREFIX}{name}'], cwd=ROOT)
        if (ROOT / PREFIX / name).read_bytes() != module_port(original):
            raise RuntimeError(f'Protected source changed beyond the module-only port: {name}')
    original = subprocess.check_output(['git', 'show', f'{BASELINE}:{PREFIX}Model.lean'], cwd=ROOT)
    challenge = (ROOT / 'lean/ComparatorAudit/Challenge.lean').read_bytes()
    marker = b'\n-- COMPARATOR FROZEN MODEL ENDS HERE\n'
    if challenge.count(marker) != 1 or challenge.split(marker)[0] != module_port(original):
        raise RuntimeError('Challenge model differs from the exact module-only baseline port')
    print('PASS: eleven protected files and frozen Challenge model match the exact module-only baseline port.')

if __name__ == '__main__':
    verify()
