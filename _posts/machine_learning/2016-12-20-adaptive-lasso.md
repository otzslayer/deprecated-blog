---
title: "Adaptive Lasso"
author: "Jaeyoon Han"
date: '2016-12-20'
output: html_document
layout: post
image: /assets/article_images/2016-12-20-adaptive-lasso/title.jpg
categories: R
---





## Preliminary

1. 머신러닝을 공부하면서 Kaggle을 접하고, 다양한 알고리즘에 대해 얕게나마 알게 되었다. 처음 공부할 때는 알고리즘의 겉만 핥은 채로 R에서 구현된 함수를 이용해서 문제를 해결했다. 이래도 되겠거니 싶었지만, 결국 알고리즘의 수학적 특성과 코어(core)를 알지 못하면 아무리 소프트웨어에서 편한 방식으로 알고리즘을 제공하더라도 더 나은 성능을 얻기 힘들다는 결론에 다다르게 되었다. 
이런 생각을 가질 수 있도록 만든 알고리즘은 XGBoost 였다. 다양한 파라미터가 어떻게 작동하는 지도 모른 채 맹목적으로 사용해왔다. Kaggle에서 Kobe Shot Selection 대회에서 이렇게 맹목적으로 알고리즘을 사용했음에도 상위 6%라는 성적을 얻었지만, 이는 분명 개선의 여지가 있었다고 생각한다. 당시에는 Bias-Variance Trade-offs 에 대한 생각도 많이 해보지 않았었고, CV의 중요성도 깨닫지 못했었다. 물론 지금은 완전 다르지만. 요즘은 어떤 알고리즘을 사용해보기 전에 그 논문을 자세히 들여다보지 않으면 절대 사용하지 않는다. 그래서 최근엔 XGBoost의 사용을 최대한 자제하고 있다.

2. 처음 머신러닝을 접하고 자주 사용했던 알고리즘은 랜덤 포레스트(random forest)였다. 단순해보이면서 의사결정나무의 단점을 보완하는 예측력은 정말 매력적으로 다가왔다. 그 이후로도 계속해서 Tree-based methods에 관심을 가지게 되었고, Kaggle을 본격적으로 하면서는 RF와 XGBoost를 즐겨 사용했다. 하지만 어느 순간 파라미터 튜닝에만 목을 매고 있는 모습을 발견하면서 조금 거리를 두고 있다.
이와 동시에 최근 관심사가 바뀌기 시작했는데 바로 Lasso다. 올해 반년 동안 진행했던 프로젝트에서 발군의 성능을 보이며 프로젝트를 성공으로 이끌었던 알고리즘인데, 이 알고리즘에 대한 설명은 [위키피디아 페이지](https://en.wikipedia.org/wiki/Lasso_(statistics))로 대체하고자 한다.

3. Lasso의 Variable Selection은 기존 stepwise elimination의 여러 단점을 충분히 보완하고 남는다고 생각하며, 예측력 역시 출중하다고 생각한다. 하지만 이와 동시에 의심되었던건 '정말 variable selection이 올바르게 되었느냐'라는건데, 답을 얻지 못하고 있었다. 현재도 개설되어 있는 Kaggle 대회 중 House Price 예측과 관련한 대회에서 이 질문에 대해 깊이 있게 생각하게 되었다.
Tuning parameter인 $\lambda$는 CV에 의해 적절한 값으로 설정되는데, 어느날 한 번은 CV에 의한 값에서 테스트 데이터에 맞춰 더 튜닝을 해봤다. 물론 잘못된 행동임을 알았지만 실험을 해보고 싶었다. $\lambda$값 차이가 크지 않았음에도 불구하고 과연 서로 다른 값에 의해 선택된 feature들이 얼마나 다를까 궁금했으니까. 결론적으로는 굉장히 달랐다. 삭제되는 변수만 다른게 아니라 살아남은 변수들 사이의 계수추정치까지 아예 뒤집혔다. 
결국 스스로 'CV에 의해 나온 $\lambda$값으로 얻은 feature들이 적절하게 걸러진 결과물이다'라고 결론을 내렸다. 최근 feature selection 기능으로 인해 가끔 언급되는 Boruta 알고리즘의 결과와 유사했기 때문이었다.

4. 이런저런 일이 있고 나서 Adaptive lasso에 대해서 알게 되었다. 해당 논문에선 Lasso의 몇몇 문제점을 지적하며 feature selection 기능을 보완하는 기법을 제안한다. 매우 재밌게 읽은 논문이고, 스스로 공부한 부분이 맞는지 검증하는 차원에서 본 포스팅으로 논문 summary를 공유한다. 논문에 실린 몇몇 theorem들과 증명은 포스팅하지 않는다. 만약 이 글이 너무 conceptual하다면 해당 논문을 직접 보길 권장한다.

---

## Summary: The Adaptive Lasso and Its Oracle Properties (Zou, H., 2006)

#### Introduction

- Two fundamental goals in statistical learning:
	- Ensuring high prediction accuracy
	- Discovering relevant predictive variables

- The *oracle* property
	- Denote by $\hat{\beta}(\delta)$ the coefficient estimator produced by a fitting procedure $\delta$.
	- We call $\delta$ an *oracle* procedure if $\hat{\beta}(\delta)$ (asymptotically) has the following oracle properties:
		- Identifies the right subset model, $\{j : \hat{\beta}_j \neq 0\} = \mathcal{A}$
		- Asymptotic normality: Has the optimal estimation rate, $$ \sqrt{n}(\hat{\beta}(\delta)_\mathcal{A} - \beta^*_\mathcal{A}) \to_d N(0, \Sigma^*), $$ where $\Sigma^*$ is the covariance matrix knowing the true subset model. [Wikipedia (Asymptotic normality)](https://ko.wikipedia.org/wiki/%EC%B6%94%EC%A0%95%EB%9F%89#.EC.9D.BC.EC.B9.98.EC.84.B1.EA.B3.BC_.EC.A0.90.EA.B7.BC.EC.A0.81_.EC.A0.95.EA.B7.9C.EC.84.B1)
	- A good procedure should have these oracle properties.

- Some problems of LASSO
	- The lasso shrinkage produces biased estimates for the large coefficients, and thus it could be suboptimal in terms of estimation risk. [Fan and Li, 2001] 
		- They also proposed a smoothly clipped absolute deviation (SCAD) penalty for variable selection and proved its oracle properties.
	- There is the conflict of optimal prediction and consistent variable selection in the lasso. [Meinshausen and Bühlmann, 2004]
		- The optimal $\lambda$ for prediction gives inconsistent variable selection results; in fact, many noise features are included in the predictive model.

---

#### Adaptive Lasso

- Adaptive Lasso
	- Let us consider the weighted lasso,
	
	$$\underset{\beta}{\arg\min} \left\| y - \sum^p_{j=1} x_j \beta_j \right\|^2 + \lambda \sum^p_{j=1} w_j |\beta_j|,$$
	
	where $w$ is a known weights vector. If the weights are data-dependent and cleverly chosen, then the weighted lasso can have the oracle properties.
	
	- Definition of Adaptive Lasso
		- The adaptive lasso estimates $\hat{\beta}^{*(n)}$ are given by
		
		$$ \hat{\beta}^{*(n)} = \underset{\beta}{\arg\min} \left\| y - \sum^p_{j=1} x_j \beta_j \right\|^2 + \lambda_n \sum^p_{j=1} \hat{w_j}|\beta_j|. $$
		
		- The weight vector

		$$\hat{w} = \frac{1}{|\hat{\beta}|^\gamma},$$
		
		which can be used $\hat{\beta}(\text{ols})$ or $\hat{\beta}(\text{ridge})$.
		
		- Note that
		
		$$\mathcal{A}^*_n = \{j : \hat{\beta}_j^{*(n)} \neq 0 \}$$
		
	- *Theorem 2* (Oracle properties). Suppose that $\lambda_n/\sqrt{n} \to 0$ and $\lambda_n n^{(\gamma-1)/2)} \to \infty$. Then the adaptive lasso estimates must satisfy the following:
		1. Consistency in variable selection: $\lim_n P(\mathcal{A}_n^* = \mathcal{A}) = 1$
		2. Asymptotic normality:
		
		$$\sqrt{n} (\hat{\beta}_\mathcal{A}^{*(n)} - \hat{\beta}_\mathcal{A}^* )  \to_d N(0, \sigma^2 \times C^{-1}_{11}).$$ 
		
		- Theorem 2 shows that the $\ell_1$ penalty is at least as good as any other "oracle" penalty. 

<img src="/assets/images/AdaptiveLassoFigure1.png" title="Figure 1. Plot of Thresholding Function with $\lambda = 2$" alt="Figure 1. Plot of Thresholding Function with $\lambda = 2$" width="500pt" style="display: block; margin: auto;" />

- The above figure describes that thresholding functions with $\lambda = 2$ for (a) the Hard; (b) Bridge $L_{.5}$; (c) the Lasso; (d) the SCAD; (e) the Adpative Lasso $\gamma = .5$; and (f) the Adaptive Lasso $\gamma = 2$. 
- Parameter Tuning
	- If we use $\hat{\beta}(\text{ols})$ to construct the adaptive weights : find optimal pair of $(\gamma, \lambda_n)$. (Two-dimensional cross-validation)
	- We can choose $\hat{\beta}(\text{ridge})$ as $\hat{\beta}$. Especially, it suggest by the author when collinearity is a concern, because it is more stable than $\hat{\beta}(\text{ols})$.
	- Good range of $\gamma$ is $0.5, 1, 2$.

---

#### Comparison

- Comparison Targets: Lasso, Adaptive Lasso, SCAD, and Nonnegative garrote
- $p = 8$ and $p_0 = 3$. Consider a few large effects ($n = 20, 60$) and many small effects ($n = 40, 80$)
- Lasso performs best when the SNR is low.
- Adaptive Lasso, SCAD, and nonnegative garrote outperforms Lasso with a medium or low level of SNR.
- Adaptive Lasso tends to be more stable than SCAD.
- Lasso tends to select noise variables more often than other methods.

---

#### Adaptive Lasso in R


{% highlight r %}
library(ISLR)
data("Hitters")
Hitters <- na.omit(Hitters)
head(Hitters)
{% endhighlight %}



|                  | AtBat| Hits| HmRun| Runs| RBI| Walks| Years| CAtBat| CHits| CHmRun| CRuns| CRBI| CWalks|League |Division | PutOuts| Assists| Errors| Salary|NewLeague |
|:-----------------|-----:|----:|-----:|----:|---:|-----:|-----:|------:|-----:|------:|-----:|----:|------:|:------|:--------|-------:|-------:|------:|------:|:---------|
|-Alan Ashby       |   315|   81|     7|   24|  38|    39|    14|   3449|   835|     69|   321|  414|    375|N      |W        |     632|      43|     10|  475.0|N         |
|-Alvin Davis      |   479|  130|    18|   66|  72|    76|     3|   1624|   457|     63|   224|  266|    263|A      |W        |     880|      82|     14|  480.0|A         |
|-Andre Dawson     |   496|  141|    20|   65|  78|    37|    11|   5628|  1575|    225|   828|  838|    354|N      |E        |     200|      11|      3|  500.0|N         |
|-Andres Galarraga |   321|   87|    10|   39|  42|    30|     2|    396|   101|     12|    48|   46|     33|N      |E        |     805|      40|      4|   91.5|N         |
|-Alfredo Griffin  |   594|  169|     4|   74|  51|    35|    11|   4408|  1133|     19|   501|  336|    194|A      |W        |     282|     421|     25|  750.0|A         |
|-Al Newman        |   185|   37|     1|   23|   8|    21|     2|    214|    42|      1|    30|    9|     24|N      |E        |      76|     127|      7|   70.0|A         |

##### Data Preparation


{% highlight r %}
set.seed(1)
x <- model.matrix(Salary ~., Hitters)[, -1]
y <- Hitters$Salary
train <- sample(1:nrow(x), nrow(x)/2)
test <- -train
y.test <- y[test]
{% endhighlight %}

##### Implementation of Adaptive Lasso


{% highlight r %}
# Adaptive Lasso Function with Automatic 10-fold CV
adaLasso <- function(data, labels, parallel = TRUE, standardize = TRUE, weight, gamma = 1, formula = NULL, ols.data = NULL, lambda = NULL, seed = 1){
    require(glmnet)
    if(!(weight %in% c("ols", "ridge"))){
        message("The parameter 'weight' should be chosen either ols or ridge.")
        break
    }
    if(weight == "ols"){
        if(is.null(ols.data)){
            message("If you want to use the coefficients of OLS as the weight for Adaptive Lasso, you have to put a data.frame to ols.data argument.")
            break
        }
        ols <- lm(formula = formula, data = ols.data)
        weight <- 1/abs(as.matrix(coefficients(ols)[-1]))^gamma
    }
    if(weight == "ridge"){
        set.seed(seed)
        if(parallel)
            doMC::registerDoMC(cores = 4)
        
        cv.ridge <- cv.glmnet(x = data, y = labels, alpha = 0, parallel = parallel, standardize = standardize, lambda = lambda)
        weight <- 1/abs(matrix(coef(cv.ridge, s = cv.ridge$lambda.min)[-1, ]))^gamma
    }
    weight[,1][weight[, 1] == Inf] <- 999999999
    set.seed(seed)
    if(parallel)
        doMC::registerDoMC(cores = 4)
    cv.lasso <- cv.glmnet(x = data, y = labels, alpha = 1, parallel = parallel, standardize = standardize, lambda = lambda, penalty.factor = weight)
    lasso <- glmnet(x = data, y = labels, alpha = 1, standardize = standardize, lambda = cv.lasso$lambda.min, penalty.factor = weight)
    lasso
}
{% endhighlight %}


{% highlight r %}
adalasso <- adaLasso(data = x[train, ], labels = y[train], weight = "ridge", gamma = 1, seed = 1)
{% endhighlight %}
