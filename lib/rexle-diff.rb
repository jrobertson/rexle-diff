#!/usr/bin/env ruby

# file: rexle-diff.rb

require 'rexle'


class RexleDiff

  attr_reader :to_doc

  def initialize(source1, source2, ignore_removed: true)    

    a = timestamp(Rexle.new(source1)).to_a
    a2 = RexleParser.new(source2).to_a

    compare(a, a2)

    @to_doc = Rexle.new(a2)
  end
  
  private

  def names_values(c)
    
    c.inject([[],[]]) {|r, x|  r.first << x[0];  r.last << x[2]; r }

  end

  def added(list, list2)

    result = list2 -  list
    indexes = result.map {|x| list2.index x}

  end
  
  def array_index(a,i)
    a2 = a.select{|x| x.is_a? Array}
    a.index a2[i]
  end

  def compare(a, a2)
          _, _, _, *raw_c = a
    c = raw_c.select{|x| x.is_a? Array}
    names, values = names_values(c)
        
    _, _, _, *raw_c2 = a2
    c2 = raw_c2.select{|x| x.is_a? Array}
    names2, values2 = names_values(c2)

    added_indexes = added(values, values2)

    added_indexes.each do |i|

      offset = array_index(a2, i)
      a2[offset][1].merge!(created: Time.now, last_modified: Time.now)
    end
    
    # we need to know the deleted index
    deleted_indexes = deleted(values, values2)
    
    unchanged_indexes = unchanged(values, values2)
    #puts 'c : ' + c.inspect
    #puts 'added: ' + added_indexes.inspect
    #puts 'deleted :'  + deleted_indexes.inspect
    #puts 'unchanged : ' + unchanged_indexes.inspect

    # check the child element if any
    
    unchanged_indexes.each do |i, i2|      
          
      offset = array_index(a, i)
      offset2 = array_index(a2, i2)
      a2[offset2][1].merge!(a[offset][1])
      compare(c[i],c2[i2]) if c[i].length > 3
    end

  end
  
  def deleted(list, list2)

    result = list -  list2
    indexes = result.map {|x| list.index x}

  end  

  def timestamp(doc)

    doc.root.traverse do |x|
      x.attributes[:created] = Time.now unless x.attributes[:created]
    end

    return doc
  end
  
  def unchanged(list, list2)

    result = list &  list2
    indexes = result.map {|x| list.index x}
    indexes2 = result.map {|x| list2.index x}
    
    indexes.zip(indexes2)

  end    

end