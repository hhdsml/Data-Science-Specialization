#=============================
#  getting and cleaning data project
#  author: hhdsml
#==============================

# load packages and get data
rm(list = ls())

library(data.table)
library(reshape2)

path <- getwd()

if(!file.exists("UCI HAR Dataset")){ 
  
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  
  download.file(url, file.path(path,"datafile.zip"))
  
  unzip(zipfile = "datafile.zip")
}

## 4. Appropriately labels the data set with descriptive variable names.
## 1. Merges the training and the test sets to create one data set.

# load feature , labels 

features <- fread(".\\UCI HAR Dataset\\features.txt", 
                  col.names = c("index", "featureNames"))

activity_labels <- fread(".\\UCI HAR Dataset\\activity_labels.txt",  
                         col.names = c("activitylabel", "activityName"))


# load test and train 

subject_test <- fread(".\\UCI HAR Dataset\\test\\subject_test.txt", col.names = "subjectNumber" )
subject_train <- fread(".\\UCI HAR Dataset\\train\\subject_train.txt", col.names = "subjectNumber" )

x_test <- fread(".\\UCI HAR Dataset\\test\\X_test.txt", col.names = features$featureNames)
x_train <- fread(".\\UCI HAR Dataset\\train\\X_train.txt", col.names = features$featureNames)

y_test <- fread(".\\UCI HAR Dataset\\test\\y_test.txt", col.names = "activitylabel")
y_train <- fread(".\\UCI HAR Dataset\\train\\y_train.txt", col.names = "activitylabel")


# data test, data train
data_test <- cbind(subject_test, y_test, x_test)


data_train <- cbind(subject_train, y_train, x_train)

# merge data

data <- rbind(data_train, data_test)

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
col_select <- as.vector(grep("subjectNumber|activitylabel|mean|std", colnames(data)))

data_sub <- data[ ,..col_select]

## 3. Uses descriptive activity names to name the activities in the data set
data_sub$activitylabel <- activity_labels[data_sub$activitylabel,2]
setnames(data_sub,"activitylabel","activity")

## 5. From the data set in step 4, creates a second, independent tidy data set with 
## the average of each variable for each activity and each subject. 

data_long1 <- melt(data_sub, id.vars = c("subjectNumber","activity"), measure.vars = setdiff(colnames(data_sub),c("subjectNumber","activity")),na.rm=TRUE)
tidy_data <- dcast(data_long1, subjectNumber + activity ~ variable, mean )


write.table(tidy_data, file = "./tidy_data.txt", row.names = FALSE)








