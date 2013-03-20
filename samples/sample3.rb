#!/usr/bin/ruby
require 'ahocorasick'
myTrie = AhoC::Trie.new

myTrie.add("he") {|s| s}
myTrie.add("hi") {|s| s}
myTrie.add("she") {|s| s}
myTrie.add("hers") {|s| s}
myTrie.add("his") {|s| s}

myTrie.build do |node, f_node|
	if node && f_node
		node + "," + f_node
	elsif f_node
		f_node
	else
		node
	end
end

output = myTrie.lookup("shers", String.new) {|out, node_out| out == "" ? node_out : out + "," + node_out }
print output
print "\n"
