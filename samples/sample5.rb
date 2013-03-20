#!/usr/bin/ruby
require 'ahocorasick'
myTrie = AhoC::Trie.new(:DFA)

myTrie.add("shell")
myTrie.add("hell")
myTrie.add("ell")
myTrie.build

output = myTrie.lookup("shell")
print output
print "\n"
