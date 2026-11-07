#!/usr/bin/env python3
from pathlib import Path
import base64
parts_dir = Path(__file__).with_name('parts')
if parts_dir.exists():
    parts = [parts_dir.joinpath(f'part_{i}.txt').read_text().strip() for i in range(7)]
else:
    parts = Path(__file__).with_name('home_screen.b64.txt').read_text().splitlines()
data = base64.b64decode(''.join(parts))
Path(__file__).with_name('home_screen.dart').write_bytes(data)
print('home_screen.dart restored', len(data), 'bytes')
