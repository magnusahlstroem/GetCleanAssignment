# loading packages for the current script
library(dplyr)
library(tidyr)

# Setting the working directory
setwd("C:/Users/mras0142/Desktop/Dokumenter/Kurser/GetCleanData")

# Downloading datasets
if (!file.exists("Datasets/Course_project_data.zip")) {
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url=url, destfile="Datasets/Course_project_data.zip", method="libcurl")
unzip(zipfile = "Datasets/Course_project_data.zip", exdir="Datasets")
}

# Defining my main working directory
main.dir<-"C:/Users/mras0142/Desktop/Dokumenter/Kurser/GetCleanData/Datasets/UCI HAR Dataset"

# Loading labeling information
setwd(main.dir)
activity_labels<-read.table("activity_labels.txt", col.names=c("activity_no", "activity_name"))
features<-read.table("features.txt", col.names=c("feature_no", "feature_names"))

## Getting datasets from train
setwd(paste(main.dir, "train", sep="/"))

subject_train<-read.table("subject_train.txt", col.names=c("ID"))
X_train<-read.table("X_train.txt", col.names=features$feature_names)
y_train<-read.table("y_train.txt", col.names=c("activity_no"))

### Combinign to one train dataset
train<-
    cbind(y_train,subject_train,X_train) %>%
    mutate(Dataset = "Train") %>%
    select(contains("ID"), contains("activity_no"), contains("mean"), 
           contains("std"), -contains("meanFreq"), -contains("gravitymean"))


## Getting datasets from test
setwd(paste(main.dir, "test", sep="/"))

subject_test<-read.table("subject_test.txt", col.names=c("ID"))
## 4) Including approiate variable names
X_test<-read.table("X_test.txt", col.names=features$feature_names)
y_test<-read.table("y_test.txt", col.names=c("activity_no"))

### Combinign to one test dataset
test<-cbind(y_test,subject_test,X_test) %>%
    mutate(Dataset = "test") %>%
    select(contains("ID"), contains("activity_no"), contains("mean"), 
           contains("std"), -contains("meanFreq"), -contains("gravitymean"))

# 1) Merging the the to datasets
train.test<-rbind(train,test)  

average.table = 
    ## Adding appriate activity labels
    merge(train.test,
          activity_labels,
          by="activity_no") %>%
    arrange(ID, activity_name) %>%
    select(-activity_no) %>%
    group_by(ID, activity_name) %>%
    #group_by(ID, activity_name) %>%
    gather(variables, values, tBodyAcc.mean...X:fBodyBodyGyroJerkMag.std..) %>%
    group_by(ID, activity_name, variables) %>%
    summarize(mean.value = mean(values)) %>%
    rename (activity = activity_name)

## Saving the dataset in my datasets directory
setwd(main.dir)
setwd("../")
write.table(average.table, file="average.table.txt", row.name=FALSE)