# XMLElement
XMLElement allows for easy, dictionary-style handling of XML.
## Basic Use
###"Installation"
XMLElement.swift is just a .swift file.  At the moment, the easiest way to use it is to just copy it into your project.
###Structure
XMLElements are recursive, with each one representing an element in the parsed XML.  Each XMLElement has 6 properties:

```
var tag: String?
var attributes: [String: String]!
var contents: String?
var children = [String: [XMLElement]]()
var childList = [XMLElement]()
var parent: XMLElement?
var childTags: [String]
```

Let's consider the following piece of XML:

```
<thisIsATag attribute=4>This is a test</thisIsATag >
```

The first property of an XMLElement, `tag`, is what it sounds like: the tag.  For example, in this piece of XML the tag would be `thisIsATag`.  

Next, `attributes` is a dictionary of all the attributes in this element.  Here it would look something like `["attribute": "4"]`.

`contents` refers to everything inside the element itself.  Here the contents would be `"This is a test"`.  Contents are passed up recursively, so a higher-level element will always contain the source for lower level ones in it's contents.  For example, in:

```
<a><b>test</b><c>another test</c></a>
```

the contents of `b` would be `"test"`, the contents of `c` would be `"another test"`, and the contents of `a` would be `"<b>test</b><c>another test</c>"`.

`children` should not be used often.  It maps tags to child XMLElements in a dictionary.  The children are in lists so that multiple child elements with the same tag can be stored.  Subtract syntax can almost always be used instead.

`childList` is the list of all child elements.

`parent` is largely for internal use.  It refers to the parent of a given element.

The last property, `childTags` is a computed property, primarily for convenience.  It just represents the list of tags of all the children.

###Creation
To create an XMLElement, first you have to pass it an NSXMLParser.  This allows for all the flexibility of datasources which NSXMLParser provides.

```
let url = NSURL(string: "http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml")
let parser = NSXMLParser(contentsOfURL: url!)

let xml = XMLElement(parser: parser!)
xml.parse()
```

The `xml.parse()` at the end populates the XMLElement.

###Querying
XMLElements can be queried a bit like dictionaries or lists, with subscripts of keys or indices.  Continuing with the example above (with the New York Times RSS feed) we can see what the tag of our root is by running:

```
print(xml.tag)
```

In the case of an RSS feed, the root should be `rss`.  To explore a bit further, we can take advantage of the property `childTags`:

```
print(xml.childTags)
```

This returns `["channel"]`.  That tells us that under `rss` (the root) there is a single element called `channel`.  We can access it using a subscript:

```
xml["channel"]
```

This will return the first element with the tag channel.  This is one reason why subscripts are often more convenient than using the `children` property.  `children` contains lists of elements, so to get `channel` we would have to run something like:

```
xml.children["channel"]?[0]
```

Also notice that (in both these cases) the result is optional.

We could now explore a bit under the channel:

```
print(xml["channel"]?.childTags)
```

that prints something like:

```
Optional(["atom:link", "title", "link", "description", "language", "copyright", "pubDate", "lastBuildDate", "ttl", "image", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item", "item"])
```

If we wanted to look at the first element with the tag `item`, we could run something like `xml["channel"]?["item"]`.  And if we wanted, for example, the title of that item we could run something like `xml["channel"]?["item"]?["title"]?.contents`.  Of course intermediate steps could also be stored:

```
let item = xml["channel"]?["item"]
print(item?["title"]?.contents)
```

We could also get all the `item`s with subscripts by running something like `xml["channel"]?["item", .All]`.  The `.All` is an element of an enum.  Other options include `.First` and `.Last`.  This will return all the elements with the tag `"item"`.  If we wanted all the titles of all the `item`s we could run `xml["channel"]?["item", .All]?.map({$0["title"]?.contents})`.

Subscripts can also be given indices.  Something like `xml["channel"]?[0]`.