---
title: "XGBoost Parallelization Test"
author: "Jaeyoon Han"
date: '2016-12-18'
output: html_document
layout: post
image: /assets/article_images/2016-12-18-xgboost-parallelization/title.jpg
categories: R
---


## Parallelization option in XGBoost is ignored in mac?!

---



XGBoost는 전세계적으로 검증받은 알고리즘이자 라이브러리로 만약 데이터 사이언티스트가 되고 싶거나, 최소 Kaggle 등의 컴피티션에 참여하고자 하는 사람들은 반드시 알아야 하는 필수 요소다. XGBoost의 특징은 기존 GBM에 보다 Regularization을 가했다는 점인데, 이와 더불어 Tuning 가능한 파라미터가 굉장히 많다는 점이다. 이에 따라 혹자는 Kaggle에서 XGBoost가 많이 사용되면서 결국 파라미터 튜닝이 머신 러닝을 통한 문제 해결의 전부처럼 비춰질 수 있다고 우려하지만 (본인도 마찬가지다.), 그 성능을 무시할 수는 없다.

Scalability 등의 이유로 인해 Python에서 XGBoost 구현체를 사용하는 모습이 많지만, 아직 본인처럼 R을 이용해서 XGBoost를 사용하는 유저들이 적지는 않다. 다만 생각보다 Python에 비해 부족한 부분이 많다고 느껴지는 것은 사실이다. 그 중 가장 뼈저리게 느끼는 부분은 바로 Cross Validation 부분이다. 파라미터 서치를 위해 CV를 수행하다 보면, R에서는 Python만큼 강력한 기능이 부재하기 때문이다. 물론 몇 가지 방법을 통해서 어느 정도 극복을 할 수 있으니 다행이다. 하지만 여전히 논란이 되는 부분이 있는데 바로 병렬처리다.

다양한 파라미터를 튜닝하기 때문에 연산량이 제법 큰데, Python의 XGBoost의 경우 멀티쓰레딩과 관련한 문제는 발생하지 않는 것으로 알고 있다. 하지만 R의 경우 쓰레드의 개수가 20개를 넘어가는 순간 성능이 저하하거나, 심지어 OpenMP의 설치 유무와 상관없이 멀티쓰레딩이 되지 않는 경우가 있다. 이를 위해 몇몇 사용자들이 해결책을 내놓고 있기는 하다. [참고](https://github.com/dmlc/xgboost/blob/master/doc/build.md)

(덧 : 본인은 심지어 OpenMP를 설치해서 더이상 `xgboost` 라이브러리를 불러올 때 에러 메시지가 출력되지 않음에도 불구하고 XGBoost의 `nthread` 옵션이 작동하지 않는다.)


#### Test

모의 데이터를 통해서 실제 병렬처리 옵션이 작동을 하지 않는지 확인하였다.
실행 시간을 위해서 모의 데이터는 예측 클래스를 포함하여 `500 * 16` 사이즈로 데이터를 구성했다.
테스트는 작업용 맥북프로 레티나 13인치, 4개 쓰레드 + 8GB 메모리 환경에서 수행하였다.


{% highlight r linenos %}
library(caret)
library(plyr)
library(xgboost)
library(doMC)

foo <- function(...) {
    set.seed(2)
    mod <- train(Class ~ ., data = dat, 
                 method = "xgbTree", tuneLength = 50,
                 ..., trControl = trainControl(search = "random"))
    invisible(mod)
}

set.seed(1)
dat <- twoClassSim(500)
{% endhighlight %}

세 가지의 경우를 보기로 했다.

- 아무런 설정을 하지 않은 경우
- XGBoost CV에 직접 옵션을 기재한 경우 (`nthread = 4`)
- `doMC` 라이브러리의 병렬처리 기능을 사용한 경우 (`registerDoMC(cores = 4)`)


{% highlight r linenos %}
vanilla <- system.time(foo())


## I don't have OpenMP installed
xgb_option <- system.time(foo(nthread = 4))


registerDoMC(cores = 4)
domc <- system.time(foo())
{% endhighlight %}



{% highlight r linenos %}
vanilla[3] 
{% endhighlight %}



{% highlight text %}
[1] 193.52
{% endhighlight %}



{% highlight r linenos %}
xgb_option[3]
{% endhighlight %}



{% highlight text %}
[1] 195.232
{% endhighlight %}



{% highlight r linenos %}
domc[3]
{% endhighlight %}



{% highlight text %}
[1] 81.307
{% endhighlight %}



{% highlight r linenos %}
vanilla[3]/domc[3]
{% endhighlight %}



{% highlight text %}
[1] 2.380115
{% endhighlight %}



{% highlight r linenos %}
vanilla[3]/xgb_option[3]
{% endhighlight %}



{% highlight text %}
[1] 0.9912309
{% endhighlight %}



{% highlight r linenos %}
xgb_option[3]/domc[3]
{% endhighlight %}



{% highlight text %}
[1] 2.401171
{% endhighlight %}

첫 번째와 두 번째 경우의 차이는 거의 없다. 하지만, `doMC` 라이브러리의 병렬처리 기능을 사용하여 4개의 쓰레드로 CV를 수행한 경우 두 배 이상의 속도를 보여주며 병렬처리 기능이 활성화됨을 알 수 있다.

<img src="/assets/article_images/2016-12-18-xgboost-parallelization.rmd/unnamed-chunk-21-1.png" title="plot of chunk unnamed-chunk-21" alt="plot of chunk unnamed-chunk-21" width="576" style="display: block; margin: auto;" />

