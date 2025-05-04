---
title: Logger
comments: true
---

```py
import os
import logging
from rich.logging import RichHandler
from rich.console import Console

def get_logger(out_dir):
    logger = logging.getLogger("Eval-Dataset")
    logger.setLevel(logging.DEBUG)
    logger.propagate=False
    os.makedirs(out_dir, exist_ok=True)
    log_path = os.path.join(out_dir, "eval-dataset.log")
    file_console = Console(file=open(log_path, "a", encoding="utf-8"), markup=True, highlight=True)
    file_rich_hdlr = RichHandler(console=file_console, markup=True, rich_tracebacks=True, omit_repeated_times=False, show_path=False)
    file_rich_hdlr.setLevel(logging.DEBUG)
    file_rich_hdlr.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(file_rich_hdlr)
    console_rich_hdlr = RichHandler(markup=True, rich_tracebacks=True, omit_repeated_times=False, show_path=False)
    console_rich_hdlr.setLevel(logging.DEBUG)
    console_rich_hdlr.setFormatter(logging.Formatter("%(message)s"))
    logger.addHandler(console_rich_hdlr)
```
