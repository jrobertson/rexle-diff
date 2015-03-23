# Introducing the Rexle-diff Gem

    require 'rexle-diff'

    xml = '
    <ul>
      <li>apple</li>
      <li>orange</li>
      <li>grapes
        <color>green</color>
      </li>
    </ul>
    '
    xml2 = '
    <ul>
      <li>apple</li>
      <li>peach</li>
      <li>grapes
        <color>red</color>
      </li>
      <li>bananas</li>
    </ul>
    '


    puts RexleDiff.new(xml, xml2).to_doc.xml pretty: true

<pre>
<?xml version='1.0' encoding='UTF-8'?>
<ul>
  <li created='2015-03-22 23:42:29 +0000'>apple</li>
  <li created='2015-03-22 23:42:29 +0000' last_modified='2015-03-22 23:42:29 +0000'>peach</li>
  <li created='2015-03-22 23:42:29 +0000'>
    grapes

    <color created='2015-03-22 23:42:29 +0000' last_modified='2015-03-22 23:42:29 +0000'>red</color>
  </li>
  <li created='2015-03-22 23:42:29 +0000' last_modified='2015-03-22 23:42:29 +0000'>bananas</li>
</ul>
</pre>

Note: It's not fully tested yet.

## Resources

* ?rexle-diff https://rubygems.org/gems/rexle-diff?

rexlediff rexle diff gem xml
