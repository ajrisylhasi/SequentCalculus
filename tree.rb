class Tree
	def initialize(root)
		@root = root
		@rows = []
	end

	def structurize
		@rows << [[@root]]
		@rows << [@root.children]
		loop do 
			thisRow = []
			@rows.last.each do |arr|
				arr.each do |obj|
					unless obj.is_a? Leaf
						thisRow << obj.children
					end
				end
			end
			break if thisRow == []
			@rows << thisRow
		end
	end

	def show
		structurize
		@rows.pop
		@rows.each_with_index do |row, i|
			print "#{i+1}. "
			row.each_with_index do |arr, iObj|
				arr.each_with_index do |obj, iiObj|
					if iObj>0
						iiObj += 1
					end
					str = obj.string.gsub(">", "⊃").gsub("!", "¬").gsub("=", "≡").gsub("&", "∧").gsub("|", "∨").gsub(",", " , ").gsub("L", " ⊢ ")
					print "#{(97+iObj+iiObj).chr}) #{str}     "
				end
			end
			puts
			puts "------------------------------"
			puts
		end
	end
end
