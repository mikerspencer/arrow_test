# ---------------------------------
# ---------------------------------
# generate test data
# ---------------------------------
# ---------------------------------

library(tidyverse)

# ---------------------------------
# Demographic
sample_size = 500000


cid = paste0(sample(1:26, 500000, replace = TRUE), sample(100000000:999999999, sample_size))
#postal_district
#age_band
sex = sample(c("M", "F"), 500000, replace = TRUE)


# ---------------------------------
# Weekly

dates = seq.Date(as.Date("2019-01-06"), by = 7, to = today())

if(!dir.exists("data")){
  dir.create("data")
}

parallel::mclapply(dates, mc.cores = 6, function(i){
  tibble(cid,
         sex,
         end_of_this_period = i) %>%
    mutate(income = rlnorm(sample_size) * 25000,
           income_salary = rlnorm(sample_size) * 25000,
           income_benefits = rlnorm(sample_size) * 2000,
           income_pension = rlnorm(sample_size) * 10000,
           income_investment = rlnorm(sample_size) * 100,
           income_interest = rlnorm(sample_size) * 200,
           income_other = rlnorm(sample_size) * 5000,
           expenditure = income * 0.95,
           expenditure_committed = income * 0.3,
           expenditure_essential = income * 0.5,
           expenditure_qol = income * 0.1,
           expenditure_discretionary = income * 0.05,
           expenditure_uncategorized = income * 0.05,
           cash_balance_final = rnorm(sample_size, 300, 50),
           cash_min = rnorm(sample_size, 100, 50),
           cash_max = rnorm(sample_size, 1000, 50)) %>%
    write_csv(paste0("data_in/finance_", i, ".csv"))
  gc()
})


