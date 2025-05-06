---
title: Argparse
comments: true
---

```py
import argparse

def get_args_parser(desc):
    parser = argparse.ArgumentParser(description=f"{desc}", add_help=True, formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    # ... insert your options
    return parser.parse_args()
```
