#import "@preview/ctheorems:1.1.2": *
#show: thmrules
#let definition = thmbox("definition", "Definition", inset: (x: 1.2em, top: 1em))

= One Max Problem

#include "definition.typ"
#include "rep_ev.typ"
#include "init.typ"
#include "genetic_operators.typ"

== Selection

Following the initialization phase, the GA enters its main evolutionary cycle, with selection being a pivotal process. This step mimics natural selection by preferentially choosing individuals with higher fitness for reproduction, thus steering the population towards more optimal solutions.

In this context, the concept of elitism is introduced through a survival rate $sigma$, which determines the fraction of the population that advances to the next generation unchanged. Specifically, the top $floor(sigma N)$ individuals, based on their fitness, are preserved, while the rest are replaced by offspring generated through genetic operators. This blend of elitism and generation of new individuals helps balance exploration and exploitation in the search space.

#definition[Selection operator][
  The selection process is formalized through a selection operator, denoted as $Sigma$, which is defined for a population $P$ comprising $N$ individuals, each with a fitness value $phi_i$. 
  The operator is described as:
  
  $
    Sigma (P: PP, n: NN, dots) -> P'
  $
  
  where $PP$ is the set of all possible populations, $NN$ represents the set of natural numbers, $P'$ is the selected subset of the population, and $n$ is the number of selections to be made.
]

A commonly used method within this operator is the *roulette wheel selection*, where each individual's chance of being selected is proportional to its fitness. This can be mathematically expressed as:

$
  rho_Sigma(i) = phi_i sum_[j=1]^N phi_j
$

where $rho_Sigma(i)$ represents the selection probability of the $i$-th individual.

In Keen, all selection methods conform to the `Selector` interface:

```kt
interface Selector<T, G> : GeneticOperator<T, G> where G : Gene<T, G> {

    override fun invoke(
       state: EvolutionState<T, G>, outputSize: Int
    ): EvolutionState<T, G> { ... }

    fun select(
       population: Population<T, G>, count: Int, ranker: IndividualRanker<T, G>
    ): Population<T, G>
}

```

Configuring the selection mechanism within a GA is typically straightforward, as demonstrated in the following Kotlin snippet for the Keen library:

```kt
val engine = evolutionEngine(::count, genotypeOf {
    chromosomeOf {
        booleans {
            size = CHROMOSOME_SIZE
            trueRate = TRUE_RATE
        }
    }
}) {
    // For selecting parents for crossover.
    parentSelector = RouletteWheelSelector()
    // For selecting individuals to survive to the next generation.
    survivorSelector = TournamentSelector()
    /* Additional configurations */
}
```

This configuration illustrates the use of `RouletteWheelSelector` for parent selection, where probabilities are aligned with individuals' fitness, and `TournamentSelector` for survivor selection, which involves selecting the best among a randomly chosen subset of individuals. The flexibility to use different selectors for these phases allows for a tailored approach, potentially enhancing the GA's ability to converge on optimal solutions.

== Variation

Variation is the cornerstone of GA, facilitating the creation of new individuals from existing ones to explore the solution space comprehensively. This process is essential to circumvent premature convergence to sub-optimal solutions, analogous to how genetic diversity in nature fosters adaptability and resilience in species.

The primary mechanisms of variation in GAs are crossover and mutation. *Crossover* resembles biological recombination, merging genetic information from two or more parents to produce offspring. *Mutation*, akin to spontaneous genetic mutations in nature, introduces random alterations to an individual's genetic makeup.

To formally define a variation operator, which is pivotal in generating new individuals within a population, consider the following:

#definition[Variation operator][
  A variation operator is a mechanism that derives new individuals from existing ones in a population. Formally, it can be represented as a function:

  $
  phi.alt : (P: PP, ρ_phi.alt: RR, ...) → PP
  $

  where:

  - $PP$ represents the set of all possible populations.
  - $RR$ denotes the set of real numbers, corresponding to the range of the probability parameter.
  - $P$ specifies the particular population subject to variation.
  - $ρ_phi.alt$ is the probability of applying the variation operator to an individual within $P$.

  The ellipsis ($dots$) signifies additional parameters that may be included based on the specific implementation and characteristics of the variation operator.
]

Variation operators in genetic algorithms are typically variadic, capable of accepting a variable number of parent individuals to produce offspring. This adaptability enables a diverse array of genetic combinations within the population, encouraging a thorough exploration of potential solutions.

Keen represents variation operators through the `Alterer` interface:

```kt
interface Alterer<T, G> : GeneticOperator<T, G> where G : Gene<T, G> {
    operator fun plus(alterer: Alterer<T, G>) = listOf(this, alterer)
}
```

=== Crossover

A critical variation operator is the *crossover*, which mirrors genetic recombination observed in nature.
This operator facilitates the exchange of genetic material between two parent individuals, leading to the generation of new offspring.

#definition[Crossover Operator][
  The crossover operator recombines genetic material from existing individuals to create new ones.
  It is formally represented as:

  $
    X(P: PP, rho_X: RR, dots) -> PP
  $

  where:
  - $PP$ represents the set of all possible populations,
  - $RR$ is the set of real numbers, indicating probabilities,
  - $P$ denotes the current population under consideration,
  - $rho_X$ is the probability of applying the crossover to an individual.
]

In Keen, the crossover functionality is encapsulated within the following interface:

```kt
interface Crossover<T, G> : Alterer<T, G> where G : Gene<T, G> {
    val numOffspring: Int
    val numParents: Int
    val chromosomeRate: Double
    val exclusivity: Boolean

    override fun invoke(
        state: EvolutionState<T, G>, outputSize: Int
    ): EvolutionState<T, G> { ... }

    fun crossover(parentGenotypes: List<Genotype<T, G>>): List<Genotype<T, G>> { ... }

    fun crossoverChromosomes(
        chromosomes: List<Chromosome<T, G>>
    ): List<Chromosome<T, G>>
}
```

We'll use a *single-point crossover* operator in our example. 
This operator selects a random index within the parent chromosome to swap genes before and after this cut point. 
For instance, consider two parent individuals, $I_1 = 1100$ and $I_2 = 0001$. 
Using the single-point crossover, if the cut is made after the second gene, the resulting offspring would be $O_1 = 1101$ and $O_2 = 0000$.

Implementing this in Keen is straightforward:

```kt
val engine = evolutionEngine(::count, genotypeOf {
    chromosomeOf {
        booleans {
            size = CHROMOSOME_SIZE
            trueRate = TRUE_RATE
        }
    }
}) {
    alterers += SinglePointCrossover(chromosomeRate = 0.6)
    /* Other configurations */
}
```

Note the use of `+=` for adding alterers, as they are initialized to an empty mutable list to provide flexibility in configuration.

=== Mutation

While the crossover operator effectively recombines existing genetic material, it is limited by the genetic diversity already present in the population.
This can sometimes lead to premature convergence, especially for complex problems characterized by numerous local optima.

To combat this and infuse fresh _diversity_, the *mutation* operator is employed.
It introduces small, probabilistic changes to the genetic makeup of individuals.

#definition[Mutation operator][
  The mutation operator introduces variations in an individual's genetic material based on a predefined probability, resulting in a new population.
  Formally, a mutation operator can be represented as:
  $
    Mu (P: PP, mu: [0, 1], dots) -> PP
  $

  where: 
  - $PP$ -- denotes the set of all possible populations
  - $[0, 1]$ -- is the range of valid probabilities
  - $P$ -- stands for the current population
  - $mu$ -- indicates the mutation rate, i.e., the chance of an individual undergoing mutation

  Additional parameters vary depending on the specific mutation operator in play.
]

== Termination

In genetic algorithms, termination criteria are pivotal as they dictate when the algorithm should stop. 
This is crucial for preventing unnecessary computations and focusing the search on promising areas of the solution space.

In Keen, we represent these criteria using `Limit`s, which are defined with the following signature:

```kt
interface Limit<T, G> where G : Gene<T, G> {
    var engine: Evolver<T, G>?
    operator fun invoke(state: EvolutionState<T, G>): Boolean
}
```

For this example, we utilize one of Keen's integrated limits to halt the algorithm when either the desired fitness is achieved or a maximum number of generations has been reached:

```kt
val engine = evolutionEngine(::count, genotypeOf {
    chromosomeOf {
        booleans {
            size = CHROMOSOME_SIZE
            trueRate = TRUE_RATE
        }
    }
}) {
    // Add termination conditions
    limits += listOf(MaxGenerations(1000), TargetFitness(50.0))
}
```

By setting a clear termination condition, such as achieving the highest possible fitness score, the algorithm efficiently navigates the search terrain.
Although it might not explore every possible solution, it strategically focuses on those that improve the fitness, effectively optimizing the search process.

== Full implementation <omp-impl>

```kt
private const val POPULATION_SIZE = 100
private const val CHROMOSOME_SIZE = 50
private const val TRUE_RATE = 0.15
private const val TARGET_FITNESS = CHROMOSOME_SIZE.toDouble()
private const val MAX_GENERATIONS = 500

private fun count(genotype: Genotype<Boolean, BooleanGene>) = 
    genotype.flatten().count { it }.toDouble()

fun main() {
    val engine = evolutionEngine(::count, genotypeOf {
        chromosomeOf {
            booleans {
                size = CHROMOSOME_SIZE
                trueRate = TRUE_RATE
            }
        }
    }) {
        populationSize = POPULATION_SIZE
        parentSelector = RouletteWheelSelector()
        survivorSelector = TournamentSelector()
        alterers += listOf(
            BitFlipMutator(individualRate = 0.5),
            SinglePointCrossover(chromosomeRate = 0.6)
        )
        limits += listOf(MaxGenerations(MAX_GENERATIONS), TargetFitness(TARGET_FITNESS))
        listeners += listOf(EvolutionSummary(), EvolutionPlotter())
    }
    engine.evolve()
    engine.listeners.forEach { it.display() }
}
```
