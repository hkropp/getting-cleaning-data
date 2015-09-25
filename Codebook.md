# Human Activity Recognition Using Smartphones Dataset

## Background

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

## Data Provided

Download here: 
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

## Data Transformation

1. Dependent packages.

    library(data.table)
    library(utils)
    library(reshape2)

2. Download and unzip the data.

    if(!file.exists("FUCI_HAR_Dataset.zip")){
      download.file(url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                    destfile ="FUCI_HAR_Dataset.zip",
                    method = "curl")
      unzip("FUCI_HAR_Dataset.zip")
    }

3. Read training and test data sets.

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

4. Merge training and test data sets into one dataset.

    # merge train + test data set
    full_x.tbl <- rbind( train_x.tbl, test_x.tbl)
    
    # put col names
    colnames(full_x.tbl) <- c(as.character(features.tbl[,2]))

5. Filter columns by 'mean' and 'std' as we are only interested in such values.

    mean_std.filter <- grepl("mean", colnames(full_x.tbl)) | grepl("std", colnames(full_x.tbl))
    full_x_mean_std.tbl <- full_x.tbl[, mean_std.filter]

6. Assigne activity label to the dataset.

    full_y.tbl <- rbind( train_y.tbl, test_y.tbl)
    full_activity.tbl <- cbind(full_y.tbl, full_x_mean_std.tbl)
    colnames(full_activity.tbl)[1] <- "Activity"
    # label for activity
    for(i in 1:length(full_activity.tbl[,1])){
      full_activity.tbl[i,1] <- activity_label.tbl[full_activity.tbl[i,1],2]
    }

7. Assigne subjects to the the records.

    all_subjects.tbl <- rbind(train_subjects.tbl, test_subjects.tbl)
    
    subjects_activity.tbl <- cbind(all_subjects.tbl, full_activity.tbl)
    colnames(subjects_activity.tbl)[1] <- "Subject"

7. Creating mean and aggregated view of the data.
    subjects_activity.melted = melt(subjects_activity.tbl, id.var = c("Subject", "Activity"))
    subjects_activity.means = dcast(subjects_activity.melted , Subject + Activity ~ variable, mean)

8. Write data to CSV file.
    write.table(subjects_activity.means, file="activity_data.csv")

