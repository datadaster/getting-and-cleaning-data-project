## Date: 05/06/2016
## Getting and Cleaning Data Course Project

library(reshape2)
filename <- "getdata-projectfiles-UCI HAR Dataset.zip"

# Download and unzip the dataset
if (!file.exists(filename)){
        fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, filename)
}
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename)
}

# Load activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
featuresFiltered <- grep(".*mean.*|.*std.*", features[,2])
featuresFiltered.names <- features[featuresFiltered,2]
featuresFiltered.names = gsub('-mean', 'Mean', featuresFiltered.names)
featuresFiltered.names = gsub('-std', 'Std', featuresFiltered.names)
featuresFiltered.names <- gsub('[-()]', '', featuresFiltered.names)

# Load train dataset
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresFiltered]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load test dataset
test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresFiltered]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets adding labels
fullData <- rbind(train, test)
colnames(fullData) <- c("subject", "activity", featuresFiltered.names)

# turn activities & subjects into factors
fullData$activity <- factor(fullData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
fullData$subject <- as.factor(fullData$subject)

fullData.melted <- melt(fullData, id = c("subject", "activity"))
fullData.mean <- dcast(fullData.melted, subject + activity ~ variable, mean)

# Write the tidy file
write.table(fullData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

# remove variables
rm(filename)
rm(activityLabels)
rm(features)
rm(featuresFiltered)
rm(featuresFiltered.names)
rm(train)
rm(trainActivities)
rm(trainSubjects)
rm(test)
rm(testActivities)
rm(testSubjects)
rm(fullData)
rm(fullData.melted)
rm(fullData.mean)