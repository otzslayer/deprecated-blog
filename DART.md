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



# Mathematical Concepts for New Novel Features of LightGBM

## Gradient-based One-side Sampling (GOSS)

### About GOSS

In typical GBDT, the gradient for each data instance in GBDT provides us with useful information for data sampling. That is, if an instance is associated with a small gradient, the training error for this instance is small and it is already well-trained. A straightforward idea is to discard those data instances with small gradients. To avoid the problem with the loss of accuracy by ignoring small gradients, the authors propose a new method called GOSS.

<center>
<figure>
<img src="D:\Study Stuffs\imgs\goss.png" width=400px class="center">
<figcaption>Fig.1 - Pseudocode for Gradient-based One-side Sampling</figcaption>
</figure>
</center>
### Theoretical Anlaysis

#### Definition 3.1

> *Let $O$ be the training dataset on a fixed node of the decision tree. The variance gain of splitting feature $j$ at point $d$ for this node is defined as*
> $$
> V_{j \mid O}(d) = \frac{1}{n_O} \left( \frac{\left( \sum_{\{x_i \in O : x_{ij} \leq d} g_i \right)^2}{n_{l \mid O}^j (d)} + \frac{\left( \sum_{\{x_i \in O : x_{ij} > d} g_i \right)^2}{n_{r \mid O}^j (d)} \right),
> $$
> *where $n_O = \sum I[x_i \in O]$, $n_{l \mid O}^j (d) = \sum I[x_i \in O : x_{ij} \leq d]$ and $n_{r \mid O}^j (d) = \sum I[x_i \in P : x_{ij} > d]$.*

With the above definition, we can defined the variance gain over the GOSS subset, i.e.,
$$
\tilde{V}_j(d) = \frac{1}{n} \left( \frac{\left( \sum_{x_i \in A_l} g_i + \frac{1-a}{b} \sum_{x_i \in B_l} g_i \right)^2}{n_l^j(d)} + \frac{\left( \sum_{x_i \in A_r} g_i + \frac{1-a}{b} \sum_{x_i \in B_r} g_i \right)^2}{n_r^j(d)} \right),
$$
where $A_l = \{ x_i \in A : x_{ij} \leq d\}$ , $A_r = \{ x_i \in A : x_{ij} > d \}$, $B_l = \{ x_i \in B : x_{ij} \leq d \}$, $B_r = \{x_i \in B : x_{ij} > d \}$, and the coefficient $\frac{1-a}{b}$ is used to normalize the sum of the gradients over $B$ back the the size of $A^c$.

#### Remark 1 (Hoeffding's Inequality)

> **The weak law of large numbers**
> $$
> \lim_{n \to \infty} \Pr \left( \left| \bar{X}_n - \mu \right| > \varepsilon \right) = 0.
> $$
>

We already know that the sample sizes goes larger, the sample and true means will likely be very close to each other by a non-zero distance no greater than epsilon. The weak law of large numbers states that the convergence is guaranteed. Within the framework of reducing the generalization gap, it can be interpreted that the generalization gap is closing. But, this law does not provide information about how fast it converges.

To offer this information, we adopted the concentration inequalities, which is a set of inequalities that quantifies how much random variables deviate from their expected values. Hoeffding's Inequality is one of them that provides an upper bound on the probability that the sum of bounded independent random variables deviates from its expected value by more than a certain amount. 

> **Heoffding's Inequality**
> $$
> P(|R(h) - R_{\text{emp}}| > \varepsilon) \leq 2 \exp(-2m\varepsilon^2),
> $$
> for some $\varepsilon > 0$ where $m$ is the size of samples .

This means that the probability of the generalization gap exceeding $\varepsilon$ exponentially decays as the dataset size goes larger.

Let $\delta = 2 \exp (-2m \varepsilon^2)$ be a tolerance lever. Then we can say that with a confidence $1 - \delta​$ :
$$
|R(h) - R_{\text{emp}}| \leq \varepsilon \implies R(h) \leq R_{\text{emp}}(h) + \varepsilon,
$$
and
$$
\log \frac{\delta}{2} = -2m\varepsilon^2 \implies \varepsilon = \sqrt{\frac{\log 2/\delta}{2m}}.
$$
The some algebraic results state that the generalization error is bounded by the size of samples.

The following theorem indicates that GOSS will not lose much training accuracy and will outperform random sampling.

#### Theorem 3.2

> We denote the approximation error in GOSS as $\mathscr{E}(d) = \left| \tilde{V}_j(d) - V_j(d) \right|$ and $\bar{g}_l^j(d) = \frac{\sum_{x_i \in (A \cup A^c)_l} |g_i|}{n_l^j(d)}$, $\bar{g}_r^j(d) = \frac{\sum_{x_i \in (A \cup A^c)_r} |g_i|}{n_r^j(d)}$. With probability at least $1 - \delta$, we have
> $$
> \mathscr{E}(d) \leq C^2_{a, b} \ln 1/\delta \cdot \max \left\{ \frac{1}{n_l^j(d)}, \frac{1}{n_r^j(d)} \right\} + 2DC_{a, b} \sqrt{\frac{\ln 1/\delta}{n}},
> $$
> where $C_{a, b} = \frac{1 - a}{\sqrt{b}} \max_{x_i \in A^c} |g_i|$, and $D = \max(\bar{g}_l^j(d), \bar{g}_r^j(d))$.

***Proof :***

For a fixed $d$, we have
$$
\begin{aligned}
\tilde{V}_j(d)- V_j(d) &= \left( \frac{\left( \sum_{x_i \in A_l} g_i + \frac{1-a}{b} \sum_{x_i \in B_l} g_i \right)^2}{n_l^j(d)} + \frac{\left( \sum_{x_i \in A_r} g_i + \frac{1-a}{b} \sum_{x_i \in B_r} g_i \right)^2}{n_r^j(d)} \right) - \left( \frac{\left( \sum_{x_i \in A_l} g_i + \sum_{x_i \in A_l^c} g_i \right)^2}{n_l^j(d)}  + \frac{\left( \sum_{x_i \in A_r} g_i + \sum_{x_i \in A_r^c} g_i \right)^2}{n_r^j(d)} \right) \\
& = \frac{1}{n_l^j(d)} \left( A_l^2 + \frac{2(1-a)}{b} A_l B_l + \left( \frac{1-a}{b} \right)^2 B_l^2 - A_l^2 - 2 A_l A_l^c - A_l^c \right) + \frac{1}{n_r^j(d)} \left( A_r^2 + \frac{2(1-a)}{b} A_r B_r + \left( \frac{1-a}{b} \right)^2 B_r^2 - A_r^2 - 2 A_r A_r^c - A_r^c \right) \\ 
&= \frac{1}{n_l^j(d)} \left( \frac{2(1-a)}{b} A_l B_l + \left( \frac{1-a}{b} \right)^2 B_l^2 - 2 A_l A_l^c - A_l^c \right) + \frac{1}{n_r^j(d)} \left( \frac{2(1-a)}{b} A_r B_r + \left( \frac{1-a}{b} \right)^2 B_r^2 - 2 A_r A_r^c - A_r^c \right) \\ 
&= \frac{1}{n_l^j(d)} \left( \frac{2(1-a)}{b} A_l B_l + \left( \frac{1-a}{b} \right)^2 B_l^2 - 2 A_l A_l^c - A_l^c + \frac{1-a}{b} A_l^c B_l - \frac{1-a}{b} A_l^c B_l \right) \\ & \quad + \frac{1}{n_r^j(d)} \left( \frac{2(1-a)}{b} A_r B_r + \left( \frac{1-a}{b} \right)^2 B_r^2 - 2 A_r A_r^c - A_r^c + \frac{1-a}{b} A_r^c B_r - \frac{1-a}{b} A_r^c B_r \right) \\ 
& = \frac{\frac{1-a}{b} B_l + A_l^c + 2 A_l}{n_l^j(d)} \left( \frac{1-a}{b} B_l - A_l^c \right) + \frac{\frac{1-a}{b} B_r + A_r^c + 2 A_r}{n_r^j(d)} \left( \frac{1-a}{b} B_r - A_r^c \right) \\
& = C_l \left( \frac{1-a}{b} \sum_{x_i \in B_l} g_i  - \sum_{x_i \in A_l^c} g_i \right) + C_r \left( \frac{1-a}{b} \sum_{x_i \in B_r} g_i  - \sum_{x_i \in A_r^c} g_i \right).
\end{aligned}
$$

Thus, we have
$$
|\tilde{V}_j(d) - V_j(d)| \leq \max \{ C_l, C_r \} \left| \frac{1-a}{b} \sum_{x_i \in B} g_i - \sum_{x_i \in A_c} g_i \right|.
$$
Firstly, we bound $C_l$ and $C_r$. Let $D_{A^c} = \max_{x_i \in A^c} |g_i|$. It follows that $g_i \leq D_{A^c}$ for all $x_i \in B_l$. Note that 
$$
D_{A^c} + \sum_{x_i \in A_l} g_i \leq D \implies \sum_{x_i \in A_l} g_i \leq D - D_{A^c}.
$$
Then we have
$$
\begin{aligned}
C_l &= \frac{\left( \frac{1-a}{b} \sum_{x_i \in B_l} g_i + \sum_{x_i \in A_l} g_i \right)}{n_l^j(d)} + \frac{\left( \sum_{x_i \in A_l^c} g_i + \sum_{x_i \in A_l} g_i \right)}{n_l^j(d)} \\ 
& \leq 
\end{aligned}
$$

