getwd()
setwd("C:/Users/Chunhung.Lo/Documents/Projects/FJCU2020_RegressionAnalysis")
# Section Tidy Data -Start
#install.packages("readxl") # 安裝並載入可直接讀取excel的package
library("readxl")
UniStudent <- read_excel("108_student.xls",skip = 2)
class(UniStudent) # 確認是否為特殊物件
dfStud <- data.frame(UniStudent) # 調整為dataframe資料類型
class(dfStud)
rm(UniStudent) #刪除舊有資料集
## Q2-1
dfSD2_0 <- dfStud[(dfStud$"日間.進修別" == 'D 日' & dfStud$"體系別" == "1 一般"),c(1:5)]
dfSD2_0["公私立"] = "私立"
dfSD2_0[grepl(c("國立"),dfSD2_0$"學校名稱"), "公私立"] <- "公立"
dfSD2_0[grepl(c("市立"),dfSD2_0$"學校名稱"), "公私立"] <- "公立"
colnames(dfSD2_0)<-c("SchNo","SchName","DN","Degree","SSum","SchSYS")
#fillist <- list("SchNo" = dfSD2_0$SchNo,"SchName" = dfSD2_0$SchName,"SchSYS"= dfSD2_0$SchSYS)
dfSD2_1<- aggregate(SSum ~ SchSYS+SchName+SchNo,data =dfSD2_0,sum)

#Data source 2- 取出資料來源 108_teacher.xls中的學校代碼與專任教師合計人數總計
dfTRaw <- read_excel("108_teacher.xls",skip = 5, col_names = FALSE)
dfTeacher <- dfTRaw[ (dfTRaw[3] == '日'& dfTRaw[26] == "1 一般"), c(1,4)]
#Updated the name of variables.
colnames(dfTeacher)<-c("SchNo","TSum")
rm(dfTRaw)

#Merge Data source 1 and 2 by SchNo(學校代號)
dfStAndT<-merge.data.frame(dfSD2_1,dfTeacher, by = intersect(names(dfSD2_1),names(dfTeacher)))
# 全國日間部學生/專任教師
plot(dfStAndT$SSum,dfStAndT$TSum)
cor.test(dfStAndT$SSum,dfStAndT$TSum) # Pearson's corr is 0.8673092
cor.test(dfStAndT$SSum,dfStAndT$TSum, method = "spearman") #Spearman's rho 0.9048077 
#公私立系統比較
cor.test(dfStAndT[dfStAndT$SchSYS == "公立", "SSum"],dfStAndT[dfStAndT$SchSYS == "公立", "TSum"])
plot(dfStAndT[dfStAndT$SchSYS == "公立", "SSum"],dfStAndT[dfStAndT$SchSYS == "公立", "TSum"])
cor.test(dfStAndT[dfStAndT$SchSYS == "私立", "SSum"],dfStAndT[dfStAndT$SchSYS == "私立", "TSum"])
plot(dfStAndT[dfStAndT$SchSYS == "私立", "SSum"],dfStAndT[dfStAndT$SchSYS == "私立", "TSum"])
#########
## Q2-2 #
#########

lm(formula= SSum~ TSum, dfStAndT)
SimpleSTModel<-lm(formula= SSum~ TSum, dfStAndT)
summary(SimpleSTModel)
plot(SSum~ TSum, dfStAndT)
abline(coef(SimpleSTModel))
#########
## Q2-3 #
#########
PublicSModel <-lm(formula= SSum~ TSum, dfStAndT[dfStAndT$SchSYS == "公立",])
summary(PublicSModel)
PrivateSModle <- lm(formula= SSum~ TSum, dfStAndT[dfStAndT$SchSYS == "私立",])
summary(PrivateSModle)
#########
## Q2-4 #
#########
#2020/05/06 AM03:40 updated- done.
library(data.table)
#install.packages("mltools")
library(mltools)
#Make virtual variable- one hot encode.
dt<-data.table(SchNo= dfStAndT$SchNo,SchSYS= as.factor(dfStAndT$SchSYS))
dfsplitM<- as.data.frame(one_hot(dt))
#baseline- 公立大學
NewPbSModel<-lm(formula= SSum~ TSum+SchSYS_公立,merge.data.frame(dfStAndT,dfsplitM, 
                 by= intersect(names(dfStAndT),names(dfsplitM)))[,c(1,4:6)]
)               
summary(NewPbSModel)
#baseline- 私立大學
NewPrSModel<-lm(formula= SSum~ TSum+SchSYS_私立,merge.data.frame(dfStAndT,dfsplitM, 
                                                             by= intersect(names(dfStAndT),names(dfsplitM)))[,c(1,4:5,7)]
)               
summary(NewPrSModel)


#########
## Q2-5 #
#########
# Data Tidy- Staff
dfStaff <- read_excel("108_staff.xls",skip = 2)
dfStaff <-dfStaff[dfStaff$"體系別" == "1 一般",c(1,3)]
colnames(dfStaff)<-c("SchNo","StfSum")
# Data Tidy- Books
dfBooks <- read_excel("108_library.xls", sheet = "校別資料",skip = 10,col_names = TRUE)
dfBooks <-dfBooks[c(1,4,14)]
dfBooks[4]<-dfBooks[2]+dfBooks[3]
dfBooks <- dfBooks[,c(1,4)]
colnames(dfBooks)<-c("SchNo","BookSum")
# Data Tidy- BuildingAreas
dfLands <-read_excel("108_land.xls",skip = 8)
dfLands <-dfLands[,c(1,4)]
colnames(dfLands)<-c("SchNo","BldAreaSum")

for (i in 1:dim(dfLands)[1]) {
  if (is.na(dfLands[i,"SchNo"])) {
    #print(dfLands[i,"SchNo"])
    dfLands[i,"SchNo"] <- dfLands[i-1,"SchNo"]
  }
  #print(i)
}

#Linear Multi Regression
dfLands_1<- aggregate(BldAreaSum ~ SchNo,data =dfLands,sum)
dfAll<-merge.data.frame(dfStAndT,dfStaff, by = intersect(names(dfStAndT),names(dfStaff)))
dfAll<-merge.data.frame(dfAll,dfBooks, by = intersect(names(dfStAndT),names(dfBooks)))
dfAll<-merge.data.frame(dfAll,dfLands_1, by = intersect(names(dfStAndT),names(dfLands_1)))
MutiRgreModel <-lm(SSum~TSum+StfSum+BookSum+BldAreaSum,data= dfAll)
#標準化比較
dfAllstd <- scale(dfAll[,4:8])
MutiRgreModelstd <-lm(SSum~TSum+StfSum+BookSum+BldAreaSum,data= as.data.frame(dfAllstd) )
summary(MutiRgreModel)
summary(MutiRgreModelstd)

# 誤讀老師題目，需刪除教官後其他人員，後經由教育部資料定義發現誤會
# 保留紀念自己的中文能力拙劣
# dfTeacher <- dfTRaw[ (dfTRaw[3] == '日'& dfTRaw[26] == "1 一般")
#                      ,c(1:4,15:26)]
# dfTeacher["TSumR"]<-dfTeacher["TSum"]- data.frame(rowSums(dfTeacher[,c("M1","F1","M2","F2","M3","F3","M4","F4")], na.rm = FALSE, dims = 1))
# dfLands <-read.csv("108_land.csv",header= FALSE,skip = 8,stringsAsFactors = FALSE,col.names= c(1:12), fileEncoding="UTF8")
# dfLands_1 <- aggregate()



