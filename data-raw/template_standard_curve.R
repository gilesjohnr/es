path <- file.path(getwd(), "data-raw/3 std card BG-SP_08-01-23.csv")

x <- read.csv(path)

# Fix columns
x <- x[!(colnames(x) %in% c('file_name', 'target_name_unique'))]
colnames(x)[colnames(x) == 'target_name_concise'] <- 'target_name'


# Make 3 generic target names
x <- x[x$target_name %in% unique(x$target_name)[1:3],]
x$target_name[x$target_name == unique(x$target_name)[1]] <- "target_1"
x$target_name[x$target_name == unique(x$target_name)[2]] <- "target_2"
x$target_name[x$target_name == unique(x$target_name)[3]] <- "target_3"


# Make random emulation of the data
template_standard_curve <- x
template_standard_curve$ct_value <- NA
std_dev <- sd(x$ct_value)*0.25

for (i in 1:nrow(x)) {

     template_standard_curve$ct_value[i] <- rnorm(1, x$ct_value[i], sd=std_dev)

}

write.csv(template_standard_curve, file.path(getwd(), "data-raw/template_standard_curve.csv"), row.names = FALSE)
usethis::use_data(template_standard_curve, overwrite = TRUE)
