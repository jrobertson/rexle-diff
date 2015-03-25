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
      
      attributes = element.attributes.clone
      attributes.delete :created
      val = [element.name, attributes, element.text].to_s      
      
      h = Digest::MD5.new << val
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