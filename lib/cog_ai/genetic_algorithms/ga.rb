module CogAi
  module GeneticAlgorithms
    #
    # = How to use it
    #
    #   # Create the genetic algorithms
    #   @params: population size
    #   @params: number of generation
    #   ga = CogAi::GeneticAlgorithms::GA.new(800, 100)
    #
    #   @return: best chromosome
    #    solution = ga.evolve
    #    solution.fitness, solution.genes
    #
    class GA

      attr_accessor :population

      def initialize(population_size, generations)
        @population_size = population_size
        @max_generation = generations
        @generation = 0
      end

      def evolve
        # Step 1: Initialize population
        initialize_population()

        @max_generation.times do
          # Step 2: Selection
          mating_pool = selection()

          # Step 3: Reproduction (crossover & mutation)
          reproduction(mating_pool)
        end

        return best_chromosome()
      end

      def initialize_population
        @population = []
        @population_size.times do
          population << Chromosome.randomize_gene
        end
      end

      #
      # Step 2: Selection
      # Step 2a: Calculate fitness
      # Step 2b: Build mating pool - using Roulette Wheel Selection
      # Parents are selected according to their fitness.
      # The better the chromosomes are, the more chances to be selected they have.
      # Chromosome with bigger fitness will be selected more times.
      #
      def selection
        max_fitness = @population.max_by(&:fitness).fitness
        min_fitness = @population.min_by(&:fitness).fitness
        accumulate_normalized_fitness = 0
        if max_fitness - min_fitness > 0
          offset_fitness = max_fitness - min_fitness
          @population.each do | chromosome |
            chromosome.normalized_fitness = (chromosome.fitness - min_fitness) / offset_fitness
            accumulate_normalized_fitness += chromosome.normalized_fitness
          end
        else
          @population.each { | chromosome | chromosome.normalized_fitness = 1} 
        end

        mating_pool = []
        @population.each do | chromosome |
          if accumulate_normalized_fitness == 0
            num_select = 1
          else
            num_select = (chromosome.normalized_fitness / accumulate_normalized_fitness * @population_size).round
          end
          num_select.times do
            mating_pool << chromosome
          end
        end

        mating_pool
      end

      # Step 3: Reproduction
      # Step 3a: Crossover
      # Step 3b: Mutation
      def reproduction(mating_pool)
        @population.each_index do | i |
          r1 = rand(mating_pool.length - 1)
          r2 = rand(mating_pool.length - 1)
          @population[i] = Chromosome.crossover(mating_pool[r1], mating_pool[r2])

          Chromosome.mutate(@population[i])
        end
      end

      # Select the best chromosome in the population
      def best_chromosome
        return @population.min_by(&:fitness)
      end

    end # /class Ga

  end # /module GeneticAlgorithms
end # /module CogAi