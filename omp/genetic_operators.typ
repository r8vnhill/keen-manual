== Genetic operators

Genetic operators are crucial components in genetic algorithms, directly manipulating genetic material to drive the evolutionary process. 
These operators, including mutation, crossover, and selection, modify genetic material to produce variability and innovation within a population.

In the Keen framework, all genetic operators implement the `GeneticOperator` interface, ensuring standardization and interoperability across different evolutionary strategies. 
Here’s how this interface is defined:

```kt
// Interface for genetic operators where T represents the type of value in the gene,
// and G represents the gene itself.
interface GeneticOperator<T, G> where G : Gene<T, G> {

    // Function invoked to apply genetic operations. It takes the current evolutionary
    // state and the desired output size, returning the new evolutionary state.
    operator fun invoke(
        state: EvolutionState<T, G>, outputSize: Int
    ): EvolutionState<T, G>
}
```

