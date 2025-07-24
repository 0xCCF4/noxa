## defaults

Default options applied to all nodes\.



*Type:*
anything



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes)



## nodeNames



A list of node names managed by Noxa\. Due to the architecture of Noxa,
noxa modules might unwillingly create new nodes, this list contains the name of all nodes
that are currently managed by Noxa\. Noxa modules can check this list to see if a node
was created by themselves\.

````
  The user must set this to the listOf all nodes they want to manage, otherwise if you
  don't care, set this to `attrNames config.nodes`.
````



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [noxa/modules/noxa/nodes](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes)



## nodes



A set of nixos hosts managed by Noxa\.



*Type:*
attribute set of anything



*Default:*
` { } `

*Declared by:*
 - [noxa/modules/noxa/nodes](https://github.com/0xCCF4/noxa/tree/main/modules/noxa/nodes)


