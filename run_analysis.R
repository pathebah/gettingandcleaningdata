#Create variable to hold the path to the different datasets

  library(dplyr)
  library(RCurl)
  library(bitops)
  
  #download dataset
if(!dir.exists("./UCI_HAR_Dataset"))
  {
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    dir.create("./UCI HAR Dataset")
    download.file(fileUrl, "experiment_data.zip")
    unzip("./experiment_data.zip")
}

  #features dataset path
  feat_url <- "UCI_HAR_Dataset/features.txt"
  act_labels_url <- "UCI_HAR_Dataset/activity_labels.txt"

#Read the training datasets into R
X_train <- read.table("UCI_HAR_Dataset/train/X_train.txt")
subj_train <- read.table("UCI_HAR_Dataset/train/subject_train.txt")
y_train <- read.table("UCI_HAR_Dataset/train/y_train.txt")

#Read the test datasets into R
X_test <- read.table("UCI_HAR_Dataset/test/X_test.txt")
subj_test <- read.table("UCI_HAR_Dataset/test/subject_test.txt")
y_test <- read.table("UCI_HAR_Dataset/test/y_test.txt") 

#Read the features and activity labels dataset into R
features <- read.table("UCI_HAR_Dataset/features.txt")
colnames(features) <- c("featureCode","featureName")
activity_labels <- read.table("UCI_HAR_Dataset/activity_labels.txt")
colnames(activity_labels) <- c("activityCode","activityName")

#combine the datasets
xComb <- rbind(X_train,X_test)
yComb <- rbind(y_train,y_test)
subj <- rbind(subj_train,subj_test)
comb_dataset <- cbind(subj,yComb,xComb)

#Add column names to the combined dataset
dataNames <- make.names(features$featureName,unique = TRUE)
colnames(comb_dataset) <- c("subjectNum","activityCode",dataNames)

#add activity names
comb_dataset <- inner_join(comb_dataset,activity_labels,by = "activityCode")

#Extract columns with meand and std
cols <- grep("*std*|*mean*", names(comb_dataset), value = TRUE)

#give meaningful variable names
names(comb_dataset) <- gsub("^t", "Time", names(comb_dataset))
names(comb_dataset) <- gsub("^f", "Frequency", names(comb_dataset))
names(comb_dataset) <- gsub("Acc", "Accelerometer", names(comb_dataset))
names(comb_dataset) <- gsub("Gyro", "Gyroscope", names(comb_dataset))
names(comb_dataset) <- gsub("Mag", "Magnitude", names(comb_dataset))

#summarize the data by activity type and subject
meanDataset <- comb_dataset %>% group_by(activityName,subjectNum) %>% summarize_all(funs(mean))
write.table(meanDataset,"UCI_HAR_Dataset/finalData.txt")

