Arrow_summary
================
Mike Spencer

## Intro

Doc trials different ways of reading data.

``` r
library(tidyverse)
```

    ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
    ✔ dplyr     1.1.2     ✔ readr     2.1.4
    ✔ forcats   1.0.0     ✔ stringr   1.5.0
    ✔ ggplot2   3.4.2     ✔ tibble    3.2.1
    ✔ lubridate 1.9.2     ✔ tidyr     1.3.0
    ✔ purrr     1.0.1     
    ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ✖ dplyr::filter() masks stats::filter()
    ✖ dplyr::lag()    masks stats::lag()
    ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors

``` r
library(arrow)
```


    Attaching package: 'arrow'

    The following object is masked from 'package:lubridate':

        duration

    The following object is masked from 'package:utils':

        timestamp

## csv

### Single file, readr

``` r
tick = proc.time()
f = list.files("data_in", full.names = TRUE)

parallel::mclapply(f, mc.cores = 8, function(i){
read_csv(i) %>% 
    group_by(sex) %>% 
    summarise(end_of_this_period = unique(end_of_this_period),
              mean_income = mean(income),
              overdraft_users = sum(cash_min < 0))
}) %>% 
  bind_rows()
```

    # A tibble: 456 × 4
       sex   end_of_this_period mean_income overdraft_users
       <chr> <date>                   <dbl>           <int>
     1 F     2019-01-06              41201.            5622
     2 M     2019-01-06              41479.            5727
     3 F     2019-01-13              41288.            5592
     4 M     2019-01-13              41304.            5632
     5 F     2019-01-20              41144.            5658
     6 M     2019-01-20              41298.            5692
     7 F     2019-01-27              41172.            5579
     8 M     2019-01-27              41295.            5684
     9 F     2019-02-03              41270.            5658
    10 M     2019-02-03              41183.            5612
    # ℹ 446 more rows

``` r
tock_csv_single_readr = proc.time()[3] - tick[3]
```

### Single file, arrow

``` r
tick = proc.time()
f = list.files("data_in", full.names = TRUE)

parallel::mclapply(f, mc.cores = 8, function(i){
read_csv_arrow(i) %>% 
    group_by(sex) %>% 
    summarise(end_of_this_period = unique(end_of_this_period),
              mean_income = mean(income),
              overdraft_users = sum(cash_min < 0))
}) %>% 
  bind_rows()
```

    # A tibble: 456 × 4
       sex   end_of_this_period mean_income overdraft_users
       <chr> <date>                   <dbl>           <int>
     1 F     2019-01-06              41201.            5622
     2 M     2019-01-06              41479.            5727
     3 F     2019-01-13              41288.            5592
     4 M     2019-01-13              41304.            5632
     5 F     2019-01-20              41144.            5658
     6 M     2019-01-20              41298.            5692
     7 F     2019-01-27              41172.            5579
     8 M     2019-01-27              41295.            5684
     9 F     2019-02-03              41270.            5658
    10 M     2019-02-03              41183.            5612
    # ℹ 446 more rows

``` r
tock_csv_single_arrow = proc.time()[3] - tick[3]
```

### Dataset, arrow

``` r
tick = proc.time()
f = list.files("data_in", full.names = TRUE)

open_csv_dataset(f) %>% 
    group_by(end_of_this_period, sex) %>% 
    summarise(mean_income = mean(income),
              overdraft_users = sum(cash_min < 0)) %>% 
  collect()
```

    # A tibble: 456 × 4
    # Groups:   end_of_this_period [228]
       end_of_this_period sex   mean_income overdraft_users
       <date>             <chr>       <dbl>           <int>
     1 2019-01-06         M          41479.            5727
     2 2019-01-06         F          41201.            5622
     3 2019-01-13         M          41304.            5632
     4 2019-01-13         F          41288.            5592
     5 2019-01-20         F          41144.            5658
     6 2019-01-20         M          41298.            5692
     7 2019-01-27         M          41295.            5684
     8 2019-01-27         F          41172.            5579
     9 2019-02-24         M          41584.            5635
    10 2019-02-24         F          41210.            5753
    # ℹ 446 more rows

``` r
tock_csv_dataset_arrow = proc.time()[3] - tick[3]
```

## Parquet

### Single file

``` r
tick = proc.time()
f = list.files("data_part_date", recursive = T, full.names = TRUE)

parallel::mclapply(f, mc.cores = 8, function(i){
read_parquet(i) %>% 
    group_by(sex) %>% 
    summarise(end_of_this_period = as.Date(str_sub(i, 35, 44)),
              mean_income = mean(income),
              overdraft_users = sum(cash_min < 0))
}) %>% 
  bind_rows()
```

    # A tibble: 456 × 4
       sex   end_of_this_period mean_income overdraft_users
       <chr> <date>                   <dbl>           <int>
     1 F     2019-01-06              41201.            5622
     2 M     2019-01-06              41479.            5727
     3 F     2019-01-13              41288.            5592
     4 M     2019-01-13              41304.            5632
     5 F     2019-01-20              41144.            5658
     6 M     2019-01-20              41298.            5692
     7 F     2019-01-27              41172.            5579
     8 M     2019-01-27              41295.            5684
     9 F     2019-02-03              41270.            5658
    10 M     2019-02-03              41183.            5612
    # ℹ 446 more rows

``` r
tock_parquet_single_arrow = proc.time()[3] - tick[3]
```

### Dataset

``` r
tick = proc.time()

open_dataset("data_part_date") %>% 
    group_by(end_of_this_period, sex) %>% 
    summarise(mean_income = mean(income),
              overdraft_users = sum(cash_min < 0)) %>% 
  collect()
```

    # A tibble: 456 × 4
    # Groups:   end_of_this_period [228]
       end_of_this_period sex   mean_income overdraft_users
       <chr>              <chr>       <dbl>           <int>
     1 2019-01-27         M          41295.            5684
     2 2019-01-27         F          41172.            5579
     3 2019-01-13         M          41304.            5632
     4 2019-01-13         F          41288.            5592
     5 2019-01-06         M          41479.            5727
     6 2019-01-06         F          41201.            5622
     7 2019-01-20         M          41298.            5692
     8 2019-01-20         F          41144.            5658
     9 2019-02-03         F          41270.            5658
    10 2019-02-03         M          41183.            5612
    # ℹ 446 more rows

``` r
tock_parquet_dataset_arrow = proc.time()[3] - tick[3]
```

## Results

``` r
tibble(method = c("csv_single_readr",
                  "csv_single_arrow",
                  "csv_dataset_arrow",
                  "parquet_single_arrow",
                  "parquet_dataset_arrow"),
       time_seconds = c(tock_csv_single_readr,
                  tock_csv_single_arrow,
                  tock_csv_dataset_arrow,
                  tock_parquet_single_arrow,
                  tock_parquet_dataset_arrow)) %>% 
  knitr::kable()
```

| method                | time_seconds |
|:----------------------|-------------:|
| csv_single_readr      |      144.419 |
| csv_single_arrow      |       63.787 |
| csv_dataset_arrow     |       57.479 |
| parquet_single_arrow  |       33.672 |
| parquet_dataset_arrow |        6.326 |
