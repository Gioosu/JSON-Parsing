# JSON PARSING

## General Information

**Project Name**: jsonparse.pl & jsonparse.lisp

**Languages**: SWI-Prolog & Common Lisp

**Purpose**: Enabling JSON handling in both Prolog and Common Lisp

## Introduction
Developing web applications on the internet, but not limited to, requires exchanging data between heterogeneous applications, for example, between a web client written in Javascript and a server, and vice versa. A widely used standard for data exchange is the JavaScript Object Notation, or JSON. The purpose of this project is to develop a Prolog library capable of constructing data structures that represent JSON objects from their string representations.

## JSON String Syntax

The JSON syntax is defined on the website https://www.json.org. From the given grammar, a JSON object can be recursively broken down into the following parts, as does the parser:
   - Object
   - Array
   - Value
   - String
   - Number

## Examples

Empty object:

```json
{}
````

Empty array:

```json
[]
````

Object with two items:

```json
{
  "name": "Arthur",
  "surname": "Dent"
}
```

A complex object containing a sub-object, which in turn contains an array of numbers:

```json
{
  "model": "SuperBook 1234",
  "year of production": 2014,
  "processor": {
                "manufacturer": "EsseTi",
                "operating speed (GHz)": [1, 2, 4, 8]
               }
}
```
An example from Wikipedia (a possible menu entry):

```json
{
  "type": "menu",
  "value": "File",
  "items": [
            {"value": "New", "action": "CreateNewDoc"},
            {"value": "Open", "action": "OpenDoc"},
            {"value": "Close", "action": "CloseDoc"}
           ]
}
```

## Guidelines and Requirements

Building a parser for JSON strings as described is required. The input string should be recursively analyzed to construct an appropriate structure for storing its components. The development of a parser guided by the recursive structure of the input text is aimed for. For instance, an array (and its internal composition of elements) should be identified after the discovery of the member it belongs to, and the search mechanism should not restart from the initial string but rather from the result of the member's search itself.

## Syntax Errors

Should the syntax encountered be incorrect, failing in Prolog or reporting an error in Common Lisp by calling the `error` function is necessary.
