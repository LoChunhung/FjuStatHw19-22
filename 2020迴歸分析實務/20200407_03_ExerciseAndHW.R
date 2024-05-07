#feature 1. 最高日溫平均
#feature 2. 最低日溫平均
#feature 3. 風速
#feature 4. 雲層
#feature 5. 用電量
#Y is 日用電量
#在簡單回歸模型，最適合的X是?

#Exercise in our class.
data1<-read.table("http://letitbe.ncue.edu.tw/ibl/data/8_21.txt",head=F, sep="")
colnames(data1)<-c('Tmax','Tmin','Wndspd', 'Cldcvr', 'Kwh')
dim(data1) #Check out- Dimension of dataset.
summary(data1) # Check out- discriptive stats of dataset.
pairs(data1)   #散佈圖視覺化判斷(Tmin,Kwh) (TMax, Kwh)皆有線性相關
cor(data1)     #相關係數矩陣可得知Tmin與Kwh有最強的正相關

lm(Kwh~ Tmin, data = data1)
DElecUseModel <- lm(Kwh ~ Tmin, data = data1)
summary(DElecUseModel) 

# DElecUseModel2 <- lm(Kwh ~ Tmax, data = data1)
# summary(DElecUseModel2)

#Homework
#Let Tmin convert to centidegree. formula is (Tmin-32) * 5/9

#1. b0,b1 changed?
#2. coefficent value chaged?
#3. R squre changed?
#4. To prove them in math.
data2 <- data1[,c("Tmin","Kwh")]
data2["TminC"] <- (data2["Tmin"]-32)*5/9
summary(data2)
cor(data2)
DElecUseModel3 <- lm(Kwh ~ TminC, data = data2)
summary(DElecUseModel3) 

