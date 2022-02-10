require_relative 'helper'
class Root
	def initialize(str)
		@string = str
		@children = []
	end

	def string
		@string
	end

	def children
		@children
	end
end