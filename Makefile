.PHONY: setup clean run all
setup:
\tpython3 -m venv .venv && . .venv/bin/activate && python3 -m pip install -r requirements.txt
run:
\tpython3 src/python/load_clean.py && \
\tpython3 src/python/transform_data.py && \
\tpython3 src/python/visualize_data.py
clean:
\trm -f data/interim/*.csv data/processed/*.csv outputs/tables/*.csv outputs/figures/*.png
all: setup run
