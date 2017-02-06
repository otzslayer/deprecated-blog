---
title: "House Sales in King County, USA"
author: "Jaeyoon Han"
date: "2017-02-06"
output: html_document
layout: post
image: /assets/article_images/2017-01-20-king-county/title.jpg
categories: machine-learning
---



## House Sales Prediction in King County, USA

#### Introduction

- Kaggle의 오픈 데이터에서 강의용 데이터로 쓸만한 회귀분석용 데이터를 찾던 중 이 데이터를 찾게 되었다. [링크](https://www.kaggle.com/harlfoxem/housesalesprediction)

- 이 데이터셋은 2014년 5월부터 2015년 5월까지 매매된 King County의 집값 데이터를 포함하고 있다.

- 이 데이터를 활용해서 강의에서 전달하고자 하는 바는 **Feature Engineering**과 **Data Exploration**의 힘이다. 정말 간단한 몇 개의 과정을 반복하는 것만으로도 예측 모델의 성능을 어디까지 끌어올릴 수 있는지를 보여주고자 했다.

- 강의를 위해서 준비한 자료를 공유하는 것이기 때문에, 자세한 코멘트는 달지 않았다. 추후 시간을 더 들여서 자세한 설명을 담은 포스트를 작성하고자 한다.

### Tying Shoes


{% highlight r linenos %}
### Load the libraries
library(lubridate)
library(readr)
library(dplyr)
library(ggplot2)
library(GGally)
library(corrplot)
library(ggmap)
{% endhighlight %}


{% highlight r linenos %}
### Load the dataset
House <- read_csv("data/king_county/kc_house_data.csv")
{% endhighlight %}


{% highlight r linenos %}
head(House)
{% endhighlight %}



|id         |date       |   price| bedrooms| bathrooms| sqft_living| sqft_lot| floors| waterfront| view| condition| grade| sqft_above| sqft_basement| yr_built| yr_renovated| zipcode|     lat|     long| sqft_living15| sqft_lot15|
|:----------|:----------|-------:|--------:|---------:|-----------:|--------:|------:|----------:|----:|---------:|-----:|----------:|-------------:|--------:|------------:|-------:|-------:|--------:|-------------:|----------:|
|7129300520 |2014-10-13 |  221900|        3|      1.00|        1180|     5650|      1|          0|    0|         3|     7|       1180|             0|     1955|            0|   98178| 47.5112| -122.257|          1340|       5650|
|6414100192 |2014-12-09 |  538000|        3|      2.25|        2570|     7242|      2|          0|    0|         3|     7|       2170|           400|     1951|         1991|   98125| 47.7210| -122.319|          1690|       7639|
|5631500400 |2015-02-25 |  180000|        2|      1.00|         770|    10000|      1|          0|    0|         3|     6|        770|             0|     1933|            0|   98028| 47.7379| -122.233|          2720|       8062|
|2487200875 |2014-12-09 |  604000|        4|      3.00|        1960|     5000|      1|          0|    0|         5|     7|       1050|           910|     1965|            0|   98136| 47.5208| -122.393|          1360|       5000|
|1954400510 |2015-02-18 |  510000|        3|      2.00|        1680|     8080|      1|          0|    0|         3|     8|       1680|             0|     1987|            0|   98074| 47.6168| -122.045|          1800|       7503|
|7237550310 |2014-05-12 | 1225000|        4|      4.50|        5420|   101930|      1|          0|    0|         3|    11|       3890|          1530|     2001|            0|   98053| 47.6561| -122.005|          4760|     101930|

#### Visualizing (Heat Map)


{% highlight r linenos %}
### Initialize a map for King County
kingCounty <- get_map(location = 'issaquah',
                      zoom = 9,
                      maptype = "roadmap"
)

### Generate a heat map
ggmap(kingCounty) + 
    geom_density2d(data = House, aes(x = long, y = lat), size = .3) + 
    stat_density2d(data = House, aes(x = long, y = lat, fill = ..level.., alpha = ..level..), size = 0.01, bins = 16, geom = "polygon") + 
    scale_fill_gradient(low = "green", high = "red") + 
    scale_alpha(range = c(0.2, 0.4), guide = FALSE)
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-4-1.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" width="1008" style="display: block; margin: auto;" />

- 대부분의 데이터가 시애틀 지역을 기반에 두고 있으며, 외곽의 버클리나 스노퀄미 등의 지역의 데이터도 포함되어 있다.

#### Data Preparation


{% highlight r linenos %}
House %>%
    mutate(
        sale_year = year(date),
        sale_month = month(date)
    ) %>%
    select(-id, -date) -> House
{% endhighlight %}


{% highlight r linenos %}
set.seed(2017)
trainIdx <- sample(1:nrow(House), size = 0.7 * nrow(House))
train <- House[trainIdx, ]
test <- House[-trainIdx, ]
{% endhighlight %}

#### Benchmark


{% highlight r linenos %}
bench_model <- lm(price ~ ., data = train)
summary(bench_model)
{% endhighlight %}



{% highlight text %}

Call:
lm(formula = price ~ ., data = train)

Residuals:
     Min       1Q   Median       3Q      Max 
-1289272   -98433    -9562    76172  4400147 

Coefficients: (1 not defined because of singularities)
                Estimate Std. Error t value Pr(>|t|)    
(Intercept)   -7.428e+07  1.179e+07  -6.301 3.03e-10 ***
bedrooms      -3.369e+04  2.203e+03 -15.296  < 2e-16 ***
bathrooms      4.165e+04  3.863e+03  10.782  < 2e-16 ***
sqft_living    1.444e+02  5.198e+00  27.778  < 2e-16 ***
sqft_lot       1.202e-01  5.446e-02   2.207 0.027360 *  
floors         5.802e+03  4.248e+03   1.366 0.172069    
waterfront     5.701e+05  2.039e+04  27.952  < 2e-16 ***
view           5.602e+04  2.482e+03  22.572  < 2e-16 ***
condition      2.925e+04  2.802e+03  10.439  < 2e-16 ***
grade          9.494e+04  2.551e+03  37.217  < 2e-16 ***
sqft_above     2.731e+01  5.154e+00   5.299 1.18e-07 ***
sqft_basement         NA         NA      NA       NA    
yr_built      -2.489e+03  8.579e+01 -29.018  < 2e-16 ***
yr_renovated   2.151e+01  4.304e+00   4.997 5.89e-07 ***
zipcode       -5.576e+02  3.909e+01 -14.265  < 2e-16 ***
lat            6.133e+05  1.268e+04  48.360  < 2e-16 ***
long          -2.092e+05  1.559e+04 -13.422  < 2e-16 ***
sqft_living15  2.897e+01  4.061e+00   7.134 1.02e-12 ***
sqft_lot15    -2.804e-01  8.390e-02  -3.342 0.000833 ***
sale_year      3.893e+04  5.581e+03   6.976 3.16e-12 ***
sale_month     1.914e+03  8.338e+02   2.296 0.021713 *  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 198800 on 15109 degrees of freedom
Multiple R-squared:  0.7017,	Adjusted R-squared:  0.7013 
F-statistic:  1870 on 19 and 15109 DF,  p-value: < 2.2e-16
{% endhighlight %}



{% highlight r linenos %}
benchmark <- predict(bench_model, test)
benchmark <- ifelse(benchmark < 0, 0, benchmark)
{% endhighlight %}

- 벤치마크 모델의 경우 굉장히 나쁜 성능을 보일 것은 자명하다. 밑의 과정들을 통해서 성능을 개선해보자.


### Data Exploration


{% highlight r linenos %}
### Generate a heat map
ggmap(kingCounty) + 
    geom_point(data = train, aes(x = long, y = lat, color = log(price), alpha = log(price))) + 
    scale_color_gradient(low = "green", high = "red")
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-8-1.png" title="plot of chunk unnamed-chunk-8" alt="plot of chunk unnamed-chunk-8" width="1008" style="display: block; margin: auto;" />

- `price`를 로그화하여 시각화한 결과로, 남부(`lat < 47.5`)보다 북부(`lat >= 47.5`) 쪽의 가격이 더 높음을 알 수 있다.
- 그 중에서도 해변가에 인접한 곳의 가격이 더 높다.

#### Correlation


{% highlight r linenos %}
cor_House <- cor(House[, -1])
corrplot(cor_House, order = "hclust")
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" width="1008" style="display: block; margin: auto;" />

#### Boxplots

###### Grade - Price


{% highlight r linenos %}
train %>%
    mutate(grade = factor(grade)) %>%
    ggplot(aes(x = grade, y = price, fill = grade)) +
    geom_boxplot() + 
    geom_point(
        data = train %>% 
            group_by(grade) %>%
            summarise(median = median(price)) %>%
            mutate(grade = factor(grade)),
        aes(x = grade, y = median, group = 1),
        size = 5, stroke = 2,
        color = "black", fill = "white", shape = 23
    )
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-10-1.png" title="plot of chunk unnamed-chunk-10" alt="plot of chunk unnamed-chunk-10" width="1008" style="display: block; margin: auto;" />

- `grade`가 한 단계 높아질 때마다 가격이 기하급수적으로 증가하는 것으로 보인다. 확인을 위해서 `log(price)`에 대해서 박스플롯을 그려본다.


{% highlight r linenos %}
train %>%
    mutate(grade = factor(grade)) %>%
    ggplot(aes(x = grade, y = log(price), fill = grade)) +
    geom_boxplot() + 
    geom_point(
        data = train %>% 
            group_by(grade) %>%
            summarise(median = median(log(price))) %>%
            mutate(grade = factor(grade)),
        aes(x = grade, y = median, group = 1),
        size = 5, stroke = 2,
        color = "black", fill = "white", shape = 23
    )
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-11-1.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" width="1008" style="display: block; margin: auto;" />

###### Year Build - Price


{% highlight r linenos %}
train %>%
    mutate(yr_cat = cut(yr_built, breaks = seq(1900, 2020, by = 10),
                        labels = paste0(seq(1900, 2010, by = 10), "s"))) %>%
    ggplot(aes(x = yr_cat, y = log(price), fill = yr_cat)) + 
    geom_boxplot()
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-12-1.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" width="1008" style="display: block; margin: auto;" />

- 건물이 지어진 연대와 가격 사이에는 큰 인사이트를 얻기 힘들어 보인다. 

###### Year Renovated - Price


{% highlight r linenos %}
train %>%
    filter(yr_renovated != 0) %>%
    mutate(renovated_cat = cut(yr_renovated, breaks = seq(1930, 2020, by = 10),
                        labels = paste0(seq(1930, 2010, by = 10), "s"))) %>%
    ggplot(aes(x = renovated_cat, y = log(price), fill = renovated_cat)) + 
    geom_boxplot()
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-13-1.png" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" width="1008" style="display: block; margin: auto;" />

- 집을 개조한 경우, 최근에 개조할 수록 가격이 조금이라도 증가하는 경향을 보인다.

###### Is there any difference between renovated / non-renovated


{% highlight r linenos %}
train %>%
    mutate(isRenovated = factor(ifelse(yr_renovated != 0, 1, 0))) %>%
    ggplot(aes(x = isRenovated, y = log(price), fill = isRenovated)) + 
    geom_boxplot()
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-14-1.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" width="1008" style="display: block; margin: auto;" />

- 개조한 집의 가격이 대체로 비싸게 책정됨을 알 수 있다.

###### Year Saled - Price / Month Saled - Price


{% highlight r linenos %}
train %>%
    mutate(sale_year = factor(sale_year)) %>%
    ggplot(aes(x = sale_year, y = log(price), fill = sale_year)) + 
    geom_boxplot()
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-15-1.png" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" width="1008" style="display: block; margin: auto;" />


{% highlight r linenos %}
train %>%
    mutate(sale_month = factor(sale_month)) %>%
    ggplot(aes(x = sale_month, y = log(price), fill = sale_month)) + 
    geom_boxplot()
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-16-1.png" title="plot of chunk unnamed-chunk-16" alt="plot of chunk unnamed-chunk-16" width="1008" style="display: block; margin: auto;" />

- 두 변수 모두 가격에 영향을 미치는 것으로 보이진 않는다.

###### Bathrooms - Price


{% highlight r linenos %}
train %>%
    mutate(bathrooms = factor(bathrooms)) %>%
    ggplot(aes(x = bathrooms, y = log(price), fill = bathrooms)) + 
    geom_boxplot()
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-17-1.png" title="plot of chunk unnamed-chunk-17" alt="plot of chunk unnamed-chunk-17" width="1008" style="display: block; margin: auto;" />

- `log(price)`와 `bathrooms`는 유사 선형관계를 가진다.

###### Coordinate - Price


{% highlight r linenos %}
train %>%
    ggplot(aes(x = lat, y = log(price), color = lat)) + 
    geom_line() + geom_point(shape = 21)
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-18-1.png" title="plot of chunk unnamed-chunk-18" alt="plot of chunk unnamed-chunk-18" width="1008" style="display: block; margin: auto;" />


{% highlight r linenos %}
train %>%
    ggplot(aes(x = long, y = log(price), color = long)) + 
    geom_line() + geom_point(shape = 21)
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-19-1.png" title="plot of chunk unnamed-chunk-19" alt="plot of chunk unnamed-chunk-19" width="1008" style="display: block; margin: auto;" />

- 위도와 경도 모두 특정 영역에서 높은 가격대가 형성이 되어 있다. 변수를 새로 생성해서 영역을 분리하는 것이 도움이 될 것으로 보인다.
    - Latitude : ~47.5 / 47.5 ~ 47.6 / 47.6 ~ 

###### Zip Code - Price


{% highlight r linenos %}
sort(unique(train$zipcode)) == sort(unique(test$zipcode))
{% endhighlight %}



{% highlight text %}
 [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
[15] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
[29] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
[43] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
[57] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
{% endhighlight %}

- 트레이닝 데이터와 테스트 데이터에 존재하는 Zip Code는 동일하다.


{% highlight r linenos %}
train %>%
    arrange(zipcode) %>%
    mutate(zipcode = factor(zipcode)) %>%
    ggplot(aes(x = zipcode, y = log(price), fill = zipcode)) + 
    geom_boxplot()
{% endhighlight %}

<img src="/assets/article_images/2017-01-20-king-county/unnamed-chunk-21-1.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" width="1008" style="display: block; margin: auto;" />

- **one-hot encoding** 으로 데이터를 확장하는 것을 고려하자.

### Feature Engineering

###### Split the latitude


{% highlight r linenos %}
splitLat <- function(data){
    data <- data %>%
        dplyr::mutate(lat1 = ifelse(lat <= 47.5, lat, 0),
                      lat2 = ifelse(lat > 47.5 & lat <= 47.6, lat, 0),
                      lat3 = ifelse(lat > 47.6, lat, 0)) %>%
        dplyr::select(-lat)
    return(data)
}

train <- splitLat(train)
test <- splitLat(test)
{% endhighlight %}

###### Is this house renovated?


{% highlight r linenos %}
train <- train %>%
    mutate(isRenovated = ifelse(yr_renovated != 0, 1, 0))

test <- test %>%
    mutate(isRenovated = ifelse(yr_renovated != 0, 1, 0))
{% endhighlight %}

###### How old is this house?


{% highlight r linenos %}
train <- train %>%
    mutate(age = ifelse(yr_renovated != 0, 2016 - yr_renovated, 2016 - yr_built))

test <- test %>%
    mutate(age = ifelse(yr_renovated != 0, 2016 - yr_renovated, 2016 - yr_built))
{% endhighlight %}

###### Zip Code (one-hot encoding)


{% highlight r linenos %}
train$zipcode <- factor(train$zipcode)
test$zipcode <- factor(test$zipcode)
{% endhighlight %}

### Modeling


{% highlight r linenos %}
model <- lm(log(price) ~ ., data = train)
summary(model)
{% endhighlight %}



{% highlight text %}

Call:
lm(formula = log(price) ~ ., data = train)

Residuals:
     Min       1Q   Median       3Q      Max 
-1.34466 -0.09549  0.00900  0.10445  0.99991 

Coefficients: (1 not defined because of singularities)
                Estimate Std. Error t value Pr(>|t|)    
(Intercept)   -1.724e+02  1.346e+01 -12.801  < 2e-16 ***
bedrooms       3.475e-03  2.059e-03   1.687 0.091539 .  
bathrooms      3.492e-02  3.607e-03   9.682  < 2e-16 ***
sqft_living    1.293e-04  4.842e-06  26.706  < 2e-16 ***
sqft_lot       5.831e-07  5.052e-08  11.542  < 2e-16 ***
floors        -2.629e-02  4.304e-03  -6.107 1.04e-09 ***
waterfront     4.803e-01  1.920e-02  25.022  < 2e-16 ***
view           5.911e-02  2.351e-03  25.144  < 2e-16 ***
condition      6.463e-02  2.662e-03  24.278  < 2e-16 ***
grade          8.787e-02  2.489e-03  35.305  < 2e-16 ***
sqft_above     7.052e-05  4.960e-06  14.218  < 2e-16 ***
sqft_basement         NA         NA      NA       NA    
yr_built       1.412e-05  3.319e-04   0.043 0.966069    
yr_renovated   3.900e-03  5.273e-04   7.396 1.48e-13 ***
zipcode98002  -1.643e-02  1.959e-02  -0.839 0.401492    
zipcode98003   2.312e-03  1.732e-02   0.133 0.893808    
zipcode98004   8.901e-01  3.264e-02  27.266  < 2e-16 ***
zipcode98005   5.514e-01  3.427e-02  16.091  < 2e-16 ***
zipcode98006   4.636e-01  2.867e-02  16.173  < 2e-16 ***
zipcode98007   4.747e-01  3.537e-02  13.422  < 2e-16 ***
zipcode98008   4.733e-01  3.451e-02  13.714  < 2e-16 ***
zipcode98010   3.160e-01  2.935e-02  10.768  < 2e-16 ***
zipcode98011   2.156e-01  4.426e-02   4.871 1.12e-06 ***
zipcode98014   2.213e-01  4.945e-02   4.476 7.67e-06 ***
zipcode98019   1.608e-01  4.803e-02   3.347 0.000818 ***
zipcode98022   1.466e-01  2.632e-02   5.570 2.59e-08 ***
zipcode98023  -6.187e-02  1.647e-02  -3.755 0.000174 ***
zipcode98024   3.271e-01  4.332e-02   7.552 4.52e-14 ***
zipcode98027   4.123e-01  2.915e-02  14.143  < 2e-16 ***
zipcode98028   1.791e-01  4.291e-02   4.175 3.00e-05 ***
zipcode98029   4.862e-01  3.361e-02  14.466  < 2e-16 ***
zipcode98030   5.803e-02  1.987e-02   2.920 0.003506 ** 
zipcode98031   6.711e-02  2.010e-02   3.338 0.000845 ***
zipcode98032  -5.169e-02  2.409e-02  -2.146 0.031880 *  
zipcode98033   5.632e-01  3.741e-02  15.053  < 2e-16 ***
zipcode98034   3.090e-01  3.971e-02   7.780 7.72e-15 ***
zipcode98038   2.167e-01  2.205e-02   9.829  < 2e-16 ***
zipcode98039   1.016e+00  4.378e-02  23.207  < 2e-16 ***
zipcode98040   6.770e-01  2.881e-02  23.495  < 2e-16 ***
zipcode98042   8.254e-02  1.863e-02   4.430 9.48e-06 ***
zipcode98045   4.201e-01  4.097e-02  10.255  < 2e-16 ***
zipcode98052   4.434e-01  3.821e-02  11.606  < 2e-16 ***
zipcode98053   4.215e-01  4.088e-02  10.312  < 2e-16 ***
zipcode98055   1.231e-01  2.272e-02   5.419 6.09e-08 ***
zipcode98056   1.924e-01  2.462e-02   7.814 5.90e-15 ***
zipcode98058   1.456e-01  2.153e-02   6.762 1.41e-11 ***
zipcode98059   2.764e-01  2.401e-02  11.511  < 2e-16 ***
zipcode98065   3.206e-01  3.819e-02   8.396  < 2e-16 ***
zipcode98070   2.187e-01  2.839e-02   7.704 1.41e-14 ***
zipcode98072   2.680e-01  4.418e-02   6.066 1.35e-09 ***
zipcode98074   3.914e-01  3.681e-02  10.635  < 2e-16 ***
zipcode98075   4.124e-01  3.445e-02  11.972  < 2e-16 ***
zipcode98077   2.386e-01  4.607e-02   5.179 2.26e-07 ***
zipcode98092   6.066e-02  1.763e-02   3.441 0.000581 ***
zipcode98102   7.040e-01  3.863e-02  18.224  < 2e-16 ***
zipcode98103   5.535e-01  3.617e-02  15.301  < 2e-16 ***
zipcode98105   6.903e-01  3.723e-02  18.543  < 2e-16 ***
zipcode98106   1.161e-01  2.628e-02   4.417 1.01e-05 ***
zipcode98107   5.679e-01  3.732e-02  15.218  < 2e-16 ***
zipcode98108   1.462e-01  2.892e-02   5.056 4.32e-07 ***
zipcode98109   7.571e-01  3.829e-02  19.771  < 2e-16 ***
zipcode98112   8.180e-01  3.461e-02  23.633  < 2e-16 ***
zipcode98115   5.640e-01  3.664e-02  15.390  < 2e-16 ***
zipcode98116   5.312e-01  2.933e-02  18.113  < 2e-16 ***
zipcode98117   5.383e-01  3.711e-02  14.505  < 2e-16 ***
zipcode98118   2.564e-01  2.593e-02   9.887  < 2e-16 ***
zipcode98119   7.252e-01  3.653e-02  19.851  < 2e-16 ***
zipcode98122   5.698e-01  3.299e-02  17.272  < 2e-16 ***
zipcode98125   3.183e-01  3.934e-02   8.090 6.40e-16 ***
zipcode98126   3.278e-01  2.717e-02  12.066  < 2e-16 ***
zipcode98133   1.829e-01  4.042e-02   4.524 6.12e-06 ***
zipcode98136   4.607e-01  2.806e-02  16.415  < 2e-16 ***
zipcode98144   4.454e-01  2.947e-02  15.114  < 2e-16 ***
zipcode98146   1.132e-01  2.426e-02   4.664 3.12e-06 ***
zipcode98148   1.338e-01  3.442e-02   3.887 0.000102 ***
zipcode98155   1.588e-01  4.197e-02   3.783 0.000155 ***
zipcode98166   2.300e-01  2.291e-02  10.040  < 2e-16 ***
zipcode98168  -1.569e-02  2.371e-02  -0.662 0.508155    
zipcode98177   3.189e-01  4.201e-02   7.591 3.36e-14 ***
zipcode98178   3.922e-02  2.445e-02   1.604 0.108728    
zipcode98188   6.366e-02  2.540e-02   2.507 0.012197 *  
zipcode98198   6.464e-03  1.910e-02   0.338 0.734994    
zipcode98199   6.004e-01  3.569e-02  16.821  < 2e-16 ***
long          -2.737e-01  6.348e-02  -4.312 1.63e-05 ***
sqft_living15  8.920e-05  3.933e-06  22.679  < 2e-16 ***
sqft_lot15     1.997e-07  7.990e-08   2.500 0.012442 *  
sale_year      6.783e-02  5.156e-03  13.156  < 2e-16 ***
sale_month     3.004e-03  7.699e-04   3.902 9.58e-05 ***
lat1           2.801e-01  9.154e-02   3.060 0.002215 ** 
lat2           2.825e-01  9.148e-02   3.088 0.002016 ** 
lat3           2.829e-01  9.142e-02   3.094 0.001978 ** 
isRenovated   -7.677e+00  1.046e+00  -7.339 2.26e-13 ***
age            2.176e-04  3.375e-04   0.645 0.518993    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.1832 on 15037 degrees of freedom
Multiple R-squared:  0.8798,	Adjusted R-squared:  0.8791 
F-statistic:  1210 on 91 and 15037 DF,  p-value: < 2.2e-16
{% endhighlight %}

###### Evaluation Metric: RMSLE

평가 메트릭으로 **Root Mean Squared Logarithmic Error(RMSLE)**를 사용한다. 해당 메트릭은 과대평가된 항목보다는 과소평가된 항목에 페널티를 준다.

$$
RMSLE = \sqrt{\frac{1}{n} \sum^n_{i=1} \left( \log(p_i + 1) - \log(a_i + 1)\right)^2}
$$

{% highlight r linenos %}
rmsle <- function(predict, actual){
    if(length(predict) != length(actual))
        stop("The length of two vectors are different.")
    
    len <- length(predict)
    rmsle <- sqrt((1/len) * sum((log(predict + 1) - log(actual + 1))^2))
    return(rmsle)
}
{% endhighlight %}

###### Test


{% highlight r linenos %}
pred <- predict(model, test)
pred <- exp(pred)

result <- rmsle(pred, test$price)
benchmark_result <- rmsle(benchmark, test$price)
cat("RMSLE (Benchmark): ", benchmark_result, "\nRMSLE (Final): ", result)
{% endhighlight %}



{% highlight text %}
RMSLE (Benchmark):  0.9280684 
RMSLE (Final):  0.1794722
{% endhighlight %}

- 데이터에 아무런 조작을 하지 않고, 로그 스케일을 고려하지 않은 벤치마크 모델의 RMSLE 값은 0.9280684이다. 로그 스케일과 피쳐 엔지니어링을 이용한 모델의 예측력은 다섯 배 가량 개선되었다. 최종 모델의 RMSLE는 0.1794722이다.
