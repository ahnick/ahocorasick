#==Aho-Corasick Trie Data Structure
#:title:Aho-Corasick Module
#
#A set of classes that implement an automaton for the Aho-Corasick algorithm.
#
#The Aho-Corasick algorithm provides a linear-time lookup solution to the exact
#set matching problem. (i.e. locating all occurrences of a finite set of 
#patterns within an input target) The algorithm processes the input target in
#a single pass versus multiple passes for a pattern.
#
#An example use might be to search for known sequences in a DNA string.
#Although typically used to parse character strings, this implementation
#is type independent. It can be used to parse any collection where
#the items that make up that collection can be iterated. 
#
#The implementation supports both a Non-deterministic and Deterministic
#Finite Automaton construction. The NFA will consume less memory, but
#will require more transitions than its DFA counterpart.
#
#<b>Author: Alexander Nick</b>
#
#<b>Date: 04/05/2011</b>
module AhoC

	#==Aho-Corasick Trie Class
	#
	#====Description
	#A class for constructing and accessing an Aho-Corasick trie 
	#data structure. Any pattern that supports the "each" method
	#in ruby can be added to the Trie. (e.g. strings or arrays)
	#
	#
	#
	#===Example Usage:
	#====Building a Aho-Corasick Trie
	#	myTrie = AhoC::Trie.new
	#	myTrie.add("he")
	#	myTrie.add("she")
	#	myTrie.add("hers")
	#	myTrie.add("his")
	#	myTrie.build
	#
	#====Looking up a string
	#	myTrie.lookup("ushers")
	#
	#====Output from Lookup
	#	["she", "he", "hers"]
	class Trie

		# Creates an empty AhoC Trie with only a root node
		#
		# Accepts an optional argument (either :DFA or :NFA)
		# indicating the type of automaton to build. If no
		# argument is passed an NFA will be built.
		def initialize *arg
			@root = Node.new

			if !arg[0] || arg[0] == :NFA
				@type = :NFA	
			elsif arg[0] == :DFA
				@type = :DFA	
			else
				raise "Only :DFA or :NFA accepted as arguments"
			end
		end

		# Add a pattern to the Trie.
		#
		# Accepts an optional block that can be used
		# to modify the node output.
		def add pattern
			node = @root

			# If this is a string process each character
			if String(pattern) == pattern
				pattern.each_char do |char|
					if node.goto(char) == nil
						node = node.add(char)
					else
						node = node.goto(char)
					end
				end
			else # Otherwise, pattern should support "each" method.
				for item in pattern
					if node.goto(item) == nil
						node = node.add(item)
					else
						node = node.goto(item)
					end
				end
			end

			if block_given?
				node.output = yield pattern
			else
				node.output = [pattern]
			end
		end

		# Sets the failure transitions and output for each node.
		# Call this method once all the patterns have been added to the Trie.
		#
		# Accepts an optional block that can be used to modify the output
		# constructed from the node and its failure nodes.
		def build
			fifo_q = Array.new
	
			# Set the failures for the nodes coming out of the root node.
			@root.get.each_pair do |item, node|
				node.failure = @root
				fifo_q.push node
			end

			# Set the failures in breadth-first search order
			# using a FIFO queue. A failure identifies the deepest node
			# that is a proper suffix of the current node. 
			while !fifo_q.empty?
				p_node = fifo_q.shift
				if p_node.get
					p_node.get.each_pair do |item, node|
						# Push the current node onto the queue, so any child
						# nodes can be processed later.
						fifo_q.push node 
					
						f_node = p_node.failure
						
						# Follow the failures until we find a goto transition
						# or arrive back at the root node
						while f_node.goto(item) == nil and !f_node.eql? @root
							f_node = f_node.failure
						end

						if f_node.eql? @root and f_node.goto(item) == nil
							node.failure = @root
						else
							node.failure = f_node.goto(item)
							if block_given?
								node.output = yield node.output, (node.failure).output
							else
								if node.output && (node.failure).output
									node.output = node.output + (node.failure).output
								elsif (node.failure).output
									node.output = (node.failure).output
								end
							end
						end
					end
				end
			end

			build_dfa if @type == :DFA

		end

		# Finds all occurrences of patterns in the Trie contained in target.
		# Outputs an array of patterns contained within the target.
		#
		# Accepts an optional argument to override the type of the output (e.g. String.new)
		# Accepts an optional block that can modify how the output is built from each node.
		def lookup target, *arg
			output = arg[0] ? arg[0] : Array.new
			node = @root

			# If this is a string process each character
			if String(target) == target
				target.each_char do |char|
					# Follow the failures until a goto transition is found
					# or we return to the root node.
					while(!node.goto(char) and !node.eql? @root)
						node = node.failure
					end

					# If there is a goto transition follow it; otherwise, 
					# we can assume we are at the root node.
					if node.goto(char)
						node = node.goto(char)

						if node.output		
							if block_given?
								output = yield output, node.output
							else
								output = output + node.output
							end
						end

					end
				end
			else # Otherwise, target should support "each" method.
				for item in target
					# Follow the failures until a goto transition is found
					# or we return to the root node.
					while(!node.goto(item) and !node.eql? @root)
						node = node.failure
					end

					# If there is a goto transition follow it; otherwise, 
					# we can assume we are at the root node.
					if node.goto(item)
						node = node.goto(item)

						if node.output		
							if block_given?
								output = yield output, node.output
							else
								output = output + node.output
							end
						end

					end
				end
			end

			return output
		end

		# Builds a Deterministic Finite Automaton from the NFA already constructed.
		private
		def build_dfa
			fifo_q = Array.new

			@root.get.each_pair do |item, node|
				fifo_q.push node
			end

			@root.get.default = @root

			while !fifo_q.empty?
				node = fifo_q.shift

				if node.get
					node.get.each_pair do |item, node|
						fifo_q.push node
					end
				end

				# Assign transitions at the failure node as
				# goto transitions of our current node
				if (node.failure).get
					(node.failure).get.each_pair do |f_item,f_node|

						# Don't overwrite an already existing transition
						node.set(f_item, f_node) unless node.goto(f_item)	
					end
				end

				node.get.default = @root
			end
		end

	end

	#==Aho-Corasick Node Class
	#
	#====Description
	#Class for creating and accessing nodes that are added to an Aho-Corasick Trie.
	class Node
	
		# failure: gets and sets the node to go to when no goto transition exists for an item.
		attr_accessor :failure
		# output: gets and sets the output at the node. 
		attr_accessor :output

		# Creates an empty hash table to store goto transitions for this node.
		def initialize
			@hash = {}
		end

		# Creates a node in the hash table for "item".  This represents
		# a goto transition in the Aho-Corasick automaton for the item.
		def add(item)
			@hash[item] = Node.new
		end

		# Return the hash that contains all nodes pointed to by this node.
		def get
			@hash
		end

		# Returns the node pointed to by item.
		# If no node exists the default value is returned.
		def goto(item)
			@hash[item] ? @hash[item] : @hash.default
		end

		# Assigns a node to the key "item" in the hash table.
		def set(item, node)
			@hash[item] = node
		end
	end

end 
