.EXPORT_ALL_VARIABLES

QUARTO = quarto
R = Rscript

QMDFILE = arrow_summary.qmd
MDFILE = $(QMDFILE:.qmd=.md)

# Scripts
GENERATE = r/generate_data.R
PARTITION = r/partition_data.R

RAW_DIR = data_in
OUTPUT_DIR = data_part_date

# Data
DATA_RAW = $(wildcard $(RAW_DIR)/*.csv)
DATA_PART = $(wildcard $(OUTPUT_DIR)/*/part-0.parquet)

all: report

report: $(QMDFILE) dataparts
	$(QUARTO) render $(QMDFILE)

dataparts: $(PARTITION) rawparts
	$(R) $(PARTITION)
	echo Files $(DATA_RAW) generated

rawparts: $(GENERATE)
	$(R) $(GENERATE)
	echo Files $(DATA_PART) generated

