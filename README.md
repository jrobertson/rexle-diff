# Introducing Rexle-diff Version 0.5.0

    require 'rexle-diff'


    xml = '
    <ul>
      <li>apple</li>
      <li>orange</li>
      <li>grapes
        <color>red</color>
      </li>
    </ul>
    '

    xml2 = '
    <ul>
      <li>apple</li>
      <li>orange and lime</li>
      <li>grapes
        <color>green</color>
      </li>
      <li>bananas</li>
    </ul>
    '

    puts RexleDiff.new(xml, xml2).to_doc.xml pretty: true

Output:

<pre>
<?xml version='1.0' encoding='UTF-8'?>
<ul>
  <li>apple</li>
  <li last_modified='2015-03-26 17:44:25 +0000'>orange and lime</li>
  <li>
    grapes

    <color created='2015-03-26 17:44:25 +0000'>green</color>
  </li>
  <li created='2015-03-26 17:44:25 +0000'>bananas</li>
</ul>
</pre>

rexlediff gem modified
