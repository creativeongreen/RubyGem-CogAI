# CogAi

Ruby gem for backpropagation neural network and genetic algorithms

## Installation

Add this line to your application's Gemfile:

    gem 'cog_ai'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cog_ai

## Usage

>1- Create a neural network

> 	net = CogAi::NeuralNetwork::Backpropagation.new([num_input, num_hidden, num_output], learning_rate, momentum, has_bias)

> 	e.g. (XOR)
> 		net = CogAi::NeuralNetwork::Backpropagation.new([2, 2, 1], 0.3, 0.1, true)

- to train the net

> 	error = net.train(input_dataset, output_dataset)

> 	e.g. (XOR)
> 		error = net.train([1, 1], [0])

- to evaluate the result

> 	result = net.eval(input_dataset)

> 	e.g. (XOR)
> 		result = net.eval([1, 1])

>2- Create a genetic algorithms

> 	ga = CogAi::GeneticAlgorithms::GA.new(num_population, num_generation)

> 	solution = ga.evolve

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cog_ai/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
