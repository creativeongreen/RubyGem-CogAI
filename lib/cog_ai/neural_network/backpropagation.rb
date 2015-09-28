module CogAi
  module NeuralNetwork
    #
    # = How to use it
    #
    #   # Create the network with 3 inputs, 4 hidden layer with 3 neurons, and 2 outputs
    #   net = CogAi::NeuralNetwork::Backpropagation.new( [3, 4, 2] )
    #
    #   # Train the network 
    #   epoch = 1000
    #   epoch.times do |i|
    #     net.train(input[i], desired[i])
    #   end
    #
    #   # Use it: Evaluate data with the trained network
    #   net.eval([x0, x1, x2])  
    #    =>  [y0, y1]   
    #
    class Backpropagation

      attr_accessor :layers, :weights, :neurons, :previous_weight_changes

      def initialize(layers, learning_rate, momentum, has_bias)
        @layers = layers
        @learning_rate = learning_rate
        @momentum = momentum
        @has_bias = has_bias

        # randomize number between -1 ~ +1
        @function_initial_weight = lambda { | layer, i, j | ((rand 2000) / 1000.0) - 1}
        # define output activation function (logistic function): non-linear and  differentiable
        # and the derivatiive of activation function
        @function_activation = lambda { | x | 1 / (1+Math.exp(-1 * (x))) } #lambda { |x| Math.tanh(x) }
        @function_derivative_activation = lambda { | y | y * (1 - y) } #lambda { |y| 1.0 - y**2 }

        init_network
      end

      def train(inputs, outputs)
        check_input_dimension(inputs.length)
        check_output_dimension(outputs.length)
        feedforward(inputs)
        backpropagate(outputs)
        calculate_error(outputs)
      end

      def init_network
        init_neurons
        init_weights
        init_previous_weight_changes
        return self
      end

      # Evaluates the input.
      # E.g.
      #     net = Backpropagation.new([4, 3, 2])
      #     net.eval([25, 32.3, 12.8, 1.5])
      #         # =>  [0.83, 0.03]
      def eval(inputs)
        check_input_dimension(inputs.length)
        feedforward(inputs)
        return @neurons.last.clone
      end

      protected

      def marshal_dump
        [
          @layers,
          @has_bias,
          @learning_rate,
          @momentum,
          @weights,
          @previous_weight_changes,
          @neurons
        ]
      end

      def marshal_load(ary)
        @layers,
          @has_bias,
          @learning_rate,
          @momentum,
          @weights,
          @previous_weight_changes,
          @neurons = ary
        @function_initial_weight = lambda { |layer, i, j| ((rand 2000) / 1000.0) - 1}
        @function_activation = lambda { |x| 1 / (1+Math.exp(-1 * (x))) } #lambda { |x| Math.tanh(x) }
        @function_derivative_activation = lambda { |y| y * (1 - y) } #lambda { |y| 1.0 - y**2 }
      end

      def feedforward(inputs)
        inputs.each_index do |index| 
          @neurons.first[index] = inputs[index]
        end
        @weights.each_index do |layer_index|
          @layers[layer_index+1].times do |j|
            sum = 0.0
            @neurons[layer_index].each_index do |i|
              sum += (@neurons[layer_index][i] * @weights[layer_index][i][j])
            end
            @neurons[layer_index+1][j] = @function_activation.call(sum)
          end
        end        
      end

      def backpropagate(expected_output_values)
        calculate_output_layer_deltas(expected_output_values)
        calculate_inner_layer_deltas
        update_weights
      end

      # Calculate deltas for output layer
      def calculate_output_layer_deltas(expected_values)
        tmp_output_values = @neurons.last
        tmp_output_deltas = []
        tmp_output_values.each_index do |index|
          error = expected_values[index] - tmp_output_values[index]
          tmp_output_deltas << @function_derivative_activation.call(
            tmp_output_values[index]) * error
        end
        @deltas = [tmp_output_deltas]
      end

      # Calculate deltas for inner layers
      def calculate_inner_layer_deltas
        tmp_to_layer_deltas = @deltas.last
        (@neurons.length-2).downto(1) do |layer_index|
          tmp_layer_deltas = []
          @neurons[layer_index].each_index do |j|
            error = 0.0
            @layers[layer_index+1].times do |k|
              error += tmp_to_layer_deltas[k] * @weights[layer_index][j][k]
            end
            tmp_layer_deltas[j] = @function_derivative_activation.call(
              @neurons[layer_index][j]) * error
          end
          @deltas.unshift(tmp_layer_deltas)
          tmp_to_layer_deltas = tmp_layer_deltas
        end
      end

      # Update weights after @deltas have been calculated.
      def update_weights
        (@weights.length-1).downto(0) do |layer_index|
          @weights[layer_index].each_index do |i|
            @weights[layer_index][i].each_index do |j|
              change = @deltas[layer_index][j]*@neurons[layer_index][i]
              @weights[layer_index][i][j] += ( @learning_rate * change +
                  @momentum * @previous_weight_changes[layer_index][i][j])
              @previous_weight_changes[layer_index][i][j] = change
            end
          end
        end
      end

      # Calculate quadratic error for a expected output value 
      # Error = sum( (expected_value[i] - output_value[i])**2 ) / 2
      def calculate_error(expected_output)
        tmp_output_values = @neurons.last
        error = 0.0
        expected_output.each_index do |index|
          error += 
            0.5 * (tmp_output_values[index] - expected_output[index]) ** 2
        end

        return error
      end

      # e.g.: [3, 4, 2]
      # => @neurons = [ [1.0, 1.0, 1.0, bias], [1.0, 1.0, 1.0, 1.0, bias], [1.0, 1.0] ]
      def init_neurons
        @neurons = Array.new(@layers.length) do |layer_index| 
          Array.new(@layers[layer_index], 1.0)
        end
        if (@has_bias)
          @neurons[0...-1].each { |layer| layer << 1.0 }
        end
      end

      # e.g.: [3, 4, 2]
      # => @weights = [ [ matrix 3x4 ], [ matrix 4x2 ] ]
      def init_weights
        @weights = Array.new(@layers.length-1) do |layer_index|
          from_len = @neurons[layer_index].length
          to_len = @layers[layer_index+1]
          Array.new(from_len) do |i|
            Array.new(to_len) do |j|
              @function_initial_weight.call(layer_index, i, j)
            end
          end
        end
      end

      # Momentum usage need to know how much a weight changed in the previous training. 
      # This method initialize the @previous_weight_changes structure with 0 values.
      def init_previous_weight_changes
        @previous_weight_changes = Array.new(@weights.length) do |i|
          Array.new(@weights[i].length) do |j|
            Array.new(@weights[i][j].length, 0.0)
          end
        end
      end

      def check_input_dimension(inputs)
        raise ArgumentError, "Wrong number of inputs. " +
          "Expected: #{@layers.first}, " +
          "received: #{inputs}." if inputs!=@layers.first
      end

      def check_output_dimension(outputs)
        raise ArgumentError, "Wrong number of outputs. " +
          "Expected: #{@layers.last}, " +
          "received: #{outputs}." if outputs!=@layers.last
      end

    end # /class Backpropagation
  end # /module NeuralNetwork
end # /module CogAi