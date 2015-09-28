module CogAi
  module Utility

    # This module provides some basic statistics functions to operate on
    # dataset attributes.
    module Statistics

      # Get the sample mean
      def self.mean(dataset, attribute)
        index = dataset.get_index(attribute)
        sum = 0.0
        dataset.data_rows.each { | row | sum += row[index] }
        return sum / dataset.data_rows.length
      end

      # Get the variance.
      # You can provide the mean if you have it already, to speed up things.
      def self.variance(dataset, attribute, mean = nil)
        index = dataset.get_index(attribute)
        mean = mean(dataset, attribute)
        sum = 0.0
        dataset.data_rows.each { | row | sum += (row[index]-mean)**2 }
        return sum / (dataset.data_rows.length-1)
      end

      # Get the standard deviation.
      # You can provide the variance if you have it already, to speed up things.      
      def self.standard_deviation(dataset, attribute, variance = nil)
        variance ||= variance(dataset, attribute)
        Math.sqrt(variance)
      end

      # Get the sample mode. 
      def self.mode(dataset, attribute)
        index = dataset.get_index(attribute)
        count = Hash.new {0}
        max_count = 0
        mode = nil
        dataset.data_rows.each do | row | 
          attr_value = row[index]
          attr_count = (count[attr_value] += 1)
          if attr_count > max_count
            mode = attr_value
            max_count = attr_count
          end
        end

        return mode
      end

      # Get the maximum value of an attribute in the dataset
      def self.max(dataset, attribute)
        index = dataset.get_index(attribute)
        item = dataset.data_rows.max { | x, y | x[index] <=> y[index] }

        return (item) ? item[index] : (-1.0/0)
      end

      # Get the minimum value of an attribute in the dataset
      def self.min(dataset, attribute)
        index = dataset.get_index(attribute)
        item = dataset.data_rows.min { | x, y | x[index] <=> y[index] }
        return (item) ? item[index] : (1.0/0)
      end

    end # /module Statistics
  end # /module Utility
end # /module CogAi
