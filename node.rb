require_relative 'helper'
class Node
	def initialize(parent, string)
		@parent = parent
		@string = string
		@children = []
	end

	def string
		@string
	end

	def parent
		@parent
	end

	def children
		@children
	end
end