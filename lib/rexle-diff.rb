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

  
  def hashedxml(node)
    
    node.elements.map do |element|
      h = Digest::MD5.new << element.xml
      h.to_s
    end
  end

  def added(hxlist, hxlist2)
   
    added_or_changed = hxlist2 - hxlist    
    indexes = added_or_changed.map {|x| hxlist2.index x}    
    indexes

  end  
  
  def compare(node, node2)
    
    hxlist, hxlist2 = hashedxml(node), hashedxml(node2)   
    
    added_indexes = added(hxlist, hxlist2)

    added_indexes.each do |i|
      node2.elements[i+1].attributes\
                .merge!(created: Time.now.to_s, last_modified: Time.now.to_s)
    end
    
    deleted_indexes = deleted(hxlist, hxlist2)
    
    unchanged_indexes = unchanged(hxlist, hxlist2)

    unchanged_indexes.each do |i, i2|      

      node2.elements[i2+1].attributes[:created] ||= Time.now.to_s        
      compare(node.elements[i+1], node2.elements[i2+1]) if node.elements[i+1].has_elements?

    end

  end
  
  def deleted(list, list2)

    result = list -  list2
    indexes = result.map {|x| list.index x}

  end  
  
  def unchanged(list, list2)
    
    result = list &  list2
    indexes = result.map {|x| list.index x}
    indexes2 = result.map {|x| list2.index x}
    
    indexes.zip(indexes2)

  end    

end