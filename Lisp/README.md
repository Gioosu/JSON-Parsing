## Common Lisp Implementation

The implementation in Common Lisp is required to provide two functions. Firstly, a `jsonparse` function that accepts a string and produces a structure similar to that illustrated for the Prolog implementation. Secondly, a `jsonaccess` function that takes a JSON object (represented in Common Lisp, as produced by the `jsonparse` function) and a series of "fields" to retrieve the corresponding object. A field represented by N (with N being a number greater than or equal to 0) indicates an index of a JSON array.

The syntax for JSON objects in Common Lisp is defined as follows:
- Object = `'(jsonobj members)`
- Object = `'(jsonarray elements)`

And recursively:
- members = pair*
- pair = `'(attribute value)`
- attribute = `<Common Lisp string>`
- number = `<Common Lisp number>`
- value = string | number | Object
- elements = value*

### Examples

```lisp
CL-prompt> (defparameter x (jsonparse "{\"name\" : \"Arthur\", \"surname\" : \"Dent\"}"))
X

CL-prompt> x
(JSONOBJ ("name" "Arthur") ("surname" "Dent"))

CL-prompt> (jsonaccess x "surname")
"Dent"

CL-prompt> (jsonaccess (jsonparse "{\"name\" : \"Zaphod\", \"heads\" : [[\"Head1\"], [\"Head2\"]]}") "heads" 1 0)
"Head2"

CL-prompt> (jsonparse "[1, 2, 3]")
(JSONARRAY 1 2 3)

CL-prompt> (jsonparse "{}")
(JSONOBJ)

CL-prompt> (jsonparse "[]")
(JSONARRAY)

CL-prompt> (jsonparse "{]")
ERROR: syntax error

CL-prompt> (jsonaccess (jsonparse " [1, 2, 3] ") 3) ; Arrays are 0-based.
ERROR: ...
```

## Input/Output from and to Files

Two functions for reading from and writing to files are required to be provided by the library:
- `jsonread(filename) -> JSON`
- `jsondump(JSON, filename) -> filename`

The `jsonread` function opens the file `filename` and returns a JSON object (or generates an error). If the file `filename` does not exist, an error is generated. It is recommended to read the entire file into a string and then call `jsonparse`.

The `jsondump` function writes the JSON object to the file `filename` in JSON syntax. If the file `filename` does not exist, it is created; if it exists, it is overwritten. It is expected that:
```lisp
CL-PROMPT> (jsonread (jsondump '(jsonobj #| stuff |#) "foo.json"))
(JSONOBJ #| stuff |#)
```
