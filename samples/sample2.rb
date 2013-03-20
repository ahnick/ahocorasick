#!/usr/bin/ruby
require 'ahocorasick'
myTrie = AhoC::Trie.new
myTrie.add([1,2,3])
myTrie.add([2,1,4])
myTrie.add([2,1,4,3])
myTrie.add([5,6,2,4])
myTrie.add([2,1,4,3,8,9])
myTrie.build
output = myTrie.lookup([2,1,4,3,8,9,1,2,3])
print output
print "\n"
