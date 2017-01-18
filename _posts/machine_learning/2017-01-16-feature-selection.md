---
title: "[번역] Feature Selection in Machine Learning"
author: "Jaeyoon Han"
date: "2017-01-18"
output: html_document
layout: post
image: /assets/article_images/2017-01-16-feature-selection/title.png
categories: machine-learning
---




## Feature Selection in Machine Learning (Breast Cancer Datasets)

### 번역에 앞서.

이번 포스트는 최근 관심을 가지고 있는 Feature selection과 관련된 내용을 담고 있다. 완벽한 번역보다는 아티클을 보고 정리한 내용들을 거칠게 정리하려고 한다. 자세한 내용은 [원문 포스트](https://shiring.github.io/machine_learning/2017/01/15/rfe_ga_post) 참고하길 바란다.

### Introduction

머신러닝은 예측 모델을 생성하기 위해서 변수(features, 또는 variables, attributes)를 사용한다. 높은 정확도를 얻기 위해서는 적절한 변수들의 조합을 사용하는 것이 필수적이다. (불명확한) 변수들을 사용하면 모델이 과적합되는 문제가 발생하기 때문에, 일반적으로 예측하고자 하는 반응변수와 가장 연관성이 높은 변수들을 찾아서 모델에 사용하길 원한다. 가능한한 적은 수의 변수를 사용하면 모델의 복잡도(complexity)를 낮출 수 있다. 다시 말해서 모델을 실행하는 시간과 컴퓨팅 파워 요구량을 줄이고, 이해하기도 쉬워진다는 의미다.

모델에 대해서 각각의 변수가 기여하는 정도를 측정하고, 변수의 수를 정하는 방법은 여러 가지가 있다. 본 아티클에서는 랜덤 포레스트 모델에 대해서 다음의 기법을 사용한다.

- 상관계수 (Correlation),
- 재귀 변수 제거법 (Recursive Feature Elimination),
- 유전 알고리즘 (Genetic Algorithm, GA)
- 보루타 알고리즘 (Boruta Algorithm, BA) [역자 주: 원문 포스트에는 없고 테스트를 위해서 추가했다.]

추가적으로, 데이터의 특성이 다를 때 위의 변수 선택 기법이 어떤 영향을 미치는지 확인하기 위해서 세 가지의 유방암 관련 데이터셋을 사용하였다. 하나는 매우 적은 수의 변수를 가지고 있으며, 다른 두 개의 데이터는 매우 큰 데이터지만, PCA를 이용해서 결과 클러스터를 다르게 하였다.

상관계수 기법, RFE, GA를 비교한 결과에 따르면, 랜덤 포레스트에 대해서 다음의 결과를 얻었다.

- 상관계수가 높은 변수를 제거하는 것이 일반적으로 적절한 기법은 아니다.
- GA가 본 예제에서는 최상의 결과를 보여줬지만, 다양한 변수가 있는 사례에서는 실용적이지 못하다. 적절한 세대(generation)까지 모델을 실행하는 데 오랜 시간이 걸리기 때문이다.
- 시작부터 좋은 분류 결과가 나오기 힘든 데이터는 변수 선택에서 큰 효과를 보기 어렵다.

이 결론들은 물론 모든 데이터에 대해 일반화할 수는 없다. 위 기법들 이외에도 다양한 변수 선택 기법이 있으며, 굉장히 제한된 데이터셋에 대해서만 비교분석 하였으며, 랜덤 포레스트 모델에 대한 영향력만 분석했다. 하지만 작은 예제로도 서로 다른 변수와 파라미터가 예측 결과에 어떻게 영향을 미치는지 충분히 보여주고 있다는 점이 중요하다. 머신러닝에서는 이른바 "만능(one size fits all)"은 존재하지 않는다. 데이터를 유심히 살펴보는 것은 항상 가치있는 일이고, 모델이나 알고리즘에 대해서 생각하기 전에 데이터의 특징들에 익숙해지는 것이 중요하다. 주어진 데이터에 대해서 무언가 감을 잡았다면, 서로 다른 변수 선택 기법(또는 생성한 변수들), 모델, 파라미터들을 비교해보는 데에 시간을 투자하고, 마지막으로 다양한 머신러닝 알고리즘을 비교해보는 것이 큰 차이를 만들어낼 수 있다.

### Breast Cancer Wisconsin (Diagnostic) Dataset

변수 선택 기법을 비교하기 위해 사용할 데이터는 Breast Cancer Wisconsin (Diagnostic) 데이터셋이다.

> W.N. Street, W.H. Wolberg and O.L. Mangasarian. Nuclear feature extraction for breast tumor diagnosis. IS&T/SPIE 1993 International Symposium on Electronic Imaging: Science and Technology, volume 1905, pages 861-870, San Jose, CA, 1993.

> O.L. Mangasarian, W.N. Street and W.H. Wolberg. Breast cancer diagnosis and prognosis via linear programming. Operations Research, 43(4), pages 570-577, July-August 1995.

> W.H. Wolberg, W.N. Street, and O.L. Mangasarian. Machine learning techniques to diagnose breast cancer from fine-needle aspirates. Cancer Letters 77 (1994) 163-171.

> W.H. Wolberg, W.N. Street, and O.L. Mangasarian. Image analysis and machine learning applied to breast cancer diagnosis and prognosis. Analytical and Quantitative Cytology and Histology, Vol. 17 No. 2, pages 77-87, April 1995.

> W.H. Wolberg, W.N. Street, D.M. Heisey, and O.L. Mangasarian. Computerized breast cancer diagnosis and prognosis from fine needle aspirates. Archives of Surgery 1995;130:511-516.

> W.H. Wolberg, W.N. Street, D.M. Heisey, and O.L. Mangasarian. Computer-derived nuclear features distinguish malignant from benign breast cytology. Human Pathology, 26:792–796, 1995.

데이터는 [UC Irvine Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Breast+Cancer+Wisconsin+%28Diagnostic%29)에서 다운로드했다. 데이터셋의 변수들은 세포핵의 특성을 담고 있으며, 유방 세포 덩어리 세침흡인검사의 이미지 분석으로 생성되었다.

총 세 개의 데이터셋을 포함하고 있다. 첫번째 데이터셋은 아홉 개의 변수만 사용하고 있는 작은 데이터이며, 다른 두 개의 데이터는 각각 30개와 33개의 변수를 포함하고 있다. 두 데이터는 PCA로 생성되는 클러스터가 서로 다르다. 서로 다른 특성을 가지고 있는 데이터셋을 이용해서 서로 다른 변수 선택 기법의 효과를 살펴보고자 한다.

##### Breast Cancer Dataset 1

반응변수의 클래스는 다음과 같다.

- Malignant (악성)
- Benign (양성).

세포 특징에 관한 표현형은 다음과 같다.

- Sample ID (code number)
- Clump thickness
- Uniformity of cell size
- Uniformity of cell shape
- Marginal adhesion
- Single epithelial cell size
- Number of bare nuclei
- Bland chromatin
- Number of normal nuclei
- Mitosis
- Classes, i.e. diagnosis

결측값들은 `mice` 패키지를 이용해서 처리한다.


{% highlight r linenos %}
bc_data <- read.table("data/breast/breast-cancer-wisconsin.data.txt",
                      header = FALSE, sep = ",")
colnames(bc_data) <- c("sample_code_number",
                       "clump_thickness",
                       "uniformity_of_cell_size",
                       "uniformity_of_cell_shape",
                       "marginal_adhesion", 
                       "single_epithelial_cell_size", 
                       "bare_nuclei", 
                       "bland_chromatin", 
                       "normal_nucleoli",
                       "mitosis",
                       "classes"
)
bc_data$classes <- ifelse(bc_data$classes == "2", "benign",
                          ifelse(bc_data$classes == "4", "malignant", NA))
bc_data[bc_data == "?"] <- NA

# how many NAs are in the data
length(which(is.na(bc_data)))
{% endhighlight %}



{% highlight text %}
[1] 16
{% endhighlight %}


{% highlight r linenos %}
# impute missing data
library(mice)

bc_data[,2:10] <- apply(bc_data[, 2:10], 2, function(x) as.numeric(as.character(x)))
dataset_impute <- mice(bc_data[, 2:10],  print = FALSE)
bc_data <- cbind(bc_data[, 11, drop = FALSE], mice::complete(dataset_impute, 1))

bc_data$classes <- as.factor(bc_data$classes)

# how many benign and malignant cases are there?
summary(bc_data$classes)
{% endhighlight %}



{% highlight text %}
   benign malignant 
      458       241 
{% endhighlight %}


{% highlight r linenos %}
str(bc_data)
{% endhighlight %}



{% highlight text %}
'data.frame':	699 obs. of  10 variables:
 $ classes                    : Factor w/ 2 levels "benign","malignant": 1 1 1 1 1 2 1 1 1 1 ...
 $ clump_thickness            : num  5 5 3 6 4 8 1 2 2 4 ...
 $ uniformity_of_cell_size    : num  1 4 1 8 1 10 1 1 1 2 ...
 $ uniformity_of_cell_shape   : num  1 4 1 8 1 10 1 2 1 1 ...
 $ marginal_adhesion          : num  1 5 1 1 3 8 1 1 1 1 ...
 $ single_epithelial_cell_size: num  2 7 2 3 2 7 2 2 2 2 ...
 $ bare_nuclei                : num  1 10 2 4 1 10 10 1 1 1 ...
 $ bland_chromatin            : num  3 3 3 3 3 9 3 3 1 2 ...
 $ normal_nucleoli            : num  1 2 1 7 1 7 1 1 1 1 ...
 $ mitosis                    : num  1 1 1 1 1 1 1 1 5 1 ...
{% endhighlight %}

##### Breast Cancer Dataset 2

두번째 데이터셋의 반응변수의 클래스는 동일하다.

- Malignant (악성)
- Benign (양성).

데이터셋의 첫 두 칼럼은 다음과 같다.

- Sample ID
- Classes, i.e. diagnosis

각 세포핵에 대해서, 다음 10개의 특징이 측정되어 있다.

- Radius (mean of all distances from the center to points on the perimeter)
- Texture (standard deviation of gray-scale values)
- Perimeter
- Area
- Smoothness (local variation in radius lengths)
- Compactness (perimeter^2 / area - 1.0)
- Concavity (severity of concave portions of the contour)
- Concave points (number of concave portions of the contour)
- Symmetry
- Fractal dimension (“coastline approximation” - 1)

각각의 특징은 세 개의 기준을 측정되었다.

- 평균
- 표준편차
- 가장 심각한 경우


{% highlight r linenos %}
bc_data_2 <- read.table("data/breast/wdbc.data.txt",
                        header = FALSE, sep = ",")

phenotypes <- rep(c("radius",
                    "texture",
                    "perimeter",
                    "area",
                    "smoothness",
                    "compactness",
                    "concavity",
                    "concave_points",
                    "symmetry",
                    "fractal_dimension"), 3)
types <- rep(c("mean", "se", "largest_worst"), each = 10)

colnames(bc_data_2) <- c("ID",
                         "diagnosis",
                         paste(phenotypes, types, sep = "_")
)

# how many NAs are in the data
length(which(is.na(bc_data_2)))
{% endhighlight %}



{% highlight text %}
[1] 0
{% endhighlight %}


{% highlight r linenos %}
# how many benign and malignant cases are there?
summary(bc_data_2$diagnosis)
{% endhighlight %}



{% highlight text %}
  B   M 
357 212 
{% endhighlight %}


{% highlight r linenos %}
str(bc_data_2)
{% endhighlight %}



{% highlight text %}
'data.frame':	569 obs. of  32 variables:
 $ ID                             : int  842302 842517 84300903 84348301 84358402 843786 844359 84458202 844981 84501001 ...
 $ diagnosis                      : Factor w/ 2 levels "B","M": 2 2 2 2 2 2 2 2 2 2 ...
 $ radius_mean                    : num  18 20.6 19.7 11.4 20.3 ...
 $ texture_mean                   : num  10.4 17.8 21.2 20.4 14.3 ...
 $ perimeter_mean                 : num  122.8 132.9 130 77.6 135.1 ...
 $ area_mean                      : num  1001 1326 1203 386 1297 ...
 $ smoothness_mean                : num  0.1184 0.0847 0.1096 0.1425 0.1003 ...
 $ compactness_mean               : num  0.2776 0.0786 0.1599 0.2839 0.1328 ...
 $ concavity_mean                 : num  0.3001 0.0869 0.1974 0.2414 0.198 ...
 $ concave_points_mean            : num  0.1471 0.0702 0.1279 0.1052 0.1043 ...
 $ symmetry_mean                  : num  0.242 0.181 0.207 0.26 0.181 ...
 $ fractal_dimension_mean         : num  0.0787 0.0567 0.06 0.0974 0.0588 ...
 $ radius_se                      : num  1.095 0.543 0.746 0.496 0.757 ...
 $ texture_se                     : num  0.905 0.734 0.787 1.156 0.781 ...
 $ perimeter_se                   : num  8.59 3.4 4.58 3.44 5.44 ...
 $ area_se                        : num  153.4 74.1 94 27.2 94.4 ...
 $ smoothness_se                  : num  0.0064 0.00522 0.00615 0.00911 0.01149 ...
 $ compactness_se                 : num  0.049 0.0131 0.0401 0.0746 0.0246 ...
 $ concavity_se                   : num  0.0537 0.0186 0.0383 0.0566 0.0569 ...
 $ concave_points_se              : num  0.0159 0.0134 0.0206 0.0187 0.0188 ...
 $ symmetry_se                    : num  0.03 0.0139 0.0225 0.0596 0.0176 ...
 $ fractal_dimension_se           : num  0.00619 0.00353 0.00457 0.00921 0.00511 ...
 $ radius_largest_worst           : num  25.4 25 23.6 14.9 22.5 ...
 $ texture_largest_worst          : num  17.3 23.4 25.5 26.5 16.7 ...
 $ perimeter_largest_worst        : num  184.6 158.8 152.5 98.9 152.2 ...
 $ area_largest_worst             : num  2019 1956 1709 568 1575 ...
 $ smoothness_largest_worst       : num  0.162 0.124 0.144 0.21 0.137 ...
 $ compactness_largest_worst      : num  0.666 0.187 0.424 0.866 0.205 ...
 $ concavity_largest_worst        : num  0.712 0.242 0.45 0.687 0.4 ...
 $ concave_points_largest_worst   : num  0.265 0.186 0.243 0.258 0.163 ...
 $ symmetry_largest_worst         : num  0.46 0.275 0.361 0.664 0.236 ...
 $ fractal_dimension_largest_worst: num  0.1189 0.089 0.0876 0.173 0.0768 ...
{% endhighlight %}

##### Breast Cancer Dataset 3

세 번째 데이터셋의 반응변수의 클래스는 다음과 같다.

- R: 재발
- N: 재발하지 않음

데이터셋의 첫 두 칼럼은 다음과 같다.

- Sample ID
- Classes, i.e. outcome

각 세포핵에 대해서 두 번째 데이터셋과 동일한 특성과 측정기준으로 구성된 칼럼이 있으며, 추가적으로 다음의 칼럼이 있다.

- Time (recurrence time if field 2 = R, disease-free time if field 2 = N)
- Tumor size - diameter of the excised tumor in centimeters
- Lymph node status - number of positive axillary lymph nodes observed at time of surgery


{% highlight r linenos %}
bc_data_3 <- read.table("data/breast/wpbc.data.txt",
                        header = FALSE, sep = ",")
colnames(bc_data_3) <- c("ID",
                         "outcome", 
                         "time",
                         paste(phenotypes, types, sep = "_"),
                         "tumor_size",
                         "lymph_node_status"
)

bc_data_3[bc_data_3 == "?"] <- NA

# how many NAs are in the data
length(which(is.na(bc_data_3)))
{% endhighlight %}



{% highlight text %}
[1] 4
{% endhighlight %}


{% highlight r linenos %}
# impute missing data
library(mice)

bc_data_3[,3:35] <- apply(bc_data_3[,3:35], 2, function(x) as.numeric(as.character(x)))
dataset_impute <- mice(bc_data_3[,3:35],  print = FALSE)
bc_data_3 <- cbind(bc_data_3[, 2, drop = FALSE], mice::complete(dataset_impute, 1))

# how many recurring and non-recurring cases are there?
summary(bc_data_3$outcome)
{% endhighlight %}



{% highlight text %}
  N   R 
151  47 
{% endhighlight %}


{% highlight r linenos %}
str(bc_data_3)
{% endhighlight %}



{% highlight text %}
'data.frame':	198 obs. of  34 variables:
 $ outcome                        : Factor w/ 2 levels "N","R": 1 1 1 1 2 2 1 2 1 1 ...
 $ time                           : num  31 61 116 123 27 77 60 77 119 76 ...
 $ radius_mean                    : num  18 18 21.4 11.4 20.3 ...
 $ texture_mean                   : num  27.6 10.4 17.4 20.4 14.3 ...
 $ perimeter_mean                 : num  117.5 122.8 137.5 77.6 135.1 ...
 $ area_mean                      : num  1013 1001 1373 386 1297 ...
 $ smoothness_mean                : num  0.0949 0.1184 0.0884 0.1425 0.1003 ...
 $ compactness_mean               : num  0.104 0.278 0.119 0.284 0.133 ...
 $ concavity_mean                 : num  0.109 0.3 0.126 0.241 0.198 ...
 $ concave_points_mean            : num  0.0706 0.1471 0.0818 0.1052 0.1043 ...
 $ symmetry_mean                  : num  0.186 0.242 0.233 0.26 0.181 ...
 $ fractal_dimension_mean         : num  0.0633 0.0787 0.0601 0.0974 0.0588 ...
 $ radius_se                      : num  0.625 1.095 0.585 0.496 0.757 ...
 $ texture_se                     : num  1.89 0.905 0.611 1.156 0.781 ...
 $ perimeter_se                   : num  3.97 8.59 3.93 3.44 5.44 ...
 $ area_se                        : num  71.5 153.4 82.2 27.2 94.4 ...
 $ smoothness_se                  : num  0.00443 0.0064 0.00617 0.00911 0.01149 ...
 $ compactness_se                 : num  0.0142 0.049 0.0345 0.0746 0.0246 ...
 $ concavity_se                   : num  0.0323 0.0537 0.033 0.0566 0.0569 ...
 $ concave_points_se              : num  0.00985 0.01587 0.01805 0.01867 0.01885 ...
 $ symmetry_se                    : num  0.0169 0.03 0.0309 0.0596 0.0176 ...
 $ fractal_dimension_se           : num  0.00349 0.00619 0.00504 0.00921 0.00511 ...
 $ radius_largest_worst           : num  21.6 25.4 24.9 14.9 22.5 ...
 $ texture_largest_worst          : num  37.1 17.3 21 26.5 16.7 ...
 $ perimeter_largest_worst        : num  139.7 184.6 159.1 98.9 152.2 ...
 $ area_largest_worst             : num  1436 2019 1949 568 1575 ...
 $ smoothness_largest_worst       : num  0.119 0.162 0.119 0.21 0.137 ...
 $ compactness_largest_worst      : num  0.193 0.666 0.345 0.866 0.205 ...
 $ concavity_largest_worst        : num  0.314 0.712 0.341 0.687 0.4 ...
 $ concave_points_largest_worst   : num  0.117 0.265 0.203 0.258 0.163 ...
 $ symmetry_largest_worst         : num  0.268 0.46 0.433 0.664 0.236 ...
 $ fractal_dimension_largest_worst: num  0.0811 0.1189 0.0907 0.173 0.0768 ...
 $ tumor_size                     : num  5 3 2.5 2 3.5 2.5 1.5 4 2 6 ...
 $ lymph_node_status              : num  5 2 0 0 0 0 0 10 1 20 ...
{% endhighlight %}

### Principal Component Analysis (PCA)

데이터셋의 차원과 분산에 대한 아이디어를 얻기 위해서, 데이터의 샘플과 변수에 대해서 PCA 플롯을 그리도록 한다. 첫 두 주성분(principal components, PCs)는 데이터 분산의 다수를 설명할 수 있는 두 주성분을 의미한다.


{% highlight r linenos %}
# function for PCA plotting
library(pcaGoPromoter)
library(ellipse)

pca_func <- function(data, groups, title, print_ellipse = TRUE) {
    
    # perform pca and extract scores
    pcaOutput <- pca(data, printDropped = FALSE, scale = TRUE, center = TRUE)
    pcaOutput2 <- as.data.frame(pcaOutput$scores)
    
    # define groups for plotting
    pcaOutput2$groups <- groups
    
    # when plotting samples calculate ellipses for plotting (when plotting features, there are no replicates)
    if (print_ellipse) {
        
        centroids <- aggregate(cbind(PC1, PC2) ~ groups, pcaOutput2, mean)
        conf.rgn  <- do.call(rbind, lapply(unique(pcaOutput2$groups), function(t)
            data.frame(groups = as.character(t),
                       ellipse(cov(pcaOutput2[pcaOutput2$groups == t, 1:2]),
                               centre = as.matrix(centroids[centroids$groups == t, 2:3]),
                               level = 0.95),
                       stringsAsFactors = FALSE)))
        
        plot <- ggplot(data = pcaOutput2, aes(x = PC1, y = PC2, group = groups, color = groups)) + 
            geom_polygon(data = conf.rgn, aes(fill = groups), alpha = 0.2) +
            geom_point(size = 2, alpha = 0.6) + 
            scale_color_brewer(palette = "Set1") +
            labs(title = title,
                 color = "",
                 fill = "",
                 x = paste0("PC1: ", round(pcaOutput$pov[1], digits = 2), "% variance"),
                 y = paste0("PC2: ", round(pcaOutput$pov[2], digits = 2), "% variance"))
        
    } else {
        
        # if there are fewer than 10 groups (e.g. the predictor classes) I want to have colors from RColorBrewer
        if (length(unique(pcaOutput2$groups)) <= 10) {
            
            plot <- ggplot(data = pcaOutput2, aes(x = PC1, y = PC2, group = groups, color = groups)) + 
                geom_point(size = 2, alpha = 0.6) + 
                scale_color_brewer(palette = "Set1") +
                labs(title = title,
                     color = "",
                     fill = "",
                     x = paste0("PC1: ", round(pcaOutput$pov[1], digits = 2), "% variance"),
                     y = paste0("PC2: ", round(pcaOutput$pov[2], digits = 2), "% variance"))
            
        } else {
            
            # otherwise use the default rainbow colors
            plot <- ggplot(data = pcaOutput2, aes(x = PC1, y = PC2, group = groups, color = groups)) + 
                geom_point(size = 2, alpha = 0.6) + 
                labs(title = title,
                     color = "",
                     fill = "",
                     x = paste0("PC1: ", round(pcaOutput$pov[1], digits = 2), "% variance"),
                     y = paste0("PC2: ", round(pcaOutput$pov[2], digits = 2), "% variance"))
            
        }
    }
    
    return(plot)
    
}

library(gridExtra)
library(grid)
{% endhighlight %}

##### Dataset 1


{% highlight r linenos %}
p1 <- pca_func(data = t(bc_data[, 2:10]),
               groups = as.character(bc_data$classes),
               title = "Breast cancer dataset 1: Samples"
)
p2 <- pca_func(data = bc_data[, 2:10],
               groups = as.character(colnames(bc_data[, 2:10])), 
               title = "Breast cancer dataset 1: Features", 
               print_ellipse = FALSE)
grid.arrange(p1, p2, ncol = 2)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-11-1.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
h_1 <- hclust(dist(t(bc_data[, 2:10]),
                   method = "euclidean"),
              method = "complete")
plot(h_1)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-12-1.png" title="plot of chunk unnamed-chunk-12" alt="plot of chunk unnamed-chunk-12" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
library(tidyr)
bc_data_gather <- bc_data %>%
    gather(measure, value, clump_thickness:mitosis)

ggplot(data = bc_data_gather,
       aes(x = value, fill = classes, color = classes)) +
    geom_density(alpha = 0.3, size = 1) +
    geom_rug() +
    scale_fill_brewer(palette = "Set1") +
    scale_color_brewer(palette = "Set1") +
    facet_wrap( ~ measure, scales = "free_y", ncol = 3)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-13-1.png" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" width="864" style="display: block; margin: auto;" />

##### Dataset 2


{% highlight r linenos %}
p1 <- pca_func(data = t(bc_data_2[, 3:32]),
               groups = as.character(bc_data_2$diagnosis),
               title = "Breast cancer dataset 2: Samples")
p2 <- pca_func(data = bc_data_2[, 3:32],
               groups = as.character(colnames(bc_data_2[, 3:32])),
               title = "Breast cancer dataset 2: Features",
               print_ellipse = FALSE)
grid.arrange(p1, p2, ncol = 2, widths = c(0.4, 0.6))
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-14-1.png" title="plot of chunk unnamed-chunk-14" alt="plot of chunk unnamed-chunk-14" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
h_2 <- hclust(dist(t(bc_data_2[, 3:32]),
                   method = "euclidean"),
              method = "complete")
plot(h_2)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-15-1.png" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
bc_data_2_gather <- bc_data_2[, -1] %>%
    gather(measure, value, radius_mean:fractal_dimension_largest_worst)

ggplot(data = bc_data_2_gather, aes(x = value, fill = diagnosis, color = diagnosis)) +
    geom_density(alpha = 0.3, size = 1) +
    geom_rug() +
    scale_fill_brewer(palette = "Set1") +
    scale_color_brewer(palette = "Set1") +
    facet_wrap( ~ measure, scales = "free_y", ncol = 3)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-16-1.png" title="plot of chunk unnamed-chunk-16" alt="plot of chunk unnamed-chunk-16" width="864" style="display: block; margin: auto;" />

##### Dataset 3


{% highlight r linenos %}
p1 <- pca_func(data = t(bc_data_3[, 2:34]),
               groups = as.character(bc_data_3$outcome), 
               title = "Breast cancer dataset 3: Samples")
p2 <- pca_func(data = bc_data_3[, 2:34], 
               groups = as.character(colnames(bc_data_3[, 2:34])),
               title = "Breast cancer dataset 3: Features", 
               print_ellipse = FALSE)
grid.arrange(p1, p2, ncol = 2, widths = c(0.4, 0.6))
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-17-1.png" title="plot of chunk unnamed-chunk-17" alt="plot of chunk unnamed-chunk-17" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
h_3 <- hclust(dist(t(bc_data_3[,2:34]),
                   method = "euclidean"),
              method = "complete")
plot(h_3)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-18-1.png" title="plot of chunk unnamed-chunk-18" alt="plot of chunk unnamed-chunk-18" width="864" style="display: block; margin: auto;" />

데이터셋 1과 데이터셋 2는 양성과 음성을 잘 분류한다. 또한 해당 변수들에 기반을 둔 모델은 클래스 예측 성능이 좋을 것으로 보인다. 하지만 데이터셋 3은 서로 다른 그룹으로 군집화하지 못하는데, 이는 해당 변수들을 사용했을 때 예측 성능이 떨어질 것으로 예상된다.

데이터셋 2와 데이터셋 3의 변수들은 잘 구별되게 군집화되지 않는다. 많은 변수들이 유사한 패턴을 보이기 때문인 것으로 보인다. 따라서 세 개의 데이터셋에 대해서 적절한 변수 부분집합을 고르는 것은 서로 다른 효과를 보일 것으로 보인다.


{% highlight r linenos %}
bc_data_3_gather <- bc_data_3 %>%
    gather(measure, value, time:lymph_node_status)

ggplot(data = bc_data_3_gather, aes(x = value, fill = outcome, color = outcome)) +
    geom_density(alpha = 0.3, size = 1) +
    geom_rug() +
    scale_fill_brewer(palette = "Set1") +
    scale_color_brewer(palette = "Set1") +
    facet_wrap( ~ measure, scales = "free_y", ncol = 3)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-19-1.png" title="plot of chunk unnamed-chunk-19" alt="plot of chunk unnamed-chunk-19" width="864" style="display: block; margin: auto;" />

### Feature importance

변수 각각의 중요성에 대한 정보를 얻기 위해서 `caret` 패키지를 사용하여 랜덤 포레스트에 대해 10 x 10 CV를 수행하였다. 모델링을 위한 변수 선택을 위해 변수 중요성이 필요했다면, 완전한 데이터셋이 아닌 트레이닝 데이터에 CV를 수행하여야 한다. 하지만 데이터에 전체에 대한 정보를 얻고 싶었기 때문에 전체를 사용하였다. 


{% highlight r linenos %}
library(caret)
library(doMC)
registerDoMC(cores = 4)

# prepare training scheme
control <- trainControl(method = "repeatedcv", number = 10, repeats = 10)

feature_imp <- function(model, title) {
    
    # estimate variable importance
    importance <- varImp(model, scale = TRUE)
    
    # prepare dataframes for plotting
    importance_df_1 <- importance$importance
    importance_df_1$group <- rownames(importance_df_1)
    
    importance_df_2 <- importance_df_1
    importance_df_2$Overall <- 0
    
    importance_df <- rbind(importance_df_1, importance_df_2)
    
    plot <- ggplot() +
        geom_point(data = importance_df_1,
                   aes(x = Overall, y = group, color = group),
                   size = 2) +
        geom_path(data = importance_df,
                  aes(x = Overall, y = group,
                      color = group, group = group), 
                  size = 1) +
        theme(legend.position = "none") +
        labs(
            x = "Importance",
            y = "",
            title = title,
            subtitle = "Scaled feature importance",
            caption = "\nDetermined with Random Forest and
      repeated cross validation (10 repeats, 10 times)"
        )
    
    return(plot)
    
}
{% endhighlight %}


{% highlight r linenos %}
# train the model
set.seed(27)
imp_1 <- train(classes ~ .,
               data = bc_data,
               method = "rf",
               preProcess = c("scale", "center"),
               trControl = control)
p1 <- feature_imp(imp_1, title = "Breast cancer dataset 1")
{% endhighlight %}


{% highlight r linenos %}
set.seed(27)
imp_2 <- train(diagnosis ~ .,
               data = bc_data_2[, -1],
               method = "rf",
               preProcess = c("scale", "center"),
               trControl = control)
p2 <- feature_imp(imp_2, title = "Breast cancer dataset 2")
{% endhighlight %}


{% highlight r linenos %}
set.seed(27)
imp_3 <- train(outcome ~ .,
               data = bc_data_3,
               method = "rf",
               preProcess = c("scale", "center"),
               trControl = control)
p3 <- feature_imp(imp_3, title = "Breast cancer dataset 3")
{% endhighlight %}


{% highlight r linenos %}
grid.arrange(p1, p2, p3, ncol = 3, widths = c(0.3, 0.35, 0.35))
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-24-1.png" title="plot of chunk unnamed-chunk-24" alt="plot of chunk unnamed-chunk-24" width="936" style="display: block; margin: auto;" />

### Feature Selection

이제 데이터에 대한 일반적인 정보들을 얻어냈으므로, 세 개의 데이터셋에 대해서 변수 선택 기법을 적용하고, 랜덤 포레스트 모델의 정확도에 어떤 영향을 미치는지 살펴보도록 하자.

##### Creating train and test data

데이터에 작업을 수행하기 전에 기존의 데이터셋을 트레이닝 데이터와 테스트 데이터로 나눠야 한다. 전체 데이터에 대해서 변수 선택을 수행하면 예측값에 대한 편향을 초래할 수 있으므로, 모든 모델링 프로세스를 트레이닝 데이터에만 수행하도록 한다.

- Dataset 1

{% highlight r linenos %}
set.seed(27)
bc_data_index <- createDataPartition(bc_data$classes,
                                     p = 0.7, list = FALSE)
bc_data_train <- bc_data[bc_data_index, ]
bc_data_test  <- bc_data[-bc_data_index, ]
{% endhighlight %}

- Dataset 2


{% highlight r linenos %}
set.seed(27)
bc_data_2_index <- createDataPartition(bc_data_2$diagnosis,
                                       p = 0.7, list = FALSE)
bc_data_2_train <- bc_data_2[bc_data_2_index, ]
bc_data_2_test  <- bc_data_2[-bc_data_2_index, ]
{% endhighlight %}

- Dataset 3

{% highlight r linenos %}
set.seed(27)
bc_data_3_index <- createDataPartition(bc_data_3$outcome,
                                       p = 0.7, list = FALSE)
bc_data_3_train <- bc_data_3[bc_data_3_index, ]
bc_data_3_test  <- bc_data_3[-bc_data_3_index, ]
{% endhighlight %}

### Correlation

종종 우리는 높은 상관관계를 갖는 변수들을 마주하게 되고, 이 변수들은 필요 이상의 정보를 제공한다. 상관관계가 높은 변수를 제거함으로써 해당 변수에 포함된 정보들에 의한 예측값이 편향되는 것을 방지할 수 있다. 이런 점들은 우리가 특정 변수들의 생물학적/의학적 중요성에 대한 주장을 할 때, 중요 변수들은 결과물을 예측할 때 적절한 것이지, 인과관계를 설명하는 것이 아님을 인지해야 한다.

모든 변수들 사이의 상관관계는 `corrplot` 패키지를 이용해서 계산하고 시각화한다. 그 후 0.7보다 높은 상관관계를 보이는 모든 변수를 삭제할 예정이다.

- Dataset 1


{% highlight r linenos %}
library(corrplot)

# calculate correlation matrix
corMatMy <- cor(bc_data_train[, -1])
corrplot(corMatMy, order = "hclust")
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-28-1.png" title="plot of chunk unnamed-chunk-28" alt="plot of chunk unnamed-chunk-28" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
#Apply correlation filter at 0.70,
highlyCor <- colnames(bc_data_train[, -1])[findCorrelation(corMatMy, cutoff = 0.7, verbose = TRUE)]
{% endhighlight %}



{% highlight text %}
Compare row 2  and column  3 with corr  0.913 
  Means:  0.715 vs 0.601 so flagging column 2 
Compare row 3  and column  7 with corr  0.725 
  Means:  0.677 vs 0.578 so flagging column 3 
Compare row 7  and column  6 with corr  0.705 
  Means:  0.6 vs 0.544 so flagging column 7 
Compare row 6  and column  4 with corr  0.715 
  Means:  0.577 vs 0.525 so flagging column 6 
All correlations <= 0.7 
{% endhighlight %}


{% highlight r linenos %}
# which variables are flagged for removal?
highlyCor
{% endhighlight %}



{% highlight text %}
[1] "uniformity_of_cell_size"  "uniformity_of_cell_shape"
[3] "bland_chromatin"          "bare_nuclei"             
{% endhighlight %}


{% highlight r linenos %}
#then we remove these variables
bc_data_cor <- bc_data_train[, which(!colnames(bc_data_train) %in% highlyCor)]
{% endhighlight %}

- Dataset 2


{% highlight r linenos %}
corMatMy <- cor(bc_data_2_train[, 3:32])
corrplot(corMatMy, order = "hclust")
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-32-1.png" title="plot of chunk unnamed-chunk-32" alt="plot of chunk unnamed-chunk-32" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
highlyCor <- colnames(bc_data_2_train[, 3:32])[findCorrelation(corMatMy, cutoff = 0.7, verbose = TRUE)]
{% endhighlight %}



{% highlight text %}
Compare row 7  and column  8 with corr  0.92 
  Means:  0.579 vs 0.393 so flagging column 7 
Compare row 8  and column  6 with corr  0.84 
  Means:  0.548 vs 0.38 so flagging column 8 
Compare row 6  and column  28 with corr  0.827 
  Means:  0.536 vs 0.368 so flagging column 6 
Compare row 28  and column  27 with corr  0.855 
  Means:  0.506 vs 0.357 so flagging column 28 
Compare row 27  and column  26 with corr  0.894 
  Means:  0.46 vs 0.346 so flagging column 27 
Compare row 23  and column  21 with corr  0.993 
  Means:  0.454 vs 0.336 so flagging column 23 
Compare row 21  and column  24 with corr  0.983 
  Means:  0.419 vs 0.327 so flagging column 21 
Compare row 26  and column  30 with corr  0.817 
  Means:  0.402 vs 0.323 so flagging column 26 
Compare row 24  and column  3 with corr  0.943 
  Means:  0.383 vs 0.312 so flagging column 24 
Compare row 3  and column  1 with corr  0.998 
  Means:  0.347 vs 0.306 so flagging column 3 
Compare row 1  and column  4 with corr  0.986 
  Means:  0.302 vs 0.304 so flagging column 4 
Compare row 1  and column  14 with corr  0.726 
  Means:  0.264 vs 0.304 so flagging column 14 
Compare row 13  and column  11 with corr  0.973 
  Means:  0.32 vs 0.304 so flagging column 13 
Compare row 18  and column  16 with corr  0.757 
  Means:  0.388 vs 0.295 so flagging column 18 
Compare row 16  and column  17 with corr  0.796 
  Means:  0.404 vs 0.288 so flagging column 16 
Compare row 9  and column  29 with corr  0.711 
  Means:  0.343 vs 0.274 so flagging column 9 
Compare row 17  and column  20 with corr  0.745 
  Means:  0.306 vs 0.261 so flagging column 17 
Compare row 5  and column  25 with corr  0.809 
  Means:  0.311 vs 0.255 so flagging column 5 
Compare row 30  and column  10 with corr  0.753 
  Means:  0.288 vs 0.241 so flagging column 30 
Compare row 22  and column  2 with corr  0.913 
  Means:  0.243 vs 0.242 so flagging column 22 
All correlations <= 0.7 
{% endhighlight %}


{% highlight r linenos %}
highlyCor
{% endhighlight %}



{% highlight text %}
 [1] "concavity_mean"                  "concave_points_mean"            
 [3] "compactness_mean"                "concave_points_largest_worst"   
 [5] "concavity_largest_worst"         "perimeter_largest_worst"        
 [7] "radius_largest_worst"            "compactness_largest_worst"      
 [9] "area_largest_worst"              "perimeter_mean"                 
[11] "perimeter_se"                    "area_mean"                      
[13] "concave_points_se"               "compactness_se"                 
[15] "area_se"                         "symmetry_mean"                  
[17] "concavity_se"                    "smoothness_mean"                
[19] "fractal_dimension_largest_worst" "texture_largest_worst"          
{% endhighlight %}


{% highlight r linenos %}
bc_data_2_cor <- bc_data_2_train[, which(!colnames(bc_data_2_train) %in% highlyCor)]
{% endhighlight %}

- Dataset 3


{% highlight r linenos %}
corMatMy <- cor(bc_data_3_train[, -1])
corrplot(corMatMy, order = "hclust")
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-36-1.png" title="plot of chunk unnamed-chunk-36" alt="plot of chunk unnamed-chunk-36" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
highlyCor <- colnames(bc_data_3_train[, -1])[findCorrelation(corMatMy, cutoff = 0.7, verbose = TRUE)]
{% endhighlight %}



{% highlight text %}
Compare row 8  and column  9 with corr  0.898 
  Means:  0.425 vs 0.285 so flagging column 8 
Compare row 9  and column  7 with corr  0.714 
  Means:  0.39 vs 0.277 so flagging column 9 
Compare row 7  and column  29 with corr  0.753 
  Means:  0.364 vs 0.271 so flagging column 7 
Compare row 4  and column  2 with corr  0.996 
  Means:  0.348 vs 0.264 so flagging column 4 
Compare row 2  and column  5 with corr  0.993 
  Means:  0.329 vs 0.259 so flagging column 2 
Compare row 5  and column  24 with corr  0.921 
  Means:  0.303 vs 0.254 so flagging column 5 
Compare row 24  and column  22 with corr  0.985 
  Means:  0.271 vs 0.252 so flagging column 24 
Compare row 11  and column  31 with corr  0.83 
  Means:  0.341 vs 0.247 so flagging column 11 
Compare row 22  and column  15 with corr  0.773 
  Means:  0.239 vs 0.242 so flagging column 15 
Compare row 22  and column  25 with corr  0.989 
  Means:  0.216 vs 0.242 so flagging column 25 
Compare row 14  and column  12 with corr  0.975 
  Means:  0.257 vs 0.243 so flagging column 14 
Compare row 31  and column  28 with corr  0.71 
  Means:  0.328 vs 0.238 so flagging column 31 
Compare row 18  and column  17 with corr  0.812 
  Means:  0.331 vs 0.229 so flagging column 18 
Compare row 28  and column  27 with corr  0.84 
  Means:  0.286 vs 0.219 so flagging column 28 
Compare row 17  and column  21 with corr  0.839 
  Means:  0.285 vs 0.212 so flagging column 17 
Compare row 10  and column  30 with corr  0.766 
  Means:  0.277 vs 0.204 so flagging column 10 
Compare row 6  and column  26 with corr  0.754 
  Means:  0.235 vs 0.198 so flagging column 6 
Compare row 3  and column  23 with corr  0.858 
  Means:  0.164 vs 0.195 so flagging column 23 
All correlations <= 0.7 
{% endhighlight %}


{% highlight r linenos %}
highlyCor
{% endhighlight %}



{% highlight text %}
 [1] "concavity_mean"                  "concave_points_mean"            
 [3] "compactness_mean"                "perimeter_mean"                 
 [5] "radius_mean"                     "area_mean"                      
 [7] "perimeter_largest_worst"         "fractal_dimension_mean"         
 [9] "perimeter_se"                    "area_se"                        
[11] "area_largest_worst"              "fractal_dimension_largest_worst"
[13] "concavity_se"                    "concavity_largest_worst"        
[15] "compactness_se"                  "symmetry_mean"                  
[17] "smoothness_mean"                 "texture_largest_worst"          
{% endhighlight %}


{% highlight r linenos %}
bc_data_3_cor <- bc_data_3_train[, which(!colnames(bc_data_3_train) %in% highlyCor)]
{% endhighlight %}

### Recursive Feature Elimination (RFE)

변수를 선택하는 다른 방법으로 재귀 변수 제거법(RFE)이 있다. RFE는 변수들의 조합을 테스트하기 위해 랜덤 포레스트 알고리즘을 사용하며, 각 케이스에 대해서 정확도 점수를 반환한다. 가장 높은 점수를 기록한 조합을 선택한다.

- Dataset 1


{% highlight r linenos %}
# ensure the results are repeatable
set.seed(7)
# define the control using a random forest selection function with cross validation
control <- rfeControl(functions = rfFuncs, method = "cv", number = 10)

# run the RFE algorithm
results_1 <- rfe(x = bc_data_train[, -1], y = bc_data_train$classes, sizes = c(1:9), rfeControl = control)

# chosen features
predictors(results_1)
{% endhighlight %}



{% highlight text %}
[1] "bare_nuclei"              "uniformity_of_cell_size" 
[3] "clump_thickness"          "uniformity_of_cell_shape"
[5] "bland_chromatin"          "marginal_adhesion"       
[7] "normal_nucleoli"          "mitosis"                 
{% endhighlight %}


{% highlight r linenos %}
# subset the chosen features
bc_data_rfe <- bc_data_train[, c(1, which(colnames(bc_data_train) %in% predictors(results_1)))]
{% endhighlight %}

- Dataset 2


{% highlight r linenos %}
set.seed(7)
results_2 <- rfe(x = bc_data_2_train[, -c(1, 2)], y = as.factor(bc_data_2_train$diagnosis), sizes = c(1:30), rfeControl = control)

predictors(results_2)
{% endhighlight %}



{% highlight text %}
 [1] "perimeter_largest_worst"      "area_largest_worst"          
 [3] "radius_largest_worst"         "concave_points_largest_worst"
 [5] "concave_points_mean"          "texture_largest_worst"       
 [7] "area_se"                      "texture_mean"                
 [9] "concavity_largest_worst"      "concavity_mean"              
[11] "area_mean"                   
{% endhighlight %}


{% highlight r linenos %}
bc_data_2_rfe <- bc_data_2_train[, c(2, which(colnames(bc_data_2_train) %in% predictors(results_2)))]
{% endhighlight %}

- Dataset 3


{% highlight r linenos %}
set.seed(7)
results_3 <- rfe(x = bc_data_3_train[,-1], y = as.factor(bc_data_3_train$outcome), sizes = c(1:33), rfeControl = control)

predictors(results_3)
{% endhighlight %}



{% highlight text %}
 [1] "time"                            "lymph_node_status"              
 [3] "symmetry_mean"                   "smoothness_largest_worst"       
 [5] "concave_points_se"               "perimeter_se"                   
 [7] "texture_se"                      "compactness_mean"               
 [9] "concave_points_largest_worst"    "concavity_se"                   
[11] "symmetry_largest_worst"          "concavity_largest_worst"        
[13] "smoothness_mean"                 "fractal_dimension_largest_worst"
[15] "tumor_size"                      "compactness_largest_worst"      
[17] "concave_points_mean"             "concavity_mean"                 
[19] "fractal_dimension_mean"          "texture_largest_worst"          
[21] "radius_se"                       "symmetry_se"                    
[23] "perimeter_largest_worst"         "radius_largest_worst"           
[25] "area_se"                        
{% endhighlight %}


{% highlight r linenos %}
bc_data_3_rfe <- bc_data_3_train[, c(1, which(colnames(bc_data_3_train) %in% predictors(results_3)))]
{% endhighlight %}

### Genetic Algorithm (GA)

유전 알고리즘은 자연 선택의 진화 이론에 근거하여 개발되었다. 


{% highlight r linenos %}
library(dplyr)

ga_ctrl <- gafsControl(functions = rfGA, # Assess fitness with RF
                       method = "cv",    # 10 fold cross validation
                       genParallel = TRUE, # Use parallel programming
                       allowParallel = TRUE)
{% endhighlight %}

- Dataset 1


{% highlight r linenos %}
lev <- c("malignant", "benign")     # Set the levels

set.seed(27)
model_1 <- gafs(x = bc_data_train[, -1], y = bc_data_train$classes,
                   iters = 10, # generations of algorithm
                   popSize = 5, # population size for each generation
                   levels = lev,
                   gafsControl = ga_ctrl)

plot(model_1) # Plot mean fitness (AUC) by generation
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-47-1.png" title="plot of chunk unnamed-chunk-47" alt="plot of chunk unnamed-chunk-47" width="360" style="display: block; margin: auto;" />


{% highlight r linenos %}
model_1$ga$final
{% endhighlight %}



{% highlight text %}
[1] "clump_thickness"             "uniformity_of_cell_shape"   
[3] "marginal_adhesion"           "single_epithelial_cell_size"
[5] "bare_nuclei"                 "normal_nucleoli"            
[7] "mitosis"                    
{% endhighlight %}


{% highlight r linenos %}
bc_data_ga <- bc_data_train[, c(1, which(colnames(bc_data_train) %in% model_1$ga$final))]
{% endhighlight %}

- Dataset 2


{% highlight r linenos %}
lev <- c("M", "B")

set.seed(27)
model_2 <- gafs(x = bc_data_2_train[, -c(1, 2)], y = bc_data_2_train$diagnosis,
                   iters = 10, # generations of algorithm
                   popSize = 5, # population size for each generation
                   levels = lev,
                   gafsControl = ga_ctrl)

plot(model_2)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-50-1.png" title="plot of chunk unnamed-chunk-50" alt="plot of chunk unnamed-chunk-50" width="360" style="display: block; margin: auto;" />


{% highlight r linenos %}
model_2$ga$final
{% endhighlight %}



{% highlight text %}
 [1] "radius_mean"                     "texture_mean"                   
 [3] "area_mean"                       "smoothness_mean"                
 [5] "compactness_mean"                "concavity_mean"                 
 [7] "symmetry_mean"                   "fractal_dimension_mean"         
 [9] "texture_se"                      "perimeter_se"                   
[11] "area_se"                         "smoothness_se"                  
[13] "compactness_se"                  "concavity_se"                   
[15] "concave_points_se"               "symmetry_se"                    
[17] "radius_largest_worst"            "texture_largest_worst"          
[19] "perimeter_largest_worst"         "area_largest_worst"             
[21] "smoothness_largest_worst"        "compactness_largest_worst"      
[23] "concavity_largest_worst"         "concave_points_largest_worst"   
[25] "symmetry_largest_worst"          "fractal_dimension_largest_worst"
{% endhighlight %}


{% highlight r linenos %}
bc_data_2_ga <- bc_data_2_train[, c(2, which(colnames(bc_data_2_train) %in% model_2$ga$final))]
{% endhighlight %}

- Dataset 3


{% highlight r linenos %}
lev <- c("R", "N")

set.seed(27)
model_3 <- gafs(x = bc_data_3_train[, -1], y = bc_data_3_train$outcome,
                   iters = 10, # generations of algorithm
                   popSize = 5, # population size for each generation
                   levels = lev,
                   gafsControl = ga_ctrl)
plot(model_3)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-53-1.png" title="plot of chunk unnamed-chunk-53" alt="plot of chunk unnamed-chunk-53" width="360" style="display: block; margin: auto;" />


{% highlight r linenos %}
model_3$ga$final
{% endhighlight %}



{% highlight text %}
 [1] "time"                            "perimeter_mean"                 
 [3] "radius_se"                       "texture_se"                     
 [5] "texture_largest_worst"           "smoothness_largest_worst"       
 [7] "concavity_largest_worst"         "concave_points_largest_worst"   
 [9] "fractal_dimension_largest_worst" "tumor_size"                     
[11] "lymph_node_status"              
{% endhighlight %}


{% highlight r linenos %}
bc_data_3_ga <- bc_data_3_train[, c(1, which(colnames(bc_data_3_train) %in% model_3$ga$final))]
{% endhighlight %}

### Boruta Analysis

- Dataset 1


{% highlight r linenos %}
library(Boruta)

set.seed(27)
bor_1 <- Boruta(classes ~ ., data = bc_data_train)
bor_1
{% endhighlight %}



{% highlight text %}
Boruta performed 10 iterations in 0.937906 secs.
 9 attributes confirmed important: bare_nuclei, bland_chromatin,
clump_thickness, marginal_adhesion, mitosis and 4 more.
 No attributes deemed unimportant.
{% endhighlight %}


{% highlight r linenos %}
plot(bor_1)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-57-1.png" title="plot of chunk unnamed-chunk-57" alt="plot of chunk unnamed-chunk-57" width="864" style="display: block; margin: auto;" />



{% highlight r linenos %}
bc_data_bor <- bc_data_train[, c("classes", getSelectedAttributes(bor_1))]
{% endhighlight %}

- Dataset 2


{% highlight r linenos %}
set.seed(27)
bor_2 <- Boruta(diagnosis ~ ., data = bc_data_2_train[, -1])
bor_2
{% endhighlight %}



{% highlight text %}
Boruta performed 99 iterations in 18.61058 secs.
 26 attributes confirmed important: area_largest_worst, area_mean,
area_se, compactness_largest_worst, compactness_mean and 21 more.
 3 attributes confirmed unimportant: smoothness_se, symmetry_se,
texture_se.
 1 tentative attributes left: fractal_dimension_mean.
{% endhighlight %}


{% highlight r linenos %}
plot(bor_2)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-60-1.png" title="plot of chunk unnamed-chunk-60" alt="plot of chunk unnamed-chunk-60" width="864" style="display: block; margin: auto;" />



{% highlight r linenos %}
bc_data_2_bor <- bc_data_2_train[, c("diagnosis", getSelectedAttributes(bor_2))]
{% endhighlight %}

- Dataset 3


{% highlight r linenos %}
set.seed(27)
bor_3 <- Boruta(outcome ~ ., data = bc_data_3_train, maxRuns = 500)
bor_3
{% endhighlight %}



{% highlight text %}
Boruta performed 499 iterations in 19.98457 secs.
 2 attributes confirmed important: lymph_node_status, time.
 30 attributes confirmed unimportant: area_largest_worst,
area_mean, area_se, compactness_largest_worst, compactness_mean
and 25 more.
 1 tentative attributes left: concave_points_se.
{% endhighlight %}


{% highlight r linenos %}
plot(bor_3)
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-63-1.png" title="plot of chunk unnamed-chunk-63" alt="plot of chunk unnamed-chunk-63" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
bc_data_3_bor <- bc_data_3_train[, c("outcome", getSelectedAttributes(bor_3))]
{% endhighlight %}


### Model comparison

##### All features

- Dataset 1


{% highlight r linenos %}
set.seed(27)
model_bc_data_all <- train(classes ~ .,
                           data = bc_data_train,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))
{% endhighlight %}


{% highlight r linenos %}
cm_all_1 <- confusionMatrix(predict(model_bc_data_all, bc_data_test[, -1]), bc_data_test$classes)
cm_all_1
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

           Reference
Prediction  benign malignant
  benign       134         5
  malignant      3        67
                                         
               Accuracy : 0.9617         
                 95% CI : (0.926, 0.9833)
    No Information Rate : 0.6555         
    P-Value [Acc > NIR] : <2e-16         
                                         
                  Kappa : 0.9147         
 Mcnemar's Test P-Value : 0.7237         
                                         
            Sensitivity : 0.9781         
            Specificity : 0.9306         
         Pos Pred Value : 0.9640         
         Neg Pred Value : 0.9571         
             Prevalence : 0.6555         
         Detection Rate : 0.6411         
   Detection Prevalence : 0.6651         
      Balanced Accuracy : 0.9543         
                                         
       'Positive' Class : benign         
                                         
{% endhighlight %}

- Dataset 2


{% highlight r linenos %}
set.seed(27)
model_bc_data_2_all <- train(diagnosis ~ .,
                           data = bc_data_2_train[, -1],
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))
{% endhighlight %}


{% highlight r linenos %}
cm_all_2 <- confusionMatrix(predict(model_bc_data_2_all, bc_data_2_test[, -c(1, 2)]), bc_data_2_test$diagnosis)
cm_all_2
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction   B   M
         B 106   5
         M   1  58
                                          
               Accuracy : 0.9647          
                 95% CI : (0.9248, 0.9869)
    No Information Rate : 0.6294          
    P-Value [Acc > NIR] : <2e-16          
                                          
                  Kappa : 0.9233          
 Mcnemar's Test P-Value : 0.2207          
                                          
            Sensitivity : 0.9907          
            Specificity : 0.9206          
         Pos Pred Value : 0.9550          
         Neg Pred Value : 0.9831          
             Prevalence : 0.6294          
         Detection Rate : 0.6235          
   Detection Prevalence : 0.6529          
      Balanced Accuracy : 0.9556          
                                          
       'Positive' Class : B               
                                          
{% endhighlight %}

- Dataset 3


{% highlight r linenos %}
set.seed(27)
model_bc_data_3_all <- train(outcome ~ .,
                           data = bc_data_3_train,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))
{% endhighlight %}


{% highlight r linenos %}
cm_all_3 <- confusionMatrix(predict(model_bc_data_3_all, bc_data_3_test[, -1]), bc_data_3_test$outcome)
cm_all_3
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction  N  R
         N 42  7
         R  3  7
                                          
               Accuracy : 0.8305          
                 95% CI : (0.7103, 0.9156)
    No Information Rate : 0.7627          
    P-Value [Acc > NIR] : 0.1408          
                                          
                  Kappa : 0.4806          
 Mcnemar's Test P-Value : 0.3428          
                                          
            Sensitivity : 0.9333          
            Specificity : 0.5000          
         Pos Pred Value : 0.8571          
         Neg Pred Value : 0.7000          
             Prevalence : 0.7627          
         Detection Rate : 0.7119          
   Detection Prevalence : 0.8305          
      Balanced Accuracy : 0.7167          
                                          
       'Positive' Class : N               
                                          
{% endhighlight %}

### Selected features

##### Dataset 1

- Correlation


{% highlight r linenos %}
set.seed(27)
model_bc_data_cor <- train(classes ~ .,
                 data = bc_data_cor,
                 method = "rf",
                 preProcess = c("scale", "center"),
                 trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_cor_1 <- confusionMatrix(predict(model_bc_data_cor, bc_data_test[, -1]), bc_data_test$classes)

cm_cor_1
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

           Reference
Prediction  benign malignant
  benign       131         6
  malignant      6        66
                                        
               Accuracy : 0.9426        
                 95% CI : (0.9019, 0.97)
    No Information Rate : 0.6555        
    P-Value [Acc > NIR] : <2e-16        
                                        
                  Kappa : 0.8729        
 Mcnemar's Test P-Value : 1             
                                        
            Sensitivity : 0.9562        
            Specificity : 0.9167        
         Pos Pred Value : 0.9562        
         Neg Pred Value : 0.9167        
             Prevalence : 0.6555        
         Detection Rate : 0.6268        
   Detection Prevalence : 0.6555        
      Balanced Accuracy : 0.9364        
                                        
       'Positive' Class : benign        
                                        
{% endhighlight %}

- RFE


{% highlight r linenos %}
set.seed(27)
model_bc_data_rfe <- train(classes ~ .,
                           data = bc_data_rfe,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_rfe_1 <- confusionMatrix(predict(model_bc_data_rfe, bc_data_test[, -1]), bc_data_test$classes)
cm_rfe_1
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

           Reference
Prediction  benign malignant
  benign       134         4
  malignant      3        68
                                          
               Accuracy : 0.9665          
                 95% CI : (0.9322, 0.9864)
    No Information Rate : 0.6555          
    P-Value [Acc > NIR] : <2e-16          
                                          
                  Kappa : 0.9256          
 Mcnemar's Test P-Value : 1               
                                          
            Sensitivity : 0.9781          
            Specificity : 0.9444          
         Pos Pred Value : 0.9710          
         Neg Pred Value : 0.9577          
             Prevalence : 0.6555          
         Detection Rate : 0.6411          
   Detection Prevalence : 0.6603          
      Balanced Accuracy : 0.9613          
                                          
       'Positive' Class : benign          
                                          
{% endhighlight %}

- GA


{% highlight r linenos %}
set.seed(27)
model_bc_data_ga <- train(classes ~ .,
                           data = bc_data_ga,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_ga_1 <- confusionMatrix(predict(model_bc_data_ga, bc_data_test[, -1]), bc_data_test$classes)
cm_ga_1
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

           Reference
Prediction  benign malignant
  benign       134         2
  malignant      3        70
                                          
               Accuracy : 0.9761          
                 95% CI : (0.9451, 0.9922)
    No Information Rate : 0.6555          
    P-Value [Acc > NIR] : <2e-16          
                                          
                  Kappa : 0.9472          
 Mcnemar's Test P-Value : 1               
                                          
            Sensitivity : 0.9781          
            Specificity : 0.9722          
         Pos Pred Value : 0.9853          
         Neg Pred Value : 0.9589          
             Prevalence : 0.6555          
         Detection Rate : 0.6411          
   Detection Prevalence : 0.6507          
      Balanced Accuracy : 0.9752          
                                          
       'Positive' Class : benign          
                                          
{% endhighlight %}

- Boruta


{% highlight r linenos %}
set.seed(27)
model_bc_data_bor <- train(classes ~ .,
                           data = bc_data_bor,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_bor_1 <- confusionMatrix(predict(model_bc_data_bor, bc_data_test[, -1]), bc_data_test$classes)
cm_bor_1
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

           Reference
Prediction  benign malignant
  benign       134         5
  malignant      3        67
                                         
               Accuracy : 0.9617         
                 95% CI : (0.926, 0.9833)
    No Information Rate : 0.6555         
    P-Value [Acc > NIR] : <2e-16         
                                         
                  Kappa : 0.9147         
 Mcnemar's Test P-Value : 0.7237         
                                         
            Sensitivity : 0.9781         
            Specificity : 0.9306         
         Pos Pred Value : 0.9640         
         Neg Pred Value : 0.9571         
             Prevalence : 0.6555         
         Detection Rate : 0.6411         
   Detection Prevalence : 0.6651         
      Balanced Accuracy : 0.9543         
                                         
       'Positive' Class : benign         
                                         
{% endhighlight %}

##### Dataset 2

- Correlation


{% highlight r linenos %}
set.seed(27)
model_bc_data_2_cor <- train(diagnosis ~ .,
                           data = bc_data_2_cor[, -1],
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_cor_2 <- confusionMatrix(predict(model_bc_data_2_cor, bc_data_2_test[, -c(1, 2)]), bc_data_2_test$diagnosis)

cm_cor_2
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction   B   M
         B 106   6
         M   1  57
                                         
               Accuracy : 0.9588         
                 95% CI : (0.917, 0.9833)
    No Information Rate : 0.6294         
    P-Value [Acc > NIR] : <2e-16         
                                         
                  Kappa : 0.9103         
 Mcnemar's Test P-Value : 0.1306         
                                         
            Sensitivity : 0.9907         
            Specificity : 0.9048         
         Pos Pred Value : 0.9464         
         Neg Pred Value : 0.9828         
             Prevalence : 0.6294         
         Detection Rate : 0.6235         
   Detection Prevalence : 0.6588         
      Balanced Accuracy : 0.9477         
                                         
       'Positive' Class : B              
                                         
{% endhighlight %}

- RFE


{% highlight r linenos %}
set.seed(27)
model_bc_data_2_rfe <- train(diagnosis ~ .,
                           data = bc_data_2_rfe,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_rfe_2 <- confusionMatrix(predict(model_bc_data_2_rfe, bc_data_2_test[, -c(1, 2)]), bc_data_2_test$diagnosis)
cm_rfe_2
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction   B   M
         B 105   5
         M   2  58
                                         
               Accuracy : 0.9588         
                 95% CI : (0.917, 0.9833)
    No Information Rate : 0.6294         
    P-Value [Acc > NIR] : <2e-16         
                                         
                  Kappa : 0.9109         
 Mcnemar's Test P-Value : 0.4497         
                                         
            Sensitivity : 0.9813         
            Specificity : 0.9206         
         Pos Pred Value : 0.9545         
         Neg Pred Value : 0.9667         
             Prevalence : 0.6294         
         Detection Rate : 0.6176         
   Detection Prevalence : 0.6471         
      Balanced Accuracy : 0.9510         
                                         
       'Positive' Class : B              
                                         
{% endhighlight %}

- GA


{% highlight r linenos %}
set.seed(27)
model_bc_data_2_ga <- train(diagnosis ~ .,
                          data = bc_data_2_ga,
                          method = "rf",
                          preProcess = c("scale", "center"),
                          trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_ga_2 <- confusionMatrix(predict(model_bc_data_2_ga, bc_data_2_test[, -c(1, 2)]), bc_data_2_test$diagnosis)
cm_ga_2
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction   B   M
         B 105   5
         M   2  58
                                         
               Accuracy : 0.9588         
                 95% CI : (0.917, 0.9833)
    No Information Rate : 0.6294         
    P-Value [Acc > NIR] : <2e-16         
                                         
                  Kappa : 0.9109         
 Mcnemar's Test P-Value : 0.4497         
                                         
            Sensitivity : 0.9813         
            Specificity : 0.9206         
         Pos Pred Value : 0.9545         
         Neg Pred Value : 0.9667         
             Prevalence : 0.6294         
         Detection Rate : 0.6176         
   Detection Prevalence : 0.6471         
      Balanced Accuracy : 0.9510         
                                         
       'Positive' Class : B              
                                         
{% endhighlight %}

- Boruta


{% highlight r linenos %}
set.seed(27)
model_bc_data_2_bor <- train(diagnosis ~ .,
                          data = bc_data_2_bor,
                          method = "rf",
                          preProcess = c("scale", "center"),
                          trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_bor_2 <- confusionMatrix(predict(model_bc_data_2_bor, bc_data_2_test[, -c(1, 2)]), bc_data_2_test$diagnosis)
cm_bor_2
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction   B   M
         B 105   4
         M   2  59
                                          
               Accuracy : 0.9647          
                 95% CI : (0.9248, 0.9869)
    No Information Rate : 0.6294          
    P-Value [Acc > NIR] : <2e-16          
                                          
                  Kappa : 0.9238          
 Mcnemar's Test P-Value : 0.6831          
                                          
            Sensitivity : 0.9813          
            Specificity : 0.9365          
         Pos Pred Value : 0.9633          
         Neg Pred Value : 0.9672          
             Prevalence : 0.6294          
         Detection Rate : 0.6176          
   Detection Prevalence : 0.6412          
      Balanced Accuracy : 0.9589          
                                          
       'Positive' Class : B               
                                          
{% endhighlight %}

##### Dataset 3

- Correlation


{% highlight r linenos %}
set.seed(27)
model_bc_data_3_cor <- train(outcome ~ .,
                           data = bc_data_3_cor,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_cor_3 <- confusionMatrix(predict(model_bc_data_3_cor, bc_data_3_test[, -1]), bc_data_3_test$outcome)
cm_cor_3
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction  N  R
         N 41  7
         R  4  7
                                          
               Accuracy : 0.8136          
                 95% CI : (0.6909, 0.9031)
    No Information Rate : 0.7627          
    P-Value [Acc > NIR] : 0.2256          
                                          
                  Kappa : 0.4439          
 Mcnemar's Test P-Value : 0.5465          
                                          
            Sensitivity : 0.9111          
            Specificity : 0.5000          
         Pos Pred Value : 0.8542          
         Neg Pred Value : 0.6364          
             Prevalence : 0.7627          
         Detection Rate : 0.6949          
   Detection Prevalence : 0.8136          
      Balanced Accuracy : 0.7056          
                                          
       'Positive' Class : N               
                                          
{% endhighlight %}

- RFE


{% highlight r linenos %}
set.seed(27)
model_bc_data_3_rfe <- train(outcome ~ .,
                           data = bc_data_3_rfe,
                           method = "rf",
                           preProcess = c("scale", "center"),
                           trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))

cm_rfe_3 <- confusionMatrix(predict(model_bc_data_3_rfe, bc_data_3_test[, -1]), bc_data_3_test$outcome)
cm_rfe_3
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction  N  R
         N 43  7
         R  2  7
                                          
               Accuracy : 0.8475          
                 95% CI : (0.7301, 0.9278)
    No Information Rate : 0.7627          
    P-Value [Acc > NIR] : 0.07964         
                                          
                  Kappa : 0.5195          
 Mcnemar's Test P-Value : 0.18242         
                                          
            Sensitivity : 0.9556          
            Specificity : 0.5000          
         Pos Pred Value : 0.8600          
         Neg Pred Value : 0.7778          
             Prevalence : 0.7627          
         Detection Rate : 0.7288          
   Detection Prevalence : 0.8475          
      Balanced Accuracy : 0.7278          
                                          
       'Positive' Class : N               
                                          
{% endhighlight %}

- GA


{% highlight r linenos %}
set.seed(27)
model_bc_data_3_ga <- train(outcome ~ .,
                          data = bc_data_3_ga,
                          method = "rf",
                          preProcess = c("scale", "center"),
                          trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))
cm_ga_3 <- confusionMatrix(predict(model_bc_data_3_ga, bc_data_3_test[, -1]), bc_data_3_test$outcome)
cm_ga_3
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction  N  R
         N 39  6
         R  6  8
                                          
               Accuracy : 0.7966          
                 95% CI : (0.6717, 0.8902)
    No Information Rate : 0.7627          
    P-Value [Acc > NIR] : 0.3311          
                                          
                  Kappa : 0.4381          
 Mcnemar's Test P-Value : 1.0000          
                                          
            Sensitivity : 0.8667          
            Specificity : 0.5714          
         Pos Pred Value : 0.8667          
         Neg Pred Value : 0.5714          
             Prevalence : 0.7627          
         Detection Rate : 0.6610          
   Detection Prevalence : 0.7627          
      Balanced Accuracy : 0.7190          
                                          
       'Positive' Class : N               
                                          
{% endhighlight %}

- Boruta


{% highlight r linenos %}
set.seed(27)
model_bc_data_3_bor <- train(outcome ~ .,
                          data = bc_data_3_bor,
                          method = "rf",
                          preProcess = c("scale", "center"),
                          trControl = trainControl(method = "repeatedcv", number = 5, repeats = 10, verboseIter = FALSE))
{% endhighlight %}



{% highlight text %}
note: only 1 unique complexity parameters in default grid. Truncating the grid to 1 .
{% endhighlight %}



{% highlight r linenos %}
cm_bor_3 <- confusionMatrix(predict(model_bc_data_3_bor, bc_data_3_test[, -1]), bc_data_3_test$outcome)
cm_bor_3
{% endhighlight %}



{% highlight text %}
Confusion Matrix and Statistics

          Reference
Prediction  N  R
         N 34 10
         R 11  4
                                          
               Accuracy : 0.6441          
                 95% CI : (0.5087, 0.7645)
    No Information Rate : 0.7627          
    P-Value [Acc > NIR] : 0.9864          
                                          
                  Kappa : 0.0403          
 Mcnemar's Test P-Value : 1.0000          
                                          
            Sensitivity : 0.7556          
            Specificity : 0.2857          
         Pos Pred Value : 0.7727          
         Neg Pred Value : 0.2667          
             Prevalence : 0.7627          
         Detection Rate : 0.5763          
   Detection Prevalence : 0.7458          
      Balanced Accuracy : 0.5206          
                                          
       'Positive' Class : N               
                                          
{% endhighlight %}

### Overall model parameters


{% highlight r linenos %}
overall <- data.frame(dataset = rep(c("1", "2", "3"), each = 5),
                      model = rep(c("all", "cor", "rfe", "ga", "bor"), 3),
                      rbind(cm_all_1$overall,
                      cm_cor_1$overall,
                      cm_rfe_1$overall,
                      cm_ga_1$overall,
                      cm_bor_1$overall,
                      cm_all_2$overall,
                      cm_cor_2$overall,
                      cm_rfe_2$overall,
                      cm_ga_2$overall,
                      cm_bor_2$overall,
                      cm_all_3$overall,
                      cm_cor_3$overall,
                      cm_rfe_3$overall,
                      cm_ga_3$overall,
                      cm_bor_3$overall))

library(tidyr)
overall_gather <- overall[, 1:4] %>%
  gather(measure, value, Accuracy:Kappa)
{% endhighlight %}


{% highlight r linenos %}
byClass <- data.frame(dataset = rep(c("1", "2", "3"), each = 5),
                      model = rep(c("all", "cor", "rfe", "ga", "bor"), 3),
                      rbind(cm_all_1$byClass,
                      cm_cor_1$byClass,
                      cm_rfe_1$byClass,
                      cm_ga_1$byClass,
                      cm_bor_1$byClass,
                      cm_all_2$byClass,
                      cm_cor_2$byClass,
                      cm_rfe_2$byClass,
                      cm_ga_2$byClass,
                      cm_bor_2$byClass,
                      cm_all_3$byClass,
                      cm_cor_3$byClass,
                      cm_rfe_3$byClass,
                      cm_ga_3$byClass,
                      cm_bor_3$byClass))

byClass_gather <- byClass[, c(1:4, 7)] %>%
  gather(measure, value, Sensitivity:Precision)
{% endhighlight %}


{% highlight r linenos %}
overall_byClass_gather <- rbind(overall_gather, byClass_gather)
overall_byClass_gather <- within(overall_byClass_gather, model <- factor(model, levels = c("all", "cor", "rfe", "ga", "bor")))
overall_byClass_gather$measure <- factor(overall_byClass_gather$measure,
                                         levels = c("Accuracy", "Kappa", "Sensitivity", "Specificity", "Precision"))

ggplot(overall_byClass_gather, aes(x = model, y = value, color = measure, shape = measure, group = measure)) +
    geom_point(size = 4, alpha = 0.8) +
    geom_path(alpha = 0.7) +
    scale_colour_brewer(palette = "Set1") +
    facet_grid(dataset ~ ., scales = "free_y") +
    labs(
        x = "Feature Selection method",
        y = "Value",
        color = "",
        shape = "",
        title = "Comparison of feature selection methods",
        subtitle = "in three breast cancer datasets",
        caption = "\nBreast Cancer Wisconsin (Diagnostic) Data Sets: 1, 2 & 3
    Street et al., 1993;
    all: no feature selection
    cor: features with correlation > 0.7 removed
    rfe: Recursive Feature Elimination
    ga: Genetic Algorithm
    bor: Boruta Algorithm"
    )
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-85-1.png" title="plot of chunk unnamed-chunk-85" alt="plot of chunk unnamed-chunk-85" width="864" style="display: block; margin: auto;" />


{% highlight r linenos %}
ggplot(overall_byClass_gather, aes(x = measure, y = value, color = model, shape = model, group = model)) +
    geom_point(size = 4, alpha = 0.8) +
    geom_path(alpha = 0.7) +
    scale_colour_brewer(palette = "Set1") +
    facet_grid(dataset ~ ., scales = "free_y") +
    labs(
        x = "Feature Selection method",
        y = "Value",
        color = "",
        shape = "",
        title = "Comparison of feature selection methods",
        subtitle = "in three breast cancer datasets",
        caption = "\nBreast Cancer Wisconsin (Diagnostic) Data Sets: 1, 2 & 3
    Street et al., 1993;
    all: no feature selection
    cor: features with correlation > 0.7 removed
    rfe: Recursive Feature Elimination
    ga: Genetic Algorithm
    bor: Boruta Algorithm"
    )
{% endhighlight %}

<img src="/assets/article_images/2017-01-16-feature-selection/unnamed-chunk-86-1.png" title="plot of chunk unnamed-chunk-86" alt="plot of chunk unnamed-chunk-86" width="864" style="display: block; margin: auto;" />

### Conclusions

샘플 클래스에 대한 PCA 결과 (유방암의 재발/비재발 여부는 적절한 군집화가 되지 않는다.)에서도 예상했듯이, 데이터셋 3에 대한 랜덤 포레스트 모델은 데이터셋 1과 데이터셋 2에 대한 모델 정확도보다 낮은 정확도를 보여주었다.

상관계수를 이용한 기법은 변수 중요성과는 상관없이 작동하였다. 다시 말해, 데이터셋 1에 대해서는 높은 중요성의 변수들은 높은 상관계수를 가지고 있었다. 상관계수 기법은 세 데이터셋 모두 가장 낮은 성능을 보여주었다. RFE와 GA는 높은 변수 중요성을 갖는 변수들을 포함하려는 경향은 있으나, 변수 중요성 홀로  결과물을 예측할 때 몇몇 변수들이 조합하여 잘 작동하는지를 나타내는 좋은 지표가 되지는 못한다.

데이터셋 1은 아홉 개의 변수를 가지고 있었으며, 상관계수 기법은 가장 실망스러운 성능을 보여주었다. RFE와 GA 모두 변수 선택을 하지 않은 것보다 더 나은 성능을 보여주었으며, 그 중에서도 GA가 가장 좋은 성능을 보여주었다. 데이터셋 2는 30개의 변수를 갖고 있으며, GA가 가장 좋은 성능을 보여주었다. 마지막으로 데이터셋 3은 전체적으로 낮은 정확도를 모여주었으며, 각각의 변수 선택 기법들이 그리 좋은 성능을 보여주진 못했다.
