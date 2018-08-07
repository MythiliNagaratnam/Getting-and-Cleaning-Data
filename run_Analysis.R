# Script: run_Analysis.R

# Check if subdirectory data exists for storing the file to be downloaded. 
# Create the directory data if it does not exist
if(!file.exists("./data"))
{
dir.create("./data")
}

# Store the link of the Url
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download file with mode as Web in subdirectory data
download.file(fileUrl,destfile="./data/Dataset.zip",mode="wb")

# Unzip the downloaded zip 
unzip(zipfile="./data/Dataset.zip",exdir="./data")

# Store the contents of subdirectories in the UCI HAR Dataset
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

# Read test and train data sets for Activity 
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

# Read test and train data sets for Subject
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

# Read test and train data sets for Features 
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

# Use rbind for appending rows of Test to Train for Activity
dataActivity<- rbind(dataActivityTrain, dataActivityTest)

# Use rbind for appending rows of Test to Train for Subjects
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)

# Use rbind for appending rows of Test to Train for Features
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

# Assign header to the Activity combined data set
names(dataActivity)<- c("activity")

# Assign header to the Subject combined data set
names(dataSubject)<-c("subject")

# Read file features.txt to transpose to headers for the Features data set
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

# Column bind all the three data sets - Acitivity, Subject and Features to a single Data
dataCombine <- cbind(dataActivity, dataSubject)
Data <- cbind(dataFeatures, dataCombine)

# Select only those features with keywords mean or (using |) std by embedding escape characters \\ before special characters
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

# Create subset of Data with only selected features, subject, activity
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

# Read the file activity labels to get the detailed activity
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)

# Expand to full names for representation
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

install.packages("plyr")
library(plyr)

# Mean of each subject and activity is computed for each pair and then ordered by subject followed by activity
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]

# Output is written to a file that provides a cleaner output
write.table(Data2, file = "tidydata.txt",row.name=FALSE)


