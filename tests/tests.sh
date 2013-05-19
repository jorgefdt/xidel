#!/bin/sh

tests/test.sh t1   tests/a.xml
tests/test.sh te   tests/a.xml -e //title 
#Follow all a, print all titles
tests/test.sh tfe  tests/a.xml -f //a     -e //title
tests/test.sh tfe2 tests/b.xml -f //a     -e //title
tests/test.sh tfe3 tests/c.xml -f //a     -e //title
tests/test.sh tfe4 tests/d.xml -f //a     -e //title
tests/test.sh tfe5 tests/dpre.xml -f //a     -e //title
#Print all titles in all files that can be followed to
tests/test.sh tef  tests/a.xml -e //title -f //a
tests/test.sh tefe tests/a.xml -e //title -f //a      -e //title

tests/test.sh direct '<a>foobar</a>' -e '<a>{.}</a>'
tests/test.sh direct_hidden_vars1 --hide-variable-names '<a>foobar</a>' -e '<a>{.}</a>' 
tests/test.sh direct_hidden_vars2 '<a>foobar</a>' --hide-variable-names -e '<a>{.}</a>' 
tests/test.sh direct_hidden_vars3 '<a>foobar</a>' -e '<a>{.}</a>' --hide-variable-names

#follow max level
tests/test.sh maxlevel0 tests/a.xml --follow-level 0 -e //title -f //A --allow-repetitions
tests/test.sh maxlevel1 tests/a.xml --follow-level 1 -e //title -f //A --allow-repetitions
tests/test.sh maxlevel2  tests/a.xml --follow-level 2 -e //title -f //A --allow-repetitions
tests/test.sh maxlevel3  tests/a.xml --follow-level 3 -e //title -f //A --allow-repetitions

c
#"sibling tests"
tests/test.sh sibling1a '<empty/>' -e "a:=17"  tests/a.xml -e '<a>{z:=$a + 1}</a>'
tests/test.sh sibling1b "<a/>"  -e "a:=17"  tests/a.xml -e 'a:=909'
tests/test.sh sibling1c "<a/>"  -e "a:=17"  tests/a.xml -e 'a:=909' -e 'a:=10'
tests/test.sh sibling1d "<a/>"  -e "a:=17" -e 'a:=$a+1'  tests/a.xml -e 'a:=$a+2' -e 'a:=$a+3'
tests/test.sh sibling1e "<a/>"  -e "a:=17" -e 'a:=$a+1'  tests/a.xml -e 'a:=$a+2' -e 'a:=$a+3' '<b/>' -e 'a:=$a+4' -e 'a:=$a+5'
tests/test.sh sibling2  '<a>123</a>' '<a>456</a>' -e '<a>{$x}</a>'
tests/test.sh sibling2  -e '<a>{$x}</a>' '<a>123</a>' '<a>456</a>' 
tests/test.sh sibling2b '<a>123</a>' -e '<a>{$x}</a>' '<a>456</a>' 
tests/test.sh sibling3a '<t>1</t>' -e 'concat(/t, "b")' '<t>2</t>' -e 'concat(/t, "c")'
tests/test.sh sibling3b -e 'concat(/t, "a")' '<t>1</t>' -e 'concat(/t, "b")' '<t>2</t>' #extract applied to previous data (think that is good, right?)
tests/test.sh sibling3c -e 'concat(/t, "a")' '<t>1</t>' -e 'concat(/t, "b")' '<t>2</t>' -e 'concat(/t, "c")' 
tests/test.sh sibling4 tests/a.xml  -f //a     -e //title   tests/dpre.xml -f //a     -e //title  # dpre is bound to the followed link not a, so you can access the variables defined there

tests/test.sh tfe  tests/a.xml -f //a     -e //title
tests/test.sh tfe2 tests/b.xml -f //a     -e //title

#read title from both
tests/test.sh 2urls tests/a.xml -e //title tests/b.xml -e //title 
#not separated urls
tests/test.sh 2urls2read tests/a.xml tests/b.xml -e //title -e //title

#variable tests
tests/test.sh var1 '<a>hello</a>' -e 'var:=.' 
tests/test.sh var2 '<a>hello</a>' -e 'var:=.' -e 'var2 := 17'
tests/test.sh var3 '<a>hello</a>' -e 'var:=.' -e 'var2 := 17' -e '<a>{var3:=.}</a>'
tests/test.sh novar '<a>hello</a>' -e '.' 
tests/test.sh novar2 '<a>hello</a>' -e '.'  -e '<a>{.}</a>'
tests/test.sh varmix '<a>hello</a>' -e '.'  -e '<a>{temp:=.}</a>' -e '3+4' -e 'res:=$result'
tests/test.sh varmixb '<a>hello</a>' -e 'concat(">", ., "<")'  -e '<a>{temp:=$result}</a>' -e '3+4' -e 'res:=$result'

#stdin
echo '<test>123<x/>foo<abc>bar</abc>def<x/></test>' | tests/test.sh stdin1 - -e //abc
echo //abc2 | tests/test.sh stdin2 '<test>123<x/>foo<abc2>bar2!</abc2>def<x/></test>' -e -

#multipage template
tests/test.sh multipage --extract '<action><page url="tests/a.xml"><template><title>{.}</title></template></page></action>' --extract-kind=multipage
tests/test.sh multipage2  --extract '<action><loop var="page" list='"'"'("tests/a.xml", "b.xml")'"'"'><page url="{$page}"><template><title>{.}</title></template></page></loop></action>' --extract-kind=multipage
tests/test.sh multipage3 --extract '<action><page url="tests/a.xml"><template><html>{filter(., "[A-Z]+")}</html></template></page></action>' --extract-kind=multipage
tests/test.sh multipage3 --extract '<action><page url="tests/a.xml"><template><html>{filter($raw, "[A-Z]+")}</html></template></page></action>' --extract-kind=multipage


tests/test.sh multipageVariable  --extract-kind=multipage --extract '<action><variable name="test">1+2+3</variable></action>' --xpath '$test' ##?? change to print all variables
tests/test.sh multipageChoose   --extract-kind=multipage --extract '<action><choose><when test="1=2"><variable name="result">"a"</variable></when><when test="2=2"><variable name="result">"b"</variable></when><when test="3=2"><variable name="result">"c"</variable></when></choose></action>' --xpath '$result'
tests/test.sh multipageChoose3   --extract-kind=multipage --extract '<action><choose><when test="1=2"><variable name="result">"a"</variable></when><when test="3=2"><variable name="result">"b"</variable></when><when test="3=3"><variable name="result">"c"</variable></when></choose></action>' --xpath '$result'
tests/test.sh multipageChoose4   --extract-kind=multipage --extract '<action><choose><when test="1=2"><variable name="result">"a"</variable></when><when test="3=2"><variable name="result">"b"</variable></when><when test="4=3"><variable name="result">"c"</variable></when></choose></action>' --xpath '$result' #has an error in correct output
tests/test.sh multipageChooseO1   --extract-kind=multipage --extract '<action><choose><when test="1=2"><variable name="result">"a"</variable></when><when test="3=2"><variable name="result">"b"</variable></when><when test="4=3"><variable name="result">"c"</variable></when><otherwise><variable name="result">"x"</variable></otherwise></choose></action>' --xpath '$result'
tests/test.sh multipageChooseO2   --extract-kind=multipage --extract '<action><choose><when test="1=2"><variable name="result">"a"</variable></when><when test="3=2"><variable name="result">"b"</variable></when><when test="3=3"><variable name="result">"c"</variable></when><otherwise><variable name="result">"x"</variable></otherwise></choose></action>' --xpath '$result'
tests/test.sh multipageChooseO3   --extract-kind=multipage --extract '<action><choose><otherwise><variable name="result">"x"</variable></otherwise></choose></action>' --xpath '$result'


 correct output
#output formats
tests/test.sh adhoc1 tests/a.xml --extract "<a>{.}</a>*" 
tests/test.sh xml1 tests/a.xml --extract "<a>{.}</a>*" --output-format xml-wrapped
tests/test.sh json1 tests/a.xml --extract "<a>{.}</a>*" --output-format json-wrapped
tests/test.sh json1 tests/a.xml --extract "<a>{.}</a>*" --output-format json  #deprecated
tests/test.sh xmlraw1 tests/a.xml --extract "<a>{.}</a>*" --output-format xml
tests/test.sh htmlraw1 tests/a.xml --extract "<a>{.}</a>*" --output-format html
tests/test.sh bash1 tests/a.xml --extract "<a>{.}</a>*" --output-format bash
tests/test.sh xml1b tests/a.xml --output-format xml-wrapped --extract "<a>{.}</a>*" 
tests/test.sh json1b tests/a.xml --output-format json-wrapped --extract "<a>{.}</a>*" 
tests/test.sh json1b tests/a.xml --output-format json --extract "<a>{.}</a>*"  #deprecated
tests/test.sh xmlraw1b tests/a.xml --output-format xml --extract "<a>{.}</a>*" 
tests/test.sh htmlraw1b tests/a.xml --output-format html --extract "<a>{.}</a>*" 
tests/test.sh xmlraw1c tests/a.xml --output-format xml --extract "<a>{.}</a>*"  --output-declaration="<?xml>"

tests/test.sh adhoc2 tests/a.xml tests/b.xml -e "<a>{.}</a>*"
tests/test.sh xml2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format xml-wrapped
tests/test.sh json2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format json-wrapped
tests/test.sh json2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format json  #deprecated
tests/test.sh xmlraw2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format xml
tests/test.sh htmlraw2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format html
tests/test.sh bash2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format bash
tests/test.sh xml2b tests/a.xml tests/b.xml --output-format xml-wrapped -e "<a>{.}</a>*" 
tests/test.sh json2b tests/a.xml tests/b.xml --output-format json-wrapped -e "<a>{.}</a>*" 
tests/test.sh json2b tests/a.xml tests/b.xml --output-format json -e "<a>{.}</a>*"  #deprecated
tests/test.sh xmlraw2b tests/a.xml tests/b.xml --output-format xml -e "<a>{.}</a>*" 
tests/test.sh htmlraw2b tests/a.xml tests/b.xml --output-format html -e "<a>{.}</a>*" 

tests/test.sh adhoc3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*"  
tests/test.sh xml3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format xml-wrapped
tests/test.sh json3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format json-wrapped
tests/test.sh json3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format json #deprecated option
tests/test.sh xmlraw3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format xml
tests/test.sh htmlraw3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format html
tests/test.sh bash3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format bash


tests/test.sh adhoc4 -e '"<foobar>"' 
tests/test.sh xml4 -e '"<foobar>"' --output-format xml-wrapped
tests/test.sh json4 -e '"<foobar>"' --output-format json-wrapped
tests/test.sh xmlraw4 -e '"<foobar>"' --output-format xml
tests/test.sh htmlraw4 -e '"<foobar>"' --output-format html
tests/test.sh bash4 -e '"<foobar>"' --output-format bash

tests/test.sh adhoc4b -e 'xquery version "1.0"; <foobar/>' 
tests/test.sh xml4b -e 'xquery version "1.0"; <foobar/>' --output-format xml-wrapped
tests/test.sh json4b -e 'xquery version "1.0"; <foobar/>' --output-format json-wrapped
tests/test.sh xmlraw4b -e 'xquery version "1.0"; <foobar/>' --output-format xml
tests/test.sh htmlraw4b -e 'xquery version "1.0"; <foobar/>' --output-format html
tests/test.sh bash4b -e 'xquery version "1.0"; <foobar/>' --output-format bash

   #testing, if text nodes are surrounded by a text and if node ares escaped
tests/test.sh adhoc5 '<x>123</x>'  -e '/x/text()' 
tests/test.sh xml5 '<x>123</x>' -e '/x/text()' --output-format xml-wrapped
tests/test.sh json5 '<x>123</x>' -e '/x/text()' --output-format json-wrapped
tests/test.sh xmlraw5 '<x>123</x>' -e '/x/text()' --output-format xml
tests/test.sh htmlraw5 '<x>123</x>' -e '/x/text()' --output-format html
tests/test.sh adhoc5 '<x>123</x>'  -e '/x' --printed-node-format text 
tests/test.sh xml5 '<x>123</x>' -e '/x' --output-format xml-wrapped --printed-node-format text
tests/test.sh json5 '<x>123</x>' -e '/x' --output-format json-wrapped --printed-node-format text
tests/test.sh xmlraw5 '<x>123</x>' -e '/x' --output-format xml --printed-node-format text
tests/test.sh htmlraw5 '<x>123</x>' -e '/x' --output-format html --printed-node-format text
tests/test.sh bash5 '<x>123</x>' -e '/x' --output-format bash
tests/test.sh adhoc5 '<x>123</x>'  -e '/x' 
tests/test.sh xml5 '<x>123</x>' -e '/x' --output-format xml-wrapped 
tests/test.sh json5 '<x>123</x>' -e '/x' --output-format json-wrapped 
tests/test.sh xmlraw5b '<x>123</x>' -e '/x' --output-format xml 
tests/test.sh htmlraw5b '<x>123</x>' -e '/x' --output-format html 
tests/test.sh adhoc5c '<x>123</x>'  -e '/x' --printed-node-format xml
tests/test.sh xml5c '<x>123</x>' -e '/x' --output-format xml-wrapped --printed-node-format xml
tests/test.sh json5c '<x>123</x>' -e '/x' --output-format json-wrapped --printed-node-format xml
tests/test.sh xmlraw5c '<x>123</x>' -e '/x' --output-format xml --printed-node-format xml
tests/test.sh htmlraw5c '<x>123</x>' -e '/x' --output-format html --printed-node-format xml

tests/test.sh adhoc5d '<x>123</x>'  -e '<x>{temp:=text()}</x>' 
tests/test.sh xml5d '<x>123</x>' -e '<x>{temp:=text()}</x>' --output-format xml-wrapped
tests/test.sh json5d '<x>123</x>' -e '<x>{temp:=text()}</x>' --output-format json-wrapped
tests/test.sh xmlraw5d '<x>123</x>' -e '<x>{temp:=text()}</x>' --output-format xml
tests/test.sh htmlraw5d '<x>123</x>' -e '<x>{temp:=text()}</x>' --output-format html
tests/test.sh bash5d '<x>123</x>' -e '<x>{temp:=text()}</x>' --output-format bash

tests/test.sh adhoc6 '<x>123</x>'  -e 'a:=1, b:=2'
tests/test.sh xml6 '<x>123</x>'  -e 'a:=1, b:=2' --output-format xml-wrapped
tests/test.sh json6 '<x>123</x>'  -e 'a:=1, b:=2' --output-format json-wrapped
tests/test.sh xmlraw6 '<x>123</x>'  -e 'a:=1, b:=2' --output-format xml
tests/test.sh htmlraw6 '<x>123</x>'  -e 'a:=1, b:=2' --output-format html
tests/test.sh bash6 '<x>123</x>'  -e 'a:=1, b:=2' --output-format bash

tests/test.sh adhoc7 '<x>&nbsp;&auml;&nbsp&uuml&xyz;&123;&</x>' -e /x
tests/test.sh xml7 '<x>&nbsp;&auml;&nbsp&uuml&xyz;&123;&</x>' -e /x --output-format xml-wrapped
tests/test.sh json7 '<x>&nbsp;&auml;&nbsp&uuml&xyz;&123;&</x>' -e /x --output-format json-wrapped
tests/test.sh xmlraw7 '<x>&nbsp;&auml;&nbsp&uuml&xyz;&123;&</x>' -e /x --output-format xml
tests/test.sh htmlraw7 '<x>&nbsp;&auml;&nbsp&uuml&xyz;&123;&</x>' -e /x --output-format html
tests/test.sh bash7 '<x>&nbsp;&auml;&nbsp&uuml&xyz;&123;&</x>' -e /x --output-format bash

tests/test.sh adhoc-json -e '[1,2,3,{"a": 123,"b":"c"}]'
tests/test.sh xml-json -e '[1,2,3,{"a": 123,"b":"c"}]' --output-format xml
tests/test.sh html-json -e '[1,2,3,{"a": 123,"b":"c"}]' --output-format html
tests/test.sh xmlw-json -e '[1,2,3,{"a": 123,"b":"c"}]' --output-format xml-wrapped
tests/test.sh jsonw-json -e '[1,2,3,{"a": 123,"b":"c"}]' --output-format json-wrapped
tests/test.sh bash-json -e '[1,2,3,{"a": 123,"b":"c"}]' --output-format bash

tests/test.sh bash-escape1 --xquery '"1&#xA;2"' --output-format bash
tests/test.sh bash-escape2 --xquery '"1&#xD;2"' --output-format bash
tests/test.sh bash-escape3 --xquery "concat('\"', \"'\", '\\\\')" --output-format bash
tests/test.sh bash-escape4 --xquery "concat('\"', \"'\", '\\\\', '&#xA;')" --output-format bash
tests/test.sh bash-escape5 --xquery "concat('\"', \"'\", '\\\\', '&#xD;')" --output-format bash
tests/test.sh bash-escape6 --xquery "concat('\"', \"'\", '\\\\', '&#xA;&#xD;')" --output-format bash
tests/test.sh bash-escape7 --xquery "concat('\"', \"'\", '\\\\')" --output-format bash --print-type-annotations
tests/test.sh bash-escape8 --xquery "concat('\"', \"'\", '\\\\', '&#xA;&#xD;')" --output-format bash --print-type-annotations

tests/test.sh bash-combining1 -e 1 -e '(2,3)' -e '4' --output-format bash
tests/test.sh bash-combining2 -e 1 -e '(2,3)' -e 'temp:=712' -e '4' --output-format bash
tests/test.sh bash-combining3 -e 1 -e '(2,3)' -e 'temp:=712' -e '4' -e 'temp:=189' --output-format bash

#Nesting
tests/test.sh nest0a [ ]
tests/test.sh nest0b '<empty/>'   [ ]
tests/test.sh nest0c tests/a.xml  [ ]
tests/test.sh nest1a tests/a.xml  [ -e //title ]
tests/test.sh nest1b tests/b.xml  [ -e //title ]
tests/test.sh nest1ab tests/a.xml  tests/b.xml [ -e //title ]
tests/test.sh nest1ab2 tests/a.xml  tests/b.xml -e //title [ -e //title ] 
tests/test.sh nest1ab3 tests/a.xml  tests/b.xml [ -e //title ] -e //title
tests/test.sh nest1ab4 tests/a.xml  tests/b.xml -e 'concat("X", //title)' [ -e //title ] 
tests/test.sh nest1ab5 tests/a.xml  tests/b.xml [ -e //title ] -e 'concat("Y", //title)'
tests/test.sh nest2a tests/a.xml  [ -f //a -e //title ]
tests/test.sh nest2a tests/a.xml  -f //a [ -e //title ]
tests/test.sh nest2b tests/a.xml -e //title [ -f //a -e //title ]
tests/test.sh nest2b tests/a.xml -e //title -f //a [ -e //title ]
tests/test.sh nest2c tests/a.xml  [ -f //a -e //title ] -e //title
tests/test.sh nest2d tests/a.xml -e //title [ -f //a -e //title ] -e //title
tests/test.sh nest2e tests/a.xml  -f //a [ -e //title ] -e //title
tests/test.sh nest3a [ tests/a.xml tests/b.xml ] -e //title
tests/test.sh nest3a tests/a.xml tests/b.xml -e //title
tests/test.sh nest3a tests/a.xml [ tests/b.xml -e //title ]
tests/test.sh nest3a tests/a.xml [ tests/b.xml [ -e //title ] ]
tests/test.sh nest3a -e //title tests/a.xml tests/b.xml
tests/test.sh nest3a -e //title [ tests/a.xml tests/b.xml ] 
tests/test.sh nest3a -e //title tests/a.xml [ tests/b.xml ]  
tests/test.sh nest3a tests/a.xml -e //title  [ tests/b.xml ]  #brackets prevent sibling creation (good??)
tests/test.sh nest3b tests/a.xml -e //title  tests/b.xml 
tests/test.sh nest4 -e 1+2
tests/test.sh nest4 [ -e 1+2 ]
tests/test.sh nest4 [ [ -e 1+2 ] ]
tests/test.sh nest4 [ [ [ -e 1+2 ] ] ] 
tests/test.sh nest5a [ "<a/>"  -e "a:=17" ] [  tests/a.xml -e 'a:=909'  ]
tests/test.sh nest5b [ "<a/>"  -e "a:=17" ] [  tests/a.xml -e 'a:=909'  ] [ -e '$a' ] 
tests/test.sh nest5c -e "a:=17"  tests/a.xml -e '<a>{z:=$a + 1}</a>'
tests/test.sh nest6a [ -e 1+2 ] 
tests/test.sh nest6b [ -e 1+2 ] [ -e 3+4 ]
tests/test.sh nest6c [ -e 1+2 ] [ -e 3+4 ] [ -e 5+6 ]
tests/test.sh nest7 [ tests/a.xml -f //a     -e //title ] [ tests/dpre.xml -f //a     -e //title ]
tests/test.sh nest8 tests/a.xml [ -f //a     -e //title   tests/dpre.xml -f //a     -e //title ]
tests/test.sh nest8 tests/a.xml   -f //a  [  -e //title   tests/dpre.xml -f //a     -e //title ]
tests/test.sh nest9a tests/a.xml -f //a -e //title -f //a -e //title
tests/test.sh nest9b tests/a.xml [ -f //a -e //title -f //a ] -e //title
tests/test.sh nest9c tests/a.xml [ -f //a -e //title -f //a -e //title ] -e //title
tests/test.sh nest10 tests/a.xml [ -e //title -f //a -e //title ] 
tests/test.sh nest10 tests/a.xml -e //title [ -f //a -e //title ] 
tests/test.sh nest10 [ tests/a.xml ] -e //title -f //a -e //title 
tests/test.sh nest10 [ tests/a.xml  -e //title -f //a ] -e //title 
tests/test.sh nest10b [ tests/a.xml  -e //title -f //a ] -e 'concat(//title, "x")'
tests/test.sh nest10 [ tests/a.xml  -e //title ] -f //a  -e //title 
tests/test.sh nest10b [ tests/a.xml  -e //title ] -f //a -e 'concat(//title, "x")'
tests/test.sh nest10b [ tests/a.xml ] -e //title  -f //a -e 'concat(//title, "x")'
tests/test.sh nest10b tests/a.xml [ -e //title ] -f //a -e 'concat(//title, "x")'
tests/test.sh nest10c tests/a.xml [ -e //title  -f //a ] -e 'concat(//title, "x")' # this blocks the follow to ascend to the parent (good ? yielding becomes confusing if there are many nested blocks yielding to each other (and it would still apply to a.xml) )

#type selection
tests/test.sh css '<a>hallo<b>cc</b></a>' --css b
tests/test.sh xpath1 '<a>hallo<b>cc</b></a>' --xpath b
tests/test.sh xpath2 '<a>hallo<b>cc</b></a>' --xpath //b
tests/test.sh xpath3 --xpath "'&gt;'"
tests/test.sh xpath3 -e "'&gt;'"
tests/test.sh xquery --xquery "'&gt;'"
tests/test.sh xquerypath --xquery "'&gt;'" -e "'&gt;'"

tests/test.sh xpath4 '<html>1<a class="foobar">2</a>3</html>' -e 'html'
tests/test.sh xpath5 '<html>1<a class="foobar">2</a>3</html>' -e 'a'    #make this CSS??
tests/test.sh xpath6 '<html>1<a class="foobar">2</a>3</html>' -e '//a'
tests/test.sh xpath6 '<html>1<a class="foobar">2</a>3</html>' -e '    //a   '
tests/test.sh css2 '<html>1<a class="foobar">2</a>3</html>' -e 'a.foobar'
tests/test.sh css2 '<html>1<a class="foobar">2</a>3</html>' -e '   a.foobar   '
tests/test.sh xquery4 '<html>1<a class="foobar">2</a>3</html>' -e '   let    $x := //a return $x'
tests/test.sh xquery5 '<html>1<a class="foobar">2</a>3</html>' -e 'let $x := //a return "&gt;"'
tests/test.sh xquery5 '<html>1<a class="foobar">2</a>3</html>' -e '    let $x := //a return "&gt;"'
tests/test.sh xpath7 '<html>1<a class="foobar">2</a>3</html>' -e '"&gt;"'
tests/test.sh xpath7 '<html>1<a class="foobar">2</a>3</html>' -e '     "&gt;"'
tests/test.sh template '<html>1<a class="foobar">2</a>3</html>' -e '<a class="foobar">{.}</a>'
tests/test.sh xquery6 -e '   declare     function local:abc(){"&gt;"}; local:abc()'
tests/test.sh xquery6 -e '   declare     function local:abc($arg as xs:string){"&gt;"}; local:abc("foo")'
tests/test.sh xquery6 -e '   declare variable $xyz := "a&gt;b"; substring($xyz,2,1)'
tests/test.sh xquery6 -e '  xquery version "1.0"; "&gt;"'
tests/test.sh xpath8 '<a>3</a>' -e ' 3 + . '
tests/test.sh xpath8 '<a>3</a>' -e ' . + 3 '
tests/test.sh xpath9 '<a>3</a>' -e ' . '
tests/test.sh xpath10 '<a>3</a>' -e ' . eq . '
 
#magic variables
tests/test.sh varraw '<a>3</a>' -e '$raw'
tests/test.sh varurlhostpath 'http://example.org/bar' -e 'concat($url, "||", $host, "||", $path)'
tests/test.sh varresult '<a>3</a>' -e '.'  -e 'concat("-", $result, "-")'

#other stuff
tests/test.sh system -e 'system("echo 123") * 8'
tests/test.sh namespace1 '<a xmlns="foobar">def</a>' -e / --printed-node-format xml
tests/test.sh namespace2 '<a xmlns="foobar">def</a>' -e / --printed-node-format xml --ignore-namespaces
tests/test.sh repetitionoff tests/a.xml tests/a.xml -e //title
tests/test.sh repetitionon tests/a.xml tests/a.xml -e //title --allow-repetitions
tests/test.sh inputformatAuto --input-format auto '<a>x</a>'  -e 'outer-xml(/)'
tests/test.sh inputformatXml --input-format xml '<a>x</a>'  -e 'outer-xml(/)'
tests/test.sh inputformatHtml --input-format html '<a>x</a>'  -e 'outer-xml(/)'
tests/test.sh inputformatAuto '<a>x</a>' --input-format auto  -e 'outer-xml(/)'
tests/test.sh inputformatXml  '<a>x</a>' --input-format xml -e 'outer-xml(/)'
tests/test.sh inputformatHtml  '<a>x</a>' --input-format html  -e 'outer-xml(/)'
tests/test.sh inputformatAuto '<a>x</a>'  -e 'outer-xml(/)' --input-format auto
tests/test.sh inputformatXml '<a>x</a>'  -e 'outer-xml(/)' --input-format xml
tests/test.sh inputformatHtml  '<a>x</a>'  -e 'outer-xml(/)' --input-format html
tests/test.sh optadhoc '<a>x</a>'  -e /
tests/test.sh optxml --xml '<a>x</a>'  -e /
tests/test.sh opthtml --html '<a>x</a>'  -e /
tests/test.sh moduleVars -e 'declare variable $a:=123' -e '$a'
tests/test.sh moduleFunc1 -e 'declare variable $a:=123; declare function local:xyz(){456}; 8' -e 'local:xyz()+$a'
tests/test.sh moduleFunc2 -e 'declare variable $a:=123; declare function local:xyz(){456}' -e 'declare function local:abc(){$a*1000}; local:xyz() + local:abc()'
tests/test.sh moduleFuncImport -e 'import module namespace foobar = "pseudo://test-module" at "tests/module.xq"' -e '$foobar:abc'
tests/test.sh moduleFuncImport2 -e 'import module namespace rename = "pseudo://test-module" at "tests/module.xq"' -e 'rename:test()'

tests/test.sh utf8  -e 'substring("äbcd",1,3)'

#Online tests
tests/test.sh google http://www.google.de -e "count(//title[contains(text(),\"Google\")])"
tests/test.sh get1  http://videlibri.sourceforge.net/xidelecho.php -e //meth
tests/test.sh get2a --post abc --method GET http://videlibri.sourceforge.net/xidelecho.php -e //meth
tests/test.sh get2b --post abc --method GET http://videlibri.sourceforge.net/xidelecho.php -e //raw
tests/test.sh post1a  --post test http://videlibri.sourceforge.net/xidelecho.php -e //meth
tests/test.sh post1b  --post test http://videlibri.sourceforge.net/xidelecho.php -e //raw
tests/test.sh post2  --post "user=login&pass=password" http://videlibri.sourceforge.net/xidelecho.php -e //raw
tests/test.sh post3  --post "" http://videlibri.sourceforge.net/xidelecho.php -e //meth
tests/test.sh post3b  --post "" http://videlibri.sourceforge.net/xidelecho.php -e //raw
tests/test.sh post3c  --post "" http://videlibri.sourceforge.net/xidelecho.php --download -
tests/test.sh post4  --post "123" http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)' --post "456" http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)'
tests/test.sh post4b  --post "123" http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)'  http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)'  #duplicated requests are ignored
tests/test.sh post4c  --post "123" http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)' --method GET http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)' #keep the data option
tests/test.sh post4d [  --post "123" http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)' ] --method GET http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)' 
tests/test.sh post4d [  --post "123" http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)' ]  http://videlibri.sourceforge.net/xidelecho.php -e '(//meth,//raw)' 
echo TEST | tests/test.sh post5  --post - http://videlibri.sourceforge.net/xidelecho.php -e //raw

tests/test.sh post6 '<foo>bar</foo>' -e 'v:=/foo' --post 'data={$v}'  http://videlibri.sourceforge.net/xidelecho.php -e //raw
tests/test.sh post6 '<x><foo>bar</foo><raw>OH</raw></x>' -e 'v:=//foo' --post 'data={$v}'  http://videlibri.sourceforge.net/xidelecho.php -e //raw 
tests/test.sh post6b '<x><foo>bar</foo><raw>OH</raw></x>' -e 'v:=//foo' [ --post 'data={$v}'  http://videlibri.sourceforge.net/xidelecho.php -e //raw ] # [ causes it to process both data. Does not make much sense, but is logical
tests/test.sh post6c '<x><foo>bar</foo><raw>OH</raw></x>' -e 'v:=//foo' [ -e "" --post 'data={$v}'  http://videlibri.sourceforge.net/xidelecho.php -e //raw ] 

tests/test.sh put1a  --method=PUT --post test http://videlibri.sourceforge.net/xidelecho.php -e //meth
tests/test.sh put1a  --method=POST --post test --method=PUT http://videlibri.sourceforge.net/xidelecho.php -e //meth    #override last
tests/test.sh put1b  --method=POST --post test --method=PUT http://videlibri.sourceforge.net/xidelecho.php -e //raw
tests/test.sh foobarmeth --method foobar  http://videlibri.sourceforge.net/xidelecho.php -e //meth
echo foobar | tests/test.sh foobarmeth2 --method -  http://videlibri.sourceforge.net/xidelecho.php -e //meth

tests/test.sh multipageonline --extract '<action><variable name="obj">{"url": "http://videlibri.sourceforge.net/xidelecho.php", "method": "PUT"}</variable><page url="{$obj}"><template><meth>{.}</meth></template></page></action>' --extract-kind=multipage
tests/test.sh multipageonline2 --extract '<action><variable name="obj">{"url": "http://videlibri.sourceforge.net/xidelecho.php", "method": "PUT", "post": "foobar&123"}</variable><page url="{$obj}"><template><raw>{outer-xml(.)}</raw></template></page></action>' --extract-kind=multipage

tests/test.sh regression_doconline --xquery '<a/> / doc("http://videlibri.sourceforge.net/xidelecho.php") // meth'
tests/test.sh regression_doclocal --xquery '<a/> / doc("tests/a.xml") // title'
tests/test.sh regression_doclocal --xquery 'doc("tests/a.xml") // title'

#Regressions tests for bugs that have been fixed and should not appear again
tests/test.sh regression_text1a '<r><a>1</a><a>2</a></r>' -e '<r><a>{text()}</a></r>'
tests/test.sh regression_text1b '<r><a>1</a><a>2</a></r>' -e '<r><a>{following-sibling::a/text()}</a></r>'
tests/test.sh regression_text1c '<r><a>1</a><a>2</a></r>' -e '<r><a>{following-sibling::a/(text())}</a></r>'
tests/test.sh regression_text1d '<r><a>1</a><a>2</a></r>' -e '<r><a>{following-sibling::a/concat("-",text(),"-")}</a></r>'
tests/test.sh regression_text1e '<a>1</a>' -f '<a>{object(("url", "&lt;a>2&lt;/a>"))}</a>' -e '/a/concat(">",text(),"<")'

tests/test.sh regression_entity1a '<a>&amp;</a>' -e //a
tests/test.sh regression_entity1b '<a>&amp;amp;</a>' -e //a
tests/test.sh regression_entity1c '<a>&amp;amp;amp;</a>' -e //a
tests/test.sh regression_entity2 -e '"&amp;"'
tests/test.sh regression_entity3a '<a>x</a>' -e '<a>{res := "&amp;"}</a>'
tests/test.sh regression_entity3b '<a>x</a>' -e '<a>{res := "&amp;amp;"}</a>'
tests/test.sh regression_entity3c '<a>x</a>' -e '<a>{res := "&amp;amp;amp;"}</a>'
tests/test.sh regression_entity3d '<a>x</a>' -e '<a>{res := "&amp;amp;amp;amp;"}</a>'

tests/test.sh regression_object1 -e '($x := xs:object(("b","c")), $x.b)' 
tests/test.sh regression_object2 -e '($x := xs:object(("b","c")), $x.a)' #allow accessing undefined properties

tests/test.sh regression_multipage1  -e "<action><page url=\"tests/a.xml\"><template><title>{concat(., \"'\", '\"')}</title></template></page></action>" --extract-kind=multipage
tests/test.sh regression_multipage2 -e "<action><page url=\"tests/a.xml\"><template><title><t:read var=\"res\" source=\" concat(., &quot;'&quot;, '&quot;')\"/></title></template></page></action>" --extract-kind=multipage
tests/test.sh regression_multipage3 -e '<action><page url="http://example.org"><template><title>{resolve-uri("b.xml")}</title></template></page></action>' --extract-kind=multipage
tests/test.sh regression_multipage3b -e '<action><page url="http://example.org/abc/def/ghi"><template><title>{resolve-uri("../b.xml")}</title></template></page></action>' --extract-kind=multipage

tests/test.sh regression_htmlparse '<ol><li>a<li>b<li>c</ol>' -e '/ol/li'