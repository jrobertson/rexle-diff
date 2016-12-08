#!/usr/bin/env ruby

# file: rexle-diff.rb

require 'rexle'
require 'fuzzy_match'


class Rexle::Element

  def hashed()      @hash        end
  def hashed=(num)  @hash = num  end  

end


class RexleDiff
  
  class HashedDoc

    def initialize(node)

      @node = node
      @node.hashed = hash(node) + hashit(node).inject(:+)

    end

    def to_doc()
      @node
    end
    
    def hash(element)

      attributes = element.attributes.clone    
      %i(created last_modified).each {|x| attributes.delete x}
      [element.name, attributes, element.text.to_s.strip].hash

    end

    def hashit(node)
      
      a = node.elements.map do |element|
        
        row = hash element

        if element.has_elements?
          r = hashit(element)
          sum = row + r.inject(:+)
          element.hashed = sum
          sum
        else
          element.hashed = row
          row
        end  
      end

    end  

  end

  

  def initialize(source1, source2, fuzzy_match: false)    

    @fuzzy_match = fuzzy_match

    doc1, doc2  = HashedDoc.new(Rexle.new(source1).root).to_doc, 
        HashedDoc.new(Rexle.new(source2).root).to_doc

    compare(doc1.root, doc2.root)

    @doc = doc2
  end
    
  def changed()
    @doc.root.xpath('*[@last_modified]')
  end
  
  alias updated changed
  
  def created()
    @doc.root.xpath('*[@created]')
  end
  
  def to_doc()
    @doc
  end
  
  private

  
  # Returns an array of indexes of the nodes from the newer document which 
  # have been added or changed
  #
  def added(hxlist, hxlist2)
        
    list1 =  hxlist.map.with_index {|x,i| x + i}
    list2 =  hxlist2.map.with_index {|x,i| x + i}
        
    added_or_changed = list2 - list1
    indexes = added_or_changed.map {|x| list2.index x} 
    
    indexes

  end  
  
  # The main method for comparing the newest document node with the 
  # older document node
  #
  def compare(node, node2)

    hxlist, hxlist2 = hashedxml(node), hashedxml(node2)   
    
    # elements which may have been modified are also 
    #                                         added to the added_indexes list    
    added_or_changed_indexes = added(hxlist, hxlist2)

    added_indexes, updated_indexes  = @fuzzy_match ? \
                   fuzzy_match(added_or_changed_indexes, node, node2) : \
                                                   [added_or_changed_indexes, []]
    added_indexes.each do |i|
      
      attributes = node2.elements[i+1].attributes
      attributes[:created] ||= Time.now.to_s
      
      node2.elements[i+1].traverse do |e|

        e.attributes[:created] ||= Time.now.to_s

      end
    end

    deleted_indexes = deleted(hxlist, hxlist2)
    
    unchanged_indexes = unchanged(hxlist, hxlist2)
    
    unchanged_indexes.each do |i, i2|      

      compare(node.elements[i+1], node2.elements[i2+1]) if node\
                                                   .elements[i+1].has_elements?
      attributes2 = node2.elements[i2+1].attributes
      
      if attributes2[:created].nil? then
       attributes = node.elements[i+1].attributes
       attributes2[:created] = attributes[:created] if attributes[:created]
      end
    end

  end
  
  # Returns an array of indexes pointing to the nodes which were removed from 
  # the original document's relative parent node
  #
  def deleted(list, list2)

    result = list -  list2
    indexes = result.map {|x| list.index x}

  end
  
  def fuzzy_match(added_or_changed_indexes, node, node2)

        # is the added index item a new entry or an entry modification?
    updated_indexes, added_indexes = added_or_changed_indexes.partition do |i|

      e1 = node.elements[i+1]
      next unless e1

      fm = FuzzyMatch.new [e1.text]
      result, score1, score2 = fm.find_with_score node2.elements[i+1].text
      #puts "result: %s score1: %s score2: %s" % [result, score1, score2]
      
      result and score1 >= 0.5 
      
    end
    
    updated_indexes.each do |i|
      
      attributes2 = node2.elements[i+1].attributes
      attributes2[:last_modified] = Time.now.to_s      
      
      attributes = node.elements[i+1].attributes
      attributes2[:created] = attributes[:created] if attributes[:created]      
    end

    [added_indexes, updated_indexes]
  end
  

  # Returns an array of MD5 hashed strings representing each child node itself
  #
  def hashedxml(node)
    
    node.elements.map &:hashed
            
  end  
  
  # Returns an array of indexes from both original and new nodes which 
  # identifies which nodes did not change.
  #
  def unchanged(list, list2)
    
    result = list &  list2
    indexes = result.map {|x| list.index x}
    indexes2 = result.map {|x| list2.index x}
    
    indexes.zip(indexes2)

  end    

end