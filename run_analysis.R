# Downloading and unzipping dataset for project


# Create project directory if there isn’t already one
if(!file.exists("Week4Project")){
  dir.create("Week4Project")
}

# Data for project:
URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Download project data from URL
if(!file.exists("Week4Project/project_Dataset.zip")){
  download.file(URL,destfile="Week4Project/project_Dataset.zip", mode = "wb")
}

# Unzip data file and save to directorty
if(!file.exists("Week4Project/UCI HAR Dataset")){
  unzip(zipfile="Week4Project/project_Dataset.zip",exdir="Week4Project")
}

#List all the files
path <- file.path("Week4Project" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

#Read the text files

# Reading TRAINING tables
set_train <- read.table(file.path(path, "train", "X_train.txt"), header = FALSE)
label_train <- read.table(file.path(path, "train", "y_train.txt"), header = FALSE)
subject_train <- read.table(file.path(path, "train", "subject_train.txt"), header = FALSE)


# Reading TESTING tables
set_test  <- read.table(file.path(path, "test" , "X_test.txt" ), header = FALSE)
label_test  <- read.table(file.path(path, "test" , "y_test.txt" ), header = FALSE)
subject_test  <- read.table(file.path(path, "test" , "subject_test.txt"), header = FALSE)


# Merging all data together in one:

# Generating rows
r_subject <- rbind(subject_train, subject_test)
r_label<- rbind(label_train, label_test)
rSet<- rbind(set_train, set_test)


# Variable Names
names(r_subject)<-c("subject")
names(r_label)<- c("activity")
rSetNames <- read.table(file.path(path, "features.txt"), head=FALSE)
names(rSet)<- rSetNames$V2


# Merge Columns
data_combine <- cbind(r_subject, r_label)
merge <- cbind(rSet, data_combine)


# Mean and Standard Deviation
subrSetNames<-rSetNames$V2[grep("mean\\(\\)|std\\(\\)", rSetNames$V2)]
selectedNames<-c(as.character(subrSetNames), "subject", "activity" )
merge<-subset(merge,select=selectedNames)


# Read in the Activity Labels document
activityLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
merge$activity<-factor(merge$activity,labels=activityLabels[,2])


# Labeling the Merged Dataset
names(merge)<-gsub("^t", "time", names(merge))
names(merge)<-gsub("^f", "frequency", names(merge))
names(merge)<-gsub("Gyro", "Gyroscope", names(merge))
names(merge)<-gsub("Acc", "Accelerometer", names(merge))
names(merge)<-gsub("Mag", "Magnitude", names(merge))


# Write new tidy file into new text file
Tidy_Data<-aggregate(. ~subject + activity, merge, mean)
Tidy_Data<-Tidy_Data[order(Tidy_Data$subject,Tidy_Data$activity),]
write.table(Tidy_Data, file = "tidy_data.txt",row.name=FALSE,quote = FALSE, sep = '\t')
