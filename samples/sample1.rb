#!/usr/bin/ruby
require 'ahocorasick'
myTrie = AhoC::Trie.new

myTrie.add("he")
myTrie.add("she")
myTrie.add("his")
myTrie.add("hers")

myTrie.build

output = myTrie.lookup("ushers")

print output
print "\n"
