require_relative 'helper'
class Leaf 
	def initialize(parent, string)
		@parent = parent
		@string = string
	end

	def parent
		@parent
	end

	def string
		@string
	end

	def axiom?
		sides = @string.split("L")
		leftSide = [sides[0]]
		rightSide = [sides[1]]
		leftSide=sides[0].split(",") if sides[0] != nil && sides[0].count(",") > 0
		rightSide=sides[1].split(",") if sides[1] != nil && sides[1].count(",") > 0
		if leftSide.any? { |atom| rightSide.any? { |s| s==atom}}
			return true
		else
			return false
		end
	end
end