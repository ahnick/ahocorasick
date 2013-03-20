# AhoCorasick

## Overview

A memory efficient, pure Ruby implementation of the Aho-Corasick algorithm. The Aho-Corasick[http://en.wikipedia.org/wiki/Aho%E2%80%93Corasick_string_matching_algorithm] algorithm provides a linear-time lookup solution for the exact set matching problem. (i.e. An efficient method of locating all occurrences of a set of keywords in a string of text) 

Most importantly, this implementation is type independent, so you are not limited to only adding strings to the Trie.  You can pass any collection that can be iterated over and hashed.  (e.g. An array of integers)  See the samples/sample2.rb script for an example. You can also customize the output of the lookup by passing optional blocks to the add, build, and lookup functions.  See the samples/sample3.rb and samples/sample4.rb scripts for examples.

This implementation supports both a Non-deterministic Finite Automaton(NFA) and a Deterministic Finite Automaton(DFA). The NFA is more memory efficient, but requires more state transitions than the DFA version. 

## Installation

From the command line:

    $ gem install ahocorasick

## Usage

````ruby
require 'ahocorasick'

myTrie = AhoC::Trie.new
myTrie.add("he")
myTrie.add("she")
myTrie.add("his")
myTrie.add("hers")
myTrie.build

print myTrie.lookup("ushers")
````

To use the DFA version of the automaton pass :DFA as an argument when creating the Trie:

````ruby
myTrie = AhoC::Trie.new(:DFA)
````

## Documentation

1. Read through the generated rdoc documentation.
2. Take a look at the sample scripts in the samples/ directory.
3. Read the original PDF paper included with the gem.
