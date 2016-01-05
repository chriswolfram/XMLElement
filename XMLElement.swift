//
//  XMLElement.swift
//
//  Copyright (c) 2016 Christopher Wolfram
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

class XMLElement: NSObject, NSXMLParserDelegate
{
    var tag: String!
    var attributes: [String: String]!
    var contents: String?
    var children = [String: [XMLElement]]()
    var childList = [XMLElement]()
    var parent: XMLElement?
    
    var childTags: [String]
    {
        get
        {
            return self.childList.map({$0.tag})
        }
    }
    
    enum XMLElementParts
    {
        case All
        case First
        case Last
    }
    
    private let xmlParser: NSXMLParser!
    
    required init(parser: NSXMLParser)
    {
        self.xmlParser = parser
    }
    
    subscript(index: Int) -> XMLElement?
    {
        return self.childList[index]
    }
    
    subscript(key: String) -> XMLElement?
    {
        return self.children[key]?[0]
    }
    
    subscript(key: String, p: XMLElementParts) -> [XMLElement]?
    {
        switch p
        {
        case .All: return self.children[key]
        case .First: return [self.children[key]![0]]
        case .Last: return [self.children[key]!.last!]
        }
    }
    
    func parse()
    {
        xmlParser.delegate = self
        xmlParser.parse()
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if contents == nil
        {
            contents = ""
        }
        
        self.contents! += string
        parent?.parser(parser, foundCharacters: string)
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        if self.tag != nil
        {
            let child = XMLElement(parser: xmlParser)
            xmlParser.delegate = child
            child.parent = self
            child.tag = elementName
            child.attributes = attributeDict
            
            self.childList.append(child)
            
            if self.children[child.tag!] != nil
            {
                self.children[child.tag!]?.append(child)
            }
                
            else
            {
                self.children[child.tag!] = [child]
            }
        }
        
        else
        {
            self.tag = elementName
            self.attributes = attributeDict
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if self.tag == elementName
        {
            xmlParser.delegate = parent
        }
    }
}