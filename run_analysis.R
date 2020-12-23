#download, read and convert data

library(data.table)
fileurl = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(fileurl,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}

features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

datatrain.x <- read.table('./UCI HAR Dataset/train/X_train.txt')
datatrain.activity <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
datatrain.subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

datatrain <-  data.frame(datatrain.subject, datatrain.activity, datatrain.x)
names(datatrain) <- c(c('subject', 'activity'), features)

datatest.x <- read.table('./UCI HAR Dataset/test/X_test.txt')
datatest.activity <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
datatest.subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

datatest <-  data.frame(datatest.subject, datatest.activity, datatest.x)
names(datatest) <- c(c('subject', 'activity'), features)


#1.
data.all <- rbind(datatrain, datatest)


#2.
mean_std.select <- grep('mean|std', features)
datasub <- data.all[,c(1,2,mean_std.select + 2)]

#3.
activity.labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)
activity.labels <- as.character(activity.labels[,2])
datasub$activity <- activity.labels[datasub$activity]

#4.
newnames <- names(datasub)
newnames <- gsub("[(][)]", "", newnames)
newnames <- gsub("^t", "TimeDomain_", newnames)
newnames <- gsub("^f", "FrequencyDomain_", newnames)
newnames <- gsub("Acc", "Accelerometer", newnames)
newnames <- gsub("Gyro", "Gyroscope", newnames)
newnames <- gsub("Mag", "Magnitude", newnames)
newnames <- gsub("-mean-", "_Mean_", newnames)
newnames <- gsub("-std-", "_StandardDeviation_", newnames)
newnames <- gsub("-", "_", newnames)
names(datasub) <- newnames

#5.
data.tidy <- aggregate(datasub[,3:81], by = list(activity = datasub$activity, subject = datasub$subject),FUN = mean)
write.table(x = data.tidy, file = "data_tidy.txt", row.names = FALSE)

