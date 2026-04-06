# NYC-Airbnb-Pricing-Dynamics-Across-Covid-Ero

> **A data visualization study** examining how Airbnb nightly prices shifted across New York City's five boroughs before, during, and after COVID-19 — analyzing 25,000+ listings across room types, price tiers, and neighborhoods to reveal uneven market recovery patterns.

<br>

[![R](https://img.shields.io/badge/R-Analysis%20%26%20Visualization-276DC3?style=flat-square&logo=r&logoColor=white)](https://www.r-project.org)
[![ggplot2](https://img.shields.io/badge/ggplot2-Data%20Visualization-FF6F61?style=flat-square)](https://ggplot2.tidyverse.org)
[![Inkscape](https://img.shields.io/badge/Inkscape-Poster%20Design-000000?style=flat-square&logo=inkscape&logoColor=white)](https://inkscape.org)
[![Data](https://img.shields.io/badge/Data-Kaggle%20NYC%20Airbnb-20BEFF?style=flat-square&logo=kaggle&logoColor=white)](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata)
[![Status](https://img.shields.io/badge/Status-Complete-1D9E75?style=flat-square)]()


## 1. What This Project Does

When COVID-19 hit New York City in 2020, Airbnb hosts and travelers faced a market they had never seen before. Demand collapsed overnight, then surged in unpredictable ways during recovery. But **which boroughs recovered fastest? Did certain room types see bigger price jumps? Did the overall market shift toward cheaper or more expensive listings?**

This project answers those questions using real Airbnb listing data from 2018 to 2022. It builds five original data visualizations — combining statistical analysis in **R** with professional poster design in **Inkscape** — that tell a clear, evidence-based story about how New York City's short-term rental market changed through three distinct phases:

| Era | Years | What Was Happening |
|---|---|---|
| **Pre-pandemic** | 2018–2019 | Normal market, baseline for all comparisons |
| **Pandemic** | 2020–2021 | Travel collapsed, prices and demand disrupted |
| **Post-pandemic** | 2022 | Recovery and market restructuring |

---

## 2. The Three Research Questions

Every visualization in this project is designed to answer one of three specific questions:

**Q1 — Borough-level prices:**
> *How did Airbnb prices change across NYC's five boroughs during COVID?*

**Q2 — Room type price distributions:**
> *How did the distribution of nightly prices shift across different room types — from pre-pandemic to post-pandemic?*

**Q3 — Market structure:**
> *Did the Airbnb market structurally shift toward higher price tiers as it transitioned through COVID eras?*

---

## 3. Dataset

| Detail | Value |
|---|---|
| **Source** | [NYC Airbnb Open Dataset — Kaggle](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata) |
| **Original size** | 102,599 listings · 26 variables |
| **After cleaning** | 25,520 listings · years 2018–2022 |
| **Geography** | All five NYC boroughs (Manhattan, Brooklyn, Queens, Bronx, Staten Island) |
| **Price range** | Nightly prices in USD |
| **Room types** | Entire home/apt · Private room · Hotel room · Shared room |
| **Time period** | Pre-pandemic (2018–2019) · Pandemic (2020–2021) · Post-pandemic (2022) |

The dataset captures real Airbnb listing attributes including nightly price, room type, borough, construction year (used as a proxy for era), service fee, and review date.

---

## 4. How the Data Was Cleaned

Raw data from Kaggle required significant cleaning before analysis. Here is exactly what was done and why:

| Cleaning Step | Why It Was Needed |
|---|---|
| Removed listings with missing construction year | Construction year was used to assign COVID era — rows without it couldn't be classified |
| Filtered to years 2018–2022 only | Focus on the pre/during/post COVID window; earlier listings are not relevant |
| Restricted to NYC's five official boroughs | Dataset contained inconsistent borough entries; only valid borough names were kept |
| Converted price from string to number | Raw prices were stored as text (e.g. "$150,00") — stripped `$` and `,` to get numeric values |
| Removed listings with zero or negative prices | Zero-price listings are data errors, not real market prices |
| Removed top 5% of prices for distribution plots | Extreme outliers ($5,000+ listings) compress the visual scale and obscure the main story |
| Assigned COVID era labels | Each listing tagged as Pre-pandemic / Pandemic / Post-pandemic based on construction year |

```r
# Example: price cleaning from the R script
AB_5Years <- AB_5Years %>%
  mutate(
    price = as.numeric(gsub("[$,]", "", price)),
    service.fee = as.numeric(gsub("[$,]", "", service.fee))
  ) %>%
  filter(!is.na(price), price > 0)
```

---

## 5. Visualizations — What Each Chart Shows

This project contains **five original visualizations**, each answering a specific question. Together they form an integrated data story presented as a research poster.

---

### Chart 1 — COVID-era Price Changes Across NYC Boroughs
**Type:** Indexed line chart (normalized to baseline = 100)

**What it shows:** Each borough's median nightly price, normalized to its own pre-pandemic level (index = 100). A value above 100 means prices rose; below 100 means they fell. This removes the absolute price differences between boroughs (Manhattan is always more expensive than the Bronx) and focuses purely on how each changed over time.

**Why this design:** A price index rather than raw dollar values lets you compare boroughs fairly — a $20 increase means very different things in Manhattan vs. Staten Island. The gradient color (light to dark red) reinforces the direction of change.

---

### Chart 2 — Distribution of Airbnb Nightly Prices in NYC
**Type:** Histogram with log-scaled x-axis

**What it shows:** The full shape of nightly price distribution across all 25,000+ listings. The log scale is used because prices are right-skewed — most listings cluster in the $50–$300 range, but some go to $1,000+. A log scale makes the full range readable without the expensive outliers dominating the chart.

**Why this design:** Shows where the "middle" of the market really sits, and reveals the long tail of premium listings that would be invisible on a standard linear scale.

---

### Chart 3 — NYC Airbnb Listings by Borough
**Type:** Horizontal bar chart (share of listings)

**What it shows:** What percentage of all NYC Airbnb listings belong to each borough — Manhattan and Brooklyn dominate, together accounting for over 80% of all listings.

**Why this design:** Provides essential geographic context before interpreting price patterns. A borough with 0.8% of listings (Staten Island) tells a different story than one with 42.3% (Manhattan).

---

### Chart 4 — Airbnb Price Tier Composition Across COVID Eras
**Type:** Alluvial (Sankey-style flow) diagram

**What it shows:** How the mix of listings across four price tiers (under $150 / $150–$300 / $300–$600 / $600+) changed across the three COVID eras. The flowing bands show where listings moved — did the market shift toward premium prices, or did it commoditize downward?

**Why this design:** An alluvial diagram is the clearest way to show compositional change over time. The flow of colored bands makes it immediately visible when large groups of listings shift price tiers between eras — something a grouped bar chart would hide.

```r
# Price tier classification
AB_5Years2 <- AB_5Years %>%
  mutate(
    price_bucket = case_when(
      price < 150  ~ "< $150",
      price < 300  ~ "$150–$300",
      price < 600  ~ "$300–$600",
      TRUE         ~ "$600+"
    )
  )
```

---

### Chart 5 — Airbnb Price Shifts by Room Type (Pre vs Post COVID)
**Type:** Ridgeline density plot with median markers

**What it shows:** For each room type (Entire home/apt, Private room, Hotel room, Shared room), the full price distribution is shown for pre-pandemic (red) and post-pandemic (beige). Vertical lines mark the median for each group. Overlapping distributions reveal where price ranges widened, narrowed, or shifted entirely.

**Why this design:** A ridgeline plot shows the full shape of a distribution — not just the average. Two overlapping density curves immediately reveal whether prices shifted or simply spread out more. Median lines give a precise reference point within each shape.

---

## 6. Key Findings

**Borough-level price changes:**
- **Staten Island** saw the largest price increase through the COVID period, far outpacing other boroughs
- **Manhattan** — the most expensive borough — saw the flattest price trajectory, with minimal recovery relative to its pre-pandemic baseline
- **Brooklyn and Bronx** showed moderate, similar recovery curves
- Outer boroughs benefited from a "suburban shift" in traveler preferences during and after the pandemic

**Price distribution:**
- The overall market is right-skewed — most listings price between $50 and $300, with a long tail of premium properties
- The market did **not** simply become uniformly more expensive — instead it polarized, with both the budget and premium tiers growing

**Room type shifts:**
- **Entire homes/apartments** saw the most dramatic upward price shift post-pandemic — the median rose significantly
- **Private rooms** maintained more stable pricing, making them relatively more affordable post-COVID
- **Hotel rooms** showed the widest spread in post-pandemic pricing, reflecting varied recovery across hotel-style listings
- **Shared rooms** — the most affordable category — saw the smallest absolute shifts

**Market structure:**
- The $600+ tier (premium listings) grew substantially between pandemic and post-pandemic eras
- The sub-$150 tier shrank — fewer budget listings relative to earlier years
- This confirms a structural shift: **the NYC Airbnb market moved upmarket through COVID recovery**

---

## 7. Repository Structure

```
nyc-airbnb-covid-pricing-analysis/
│
├── README.md                          ← You are here
│
├── analysis/
│   └── Sudarshana_Sanchitha.R         ← Full R script: data cleaning + all 5 visualizations
│
├── visuals/
│   └── Sudarshana_Sanchitha.svg       ← Final poster (SVG format, scalable)
│
├── poster/
│   └── Sudarshana_Sanchitha.pdf       ← Completed research poster (PDF format)
│
└── data/
    └── README_data.md                 ← Data source info and download instructions
```

> **Note on raw data:** The source dataset (102,599 listings) is not included in this repository due to file size. Download it directly from [Kaggle](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata) and place it in the `data/` folder before running the R script.

---

## 8. Tech Stack

| Tool | What It Was Used For |
|---|---|
| **R** | All data cleaning, transformation, and statistical analysis |
| **ggplot2** | Core chart-building library — all five visualizations |
| **ggridges** | Ridgeline density plots (Chart 5 — room type price shifts) |
| **ggalluvial** | Alluvial / Sankey flow diagrams (Chart 4 — price tier composition) |
| **dplyr** | Data wrangling — filtering, grouping, summarizing |
| **scales** | Dollar formatting, percentage labels on chart axes |
| **ggpubr** | Combining multiple charts into a single composite layout |
| **Inkscape** | Professional poster layout, typography, and design |

---

## 9. How to Run This Project

### Prerequisites
- R (version 4.0 or newer) — download at [r-project.org](https://www.r-project.org)
- RStudio (recommended) — download at [posit.co](https://posit.co/download/rstudio-desktop/)

### Step 1 — Download the dataset

Go to [Kaggle NYC Airbnb Open Data](https://www.kaggle.com/datasets/arianazmoudeh/airbnbopendata) → Download → place the CSV file in the `data/` folder of this project. The file should be named `Airbnb_Open_Data.csv`.

### Step 2 — Install required R packages

Open RStudio and run this once:
```r
install.packages(c("dplyr", "ggplot2", "ggridges", "ggalluvial", "ggpubr", "scales"))
```

### Step 3 — Load the data

In RStudio, load your dataset:
```r
Airbnb_Open_Data <- read.csv("data/Airbnb_Open_Data.csv")
```

### Step 4 — Run the analysis script

Open `analysis/Sudarshana_Sanchitha.R` in RStudio → click **Run All** (or press `Ctrl + Shift + Enter`).

The script will:
1. Clean and prepare the dataset
2. Assign COVID era labels to each listing
3. Generate all five visualizations in sequence

Each chart will appear in RStudio's Plots panel. Export any chart as PNG or PDF using RStudio's **Export** button in the Plots panel.

---
