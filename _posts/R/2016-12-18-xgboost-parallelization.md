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

다양한 파라미터를 튜닝하기 때문에 연산량이 제법 큰데, Python의 XGBoost의 경우 멀티쓰레딩과 관련한 문제는 발생하지 않는 것으로 알고 있다. 하지만 R의 경우 쓰레드의 개수가 20개를 넘어가는 순간 성능이 저하하거나, 심지어 OpenMP의 설치 유무와 상관없이 멀티쓰레딩이 되지 않는 경우가 있다.
