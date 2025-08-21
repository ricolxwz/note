#!/bin/bash
cd /home/wenzexu/note
source .venv/bin/activate
mkdocs serve -a 0.0.0.0:9080 --dirty
