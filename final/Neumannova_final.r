##############################################################################
# Final Credit risk analysis
##############################################################################

##############################################################################
# Instructions
##############################################################################
# 1) You should submit the .R script with the solution
# 2) Make sure to comment wherever it is needed
# 3) Every student should submit his\her own copy
# 4) Pay attention to the question (if question asks for regex and you solve it differently - no points are awarded)
# 5) You cannot use attach(dataframe)

##############################################################################
# Part 1: Welcome to Credit Risk Analysis
##############################################################################

# You will be working on bankloans.csv. The data contains the credit details about credit borrowers: 
# Data Description:
  
# age - Age of Customer
# ed - Eductation level of customer
# employ: Tenure with current employer (in years)
# address: Number of years in same address
# income: Customer Income
# debtinc: Debt to income ratio
# creddebt: Credit to Debt ratio
# othdebt: Other debts
# default: Customer defaulted in the past (1= defaulted, 0=Never defaulted)

# 1) Create a function 'var_summary' that has column (or vector) as an input and returns you a table with 
#     number of observations, number of missing values, sum of all values, mean, standard deviation,
#     variance, minimum, 0.01, 0.05, 0.10, 0.25, 0.5, 0.75, 0.90, 0.95 and 0.99 quantiles and maximum
#     i.e. extended descriptive statistics

library(dplyr)
library(grid)
library(ggplot2)
bankloans <- read.csv("bankloans.csv")

var_summary = function(vect){
  
  number_obs = length(vect)
  number_miss = sum(is.na(vect))
  sum = sum(vect,na.rm = TRUE)
  mean = mean(vect, na.rm = TRUE)
  sd = sd(vect,na.rm = TRUE)
  var = sd^2
  min = min(vect,na.rm = TRUE)
  quantile_0.01 = quantile(vect,na.rm = TRUE,0.01)
  quantile_0.05 = quantile(vect,na.rm = TRUE,0.05)
  quantile_0.1 = quantile(vect,na.rm = TRUE,0.1)
  quantile_0.25 = quantile(vect,na.rm = TRUE,0.25)
  quantile_0.5 = quantile(vect,na.rm = TRUE,0.5)
  quantile_0.75 = quantile(vect,na.rm = TRUE,0.75)
  quantile_0.9 = quantile(vect,na.rm = TRUE,0.9)
  quantile_0.95 = quantile(vect,na.rm = TRUE,0.95)
  quantile_0.99 = quantile(vect,na.rm = TRUE,0.99)
  max = max(vect,na.rm=TRUE)
  return(c(observations = number_obs, missing_values = number_miss, sum = sum, mean = mean, sd = sd, var = var, min = min,
           quantile_0.01,quantile_0.05,quantile_0.1, 
           quantile_0.25, quantile_0.5, quantile_0.75,
           quantile_0.9, quantile_0.95, quantile_0.99, max = max))
}


# 2) Create a function 'create_dummies' that has two inputs - a dataframe and column_name
#   The function has to create dummy variables for categorical data stored in column_name, i.e.
#   suppose you have a single column  c('a','b','c','a') the return of the function has to produce 4x3 matrix with
#   a b c
#   1 0 0
#   0 1 0
#   0 0 1
#   1 0 0
#   The output of the function should be an input dataframe with dummies matrix added as new columns


create_dummies = function(dataframe, column_name){
  tmp = dataframe[,column_name]
  dim = length(unique(tmp))
  name = unique(tmp)
  x= matrix(0,nrow = dim(dataframe)[1] , ncol = dim )
  
  
  for (j in 1:ncol(x)) {
    for (i in 1:nrow(x)) {
      if(tmp[i]==name[j]){
        x[i,j]=1
      }
    }
  }
  colnames(x) = name
  data_final = dataframe %>% select(-column_name)
  data_final = data.frame(cbind(data_final,x))
  return(data_final)
}

# 3) Create a function 'outlier_capping' that would have vector or column as inputs. The function then 
#    replaces all right tail outliers (very huge numbers) with 0.99 quantile and all 
#    left tail outliers (big negative numbers) with 0.01 quantile of the column.
#    The function should output the same column\vector with processed outliers

outlier_capping = function(vector){
  quantile_0.01 = quantile(vector,0.01)
  quantile_0.99 = quantile(vector, 0.99)
  vector[which(vector<quantile_0.01)] = quantile_0.01
  vector[which(vector>quantile_0.99)] = quantile_0.99
  return(vector)
}

# 4) Create a function 'process_missing' that would have a column\vector as an input. The function then
#    replaces all missing values with the mean and returns the processed column\vector of data.

process_missing = function(vect1){
  xxx = vect1
  xxx[which(is.na(xxx))]=mean(xxx,na.rm = TRUE)
  return(xxx)
}

# 5) Apply the 'var_summary' function to each column of the data. (Use purrr maps or lapply or sapply - whichever you prefer). Any missing data?

loans_data = apply(bankloans, 2, var_summary)
loans_data

## only default has missing values (150)

# 6) If everything is done correctly, there should be 150 NA's in 'default' column. Separate the dataframe into two
#    bankloans_existing and bankloans_new based on whether default value is present or missing

bankloans_existing = bankloans[which(is.na(bankloans$default) == FALSE) ,]
bankloans_new = bankloans[which(is.na(bankloans$default) == TRUE) ,]

bankloans_existing
bankloans_new

# 7) Apply outlier_capping and process_missing on every column of bankloans_existing

result1 = data.frame(apply(bankloans_existing,2,outlier_capping))
result2 = data.frame(apply(result1,2 ,process_missing ))
bankloans_existing = result2

# 8) Calculate the correlation matrix with correlations represented by color (google heatmap, there is really simple solution using on
#    of the packages mentioned in the course)
heatmap(as.matrix(bankloans_existing))

# 9) Create a 2x4 matrix of boxplots where x = default, y is all other columns (all 8 plots should be on one picture)


# "age"      "ed"       "employ"   "address"  "income"   "debtinc"  "creddebt" "othdebt"  "default" 

graph1 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=age ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())

graph2 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=ed ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())

graph3 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=employ ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())

graph4 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=address ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())

graph5 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=income ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())

graph6 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=debtinc ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())

graph7 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=creddebt ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())

graph8 = ggplot(bankloans_existing)+geom_boxplot(aes(x=as.factor(default) , y=othdebt ,col = as.factor(default)))+
  theme(legend.position = "none",
        axis.title.x = element_blank())


grid.newpage()
vplayout = function(x,y)
  viewport(layout.pos.row = x, layout.pos.col = y)
pushViewport(viewport(layout = grid.layout(2,4)))
print(graph1, vp = vplayout(1, 1))
print(graph2, vp = vplayout(1, 2))
print(graph3, vp = vplayout(1, 3))
print(graph4, vp = vplayout(1, 4))
print(graph5, vp = vplayout(2, 1))
print(graph6, vp = vplayout(2, 2))
print(graph7, vp = vplayout(2, 3))
print(graph8, vp = vplayout(2, 4))

# 10) Create histogram of employ for those who defaulted (default = 1) and not (default  = 0) on the same graph (use color to distinguish 
#     defaulted and nondefaulted). Make histogram a bit transparent by setting alpha to 0.5 (hope you remember how to do it)

ggplot(data = bankloans_existing)+geom_histogram(aes(employ, fill  = as.factor(default)), binwidth = 0.5)

##############################################################################
# Part 2: ITS LOGIT TIME
##############################################################################

# 1) Estimate a logistic regression (google glm) of default on all other variables (use bankloans_existing data).
#    To do that you need to run the following commands
#     For references on the model please visit https://towardsdatascience.com/introduction-to-logistic-regression-66248243c148
#     Effectively, the fitted values are the estimated probabilities given person defaults or not, i.e. look at the observation
#     age  ed    employ address income    debtinc      creddebt       othdebt     default  model$fitted.values
#     41   3       17    12       176       9.3        11.35939      5.008608       1              0.7344775
#     The person with this properties has defaulted, and our model suggests that for him the probability to default was 73% (last column)

bankloans_existing$default = as.factor(bankloans_existing$default)

model = glm(default ~ . , data = bankloans_existing, family="binomial")
summary(model)

# 2) Create a confusion matrix for threshold 0.5, by running the following line.
#    For more info on confusion matrix https://towardsdatascience.com/taking-the-confusion-out-of-confusion-matrices-c1ce054b3d3e
#    Note, confusion matrixes are 2x2 matrices with elements
#    True positive (TP) | False Positive (FP)
#    False negative (FN)| True  Negative (TN)
fitted = model$fitted.values
fitted = ifelse(fitted>0.5,1,0)
tmp = data.frame(fitted , real = bankloans_existing$default)

# first row of the confusion matrix
positive = dim(tmp[which(tmp$real==1),])[1]
tp = dim(tmp[which(tmp$real==1 & tmp$fitted==1),])[1]
fp = dim(tmp[which(tmp$real==0 & tmp$fitted==1),])[1]

# second row of the confusion matrix
negative = dim(tmp[which(tmp$real==0),])[1]
fn = dim(tmp[which(tmp$real==1 & tmp$fitted==0),])[1]
tn =dim(tmp[which(tmp$real==0 & tmp$fitted==0),])[1] 

first = c(True_positive = tp,False_positive=fp)/positive
second = c(False_negative=fn,True_negative=tn)/negative

## confusion matrix is :
first
second
table(bankloans_existing$default, model$fitted.values  > 0.5)

# 3) Accuracy is one of the way it is calculating using the formula
#    accuracy =  (TP+TN)/(TP+TN+FP+FN)
#    it is effectively a fraction of all correctly specified 
#    Create a function that has inputs  default_column  and the predicted default probabilities (they have to have the same lenght!)
#    The function has to estimate accuracy for a grid of thresholds starting from 0.05 to 0.95 with increment 0.05, i.e.
#    0.05, 0.10, 0.15, ...., 0.85, 0.90, 0.95
#    The function should output the optimal threshold value, i.e. value for the threshold for which accuracy is maximized!
best_threshold = function(default_col, pred_col){
  threshold = seq(0.05,0.95,0.05)
  acc = numeric(length(threshold))
  for (i in 1:length(threshold)) {
    fitted = ifelse(pred_col>threshold[i],1,0)
    tmp = data.frame(fitted, real = default_col)
    tp = dim(tmp[which(tmp$real==1 & tmp$fitted==1),])[1]
    fp = dim(tmp[which(tmp$real==0 & tmp$fitted==1),])[1]
    fn = dim(tmp[which(tmp$real==1 & tmp$fitted==0),])[1]
    tn =dim(tmp[which(tmp$real==0 & tmp$fitted==0),])[1] 
    acc[i] = (tp+tn)/(tp+tn+fp+fn)
  }
  return(threshold[which.max(acc)])
  
}

best_threshold(bankloans_existing$default, model$fitted.values) 


# 4) Another (and even more popular choice) is Specifity - Sesitivity score. Optimal threshold is chosen as one for which
#    the two the absolute difference abs(Specifity - Sensitivity) is closest to zero
#    Specifity  = TN/(TN+FP)
#    Sensitivity  = TP/(TP+FN)
#    Create a function that would calculate Specifity and Sensitivity for a the same grid as in part 3. The function should output
#    the threshold value for which the absolute difference is minimized

best_threshold2  = function(default_col, pred_col){
  threshold = seq(0.05,0.95,0.05)
  specifity = numeric(length(threshold))
  sensitivity = numeric(length(threshold))
  abs_dif = numeric(length(threshold))
  for (i in 1:length(threshold)) {
    fitted = ifelse(pred_col>threshold[i],1,0)
    tmp = data.frame(fitted, real = default_col)
    tp = dim(tmp[which(tmp$real==1 & tmp$fitted==1),])[1]
    fp = dim(tmp[which(tmp$real==0 & tmp$fitted==1),])[1]
    fn = dim(tmp[which(tmp$real==1 & tmp$fitted==0),])[1]
    tn =dim(tmp[which(tmp$real==0 & tmp$fitted==0),])[1] 
    specifity[i] = (tn)/(tn+fp)
    sensitivity[i] = tp/(tp+fn)
    abs_dif[i] = abs(specifity[i]-sensitivity[i])
  }
  return(threshold[which.min(abs_dif)])
}

best_threshold2(bankloans_existing$default, model$fitted.values)

# 5) Are the estimated thresholds different between the two models?

fitted_missing = predict(model, bankloans_new[,1:8], type = "response")
fitted_missing = ifelse(fitted_missing>0.4,1,0)
table(fitted_missing)

# 6) Predict the default probabilities for the bankloans_missing ( model.predict). Obtain the probabilities of default. 
#    Convert them to booleans (1 or 0) based on either threshold estimated above. 

fitted_miss = predict(model, bankloans_new[,1:8], type = "response")
fitted_miss = ifelse(fitted_miss>0.4,1,0)
table(fitted_miss)

# 7) Compute summary statistics for the obtained predictions and for the defaults column of bankloans_existing. Compute the fractions of
#    defaults (you may use one of the functions you programmed before). Do the results differ a lot?

var_summary(fitted_miss)
var_summary(bankloans_existing$default)

# 8) Replace NA's in default columns of bankloans_missing with the predicted values. Append bankloans_missing with bankloans_existing
bankloans_new$default = fitted_miss

# 9) Save data as bankloans.xlsx with 3 sheets, on the first sheet there should be a dataframe you obtained in part 8 above, sheet 2 
#    must contain bankloans_existing dataframe, and sheet 3 must contain the transposed version of bankloans_missing dataframe

data = data.frame(rbind(bankloans_existing,bankloans_new))

write.csv(bankloans_existing,"bankloans_existing.csv")
write.csv(bankloans_new,"bankloans_new.csv")
write.csv(data,"bankloans.csv")

#    accuracy =  (TP+TN)/(TP+TN+FP+FN)
#    it is effectively a fraction of all correctly specified 
#    Create a function that has inputs  default_column  and the predicted default probabilities (they have to have the same lenght!)
#    The function has to estimate accuracy for a grid of thresholds starting from 0.05 to 0.95 with increment 0.05, i.e.
#    0.05, 0.10, 0.15, ...., 0.85, 0.90, 0.95
#    The function should output the optimal threshold value, i.e. value for the threshold for which accuracy is maximized!

best_threshold = function(default_col, pred_col){
  threshold = seq(0.05,0.95,0.05)
  acc = numeric(length(threshold))
  for (i in 1:length(threshold)) {
    fitted = ifelse(pred_col>threshold[i],1,0)
    tmp = data.frame(fitted, real = default_col)
    tp = dim(tmp[which(tmp$real==1 & tmp$fitted==1),])[1]
    fp = dim(tmp[which(tmp$real==0 & tmp$fitted==1),])[1]
    fn = dim(tmp[which(tmp$real==1 & tmp$fitted==0),])[1]
    tn =dim(tmp[which(tmp$real==0 & tmp$fitted==0),])[1] 
    acc[i] = (tp+tn)/(tp+tn+fp+fn)
  }
  return(threshold[which.max(acc)])
  
}

best_threshold(bankloans_existing$default, model$fitted.values) 

