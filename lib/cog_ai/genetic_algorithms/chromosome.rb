module CogAi
  module GeneticAlgorithms
    #
    # = How to use it
    #
    #   # Create the chromosome
    #   chromosome = CogAi::GeneticAlgorithms::Chromosome.randomize_gene
    #
    class Chromosome

      attr_accessor :genes, :normalized_fitness
        @mutation_rate = 0.000001

      def initialize(data)
        @genes = data
      end

      # compute costs of fitness of a chromosome
      def fitness
        return @fitness if @fitness
        start_gene = @genes[0]
        cost = 0
        @genes[1..-1].each do | end_gene |
          cost += @@costs[ start_gene ][ end_gene ]
          start_gene = end_gene
        end
        @fitness = -1 * cost

        return @fitness
      end

      #
      # swap mutation:
      # swap two randomly selected genes positions
      #
      def self.mutate(chromosome)
        if rand <= @mutation_rate
          data = chromosome.genes
          r1 = rand(data.length-1)
          r2 = rand(data.length-1)
          data[r1], data[r2] = data[r2], data[r1]
          chromosome.genes = data
          @fitness = nil
        end
      end

      def self.crossover(p1, p2)
        data_length = p1.genes.length
        r1 = rand(data_length-1)
        r2 = rand(data_length-1)
        if (r1 > r2)
          r1, r2 = r2, r1
        end

        # fill up child gene positions from parent p1 with range index
        child = []
        0.upto(data_length-1) { | i | child << -1 }
        r1.upto(r2) { | i |
          child[i] = p1.genes[i]
        }

        # fill up child remaining gene positions from parent p2
        index = 0
        if r1 != 0
          0.upto(r1-1) { | i |
            while child.include?(p2.genes[index]) do
              index = index + 1
            end
            child[i] = p2.genes[index]
            index = index + 1
          }
        end

        if r2 < data_length-1
          (r2+1).upto(data_length-1) { | i |
            while child.include?(p2.genes[index]) do
              index = index + 1
            end
            child[i] = p2.genes[index]
            index = index + 1
          }
        end

        return Chromosome.new(child)
      end

      #
      # generate genes randomly
      # step 1: create an ordered index array, e.g. genes = [ 0, 1, 2, 3, 4, 5 ]
      # step 2 : randomly select one from index array and push to new array until end of array
      # e.g. random_genes = [ 2, 4, 0, 5, 1, 3 ]
      #
      def self.randomize_gene
        data_size = @@costs[0].length
        genes = []
        0.upto(data_size-1) { | n | genes << n }
        random_genes = []
        while genes.length > 0 do 
          index = rand(genes.length)
          random_genes << genes.delete_at(index)
        end

        return Chromosome.new(random_genes)
      end

      def self.set_cost_matrix(costs)
        @@costs = costs
      end

    end # /class Chromosome

  end # /module GeneticAlgorithms
end # /module CogAi