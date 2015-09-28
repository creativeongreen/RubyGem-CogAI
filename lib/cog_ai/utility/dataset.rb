require 'csv'
require 'set'

module CogAi
  module Utility

    class Dataset

      attr_reader :data_labels, :data_rows

      def initialize(options = {})
        @data_labels = []
        @data_rows = options[:data_rows] || []
        set_data_labels(options[:data_labels]) if options[:data_labels]
        set_data_rows(options[:data_rows]) if options[:data_rows]
      end

      def load_csv(filepath)
        rows = []
        open_csv_file(filepath) do | entry |
          rows << entry
        end
        set_data_rows(rows)
      end

      def open_csv_file(filepath, &block)
        if CSV.const_defined? :Reader
          CSV::Reader.parse(File.open(filepath, 'r')) do | row |
            block.call row
          end
        else
          CSV.parse(File.open(filepath, 'r')) do | row |
            block.call row
          end
        end
      end

      # Load data items from csv file. 
      # The first row is used as data labels.
      def load_csv_with_labels(filepath)
        load_csv(filepath)
        @data_labels = @data_rows.shift
        return self
      end

      def set_data_labels(labels)
        check_data_labels(labels)
        @data_labels = labels
        return self
      end

      def set_data_rows(rows)
        check_data_rows(rows)
        @data_labels = default_data_labels(rows) if @data_labels.empty?
        @data_rows = rows
        return self
      end

      protected

      def check_data_rows(data_rows)
        if !data_rows || data_rows.empty?
          raise ArgumentError, "Examples dataset must not be empty."
        elsif !data_rows.first.is_a?(Enumerable)
          raise ArgumentError, "Unkown format for example data."
        end
        label_num = data_rows.first.length
        data_rows.each_index do | index |
          if data_rows[index].length != label_num
            raise ArgumentError,
                  "Quantity of labels is inconsistent. " +
                          "The first item has #{label_num} labels "+
                          "and row #{index} has #{data_rows[index].length} labels"
          end
        end
      end

      def check_data_labels(labels)
        if !@data_rows.empty?
          if labels.length != @data_rows.first.length
            raise ArgumentError,
                  "Number of labels do not match. " +
                          "#{labels.length} labels and " +
                          "#{@data_rows.first.length} labels found."
          end
        end
      end

      def default_data_labels(data_rows)
        data_labels = []
        data_rows[0][0..-2].each_index do | i |
          data_labels[i] = "label_#{i+1}"
        end
        data_labels[data_labels.length] = "class_value"
        return data_labels
      end

    end
  end
end
