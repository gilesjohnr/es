library(es.dhaka)
library(ggplot2)
library(data.table)
library(mgcv)
library(zoo)

path <- file.path(getwd(), "data-raw/compiled.csv")

d <- as.data.frame(fread(path))

# Subset to 2021 and beyond
sel <- which(d$sample_date >= as.Date("2021-01-01"))
d <- d[sel,]

# Shift dates
d$sample_date <- d$sample_date - 300

# Choose 3 locations
example_locations <- c(1,2,3)
d <- d[d$location_id %in% example_locations,]

# Consolidate messy coordinates
for (i in example_locations) {

     sel <- which(d$location_id == i)
     d$lat_dd[sel] <- round(median(d$lat_dd[sel], na.rm=T), 2)
     d$lon_dd[sel] <- round(median(d$lon_dd[sel], na.rm=T), 2)

}

# Aggregate MS2 responses
d$target_name[d$target_name %in% c('MS2_1', 'MS2_2')] <- 'MS2'

# Choose 2 targets and a control
example_targets <- c('MS2', 'Rotavirus', 'Norovirus_GI', 'V_cholerae') # List control first!
#example_targets <- c('PhHV', 'V_cholerae', 'Shigella_EIEC')

d <- d[d$target_name %in% example_targets,]
prop_missing <- sum(is.na(d$ct_value))/nrow(d)

# Simulate some MS2 values to fill in sparse data
for (i in unique(d$location_id)) {

     tmp <- d[d$location_id == i & d$target_name == 'MS2',]

     mod <- mgcv::gam(formula = ct_value ~ s(as.numeric(sample_date)), data=tmp, family = 'gaussian')
     pred <- predict(mod, newdata = tmp, type='response', se.fit=T)
     tmp$fit <- pred$fit
     tmp$se_fit <- pred$se.fit
     tmp$sim <- NA

     set.seed(1)
     for (j in 1:nrow(tmp)) tmp$sim[j] <- rnorm(1, mean=tmp[j,'fit'], sd=tmp[j,'se_fit']*2.5)


     ggplot(tmp, aes(x=sample_date, y=ct_value)) +
          geom_point(aes(y=sim), color='blue', alpha=0.5) +
          geom_point(alpha=0.5) +
          geom_line(aes(y=fit), color='green3') +
          facet_grid(rows=vars(location_id), cols=vars(target_name)) +
          theme_bw()

     d[d$location_id == i & d$target_name == 'MS2', 'ct_value'] <- tmp$sim

}


# Emulate observed ct values
for (i in unique(d$location_id)) {
     for (j in example_targets) {

          tmp <- d[d$location_id == i & d$target_name == j,]

          mod <- mgcv::gam(formula = ct_value ~ s(as.numeric(sample_date)), data=tmp, family = 'Gamma')
          pred <- predict(mod, newdata = tmp, type='response', se.fit=T)
          tmp$fit <- pred$fit
          tmp$se_fit <- pred$se.fit
          tmp$sim <- NA

          set.seed(1)
          for (k in 1:nrow(tmp)) tmp$sim[k] <- rnorm(1, mean=tmp[k,'fit'], sd=tmp[k,'se_fit']*2.5)

          if (F) {

               ggplot(tmp, aes(x=sample_date, y=ct_value)) +
                    geom_point(aes(y=sim), color='blue', alpha=0.5) +
                    geom_point(alpha=0.5) +
                    geom_line(aes(y=fit), color='green3') +
                    facet_grid(rows=vars(location_id), cols=vars(target_name)) +
                    theme_bw()

          }

          d[d$location_id == i & d$target_name == j, 'ct_value'] <- tmp$sim

     }
}

d$ct_value[is.nan(d$ct_value)] <- NA
d$ct_value <- pmin(d$ct_value, 40)

# Assign some random missingness
sel <- sample(1:nrow(d), nrow(d)*prop_missing)
d$ct_value[sel] <- NA


# Select columns and rename
d <- d[colnames(d) %in% c('sample_date', 'location_id', 'lat_dd', 'lon_dd', 'target_name', 'ct_value')]
colnames(d)[colnames(d) == 'lat_dd'] <- 'lat'
colnames(d)[colnames(d) == 'lon_dd'] <- 'lon'
d <- d[,c('sample_date', 'location_id', 'lat', 'lon', 'target_name', 'ct_value')]


d$target_name[d$target_name == 'MS2'] <- "target_0"
d$target_name[d$target_name == example_targets[2]] <- "target_1"
d$target_name[d$target_name == example_targets[3]] <- "target_2"
d$target_name[d$target_name == example_targets[4]] <- "target_3"

d$sample_date <- d$sample_date - 1000



ggplot(d, aes(x=sample_date, y=ct_value)) +
     geom_point(alpha=0.5) +
     facet_grid(rows=vars(location_id), cols=vars(target_name)) +
     theme_bw()

d <- d[order(d$sample_date, d$location_id, d$target_name),]
row.names(d) <- NULL

template_es_data <- d

write.csv(template_es_data, file.path(getwd(), "data-raw/template_es_data.csv"), row.names = FALSE)
usethis::use_data(template_es_data, overwrite = TRUE)
