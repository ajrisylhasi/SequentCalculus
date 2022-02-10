require_relative 'leaf'
require_relative 'root'
require_relative 'node'
require_relative 'tree'
$functions = [">", "|", "&", "!", "=", "L", ",", "(", ")"]
$primaryFunctions = ["!", ",", "L"]
$binaryFunctions = [">", "&", "|", "="]
$leafs = []
$nodes = []
$root = ""
def importantFunc(str)
	chars = str.chars
	if chars.count("(") == 1
		if chars[0] == "(" && chars[-1] == ")"
			t = chars.select { |s| $binaryFunctions.include? s}.first
			return t
		elsif chars[0] == "!"
			return "!"
		end
	elsif chars.count("(") == 0
		if chars[0] == "!"
			return "!"
		else
			return chars.join
		end
	else
		if chars[0] == "!"
			return "!"
		else
			charsNew = []
			chars.pop
			chars.shift
			chars.each do |c|
				if c=="(" || c==")"
					charsNew << c
				elsif $binaryFunctions.include? c
					charsNew << c
				end
			end
			charsNew = charsNew.join
			loop do 
				charsNew = charsNew.gsub("(&)", "").gsub("(|)","").gsub("(>)","").gsub("(=)","")
				break if charsNew.length == 1
			end
			index = 0
			chars.each_with_index do |c,i|
				if c == charsNew
					test = []
					test[0] = chars.join[0...i]
					test[1] = chars.join[i+1..-1]
					if test[0].count("(") == test[0].count(")") && test[1].count(")") == test[1].count("(")
						index = i
					end
				end
			end
			return " "*(index-1) + charsNew
			# chars.each_with_index do |s, i|
			# 	if $binaryFunctions.any? { |f| f==s } && (chars.index(s) < chars.index("(") || chars.reverse.index(s)< chars.reverse.index(")"))
			# 		t=s
			# 	end
			# end
			# return t	
		end
	end
end

def calculate(obj)
	if isAxiom?(obj.string) || isLeaf?(obj.string)
		if obj == $root
			$leafs << Leaf.new(obj, obj.string)
		else
			$leafs << Leaf.new(obj.parent, obj.string)
		end
		return
	end
	childrenize(obj)
	obj.children.each do |c|
		calculate(c)
	end
end

def childrenize(obj)
	if obj.string[0] == "L"
		leftSide = []
		rightSide = [obj.string.chars[1..-1].join]
		rightSide = obj.string.chars[1..-1].join.split(",") if obj.string.chars[1..-1].join != nil && obj.string.chars[1..-1].join.count(",") > 0
	elsif obj.string[-1] == "L"
		rightSide = []
		leftSide = [obj.string.chars[0..-2].join]
		leftSide = obj.string.chars[0..-2].join.split(",") if obj.string.chars[0..-2].join != nil && obj.string.chars[0..-2].join.count(",") > 0
	else
		sides = obj.string.split("L")
		leftSide = [sides[0]]
		rightSide = [sides[1]]
		leftSide = sides[0].split(",") if sides[0] != nil && sides[0].count(",") > 0
		rightSide = sides[1].split(",") if sides[1] != nil && sides[1].count(",") > 0
	end
	# Left Negation
	if leftSide != nil && leftSide.any? {|s| s[0] == "!"}
		string = leftSide.select {|s| s[0] == "!"}.first
		a = string.chars
		a.shift
		rightSide << a.join
		leftSide = leftSide - [string]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	# Right Negation
	if rightSide != nil && rightSide.any? {|s| s[0] == "!"}
		string = rightSide.select {|s| s[0] == "!"}.first
		a = string.chars
		a.shift
		leftSide << a.join
		rightSide = rightSide - [string]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Left Conjunction
	if leftSide.any? {|s| importantFunc(s).delete(" ") == "&"}
		string = leftSide.select {|s| importantFunc(s).delete(" ") == "&"}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index("&")].join
			b = chars[chars.index("&")+1..-2].join
		else
			chars.pop
			chars.shift
			chars.each_with_index do |s, i|
				if "&"==s && i == importantFunc(string).length
					a = chars[0...i].join
					b = chars[i+1..-1].join
				end
			end
		end
		leftSide = leftSide - [string] + [a] + [b]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Right Conjunction
	if rightSide.any? {|s| importantFunc(s).delete(" ") == "&"}
		string = rightSide.select {|s| importantFunc(s).delete(" ") == "&"}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index("&")].join
			b = chars[chars.index("&")+1..-2].join
		else
			chars.pop
			chars.shift
			chars.each_with_index do |s, i|
				if "&"==s && importantFunc(string).length == i
					a = chars[0...i].join
					b = chars[i+1..-1].join
				end
			end
		end
		orRightSide = rightSide
		rightSide = orRightSide - [string] + [a]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		rightSide = orRightSide - [string] + [b]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Left Disjunction
	if leftSide.any? {|s| importantFunc(s).delete(" ") == "|"}
		string = leftSide.select {|s| importantFunc(s).delete(" ") == "|"}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index("|")].join
			b = chars[chars.index("|")+1..-2].join
		else
			chars.pop
			chars.shift
			if chars.count("(")>0
				chars.each_with_index do |s, i|
					if "|"==s && importantFunc(string).length == i
						a = chars[0...i].join
						b = chars[i+1..-1].join
					end
				end
			end
		end
		orLeftSide = leftSide
		leftSide = orLeftSide - [string] + [a]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		leftSide = orLeftSide - [string] + [b]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Right Disjunction
	if rightSide.any? {|s| importantFunc(s).delete(" ") == "|"}
		string = rightSide.select {|s| importantFunc(s).delete(" ") == "|"}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index("|")].join
			b = chars[chars.index("|")+1..-2].join
		else
			chars.pop
			chars.shift
			if chars.count("(")>0
				chars.each_with_index do |s, i|
					if "|"==s && importantFunc(string).length == i
						a = chars[0...i].join
						b = chars[i+1..-1].join
					end
				end
			end
		end
		rightSide = rightSide - [string] + [a] + [b]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Right Implication
	if rightSide.any? {|s| importantFunc(s).delete(" ") == ">"}
		string = rightSide.select {|s| importantFunc(s).delete(" ") == ">"}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index(">")].join
			b = chars[chars.index(">")+1..-2].join
		else
			chars.pop
			chars.shift
			if chars.count("(")>0
				chars.each_with_index do |s, i|
					if ">"==s && importantFunc(string).length == i
						a = chars[0...i].join
						b = chars[i+1..-1].join
					end
				end
			end
		end
		rightSide = rightSide - [string] + [b]
		leftSide = leftSide + [a]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Left Implication
	if leftSide.any? {|s| importantFunc(s).delete(" ") == ">"}
		string = leftSide.select {|s| importantFunc(s).delete(" ") == ">"}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index(">")].join
			b = chars[chars.index(">")+1..-2].join
		else
			chars.pop
			chars.shift
			chars.each_with_index do |s, i|
				if ">"==s && importantFunc(string).length == i
					a = chars[0...i].join
					b = chars[i+1..-1].join
				end
			end
		end
		orLeftSide = leftSide
		orRightSide = rightSide
		leftSide = orLeftSide - [string] 
		rightSide = orRightSide + [a]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		leftSide = orLeftSide - [string] + [b]
		rightSide = orRightSide
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Right Equivalence
	if rightSide.any? {|s| importantFunc(s).delete(" ") == "="}
		string = rightSide.select {|s| importantFunc(s).delete(" ") == "="}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index("=")].join
			b = chars[chars.index("=")+1..-2].join
		else
			chars.pop
			chars.shift
			chars.each_with_index do |s, i|
				if "="==s && importantFunc(string).length == i
					a = chars[0...i].join
					b = chars[i+1..-1].join
				end
			end
		end
		orRightSide = rightSide
		orLeftSide = leftSide
		rightSide = orRightSide - [string] + [b]
		leftSide = orLeftSide + [a]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		rightSide = orRightSide - [string] + [a]
		leftSide = orLeftSide + [b]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
	#Left Equivalence
	if leftSide.any? {|s| importantFunc(s).delete(" ") == "="}
		string = leftSide.select {|s| importantFunc(s).delete(" ") == "="}.first
		chars = string.chars
		a = ""
		b = ""
		if chars.count("(") == 1
			a = chars[1...chars.index("=")].join
			b = chars[chars.index("=")+1..-2].join
		else
			chars.pop
			chars.shift
			chars.each_with_index do |s, i|
				if "="==s && importantFunc(string).length == i
					a = chars[0...i].join
					b = chars[i+1..-1].join
				end
			end
		end
		orRightSide = rightSide
		orLeftSide = leftSide
		leftSide = orLeftSide - [string] + [a] + [b]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		leftSide = orLeftSide - [string]
		rightSide = orRightSide + [a] + [b]
		objectString = leftSide.join(",")+"L"+rightSide.join(",")
		obj.children << Node.new(obj, objectString)
		return
	end
end

def isRoot?(obj)
	$root == obj
end

def isLeaf?(obj)
	sides = obj.split("L")
	rightSide = sides[1] == nil ? [""]:[sides[1]]
	leftSide = sides[0] == nil ? [""]:[sides[0]]
	leftSide=sides[0].split(",") if sides[0] != nil && sides[0].count(",") > 0
	rightSide=sides[1].split(",") if sides[1] != nil && sides[1].count(",") > 0
	if leftSide.all? {|s| !( $functions.include? importantFunc(s).delete(" ") )} && rightSide.all? {|s| !($functions.include? importantFunc(s).delete(" "))}
		return true	
	else
		return false
	end
end

def isAxiom?(obj)
	sides = obj.split("L")
	rightSide = [sides[1]]
	leftSide = [sides[0]]
	if leftSide == [] || rightSide == []
		return false
	end
	leftSide=sides[0].split(",") if sides[0] != nil && sides[0].count(",") > 0
	rightSide=sides[1].split(",") if sides[1] != nil && sides[1].count(",") > 0
	if leftSide.any? { |atom| !($functions.include? (importantFunc(atom).delete(" ")) ) && rightSide.any? { |s| s==atom}}
		return true	
	else
		return false
	end
end

def checkL(form)
	if form[0] == "L"
		return false
	end
	if form.chars.last == "L"
		return false
	end
	sides = form.split("L")
	if sides[0].count("(") > sides[0].count(")") || sides[1].count(")") > sides[1].count("(")
		return true
	else
		return false
	end
end

def checkF(form)
	chars = []
	form.chars.each_with_index do |c, i|
		if $binaryFunctions.include? c
			chars << i
		end
	end
	res = false
	chars.each_with_index do |c, i|
		if c+1 == chars[i+1]
			res = true
			break		
		end
	end
	return res
end

def checkForm
	print "Please use fully bracketed formulae for the Sequent: "
	formula = ""
	loop do 
		formula = gets.chomp.delete(" ")
		puts
		if formula == "Help"
			puts "This software will consider as atomic formula any set of characters that are not seperated by one of the functions."
			puts 
			puts "An example of a correct Sequent is: (!(p>q)&!q)L(q=!p), !p"
			print "Please use a correct Sequent: "
			next
		end
		if !(formula.include? "L")
			puts "This is not a Sequent. Use L."
		elsif formula.split("L").all? {|s| s.length == 0}
			puts "You have to use one atomic formulae in at least one of the sides."
		elsif formula.chars.all? { |s| $functions.include? s}
			puts "You have to use at least one atomic formula."
		elsif formula.chars.select { |s| $binaryFunctions.include? s}.count != formula.count("(")
			if formula.chars.select { |s| $binaryFunctions.include? s}.count > formula.count("(")
				puts "Less '(' than required."
			else 
				puts "More '(' than required."
			end
		elsif checkF(formula)
			puts "You cannot use a binary function immediately after a binary function."
		elsif checkL(formula)
			puts "L is being used inside brackets. Please put it in the middle of two formulae."
		elsif formula.count("L")>1
			puts "You can only use one Syntaxtical Consequence 'L'"
		elsif formula.chars.select { |s| $binaryFunctions.include? s}.count != formula.count(")")
			if formula.chars.select { |s| $binaryFunctions.include? s}.count > formula.count(")")
				puts "Less ')' than required."
			else 
				puts "More ')' than required."
			end
		else
			puts "I can work with that."
			puts
			break
		end
		print "Please use a correct Sequent: "
	end
	return formula
end
