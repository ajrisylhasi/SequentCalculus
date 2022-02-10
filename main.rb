require_relative 'helper'
puts "For help write 'Help'."
puts "1. For implication use: >"
puts "2. For disjunction use: |"
puts "3. For conjunction use: &"
puts "4. For negation use:    !"
puts "5. For equivalence use: ="
puts "6. For consequence use: L"
puts "7. For comma use:       ,"
puts "8. For opening bracket: ("
puts "8. For closing bracket: )"
formula = checkForm
$root = Root.new(formula)
calculate($root)
$tree = Tree.new($root)
$tree.show
if !($leafs.empty?) && $leafs.all? { |l| l.axiom?} 
	puts "<=============>"
	puts 
	puts "This formula is valid"
	puts
	puts "<=============>"
else
	puts "<=============>"
	puts 
	puts "This formula is not valid"
	puts
	puts "<=============>"
end