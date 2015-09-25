library(data.table)
library(utils)
library(reshape2)

# download data file and unzip
if(!file.exists("FUCI_HAR_Dataset.zip")){
  download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                destfile ="FUCI_HAR_Dataset.zip",
                method = "curl")
  unzip("FUCI_HAR_Dataset.zip")
}

folder <- "UCI HAR Dataset"

activity_label.tbl <- read.table(paste(folder, "activity_labels.txt", sep="/"))
features.tbl <- read.table(paste(folder, "features.txt", sep="/"))

# read train data
train_subjects.tbl <- read.table(paste(folder, "train", "subject_train.txt", sep="/"))
train_x.tbl <- read.table(paste(folder, "train", "X_train.txt", sep="/"))
train_y.tbl <- read.table(paste(folder, "train", "y_train.txt", sep="/"))

# read test data
test_subjects.tbl <- read.table(paste(folder, "test", "subject_test.txt", sep="/"))
test_x.tbl <- read.table(paste(folder, "test", "X_test.txt", sep="/"))
test_y.tbl <- read.table(paste(folder, "test", "y_test.txt", sep="/"))

# merge train + test data set
full_x.tbl <- rbind( train_x.tbl, test_x.tbl)

# put col names
colnames(full_x.tbl) <- c(as.character(features.tbl[,2]))

# extract only the measurements on the mean and std of measurments
mean_std.filter <- grepl("mean", colnames(full_x.tbl)) | grepl("std", colnames(full_x.tbl))
full_x_mean_std.tbl <- full_x.tbl[, mean_std.filter]

# assign activity
full_y.tbl <- rbind( train_y.tbl, test_y.tbl)
full_activity.tbl <- cbind(full_y.tbl, full_x_mean_std.tbl)
colnames(full_activity.tbl)[1] <- "Activity"
# label for activity
for(i in 1:length(full_activity.tbl[,1])){
  full_activity.tbl[i,1] <- activity_label.tbl[full_activity.tbl[i,1],2]
}

# assign subjects
all_subjects.tbl <- rbind(train_subjects.tbl, test_subjects.tbl)

subjects_activity.tbl <- cbind(all_subjects.tbl, full_activity.tbl)
colnames(subjects_activity.tbl)[1] <- "Subject"

# making it tidy
subjects_activity.melted = melt(subjects_activity.tbl, id.var = c("Subject", "Activity"))
subjects_activity.means = dcast(subjects_activity.melted , Subject + Activity ~ variable, mean)


write.table(subjects_activity.means, file="activity_data.txt", row.name=FALSE)
