QMDFILE = arrow_summary.qmd
MDFILE = $(QMDFILE:.qmd=.md)

# Scripts
GENERATE = r/generate_data.R
PARTITION = r/partition_data.R
# Data
DATA_RAW = $(wildcard data_in/*.csv)
DATA_PART = $(wildcard data_part_date/*/part-0.parquet)

all: $(MDFILE)

$(MDFILE): $(DATA_PART)
	quarto render $(QMDFILE)

$(DATA_RAW): $(GENERATE)
	Rscript $(GENERATE)

$(DATA_PART): $(PARTITION)
	Rscript $(PARTITION)
