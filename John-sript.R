#######################MULTIPLE LINEAR REGRESSION########################
rm(list = ls())
library(tidyverse)
library(learnr)
library(dplyr)
library(readxl)
library(readr)
library(ggpubr)
library(ggplot2)
library(Hmisc)
library(gmodels)
library(olsrr)
library(car)### VIF Calculation
library(lmtest)####### Breusch-Pagan test
library(modelr)
library(fmsb) ######compute rsquare()
#library(Metrics)###Compute MSE#####
library(caret)###Check the accuracy
library(e1071)
library(conflicted)
conflict_prefer("filter", "dplyr","stats")
conflict_prefer("lag", "dplyr", "stats")
conflicts_prefer(modelr::mse)
#setwd("~/My topic/My topic/DATA/VALID DATA/Data_final")
LoR<-read.csv("Average_Northern.csv", header = TRUE, sep = ",")
LoR<-na.omit(LoR)
LoR$Year<-as.numeric(LoR$Year)
LoR$Month<-as.numeric(LoR$Month)
str(LoR)
attach(LoR)
LoR1<-LoR[,1:11]
Train_data<-LoR1[1:90,]
Test_data<-LoR1[1:90,]
head(LoR1)

str(LoR1)

smv_Model<-svm(formula=Malaria_incidence~Prec_Average+Average_Temperature_Max + Average_RH_Max ,data=Train_data
               ,
               kernel="radial",
               type="eps-regression")
summary(smv_Model)
shapiro.test(smv_Model$residuals)
pre<- predict(smv_Model,Test_data)
mean((Test_data$Malaria_incidence - pre)^2) #mse - Mean Squared Error
caret::RMSE(Test_data$Malaria_incidence, pre) #rmse - Root Mean Squared Error
Test_data["Predicted"]<-pre
write.csv(Test_data,file = "Predicted_MIROC5_RCP8.5.csv")
View(Test_data)
ggplot(data = Test_data,aes(x=Month))+
  geom_line(aes(y=Malaria_incidence),color="Blue")+
 geom_point(aes(y=Malaria_incidence),color="blue")+
  geom_line(aes(y=Predicted),,color="red")+ggtitle("Atacora")+
 geom_point(aes(y=Predicted),,color="red")+ggtitle("SVM_Model")+
labs(x="Months",y="Malaria Prevalence(%)")+scale_x_continuous(limits = c(1,100),
                                                                breaks = scales::breaks_width(5))+theme_classic(base_family = "serif")
scale_color_manual(c("Malaria_Incidence"="blue","Predicted"="red"))

#### Check the accuracy of the model#######
pred <-predict(smv_Model,Test_data)
Test_data["Predicted"]<-pred
mse <- mean((Test_data$Malaria_incidence - Test_data$Predicted)^2) #mse(Test_data$Malaria_incidence, Test_data$Predicted)
mae<-MAE(Test_data$Malaria_incidence, Test_data$Predicted)
rmse<- RMSE(Test_data$Malaria_incidence, Test_data$Predicted)
y_mean <- mean(Test_data$Malaria_incidence)
ss_total <- sum((Test_data$Malaria_incidence - y_mean)^2)
ss_resid <- sum((Test_data$Malaria_incidence - pre)^2)
r2 <- 1 - ss_resid/ss_total

cat(" MAE:", mae, "\n", "MSE:", mse, "\n",
    "RMSE:", rmse, "\n", "R-squared:", r2)
Prec_Average <- as.numeric(readline("Veuillez saisir la valeur de Prec_Average : "))
Average_Temperature_Max <- as.numeric(readline("Veuillez saisir la valeur de Average_Temperature_Max : "))
Average_RH_Max <- as.numeric(readline("Veuillez saisir la valeur de Average_RH_Max : "))

# Créer un data frame avec les valeurs saisies par l'utilisateur
input_data <- data.frame(Prec_Average = Prec_Average,
                         Average_Temperature_Max = Average_Temperature_Max,
                         Average_RH_Max = Average_RH_Max)
# Fonction pour effectuer les prédictions
predict_iris <- function(input_data) {
  predictions <- predict(smv_Model, input_data)
  return(predictions)
}
prediction=predict_iris(input_data)
cat(prediction)


