#!/usr/bin/ruby
require 'ahocorasick'
myTrie = AhoC::Trie.new

myTrie.add("hell") {|p| [[p,:word]]}
myTrie.add("shell") {|p| [[p,:word]]}
myTrie.add("he") {|p| [[p,:word]]}
myTrie.add("she") {|p| [[p,:word]]}
myTrie.add("sh") {|p| [[p,:prefix]]}
myTrie.add("ell") {|p| [[p,:suffix]]}

myTrie.build

output = myTrie.lookup("shells", Array.new(3) { Array.new }) do |out, node_out|
	node_out.each do |item|	
		case item[1]
			when :prefix
				out[0].push item[0]
			when :word
				out[1].push item[0]
			when :suffix
				out[2].push item[0]
		end
	end
	out
end

print output
print "\n"
