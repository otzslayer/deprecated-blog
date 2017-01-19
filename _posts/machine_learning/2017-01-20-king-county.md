---
title: "House Sales in King County, USA"
author: "Jaeyoon Han"
date: "2017-01-20"
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
zipcode_train <- data.frame(model.matrix(price ~ 0 + zipcode, data = train))
zipcode_test <- data.frame(model.matrix(price ~ 0 + zipcode, data = test))
{% endhighlight %}


{% highlight r linenos %}
train <- train %>%
    select(-zipcode) %>%
    cbind(zipcode_train)

test <- test %>%
    select(-zipcode) %>%
    cbind(zipcode_test)
{% endhighlight %}

###### Feature Selection


{% highlight r linenos %}
train <- train %>%
    select(-sale_month, -yr_built, -yr_renovated, -sale_year)

test <- test %>%
    select(-sale_month, -yr_built, -yr_renovated, -sale_year)
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
-1.31378 -0.09517  0.00703  0.10587  1.03878 

Coefficients: (2 not defined because of singularities)
                Estimate Std. Error t value Pr(>|t|)    
(Intercept)   -3.601e+01  8.768e+00  -4.107 4.03e-05 ***
bedrooms       4.239e-03  2.081e-03   2.037 0.041693 *  
bathrooms      3.462e-02  3.645e-03   9.496  < 2e-16 ***
sqft_living    1.298e-04  4.893e-06  26.537  < 2e-16 ***
sqft_lot       5.868e-07  5.108e-08  11.488  < 2e-16 ***
floors        -2.920e-02  4.340e-03  -6.728 1.78e-11 ***
waterfront     4.725e-01  1.939e-02  24.373  < 2e-16 ***
view           5.974e-02  2.376e-03  25.144  < 2e-16 ***
condition      6.171e-02  2.686e-03  22.978  < 2e-16 ***
grade          8.768e-02  2.515e-03  34.859  < 2e-16 ***
sqft_above     6.999e-05  5.013e-06  13.961  < 2e-16 ***
sqft_basement         NA         NA      NA       NA    
long          -2.753e-01  6.418e-02  -4.289 1.80e-05 ***
sqft_living15  8.800e-05  3.976e-06  22.134  < 2e-16 ***
sqft_lot15     2.062e-07  8.077e-08   2.553 0.010704 *  
lat1           2.958e-01  9.253e-02   3.197 0.001391 ** 
lat2           2.982e-01  9.247e-02   3.225 0.001262 ** 
lat3           2.985e-01  9.241e-02   3.231 0.001238 ** 
isRenovated    1.015e-01  8.029e-03  12.639  < 2e-16 ***
age            1.292e-04  9.020e-05   1.432 0.152121    
zipcode98001  -6.000e-01  3.607e-02 -16.634  < 2e-16 ***
zipcode98002  -6.126e-01  3.846e-02 -15.930  < 2e-16 ***
zipcode98003  -5.942e-01  3.584e-02 -16.581  < 2e-16 ***
zipcode98004   2.902e-01  2.229e-02  13.020  < 2e-16 ***
zipcode98005  -4.894e-02  2.667e-02  -1.835 0.066498 .  
zipcode98006  -1.380e-01  2.789e-02  -4.947 7.62e-07 ***
zipcode98007  -1.268e-01  2.828e-02  -4.482 7.46e-06 ***
zipcode98008  -1.279e-01  2.639e-02  -4.847 1.27e-06 ***
zipcode98010  -2.817e-01  4.484e-02  -6.283 3.40e-10 ***
zipcode98011  -3.903e-01  2.660e-02 -14.673  < 2e-16 ***
zipcode98014  -3.849e-01  4.268e-02  -9.017  < 2e-16 ***
zipcode98019  -4.412e-01  3.629e-02 -12.157  < 2e-16 ***
zipcode98022  -4.476e-01  4.886e-02  -9.162  < 2e-16 ***
zipcode98023  -6.604e-01  3.543e-02 -18.638  < 2e-16 ***
zipcode98024  -2.707e-01  4.497e-02  -6.019 1.80e-09 ***
zipcode98027  -1.907e-01  3.268e-02  -5.836 5.45e-09 ***
zipcode98028  -4.286e-01  2.351e-02 -18.230  < 2e-16 ***
zipcode98029  -1.172e-01  3.455e-02  -3.394 0.000691 ***
zipcode98030  -5.375e-01  3.506e-02 -15.332  < 2e-16 ***
zipcode98031  -5.322e-01  3.289e-02 -16.180  < 2e-16 ***
zipcode98032  -6.489e-01  3.645e-02 -17.805  < 2e-16 ***
zipcode98033  -3.920e-02  2.198e-02  -1.784 0.074466 .  
zipcode98034  -2.973e-01  2.154e-02 -13.803  < 2e-16 ***
zipcode98038  -3.803e-01  3.779e-02 -10.065  < 2e-16 ***
zipcode98039   4.061e-01  3.498e-02  11.612  < 2e-16 ***
zipcode98040   7.559e-02  2.678e-02   2.823 0.004770 ** 
zipcode98042  -5.138e-01  3.532e-02 -14.550  < 2e-16 ***
zipcode98045  -1.860e-01  4.867e-02  -3.822 0.000133 ***
zipcode98052  -1.631e-01  2.438e-02  -6.689 2.33e-11 ***
zipcode98053  -1.842e-01  2.988e-02  -6.166 7.20e-10 ***
zipcode98055  -4.753e-01  3.046e-02 -15.607  < 2e-16 ***
zipcode98056  -4.058e-01  2.782e-02 -14.587  < 2e-16 ***
zipcode98058  -4.522e-01  3.126e-02 -14.464  < 2e-16 ***
zipcode98059  -3.239e-01  2.961e-02 -10.936  < 2e-16 ***
zipcode98065  -2.789e-01  4.200e-02  -6.641 3.22e-11 ***
zipcode98070  -3.861e-01  3.497e-02 -11.040  < 2e-16 ***
zipcode98072  -3.363e-01  2.770e-02 -12.139  < 2e-16 ***
zipcode98074  -2.122e-01  2.839e-02  -7.474 8.22e-14 ***
zipcode98075  -1.885e-01  3.323e-02  -5.671 1.45e-08 ***
zipcode98077  -3.683e-01  3.179e-02 -11.587  < 2e-16 ***
zipcode98092  -5.333e-01  3.842e-02 -13.883  < 2e-16 ***
zipcode98102   1.006e-01  2.585e-02   3.893 9.96e-05 ***
zipcode98103  -5.077e-02  1.660e-02  -3.058 0.002234 ** 
zipcode98105   9.266e-02  2.092e-02   4.428 9.56e-06 ***
zipcode98106  -4.839e-01  2.438e-02 -19.850  < 2e-16 ***
zipcode98107  -3.155e-02  1.918e-02  -1.645 0.099985 .  
zipcode98108  -4.570e-01  2.662e-02 -17.165  < 2e-16 ***
zipcode98109   1.570e-01  2.457e-02   6.389 1.72e-10 ***
zipcode98112   2.188e-01  2.018e-02  10.842  < 2e-16 ***
zipcode98115  -3.856e-02  1.737e-02  -2.220 0.026423 *  
zipcode98116  -6.890e-02  2.351e-02  -2.930 0.003390 ** 
zipcode98117  -6.495e-02  1.655e-02  -3.925 8.69e-05 ***
zipcode98118  -3.400e-01  2.436e-02 -13.953  < 2e-16 ***
zipcode98119   1.261e-01  2.104e-02   5.992 2.12e-09 ***
zipcode98122  -3.012e-02  1.954e-02  -1.542 0.123165    
zipcode98125  -2.859e-01  1.938e-02 -14.751  < 2e-16 ***
zipcode98126  -2.750e-01  2.410e-02 -11.411  < 2e-16 ***
zipcode98133  -4.204e-01  1.872e-02 -22.454  < 2e-16 ***
zipcode98136  -1.395e-01  2.541e-02  -5.490 4.08e-08 ***
zipcode98144  -1.511e-01  2.383e-02  -6.341 2.34e-10 ***
zipcode98146  -4.886e-01  2.573e-02 -18.993  < 2e-16 ***
zipcode98148  -4.721e-01  4.026e-02 -11.726  < 2e-16 ***
zipcode98155  -4.440e-01  2.056e-02 -21.597  < 2e-16 ***
zipcode98166  -3.706e-01  2.901e-02 -12.774  < 2e-16 ***
zipcode98168  -6.190e-01  2.734e-02 -22.639  < 2e-16 ***
zipcode98177  -2.873e-01  2.077e-02 -13.834  < 2e-16 ***
zipcode98178  -5.618e-01  2.777e-02 -20.234  < 2e-16 ***
zipcode98188  -5.332e-01  3.250e-02 -16.406  < 2e-16 ***
zipcode98198  -5.906e-01  3.155e-02 -18.720  < 2e-16 ***
zipcode98199          NA         NA      NA       NA    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.1852 on 15041 degrees of freedom
Multiple R-squared:  0.8771,	Adjusted R-squared:  0.8764 
F-statistic:  1234 on 87 and 15041 DF,  p-value: < 2.2e-16
{% endhighlight %}

- Singularity 가 발생한다. 우선 `Intercept`를 제거해보자.


{% highlight r linenos %}
model <- lm(log(price) ~ . -1, data = train)
summary(model)
{% endhighlight %}



{% highlight text %}

Call:
lm(formula = log(price) ~ . - 1, data = train)

Residuals:
     Min       1Q   Median       3Q      Max 
-1.31378 -0.09517  0.00703  0.10587  1.03878 

Coefficients: (1 not defined because of singularities)
                Estimate Std. Error t value Pr(>|t|)    
bedrooms       4.239e-03  2.081e-03   2.037  0.04169 *  
bathrooms      3.462e-02  3.645e-03   9.496  < 2e-16 ***
sqft_living    1.298e-04  4.893e-06  26.537  < 2e-16 ***
sqft_lot       5.868e-07  5.108e-08  11.488  < 2e-16 ***
floors        -2.920e-02  4.340e-03  -6.728 1.78e-11 ***
waterfront     4.725e-01  1.939e-02  24.373  < 2e-16 ***
view           5.974e-02  2.376e-03  25.144  < 2e-16 ***
condition      6.171e-02  2.686e-03  22.978  < 2e-16 ***
grade          8.768e-02  2.515e-03  34.859  < 2e-16 ***
sqft_above     6.999e-05  5.013e-06  13.961  < 2e-16 ***
sqft_basement         NA         NA      NA       NA    
long          -2.753e-01  6.418e-02  -4.289 1.80e-05 ***
sqft_living15  8.800e-05  3.976e-06  22.134  < 2e-16 ***
sqft_lot15     2.062e-07  8.077e-08   2.553  0.01070 *  
lat1           2.958e-01  9.253e-02   3.197  0.00139 ** 
lat2           2.982e-01  9.247e-02   3.225  0.00126 ** 
lat3           2.985e-01  9.241e-02   3.231  0.00124 ** 
isRenovated    1.015e-01  8.029e-03  12.639  < 2e-16 ***
age            1.292e-04  9.020e-05   1.432  0.15212    
zipcode98001  -3.661e+01  8.751e+00  -4.184 2.89e-05 ***
zipcode98002  -3.662e+01  8.748e+00  -4.187 2.85e-05 ***
zipcode98003  -3.660e+01  8.753e+00  -4.182 2.91e-05 ***
zipcode98004  -3.572e+01  8.757e+00  -4.079 4.54e-05 ***
zipcode98005  -3.606e+01  8.755e+00  -4.119 3.83e-05 ***
zipcode98006  -3.615e+01  8.752e+00  -4.130 3.65e-05 ***
zipcode98007  -3.614e+01  8.753e+00  -4.128 3.67e-05 ***
zipcode98008  -3.614e+01  8.752e+00  -4.129 3.66e-05 ***
zipcode98010  -3.629e+01  8.737e+00  -4.154 3.29e-05 ***
zipcode98011  -3.640e+01  8.762e+00  -4.154 3.28e-05 ***
zipcode98014  -3.639e+01  8.740e+00  -4.164 3.14e-05 ***
zipcode98019  -3.645e+01  8.748e+00  -4.167 3.11e-05 ***
zipcode98022  -3.646e+01  8.732e+00  -4.175 2.99e-05 ***
zipcode98023  -3.667e+01  8.756e+00  -4.188 2.83e-05 ***
zipcode98024  -3.628e+01  8.739e+00  -4.151 3.32e-05 ***
zipcode98027  -3.620e+01  8.746e+00  -4.139 3.50e-05 ***
zipcode98028  -3.644e+01  8.764e+00  -4.158 3.23e-05 ***
zipcode98029  -3.613e+01  8.744e+00  -4.131 3.62e-05 ***
zipcode98030  -3.655e+01  8.749e+00  -4.177 2.97e-05 ***
zipcode98031  -3.654e+01  8.750e+00  -4.176 2.98e-05 ***
zipcode98032  -3.666e+01  8.754e+00  -4.188 2.83e-05 ***
zipcode98033  -3.605e+01  8.758e+00  -4.116 3.87e-05 ***
zipcode98034  -3.631e+01  8.761e+00  -4.144 3.43e-05 ***
zipcode98038  -3.639e+01  8.740e+00  -4.163 3.15e-05 ***
zipcode98039  -3.560e+01  8.758e+00  -4.065 4.83e-05 ***
zipcode98040  -3.593e+01  8.757e+00  -4.104 4.09e-05 ***
zipcode98042  -3.652e+01  8.745e+00  -4.177 2.98e-05 ***
zipcode98045  -3.620e+01  8.729e+00  -4.147 3.39e-05 ***
zipcode98052  -3.617e+01  8.754e+00  -4.132 3.62e-05 ***
zipcode98053  -3.619e+01  8.749e+00  -4.137 3.54e-05 ***
zipcode98055  -3.648e+01  8.753e+00  -4.168 3.09e-05 ***
zipcode98056  -3.642e+01  8.753e+00  -4.160 3.19e-05 ***
zipcode98058  -3.646e+01  8.750e+00  -4.167 3.10e-05 ***
zipcode98059  -3.633e+01  8.751e+00  -4.152 3.31e-05 ***
zipcode98065  -3.629e+01  8.735e+00  -4.154 3.28e-05 ***
zipcode98070  -3.640e+01  8.766e+00  -4.152 3.32e-05 ***
zipcode98072  -3.635e+01  8.758e+00  -4.150 3.34e-05 ***
zipcode98074  -3.622e+01  8.748e+00  -4.141 3.48e-05 ***
zipcode98075  -3.620e+01  8.747e+00  -4.139 3.51e-05 ***
zipcode98077  -3.638e+01  8.754e+00  -4.156 3.26e-05 ***
zipcode98092  -3.654e+01  8.745e+00  -4.179 2.95e-05 ***
zipcode98102  -3.591e+01  8.764e+00  -4.098 4.20e-05 ***
zipcode98103  -3.606e+01  8.766e+00  -4.113 3.92e-05 ***
zipcode98105  -3.592e+01  8.763e+00  -4.099 4.18e-05 ***
zipcode98106  -3.649e+01  8.763e+00  -4.165 3.14e-05 ***
zipcode98107  -3.604e+01  8.768e+00  -4.111 3.97e-05 ***
zipcode98108  -3.647e+01  8.761e+00  -4.163 3.16e-05 ***
zipcode98109  -3.585e+01  8.765e+00  -4.090 4.33e-05 ***
zipcode98112  -3.579e+01  8.762e+00  -4.085 4.43e-05 ***
zipcode98115  -3.605e+01  8.765e+00  -4.113 3.93e-05 ***
zipcode98116  -3.608e+01  8.766e+00  -4.116 3.88e-05 ***
zipcode98117  -3.607e+01  8.769e+00  -4.114 3.91e-05 ***
zipcode98118  -3.635e+01  8.759e+00  -4.150 3.34e-05 ***
zipcode98119  -3.588e+01  8.766e+00  -4.093 4.27e-05 ***
zipcode98122  -3.604e+01  8.761e+00  -4.114 3.92e-05 ***
zipcode98125  -3.630e+01  8.766e+00  -4.141 3.48e-05 ***
zipcode98126  -3.628e+01  8.764e+00  -4.140 3.49e-05 ***
zipcode98133  -3.643e+01  8.769e+00  -4.154 3.28e-05 ***
zipcode98136  -3.615e+01  8.765e+00  -4.124 3.74e-05 ***
zipcode98144  -3.616e+01  8.762e+00  -4.127 3.69e-05 ***
zipcode98146  -3.650e+01  8.762e+00  -4.165 3.13e-05 ***
zipcode98148  -3.648e+01  8.759e+00  -4.165 3.13e-05 ***
zipcode98155  -3.645e+01  8.768e+00  -4.158 3.23e-05 ***
zipcode98166  -3.638e+01  8.761e+00  -4.152 3.31e-05 ***
zipcode98168  -3.663e+01  8.760e+00  -4.181 2.91e-05 ***
zipcode98177  -3.630e+01  8.771e+00  -4.138 3.52e-05 ***
zipcode98178  -3.657e+01  8.756e+00  -4.177 2.98e-05 ***
zipcode98188  -3.654e+01  8.757e+00  -4.173 3.02e-05 ***
zipcode98198  -3.660e+01  8.757e+00  -4.180 2.94e-05 ***
zipcode98199  -3.601e+01  8.768e+00  -4.107 4.03e-05 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.1852 on 15041 degrees of freedom
Multiple R-squared:  0.9998,	Adjusted R-squared:  0.9998 
F-statistic: 8.545e+05 on 88 and 15041 DF,  p-value: < 2.2e-16
{% endhighlight %}

- 여전히 `sqft_basement` 변수가 문제를 일으킨다. 해당 변수를 제거하고 모델링하도록 한다.


{% highlight r linenos %}
model <- lm(log(price) ~ . -1 - sqft_basement, data = train)
summary(model)
{% endhighlight %}



{% highlight text %}

Call:
lm(formula = log(price) ~ . - 1 - sqft_basement, data = train)

Residuals:
     Min       1Q   Median       3Q      Max 
-1.31378 -0.09517  0.00703  0.10587  1.03878 

Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
bedrooms       4.239e-03  2.081e-03   2.037  0.04169 *  
bathrooms      3.462e-02  3.645e-03   9.496  < 2e-16 ***
sqft_living    1.298e-04  4.893e-06  26.537  < 2e-16 ***
sqft_lot       5.868e-07  5.108e-08  11.488  < 2e-16 ***
floors        -2.920e-02  4.340e-03  -6.728 1.78e-11 ***
waterfront     4.725e-01  1.939e-02  24.373  < 2e-16 ***
view           5.974e-02  2.376e-03  25.144  < 2e-16 ***
condition      6.171e-02  2.686e-03  22.978  < 2e-16 ***
grade          8.768e-02  2.515e-03  34.859  < 2e-16 ***
sqft_above     6.999e-05  5.013e-06  13.961  < 2e-16 ***
long          -2.753e-01  6.418e-02  -4.289 1.80e-05 ***
sqft_living15  8.800e-05  3.976e-06  22.134  < 2e-16 ***
sqft_lot15     2.062e-07  8.077e-08   2.553  0.01070 *  
lat1           2.958e-01  9.253e-02   3.197  0.00139 ** 
lat2           2.982e-01  9.247e-02   3.225  0.00126 ** 
lat3           2.985e-01  9.241e-02   3.231  0.00124 ** 
isRenovated    1.015e-01  8.029e-03  12.639  < 2e-16 ***
age            1.292e-04  9.020e-05   1.432  0.15212    
zipcode98001  -3.661e+01  8.751e+00  -4.184 2.89e-05 ***
zipcode98002  -3.662e+01  8.748e+00  -4.187 2.85e-05 ***
zipcode98003  -3.660e+01  8.753e+00  -4.182 2.91e-05 ***
zipcode98004  -3.572e+01  8.757e+00  -4.079 4.54e-05 ***
zipcode98005  -3.606e+01  8.755e+00  -4.119 3.83e-05 ***
zipcode98006  -3.615e+01  8.752e+00  -4.130 3.65e-05 ***
zipcode98007  -3.614e+01  8.753e+00  -4.128 3.67e-05 ***
zipcode98008  -3.614e+01  8.752e+00  -4.129 3.66e-05 ***
zipcode98010  -3.629e+01  8.737e+00  -4.154 3.29e-05 ***
zipcode98011  -3.640e+01  8.762e+00  -4.154 3.28e-05 ***
zipcode98014  -3.639e+01  8.740e+00  -4.164 3.14e-05 ***
zipcode98019  -3.645e+01  8.748e+00  -4.167 3.11e-05 ***
zipcode98022  -3.646e+01  8.732e+00  -4.175 2.99e-05 ***
zipcode98023  -3.667e+01  8.756e+00  -4.188 2.83e-05 ***
zipcode98024  -3.628e+01  8.739e+00  -4.151 3.32e-05 ***
zipcode98027  -3.620e+01  8.746e+00  -4.139 3.50e-05 ***
zipcode98028  -3.644e+01  8.764e+00  -4.158 3.23e-05 ***
zipcode98029  -3.613e+01  8.744e+00  -4.131 3.62e-05 ***
zipcode98030  -3.655e+01  8.749e+00  -4.177 2.97e-05 ***
zipcode98031  -3.654e+01  8.750e+00  -4.176 2.98e-05 ***
zipcode98032  -3.666e+01  8.754e+00  -4.188 2.83e-05 ***
zipcode98033  -3.605e+01  8.758e+00  -4.116 3.87e-05 ***
zipcode98034  -3.631e+01  8.761e+00  -4.144 3.43e-05 ***
zipcode98038  -3.639e+01  8.740e+00  -4.163 3.15e-05 ***
zipcode98039  -3.560e+01  8.758e+00  -4.065 4.83e-05 ***
zipcode98040  -3.593e+01  8.757e+00  -4.104 4.09e-05 ***
zipcode98042  -3.652e+01  8.745e+00  -4.177 2.98e-05 ***
zipcode98045  -3.620e+01  8.729e+00  -4.147 3.39e-05 ***
zipcode98052  -3.617e+01  8.754e+00  -4.132 3.62e-05 ***
zipcode98053  -3.619e+01  8.749e+00  -4.137 3.54e-05 ***
zipcode98055  -3.648e+01  8.753e+00  -4.168 3.09e-05 ***
zipcode98056  -3.642e+01  8.753e+00  -4.160 3.19e-05 ***
zipcode98058  -3.646e+01  8.750e+00  -4.167 3.10e-05 ***
zipcode98059  -3.633e+01  8.751e+00  -4.152 3.31e-05 ***
zipcode98065  -3.629e+01  8.735e+00  -4.154 3.28e-05 ***
zipcode98070  -3.640e+01  8.766e+00  -4.152 3.32e-05 ***
zipcode98072  -3.635e+01  8.758e+00  -4.150 3.34e-05 ***
zipcode98074  -3.622e+01  8.748e+00  -4.141 3.48e-05 ***
zipcode98075  -3.620e+01  8.747e+00  -4.139 3.51e-05 ***
zipcode98077  -3.638e+01  8.754e+00  -4.156 3.26e-05 ***
zipcode98092  -3.654e+01  8.745e+00  -4.179 2.95e-05 ***
zipcode98102  -3.591e+01  8.764e+00  -4.098 4.20e-05 ***
zipcode98103  -3.606e+01  8.766e+00  -4.113 3.92e-05 ***
zipcode98105  -3.592e+01  8.763e+00  -4.099 4.18e-05 ***
zipcode98106  -3.649e+01  8.763e+00  -4.165 3.14e-05 ***
zipcode98107  -3.604e+01  8.768e+00  -4.111 3.97e-05 ***
zipcode98108  -3.647e+01  8.761e+00  -4.163 3.16e-05 ***
zipcode98109  -3.585e+01  8.765e+00  -4.090 4.33e-05 ***
zipcode98112  -3.579e+01  8.762e+00  -4.085 4.43e-05 ***
zipcode98115  -3.605e+01  8.765e+00  -4.113 3.93e-05 ***
zipcode98116  -3.608e+01  8.766e+00  -4.116 3.88e-05 ***
zipcode98117  -3.607e+01  8.769e+00  -4.114 3.91e-05 ***
zipcode98118  -3.635e+01  8.759e+00  -4.150 3.34e-05 ***
zipcode98119  -3.588e+01  8.766e+00  -4.093 4.27e-05 ***
zipcode98122  -3.604e+01  8.761e+00  -4.114 3.92e-05 ***
zipcode98125  -3.630e+01  8.766e+00  -4.141 3.48e-05 ***
zipcode98126  -3.628e+01  8.764e+00  -4.140 3.49e-05 ***
zipcode98133  -3.643e+01  8.769e+00  -4.154 3.28e-05 ***
zipcode98136  -3.615e+01  8.765e+00  -4.124 3.74e-05 ***
zipcode98144  -3.616e+01  8.762e+00  -4.127 3.69e-05 ***
zipcode98146  -3.650e+01  8.762e+00  -4.165 3.13e-05 ***
zipcode98148  -3.648e+01  8.759e+00  -4.165 3.13e-05 ***
zipcode98155  -3.645e+01  8.768e+00  -4.158 3.23e-05 ***
zipcode98166  -3.638e+01  8.761e+00  -4.152 3.31e-05 ***
zipcode98168  -3.663e+01  8.760e+00  -4.181 2.91e-05 ***
zipcode98177  -3.630e+01  8.771e+00  -4.138 3.52e-05 ***
zipcode98178  -3.657e+01  8.756e+00  -4.177 2.98e-05 ***
zipcode98188  -3.654e+01  8.757e+00  -4.173 3.02e-05 ***
zipcode98198  -3.660e+01  8.757e+00  -4.180 2.94e-05 ***
zipcode98199  -3.601e+01  8.768e+00  -4.107 4.03e-05 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

Residual standard error: 0.1852 on 15041 degrees of freedom
Multiple R-squared:  0.9998,	Adjusted R-squared:  0.9998 
F-statistic: 8.545e+05 on 88 and 15041 DF,  p-value: < 2.2e-16
{% endhighlight %}

- 참고로 Singularity가 발생하는 변수를 제거하는 것은 사실 굳이 할 필요는 없다. 다만 Intercept를 제거함으로써 모델의 설명력을 높일 수 있다. 어떻게 보면 Intercept는 모두 0인 경우를 의미하는데, 이 데이터에서는 그런 경우가 전무하다.

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
RMSLE (Final):  0.1816971
{% endhighlight %}

- 데이터에 아무런 조작을 하지 않고, 로그 스케일을 고려하지 않은 벤치마크 모델의 RMSLE 값은 0.9280684이다. 로그 스케일과 피쳐 엔지니어링을 이용한 모델의 예측력은 다섯 배 가량 개선되었다. 최종 모델의 RMSLE는 0.1816971이다.
