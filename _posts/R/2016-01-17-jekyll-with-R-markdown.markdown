---
layout: post
title:  "jekyll 기반의 블로그에 R 마크다운으로 포스팅하기"
categories: R
image: /assets/article_images/2016-01-17-jekyll-with-R-markdown/markdown.jpg
---

#### <center> jekyll with R Markdown </center>

---

블로그에 포스팅을 하면서 그간 코드를 많이 쓰거나, 시각화 관련 포스팅을 한 적이 없어서 R 마크다운 관련 기능을 생각해보지 않았다.
정작 해봐야겠다고 생각했을 때는 일반 마크다운으로는 해결되지 않았고, 결국 **R Studio의 마크다운 기능**을 이용해서 문제를 해결할 수 있었다. 다만 약간의 코드가 좀 필요해서 기록용으로 본 포스트에 올려놓으려고 한다. 본 포스트에 있는 내용은 우선 맥 El Capitan 에서 올바르게 작동하지만, 윈도우에서는 이 방법이 통할지는 확인된 바 없다.

<center> ![R Markdown in R Studio](/assets/article_images/2016-01-17-jekyll-with-R-markdown/r_markdown.png) </center>

1. 우선 Github 블로그 디렉토리 내에 몇몇 디렉토리를 만들어야 한다. 본인의 경우, R 마크다운 파일이 저장될 경로는 `_Rmd`에, R 코드로 만들어질 이미지들은 `assets/article_images/title`로, 포스트는 `_post/하위 경로` 로 설정했다.

2. 설정이 끝났으면 위의 이미지처럼 R 마크다운으로 포스팅할 내용을 적는다. 이 때, 프론트 매터는 기존의 포스트들과 동일한 형식으로 해줘야 한다. 날짜가 가장 중요한데, 기존에 날짜가 "YYYY년 MM월 DD일" 형식일 것이다. 이 형식은 오류가 발생하기 때문에 기존 형식인 `YYYY-MM-DD`로 설정해야 한다. R Studio의 기본 예제는 다음과 같다.

	```
	---
	layout: post
	title: "Test"
	author: "Jaeyoon Han"
	date: 2016-01-17
	image: /assets/article_images/2016-01-17-chapter1/beginning.jpg
	---

	This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

	When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:

	'''{r}
	summary(cars)
	'''

	You can also embed plots, for example:

	'''{r, echo=FALSE}
	plot(cars)
	'''

	Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
	```

3. 본 Rmd 파일을 `_Rmd` 폴더에 저장한다.

4. 다음의 코드를 실행한다.

{% highlight r %}
# jekyll 블로그 디렉토리 설정
base <- "/Users/Han/otzslayer.github.io/"

# Rmd 파일이 저장된 디렉토리 지정
rmds <- "_Rmd"
setwd(base)

# 파일 이름 지정
filename <- "2016-01-17-test.Rmd"

# 폴더 경로들
figs.path <- "assets/article_images/"
posts.path <- "_posts/R/"

# Rmd -> md 변환
require(knitr)
render_jekyll(highlight = "pygments")
opts_knit$set(base.url="/")

file <- paste0(rmds, "/", filename)

### 파일 경로 설정
fig.path <- paste0(figs.path, sub(".Rmd$", "", basename(file)), "/")
opts_chunk$set(fig.path = fig.path)

### suppress messages
opts_chunk$set(cache = F, warning = F, message = F, cache.path = "_cache/", tidy = F)

### 파일 변환 및 경로 지정
out.file <- basename(knit(file))
file.rename(out.file, paste0(posts.path, out.file))
{% endhighlight %}

본 코드가 오류 없이 실행됐다면, 자동으로 chunk images가 이미지 경로에 저장이 되었을 것이다. 또한 마크다운 파일도 자동으로 생성되었으므로 깃허브에 push해서 결과물을 확인하면 된다.
위 코드가 오류가 가장 많이 나는 경우는 R 마크다운 파일이 올바르게 저장되지 않았거나, 파일명이 틀리는 경우다. 확인하도록 하자.