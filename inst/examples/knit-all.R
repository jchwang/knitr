#!/usr/bin/env Rscript

if (!nzchar(Sys.which('lyx')) || system('lyx -version') != 0L) q()

call_lyx = function(file) {
  res = sapply(sprintf('lyx -e %s %s', c('knitr', 'r', 'pdf2'), file), 
               system, USE.NAMES = FALSE)
  unlink(sub('\\.lyx$', '.R', file))
  stopifnot(identical(res, integer(3L)))
}

for (i in list.files(pattern = '\\.lyx$')) {
  message(i)
  call_lyx(i)
  flush.console()
}

call_knit = function(cmd) {
  stopifnot(identical(system(cmd), 0L))
}
for (i in list.files(pattern = '\\.R(tex|md|html|rst)')) {
  message(i)
  cmd = if (i == 'knitr-minimal.Rmd') {
    sprintf("Rscript -e 'library(knitr);opts_knit$set(base.url=\"https://github.com/yihui/knitr/raw/master/inst/examples/\");opts_chunk$set(fig.path=\"\");knit(\"%s\")'", i)
  } else {
    sprintf('knit %s', i)
  }
  call_knit(cmd)
  flush.console()
}

call_knit(sprintf("Rscript -e 'library(knitr);knit(\"knitr-minimal.brew\", \"\")'"))
call_knit(sprintf("Rscript -e 'library(knitr);card(\"knitr-card.R\")'"))

setwd('child')
for (i in c('knitr-main.Rnw', 'knitr-parent.Rnw')) {
  cmd = sprintf('knit %s --pdf', i)
  stopifnot(identical(system(cmd), 0L))
}
unlink('*.tex')
setwd('..')

