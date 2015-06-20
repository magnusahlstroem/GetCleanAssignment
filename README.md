# GetCleanAssignment

---
title: "README.md"
author: "Magnus Ahlstr?m"
date: "Friday, June 19, 2015"
output: html_document
---

## I start by loading the packages needed to run this script and download the appropriate datafiles to the directory i will be working in
```{r}
library(dplyr)
library(tidyr)

setwd("C:/Users/mras0142/Desktop/Dokumenter/Kurser/GetCleanData")

if (!file.exists("Datasets/Course_project_data.zip")) {
url<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url=url, destfile="Datasets/Course_project_data.zip", method="libcurl")
unzip(zipfile = "Datasets/Course_project_data.zip", exdir="Datasets")
}
```

## Then I define my main working directory and load the labeling information
```{r}
main.dir<-"C:/Users/mras0142/Desktop/Dokumenter/Kurser/GetCleanData/Datasets/UCI HAR Dataset"

setwd(main.dir)
activity_labels<-read.table("activity_labels.txt", col.names=c("activity_no", "activity_name"))
features<-read.table("features.txt", col.names=c("feature_no", "feature_names"))
```

## I then load the train and test dataset, add the feature vector labels to the dataset, combine the train datasets into one and the test datasets into one and finally combine the test and train dataset. from the y_train and y_test datasets I only include variables that contain mean and std, also excluding meanFreq and gravitymean, since these are not "real" means
```{r}
### Getting datasets from train
setwd(paste(main.dir, "train", sep="/"))

subject_train<-read.table("subject_train.txt", col.names=c("ID"))
X_train<-read.table("X_train.txt", col.names=features$feature_names)
y_train<-read.table("y_train.txt", col.names=c("activity_no"))

#### Combinign to one train dataset
train<-
    cbind(y_train,subject_train,X_train) %>%
    mutate(Dataset = "Train") %>%
    select(contains("ID"), contains("activity_no"), contains("mean"), 
           contains("std"), -contains("meanFreq"), -contains("gravitymean"))


### Getting datasets from test
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


# 1) Then i merge
train.test<-rbind(train,test)  
```

## Finally i refine the table to the tidy dataset in and write to a file
```{r}
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
```

