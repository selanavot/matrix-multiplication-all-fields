"""Exact module-system port used to compare protected sources with the baseline."""

def module_port(source: bytes) -> bytes:
    lines = source.splitlines(keepends=True)
    imports = [i for i, line in enumerate(lines) if line.startswith(b"import ")]
    if not imports:
        raise ValueError("Expected legacy imports")
    for i in imports:
        lines[i] = b"public " + lines[i]
    lines.insert(imports[-1] + 1, b"\npublic section\n\n@[expose] section\n")
    return b"module\n\n" + b"".join(lines)
