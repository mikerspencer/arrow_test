# ---------------------------------
# ---------------------------------
# partition data
# ---------------------------------
# ---------------------------------

library(tidyverse)
library(arrow)


# ---------------------------------
# Connect to input

ds = list.files("data_in", full.names = TRUE) %>%
  open_dataset(format = "csv")


# ---------------------------------
# Date partition

dir_out = "data_part_date"

if(!dir.exists(dir_out)){
  dir.create(dir_out)
}

ds %>%
  group_by(str_sub(end_of_this_period, 1, 7)) %>%
  write_dataset(dir_out)


# ---------------------------------
# ID group partition

dir_out = "data_part_id"

if(!dir.exists(dir_out)){
  dir.create(dir_out)
}

ds %>%
  group_by(str_sub(cid, 1, 1)) %>%
  write_dataset(dir_out)
