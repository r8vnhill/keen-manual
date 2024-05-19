#import "template.typ": *


// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Evolutionary Algorithms with Keen",
  authors: (
    (name: "Ignacio Slater Muñoz", email: "reachme@ravenhill.cl"),
  ),
  logo: "TransparentBg.png",
)

#show raw.where(lang: "kt"): it => [
    #show regex("\b(genotypeOf)\b") : keyword => text(fill: blue, keyword)
    #show regex("\b(chromosomeOf)\b") : keyword => text(fill: purple, keyword)
    #show regex("\b(booleans)\b") : keyword => text(fill: olive, keyword)
    #show regex("\b(BooleanGene|Genotype)\b"): keyword => text(fill: red, keyword)
    #it
]

#set quote(block: true)
#set heading(depth: 1)

#outline(depth: 2, indent: true)

#include "installation.typ"
#include "omp/omp_main.typ"
