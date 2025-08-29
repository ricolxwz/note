#!/bin/ash
cd /root/note
source .venv/bin/activate
exec mkdocs serve -a 0.0.0.0:9080 --dirty
