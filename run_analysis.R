# Merge the training and the test sets to create one data set.

test <- data.table::fread(file = "./UCI HAR Dataset/test/X_test.txt")
train <- data.table::fread(file = "./UCI HAR Dataset/train/X_train.txt")
y_test <- data.table::fread(file = "./UCI HAR Dataset/test/y_test.txt")
y_train <- data.table::fread(file = "./UCI HAR Dataset/train/y_train.txt")

subject_test <- data.table::fread(file = "./UCI HAR Dataset/test/subject_test.txt")
subject_train <- data.table::fread(file = "./UCI HAR Dataset/train/subject_train.txt")

test <- cbind(y_test, test)
test <- cbind(subject_test, test)
train <- cbind(y_train, train)
train <- cbind(subject_train, train)

data <- rbind(test, train)

# Extract only the measurements on the mean and standard deviation for each measurement

features <- data.table::fread(file = "./UCI HAR Dataset/features.txt")

mean_std_raw <- grep("mean()|std()", features$V2)

mean_std <- c(1, 2, mean_std_raw +2)

data <- data[, ..mean_std]

# Use descriptive activity names to name the activities in the data set

activity_names = c("WALKING",
                   "WALKING_UPSTAIRS",
                   "WALKING_DOWNSTAIRS",
                   "SITTING",
                   "STANDING",
                   "LAYING")

data[,2] <- activity_names[unlist(data[,2])]

# Appropriately label the data set with descriptive variable names

features <- features[mean_std_raw]
features <- gsub("-", ".", features$V2)
features <- sub("t", "time", features)
features <- sub("f", "freq", features)
features <- c("subject", "activityLabel", features)

colnames(data) = features

# From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

library(dplyr)

tidy_data <- group_by(data, subject, activityLabel)
tidy_data <- summarise_each(tidy_data, funs = "mean")

write.table(tidy_data, file = "tidyData.txt", row.names = FALSE)