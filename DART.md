# **DART: Dropouts meet Multiple Additive Regression Trees**[^1]



## 1. Introduction

- 부스팅(Boosting) 알고리즘은 현재 모델의 성능을 높이는 것에 중점을 두고 새로운 예측변수(predictor)를 추가함.
- 새로운 예측변수는 일반적으로 문제의 작은 부분에 초점을 맞추기 때문에 기존 문제에 대한 예측력을 측정할 때는 강력한 예측력을 가지지 못함. 더불어 특정 인스턴스에 대해 과적합(over-fit)을 야기함.
- 부스팅에서 후반부 반복에서 추가되는 트리들은 매우 적은 수의 인스턴스에 대한 예측에만 영향을 미치므로 나머지 모든 인스턴스들에 대한 예측에 대한 기여도가 매우 낮음.
  - 이러한 문제를 우리는 ==*over-specialization*== 이라고 부름.
  - MART에서 이 문제를 해결하기 위해 가장 일반적인 방법이 *shrinkage*를 사용했지만, 앙상블 크기가 일정 수준 커지면 over-specialization이 다시 발생함.
- 본 논문은 이를 해결하기 위해 ==*드롭아웃(dropout)*==을 도입함. 

## 2. Overcoming the Over-specialization in MART



[^1]: Rashmi, K. V., and Ran Gilad-Bachrach. "Dart: Dropouts meet multiple additive regression trees." *International Conference on Artificial Intelligence and Statistics*. 2015.

