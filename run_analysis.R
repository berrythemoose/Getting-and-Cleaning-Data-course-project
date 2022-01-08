## load package
library(dplyr)

## loading files
if (!file.exists("getdata_dataset.zip")){
        fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
        download.file(fileurl, "getdata_dataset.zip", method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
        unzip("getdata_dataset.zip") 
}

## creating data frames
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

## merging datsets
X_all <- rbind(x_train, x_test)
Y_all <- rbind(y_train, y_test)
Subject_all <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject_all, Y_all, X_all)

## extracting mean and sd data
TidyData <- Merged_Data %>% select(subject, code, contains("mean"), contains("std"))

## name activities in merged dataset using descriptive activity names
TidyData$code <- activityLabels[TidyData$code, 2]

## label dataset with descriptive variable names
names(TidyData)[2] = "activity"
names(TidyData)<-gsub("Acc", "Accelerometer", names(TidyData))
names(TidyData)<-gsub("Gyro", "Gyroscope", names(TidyData))
names(TidyData)<-gsub("BodyBody", "Body", names(TidyData))
names(TidyData)<-gsub("Mag", "Magnitude", names(TidyData))
names(TidyData)<-gsub("^t", "Time", names(TidyData))
names(TidyData)<-gsub("^f", "Frequency", names(TidyData))
names(TidyData)<-gsub("tBody", "TimeBody", names(TidyData))
names(TidyData)<-gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-std()", "STD", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("angle", "Angle", names(TidyData))
names(TidyData)<-gsub("gravity", "Gravity", names(TidyData))

## create second, independent tidy data set with the average of each variable for each activity and each subject
FinalData <- TidyData %>%
        group_by(subject, activity) %>%
        summarise_all(list(mean=mean))
write.table(FinalData, "FinalData.txt", row.name=FALSE)