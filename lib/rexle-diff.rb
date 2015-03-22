#!/usr/bin/env ruby

# file: rexle-diff.rb

require 'rexle'
require 'rexle-builder'

class RexleDiff

  attr_reader :to_doc

  def initialize(source1, source2, ignore_removed: true)    

    a = timestamp(source1).to_a
    a2 = source2.to_a

    compare(a, a2)

    @to_doc = Rexle.new(a2)
  end
  
  private

  def names_values(c)
    c.inject([[],[]]){|r, x| r.first << x[0]; r.last << x[2]; r}
  end

  def added(list, list2)

    result = list2 -  list
    indexes = result.map{|x| list2.index x}

  end

  def compare(a, a2)

    _, _, _, *c = a
    names, values = names_values(c)
    _, _, _, *c2 = a2
    names2, values2 = names_values(c2)

    added_indexes = added(values, values2)

    added_indexes.each do |i| 
      a2[3+i][1].merge!(created: Time.now, last_modified: Time.now)
    end

    unchanged_indexes = (0..c.length-1).to_a - added_indexes

    # check the child element if any

    unchanged_indexes.each do |i|      

      a2[3+i][1].merge!(a[3+i][1])
      compare(c[i],c2[i]) if c[i].length > 3
    end

  end

  def timestamp(doc)

    doc.root.traverse do |x|
      x.attributes[:created] = Time.now unless x.attributes[:created]
    end

    return doc
  end

end

