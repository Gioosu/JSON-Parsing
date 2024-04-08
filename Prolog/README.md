## Prolog Implementation

The implementation in Prolog requires defining two predicates: `jsonparse/2` and `jsonaccess/3`.

- The `jsonparse/2` predicate is defined as `jsonparse(JSONString, Object)`. It evaluates to true if `JSONString` (a SWI Prolog string or a Prolog atom) can be decomposed into a string, number, or into composite terms:
  - Object = `jsonobj(Members)`
  - Object = `jsonarray(Elements)`
And recursively:
  - Members = `[]` or `[Pair | MoreMembers]`
  - Pair = `(Attribute, Value)`
  - Attribute = `<SWI Prolog string>`
  - Number = `<Prolog number>`
  - Value = `<SWI Prolog string>` | Number | Object
  - Elements = `[]` or `[Value | MoreElements]`

- The `jsonaccess/3` predicate is defined as `jsonaccess(Jsonobj, Fields, Result)`. It evaluates to true when `Result` is retrievable by following the chain of fields present in `Fields` (a list) starting from `Jsonobj`. A field represented by N (where N is a number greater than or equal to 0) corresponds to an index in a JSON array. Special cases include handling `jsonaccess(Jsonobj, Field, Result)` where `Field` is a SWI Prolog string.

### Examples

```prolog
?- jsonparse('{"name" : "Arthur", "surname" : "Dent"}', O), jsonaccess(O, ["name"], R).
O = jsonobj([("name", "Arthur"), ("surname", "Dent")])
R = "Arthur"

?- jsonparse('{"name": "Arthur", "surname": "Dent"}', O), jsonaccess(O, "name", R).
O = jsonobj([("name", "Arthur"), ("surname", "Dent")])
R = "Arthur"

?- jsonparse('{"name" : "Zaphod", "heads" : ["Head1", "Head2"]}', Z), jsonaccess(Z, ["heads", 1], R).
Z = jsonobj([("name", "Zaphod"), ("heads", jsonarray(["Head1", "Head2"]))])
R = "Head2"
```

## Input/Output from and to Files

Two predicates for reading from and writing to files must be provided by the library:
- `jsonread(FileName, JSON).`
- `jsondump(JSON, FileName).`

The `jsonread/2` predicate opens the file FileName and succeeds if it can construct a JSON object. If FileName does not exist, the predicate fails. It is suggested to read the entire file into a string and then invoke `jsonparse/2`.

The `jsondump/2` predicate writes the JSON object to the file FileName in JSON syntax. If FileName does not exist, it is created; if it exists, it is overwritten. It is expected that:
```lisp
?- jsondump(jsonobj([/* stuff */]), 'foo.json'), jsonread('foo.json', JSON).
JSON = jsonobj([/* stuff */])
```

Note: The content of the file foo.json written by `jsondump/2` must be standard JSON, meaning that attributes must be written as strings and not as atoms.
