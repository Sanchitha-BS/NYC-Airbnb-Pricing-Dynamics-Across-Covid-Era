library(dplyr)
library(ggplot2)
library(ggridges)
library(scales)
library(ggalluvial)
library(ggpubr)   



str(Airbnb_Open_Data)

AirBnb <- Airbnb_Open_Data

AirBnb_clean <- AirBnb %>%
  filter(!is.na(Construction.year))


AB_5Years <- AirBnb_clean %>%
  filter(Construction.year %in% c(2018, 2019, 2020, 2021, 2022))


table(AB_5Years$Construction.year, useNA = "ifany")


dim(AB_5Years)

summary(AB_5Years)


colSums(is.na(AB_5Years))


summary(AB_5Years$price)

table(AB_5Years$room.type)

table(AB_5Years$neighbourhood.group)


AB_5Years <- AB_5Years %>%
  mutate(
    price = as.numeric(gsub("[$,]", "", price)),
    service.fee = as.numeric(gsub("[$,]", "", service.fee)),
    last.review = as.Date(last.review, format = "%m/%d/%Y"),
    room.type = as.factor(room.type),
    neighbourhood.group = as.character(neighbourhood.group)
  )


boroughs <- c("Bronx","Brooklyn","Manhattan","Queens","Staten Island")

AB_5Years <- AB_5Years %>%
  filter(neighbourhood.group %in% boroughs)

AB_5Years <- AB_5Years %>%
  mutate(neighbourhood.group = factor(neighbourhood.group, levels = boroughs)) %>%
  droplevels()

AB_5Years <- AB_5Years %>%
  filter(!is.na(price), price > 0)


summary(AB_5Years$price)
table(AB_5Years$room.type, useNA = "ifany")
table(AB_5Years$neighbourhood.group, useNA = "ifany")


AB_5Years$Era <- with(AB_5Years,
                      ifelse(Construction.year %in% c(2018, 2019), "Pre-pandemic (2018–2019)",
                             ifelse(Construction.year %in% c(2020, 2021), "Pandemic (2020–2021)",
                                    "Post-pandemic (2022)"))
)

AB_5Years$Era <- factor(AB_5Years$Era,
                        levels = c("Pre-pandemic (2018–2019)",
                                   "Pandemic (2020–2021)",
                                   "Post-pandemic (2022)"))

table(AB_5Years$Era , useNA = "ifany")
str(AB_5Years)

table(AB_5Years$neighbourhood.group, useNA="ifany")




#MAIN PLOT

# How did Airbnb prices change across NYC boroughs during COVID?


nb_med <- AB_5Years %>%
  group_by(neighbourhood.group, Era) %>%
  summarise(med_price = median(price, na.rm = TRUE), .groups = "drop")

nb_baseline <- nb_med %>%
  filter(Era == "Pre-pandemic (2018–2019)") %>%
  select(neighbourhood.group, base = med_price)

nb_med2 <- nb_med %>%
  left_join(nb_baseline, by = "neighbourhood.group") %>%
  mutate(index = 100 * med_price / base) %>%
  filter(!is.na(index), is.finite(index)) %>%
  droplevels()

end_labels <- nb_med2 %>%
  filter(Era == "Post-pandemic (2022)") %>%
  mutate(label = neighbourhood.group)

ggplot(nb_med2,aes(x = Era, y = index, group = neighbourhood.group, color = index)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey45", linewidth = 0.8) +
  geom_line(linewidth = 1.2, alpha = 0.95) +
  geom_point(size = 3.0) +
  geom_text(
    data = end_labels, aes(label = label),
    hjust = 0, nudge_x = 0.07, size = 4, fontface = "bold",
    show.legend = FALSE ) +
    
  scale_color_gradient(
    low  = "#F3E6D8",   
    high = "#8C1D18",   
    name = "Price index" ) +
  
    scale_x_discrete(expand = expansion(mult = c(0.02, 0.18))) +
  
  labs(
    title = "COVID-era Changes In Airbnb Prices Across NYC Boroughs",
    #subtitle = "Median nightly prices relative to each borough’s pre-COVID baseline (index = 100)",
    x = NULL,
    y = "Median price index"
  ) +
  
  theme_classic(base_size = 12) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 10),
    axis.title.y = element_text(face = "bold"),
    axis.text.x = element_text(face = "bold",size=8),
    axis.text.y = element_text(size = 10)
  )





#1D PLOTS

#PLOT   1 (BOROUGH)


borough_share <- AB_5Years %>%
  filter(!is.na(neighbourhood.group), neighbourhood.group != "") %>%
  count(neighbourhood.group, name = "n") %>%
  mutate(share = n / sum(n)) %>%
  arrange(desc(share)) %>%
  mutate(
    rank = row_number(),
    fill_col = ifelse(rank == 1, "#B24A45", "#C97C73"),   
    neighbourhood.group = reorder(neighbourhood.group, share)
  )

bar_border <- "#5A2A27"
text_col   <- "#2B2B2B"

ggplot(borough_share, aes(x = neighbourhood.group, y = share)) +
  geom_col(aes(fill = fill_col), color = bar_border, linewidth = 0.6, width = 0.72) +
  scale_fill_identity() +
  geom_text(aes(label = percent(share, accuracy = 0.1)),
            hjust = -0.12, size = 4, color = text_col) +
  coord_flip(clip = "off") +
  scale_y_continuous(labels = percent_format(accuracy = 1),
                     expand = expansion(mult = c(0, 0.12))) +
  labs(title = "NYC Airbnb Listings By Borough", 
       x = NULL, y = "Share of listings") +
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    axis.text.y = element_text(face = "bold", color = text_col),
    axis.text.x = element_text(color = text_col),
    axis.title.x = element_text(face = "bold"),
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank()
  )





#PLOT 2 (PRICE)

p95_price <- quantile(AB_5Years$price, 0.95, na.rm = TRUE)

AB_price_1d <- AB_5Years %>%
  filter(!is.na(price), price > 0, price <= p95_price)

ggplot(AB_price_1d, aes(x = price)) +
  geom_histogram(
    bins = 45,
    fill = "#8C1D18",        
    color = "white",
    linewidth = 0.3
  ) +
  scale_x_log10(
    labels = dollar_format(),
    breaks = c(50, 100, 250, 500, 1000)
  ) +
  labs(
    title = "Distribution of Airbnb Nightly Prices in NYC",
    x = "Nightly price (log scale)",
    y = "Number of listings"
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    axis.title.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold"),
    axis.text = element_text(color = "#2B2B2B")
  )





# OTHER PLOTS

#PLOT 1 

#Did the Airbnb market structurally shift toward higher price tiers as it transitioned through COVID eras ?

AB_5Years2 <- AB_5Years %>%
  mutate(
    price_bucket = case_when(
      price < 150 ~ "< $150",
      price < 300 ~ "$150–$300",
      price < 600 ~ "$300–$600",
      TRUE ~ "$600+"
    ),
    price_bucket = factor(price_bucket,
                          levels = c("< $150", "$150–$300", "$300–$600", "$600+")),
    Era = factor(Era, levels = c("Pre-pandemic (2018–2019)",
                                 "Pandemic (2020–2021)",
                                 "Post-pandemic (2022)"))
  )

alluvial_data <- AB_5Years2 %>%
  filter(!is.na(price_bucket), !is.na(Era)) %>%
  count(Era, price_bucket, name = "n")

tier_pal <- c(
  "< $150"     = "#E8D5C4",  
  "$150–$300"  = "#D9B8A6",
  "$300–$600"  = "#C97E72",
  "$600+"      = "#B44A43"   
)

ggplot(alluvial_data,
       aes(axis1 = Era, axis2 = price_bucket, y = n)) +
  
  geom_alluvium(aes(fill = price_bucket),
                alpha = 0.75, width = 0.18, color = NA) +
  
  geom_stratum(width = 0.22, fill = "grey96", color = "grey55", linewidth = 0.4) +
  
  geom_text(stat = "stratum",
            aes(label = paste0(after_stat(stratum), "\n", comma(after_stat(count)))),
            size = 3.2, lineheight = 0.95, color = "grey15") +
  
  scale_fill_manual(values = tier_pal, name = "Price tier") +
  scale_x_discrete(limits = c("COVID era", "Price tier"),
                   expand = c(0.15, 0.05)) +
  
  labs(
    title = "Airbnb Price Tier Composition Across COVID Eras",
    y = "Listings (count)",
    x = NULL
  ) +
  
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    axis.text.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold"),
    plot.subtitle = element_text(size = 10),
    legend.position = "right"
  )




# PLOT 2

# How did the distribution of nightly prices shift across different room types from pre-pandemic to post-pandemic periods?



price_cap <- quantile(AB_5Years$price, 0.95, na.rm = TRUE)

room_medians <- AB_5Years %>%
  filter(Era %in% c("Pre-pandemic (2018–2019)", "Post-pandemic (2022)")) %>%
  group_by(room.type, Era) %>%
  summarise(med_price = median(price, na.rm = TRUE), .groups = "drop")

ggplot(
  AB_5Years %>%
    filter(Era %in% c("Pre-pandemic (2018–2019)", "Post-pandemic (2022)"),
           price <= price_cap),
  aes(x = price, y = room.type, fill = Era)
) +
  
  geom_density_ridges( alpha = 0.7, scale = 1.1,  color = "white", linewidth = 0.3
) +
  
  
geom_vline(
  data = room_medians,
  aes( xintercept = med_price, color = room.type, linetype = Era ),
  linewidth = 1.1
) +
  
  
scale_fill_manual(
  values = c(
    "Pre-pandemic (2018–2019)" = "#E15759",   
    "Post-pandemic (2022)"     = "#E8D9C5"    
  )
) +
  
  scale_color_manual(
    values = c(
      "Entire home/apt" = "#e7298a",  
      "Private room"    = "#d95f02",  
      "Shared room"     = "#1b9e77",  
      "Hotel room"      = "#1F3A5F"   
    )
  ) +
  
  scale_x_continuous(labels = dollar_format()) +
  
  labs(
    title = "Airbnb Price Shifts By Room Type (Pre vs Post COVID)",
    x = "Nightly price (USD)",
    y = "Room type",
    fill = "Era",
    color = "Room type",
    linetype = "Era"
  ) +
  
  theme_classic(base_size = 12) +
  theme(
    legend.position = "right",
    legend.key.width = unit(1.2, "cm"),
    plot.title = element_text(face = "bold", size = 16),
    axis.title.x = element_text(face = "bold"),
    axis.title.y = element_text(face = "bold"),
    plot.subtitle = element_text(size = 10)
  )


