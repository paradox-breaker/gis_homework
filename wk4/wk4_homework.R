# install package which didn't install in the past, but now I have installed
# install.packages("geojsonio")

# library all packages I need use in this task
library(readxl)
library(here)
library(dplyr)
library(geojsonio)
library(sf)
library(ggplot2)

# load excel data
GII2010 <- read_excel(here("wk4","GII2010.xlsx"), sheet = "Data")
GII2019 <- read_excel(here("wk4","GII2019.xlsx"), sheet = "Data")

# muatate a column to show the difference
GIIdiff <- GII2019 %>%
  inner_join(GII2010, by = "countryIsoCode", suffix = c("_2019", "_2010")) %>%
  mutate(GII_Difference = value_2019 - value_2010) %>%
  select(GII_Difference,COUNTRY = country_2019)

# load the geo information
world_geo <- geojson_read("wk4/World_Countries.geojson", what = "sp")

# use left_join to join difference 
world_geo@data <- world_geo@data %>%
  left_join(GIIdiff, by = "COUNTRY")

# check if there are duplicate columns
names(world_geo@data)
# check if difference successfully join in
print(world_geo@data)
# print(head(world_geo@data))

# generate a new geojson file
geojson_write(world_geo, file = "worldGII_diff_2019_2010.geojson", indent = 2)

# visualisation
world_sf <- st_as_sf(world_geo)
ggplot(data = world_sf) +
  geom_sf(aes(fill = GII_Difference), color = NA) +  
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +  
  labs(title = "GII Difference (2019 - 2010)",
       fill = "GII Difference") +
  theme_minimal()

