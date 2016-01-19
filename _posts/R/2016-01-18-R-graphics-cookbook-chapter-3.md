---
layout: post
title: "R Graphics Cookbook 3장"
author: "Jaeyoon Han"
categories : R
date: 2016-01-18
image: /assets/images/Rgraphicscookbook.jpg
---

## R Graphics Cookbook

---

R Graphics Cookbook에 있는 내용을 공부하면서, 필요하면 코드를 추가시키거나 주석을 단 것을 포스팅하려고 한다.
        
#### 3장. 막대 그래프

막대 그래프를 만들 때 유의해야 할 것은 막대의 높이가 때로는 데이터셋의 *빈도 수(count)*를 나타낼 수도 있고, *값(value)*을 나타낼 수도 있다는 점이다.

###### 3.1 막대 그래프 그리기

우선 사용할 데이터셋을 불러오기 위해 패키지를 불러온다.

{% highlight r %}
library(gcookbook)
{% endhighlight %}

본 절에서는 `pg_mean` 데이터를 사용한다. 도움말 문서에 따르면 식물 성장과 관련된 실험의 데이터의 평균값을 모아놓은 데이터라고 한다.
막대 그래프(barplot)는 `ggplot()` 뒤에 `geom_bar(stat = "identity")`로 설정하면 된다.


{% highlight r %}
ggplot(pg_mean, aes(x = group, y = weight)) + geom_bar(stat = "identity")
{% endhighlight %}

![plot of chunk unnamed-chunk-2](/assets/article_images/2016-01-18-R-graphics-cookbook-chapter-3/unnamed-chunk-2-1.png)

위에서는 `x`값이 이산값이었지만, 연속값 또는 수치형일 경우 막대의 형태가 조금 달라진다. `x`의 최솟값부터 최댓값 사이의 가능한 모든 값들이 변수가 된다. 사용할 데이터는 시간에 따른 생화학적 산소 요구량 데이터다.


{% highlight r %}
# BOD 데이터에서 Time == 6인 항목은 존재하지 않는다.
BOD
{% endhighlight %}



{% highlight text %}
##   Time demand
## 1    1    8.3
## 2    2   10.3
## 3    3   19.0
## 4    4   16.0
## 5    5   15.6
## 6    7   19.8
{% endhighlight %}



{% highlight r %}
# Time 변수는 수치형(연속형) 데이터다.
str(BOD)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	6 obs. of  2 variables:
##  $ Time  : num  1 2 3 4 5 7
##  $ demand: num  8.3 10.3 19 16 15.6 19.8
##  - attr(*, "reference")= chr "A1.4, p. 270"
{% endhighlight %}



{% highlight r %}
# 데이터를 그대로 사용해 막대 그래프를 그리면 중간에 빈 곳이 생긴다.
ggplot(BOD, aes(x = Time, y = demand)) + geom_bar(stat = "identity")
{% endhighlight %}

![plot of chunk unnamed-chunk-3](/assets/article_images/2016-01-18-R-graphics-cookbook-chapter-3/unnamed-chunk-3-1.png)

{% highlight r %}
# factor()를 사용해 Time 변수를 이산형(범주형) 변수로 바꿔주면 문제는 해결된다.
ggplot(BOD, aes(x = factor(Time), y = demand)) + geom_bar(stat = "identity")
{% endhighlight %}

![plot of chunk unnamed-chunk-3](/assets/article_images/2016-01-18-R-graphics-cookbook-chapter-3/unnamed-chunk-3-2.png)
두 그래프의 차이는 `Time == 6` 인 경우에서 드러난다. 위의 경우는 1부터 7까지의 모든 경우가 그래프에 나타나지만, 아래의 경우는 `factor()`로 인해 `Time` 변수가 범주형 변수로 바뀌었기 때문에 존재하는 데이터만 그려지게 된다.  
막대 그래프의 색상과 테두리는 다음과 같이 설정한다.

{% highlight r %}
ggplot(pg_mean, aes(x = group, y = weight)) +
	geom_bar(stat = "identity", fill = "lightblue", col = "black")
{% endhighlight %}

![plot of chunk unnamed-chunk-4](/assets/article_images/2016-01-18-R-graphics-cookbook-chapter-3/unnamed-chunk-4-1.png)

###### 3.2 막대를 함께 묶기
