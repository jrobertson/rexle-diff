#!/usr/bin/env ruby

# file: rexle-diff.rb

require 'rexle'
require 'digest/md5'


class RexleDiff

  attr_reader :to_doc

  def initialize(source1, source2)    

    doc1, doc2  = Rexle.new(source1), Rexle.new(source2)
    compare(doc1.root, doc2.root)

    @to_doc = doc2
  end
  
  private

  # Returns an array of MD5 hashed strings representing each child node itself
  #
  def hashedxml(node)
    
    node.elements.map do |element|
      
      attributes = element.attributes.clone
      
      # Although attribute last_modified isn't used by rexle-diff it is 
      # created by Dynarex whenever a record is created or updated. 
      # This would of course cause the record to be flagged as changed even 
      # when the element value itself hashn't changed.
      #
      %i(created last_modified).each {|x| attributes.delete x}
      val = [element.name, attributes, element.text.to_s.strip].to_s
      
      h = Digest::MD5.new << val
      h.to_s
    end
  end

  
  # Returns an array of indexes of the nodes from the newer document which 
  # have been added or changed
  #
  def added(hxlist, hxlist2)

    added_or_changed = hxlist2 - hxlist    
    indexes = added_or_changed.map {|x| hxlist2.index x}    
    indexes

  end  
  
  # The main method for comparing the newest document node with the 
  # older document node
  #
  def compare(node, node2)

    hxlist, hxlist2 = hashedxml(node), hashedxml(node2)   
    
    # elements which may have been modified are also 
    #                                         added to the added_indexes list    
    added_indexes = added(hxlist, hxlist2)

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