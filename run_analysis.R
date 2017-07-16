########################################
# Getting and Cleaning Data [Project]  #
# by Firas Sadiyah                     #
########################################

########### Getting the data ###########

# download data file
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

# unzip data file
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# list all files in the unzipped data folder
dataFilesPath <- file.path("./data" , "UCI HAR Dataset")
dataFiles<-list.files(dataFilesPath, recursive=TRUE)
dataFiles

# import the features table
features <- read.table('./data/UCI HAR Dataset/features.txt')

# import the activity labels
activity_lables <- read.table('./data/UCI HAR Dataset/activity_labels.txt', stringsAsFactors = FALSE)

# import the train tables
subject_train <- read.table('./data/UCI HAR Dataset/train/subject_train.txt')
X_train <- read.table('./data/UCI HAR Dataset/train/X_train.txt')
y_train <- read.table('./data/UCI HAR Dataset/train/y_train.txt')

# import the test tables
subject_test <- read.table('./data/UCI HAR Dataset/test/subject_test.txt')
X_test <- read.table('./data/UCI HAR Dataset/test/X_test.txt')
y_test <- read.table('./data/UCI HAR Dataset/test/y_test.txt')

########### Cleaning the data ###########
## Step 01: Merges the training and the test sets to create one data set.

# merge horizontally all the train tables into the train set
merged_train_set <- cbind(subject_train, y_train, X_train)

# merge horizontally all the test tables into the test set
merged_test_set <- cbind(subject_test, y_test, X_test)

# merge vertically the train and test sets
mergedAll <- rbind(merged_train_set, merged_test_set)

# label variables 3-563 using the features list
colnames(mergedAll)[c(3:563)] <- as.character(features[,2])

# label variables 1-2 as subject and activity respectively
colnames(mergedAll)[c(1:2)] <- c('subject', 'activity')

## Step 02: Extracts only the measurements on the mean and standard deviation for each measurement.
dataAll <- mergedAll[, grepl('mean\\(\\)|std\\(\\)|subject|activity', names(mergedAll))]

## Step 03: Uses descriptive activity names to name the activities in the data set
dataAll$activity <- with(activity_lables, V2[match(dataAll$activity, V1)])

## Step 04: Appropriately labels the data set with descriptive variable names.
names(dataAll) <- sub('^t','time', names(dataAll))
names(dataAll) <- sub('^f','frequency', names(dataAll))
names(dataAll) <- sub('Acc','Accelerometer', names(dataAll))
names(dataAll) <- sub('Gyro','Gyroscope', names(dataAll))
names(dataAll) <- sub('Mag','Magnitude', names(dataAll))
names(dataAll) <- sub('BodyBody ','Body', names(dataAll))

## Step 05: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidyData <-aggregate(. ~subject + activity, dataAll, mean)
tidyData <-tidyData[order(tidyData$subject, tidyData$activity),]

########### Writing the tidy data ###########
write.table(tidyData, file = 'tidyData.txt', row.name=FALSE)

