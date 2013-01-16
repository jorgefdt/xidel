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

tests/test.sh tfe  tests/a.xml -f //a     -e //title
tests/test.sh tfe2 tests/b.xml -f //a     -e //title

#read title from both
tests/test.sh 2urls tests/a.xml -e //title tests/b.xml -e //title 
#not separated urls
tests/test.sh 2urls2read tests/a.xml tests/b.xml -e //title -e //title



#stdin
echo '<test>123<x/>foo<abc>bar</abc>def<x/></test>' | tests/test.sh stdin1 - -e //abc
echo //abc2 | tests/test.sh stdin2 '<test>123<x/>foo<abc2>bar2!</abc2>def<x/></test>' -e -

#multipage template
tests/test.sh multipage --extract '<action><page url="tests/a.xml"><template><title>{.}</title></template></page></action>' --extract-kind=multipage
tests/test.sh multipage2  --extract '<action><loop var="page" list='"'"'("tests/a.xml", "b.xml")'"'"'><page url="$page;"><template><title>{.}</title></template></page></loop></action>' --extract-kind=multipage

#output formats
tests/test.sh adhoc1 tests/a.xml --extract "<a>{.}</a>*" 
tests/test.sh xml1 tests/a.xml --extract "<a>{.}</a>*" --output-format xml-wrapped
tests/test.sh json1 tests/a.xml --extract "<a>{.}</a>*" --output-format json-wrapped
tests/test.sh json1 tests/a.xml --extract "<a>{.}</a>*" --output-format json  #deprecated
tests/test.sh xml1b tests/a.xml --output-format xml-wrapped --extract "<a>{.}</a>*" 
tests/test.sh json1b tests/a.xml --output-format json-wrapped --extract "<a>{.}</a>*" 
tests/test.sh json1b tests/a.xml --output-format json --extract "<a>{.}</a>*"  #deprecated

tests/test.sh adhoc2 tests/a.xml tests/b.xml -e "<a>{.}</a>*"
tests/test.sh xml2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format xml-wrapped
tests/test.sh json2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format json-wrapped
tests/test.sh json2 tests/a.xml tests/b.xml -e "<a>{.}</a>*" --output-format json  #deprecated
tests/test.sh xml2b tests/a.xml tests/b.xml --output-format xml-wrapped -e "<a>{.}</a>*" 
tests/test.sh json2b tests/a.xml tests/b.xml --output-format json-wrapped -e "<a>{.}</a>*" 
tests/test.sh json2b tests/a.xml tests/b.xml --output-format json -e "<a>{.}</a>*"  #deprecated

tests/test.sh adhoc3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*"  
tests/test.sh xml3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format xml-wrapped
tests/test.sh json3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format json-wrapped
tests/test.sh json3 tests/a.xml tests/b.xml --extract "<title>{title:=.}</title><a>{.}</a>*" --output-format json #deprecated option

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
tests/test.sh nest2b tests/a.xml -e //title [ -f //a -e //title ]
tests/test.sh nest2c tests/a.xml  [ -f //a -e //title ] -e //title
tests/test.sh nest2d tests/a.xml -e //title [ -f //a -e //title ] -e //title
tests/test.sh nest3a [ tests/a.xml tests/b.xml ] -e //title
tests/test.sh nest3a tests/a.xml tests/b.xml -e //title
tests/test.sh nest3a -e //title [ tests/a.xml tests/b.xml ]  #brackets prevent sibling creation (good??)
#tests/test.sh nest3a -e //title tests/a.xml tests/b.xml #only left match ? good??
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

#Online test
tests/test.sh google http://www.google.de -e "count(//title[contains(text(),\"Google\")])"

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
