# jekyll 블로그 디렉토리 설정
base <- "/Users/Han/otzslayer.github.io/"

# Rmd파일이 저장될 디렉토리 지정
rmds <- "_Rmd"
setwd(base)

# 파일 이름 지정
filename <- "2016-01-18-R-graphics-cookbook-chapter-3.Rmd"

# 폴더 경로들
figs.path <- "assets/article_images/"
posts.path <- "_posts/R/"

# START!!!
require(knitr)
render_jekyll(highlight = "pygments")
opts_knit$set(base.url="/")

file <- paste0(rmds, "/", filename)

# 파일 경로 설정
fig.path <- paste0(figs.path, sub(".Rmd$", "", basename(file)), "/")
opts_chunk$set(fig.path = fig.path)

# suppress messages
opts_chunk$set(cache = F, warning = F, message = F, cache.path = "_cache/", tidy = F)

out.file <- basename(knit(file))
file.rename(out.file, paste0(posts.path, out.file))

