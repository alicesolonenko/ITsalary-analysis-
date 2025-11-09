clear all
set more off

* Paths relative to project root
global root    "."
global raw     "$root/data/raw"
global proc    "$root/data/processed"
global tables  "$root/outputs/tables"
global figs    "$root/outputs/figures"
global dostata "$root/src/stata"

* Entry folders
capture mkdir "$proc"
capture mkdir "$tables"
capture mkdir "$figs"

* 1. Load & clean data
do "$dostata/clean.do"

* 2. Prepare analytical sample
do "$dostata/prepare_data.do"

* 3. Summary statistics and graphs
do "$dostata/graphs.do"
