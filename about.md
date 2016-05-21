---
layout: default
title: About | Become a Data Scientist
permalink: /about/
---

<div class="teaserimage">
    <div class="teaserimage-image" {% if site.cover %}style="background-image: url({{ site.cover }})"{% endif %}>
        Teaser Image
    </div>
</div>

<header class="blog-header">
    {% if site.logo %}
      <a class="blog-logo" href="{{site.url}}" style="background-image: url('{{ site.logo }}')">{{ site.title }}</a>
    {% endif %}
    <h1 class="blog-title">{{ site.title }}</h1>
    <h2 class="blog-description">{{ site.description }}</h2>
    <div class="custom-links">
      {% for social in site.social %}
        {% if social.url %}
            <a class="icon-{{ social.icon }}" href="{{ social.url }}" {% if social.desc %} title="{{ social.desc }}"{% endif %}">
              <i class="fa fa-{{ social.icon }}"></i>
            </a>
            &nbsp;&nbsp;·&nbsp;&nbsp;
        {% endif %}
      {% endfor %}
      <a href="/about/">About</a>
      		&nbsp;&nbsp;·&nbsp;&nbsp;
      <a href="/category/">Category</a>
    </div>
</header>

<main class="content" role="main">

<center>
<h3>한재윤</h3>  </n>
<h3>Jaeyoon Han</h3>  </n>

경희대학교 수학과 학부 졸업  </n>

경희대학교 대학원 <a href="http://sns.khu.ac.kr/">소셜네트워크과학과</a>  </n>


경희대학교 빅데이터 교육과정 '빅리더 2기' 수료  </n>

여러 가지 데이터 분석 프로젝트 진행 중... </center>
</main>