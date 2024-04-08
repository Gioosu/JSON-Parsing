% Formisano Giuseppe Lorenzo 885862
% Pretali Riccardo 870452

% -*- Mode: Prolog -*-
% jsonparser.pl

jsonparse('{}', jsonobj([])) :- !.
jsonparse('}', _) :- !, fail.
jsonparse(']', _) :- !, fail.

% jsonparse(String, jsonobj(List))
jsonparse(JsonString, jsonobj(Result)) :-
    atomic(JsonString),
    term_string(JsonObject, JsonString),
    JsonObject =.. [{},  Body], !,
    split(Body, Pairs),
    jsonobj(Pairs, Result).

% jsonparse(Term, jsonobj(List))
jsonparse(JsonString, jsonobj(Result)) :-
    JsonString =.. [{}, (Body)], !,
    split(Body, Pairs),
    jsonobj(Pairs, Result).

% jsonparse(String, jsonarray(List))
jsonparse(JSONString, jsonarray(Result)) :-
    atomic(JSONString), !,
    term_string(Object, JSONString),
    jsonarray(Object, Result).

% jsonparse(Term, jsonarray(List))
jsonparse(JSONString, jsonarray(Result)) :-
    jsonarray(JSONString, Result).

split((Field : Attribute), [Field : Attribute]) :- !.

split(Pairs, [Pair | L]) :-
    Pairs =.. [',', Pair, OtherPairs],
    split(OtherPairs, L).

% jsonvalue(String, String)
jsonvalue(Value, Value) :-
    string(Value), !.

% jsonvalue(Number, Number)
jsonvalue(Value, Value) :-
    number(Value), !.

% jsonvalue(Term, Term)
jsonvalue(true, true) :- !.
jsonvalue(false, false) :- !.
jsonvalue(null, null) :- !.

% jsonvalue(Term, Term)
jsonvalue(Value, FixedValue) :-
    jsonparse(Value, FixedValue).

% jsonobj(List, List)
jsonobj([], []) :- !.
jsonobj([Pair | MoreMembers], [FixPair | FixMoreMembers]) :-
    jsonmember(Pair, FixPair),
    jsonobj(MoreMembers, FixMoreMembers).

% jsonmember(Term, Term)
jsonmember(Pair, FixPair) :-
    Pair =.. [':', Attribute, Value],
    string(Attribute),
    jsonvalue(Value, FixedValue),
    FixPair = (Attribute, FixedValue).

% jsonarray(List, List)
jsonarray([], []) :- !.
jsonarray([Value | MoreElements], [FixedValue | FixMoreElements]) :-
    jsonvalue(Value, FixedValue),
    jsonarray(MoreElements, FixMoreElements).

% jsonaccess(Term, List, Value)
jsonaccess(jsonarray(O), [Field], X) :-
    number(Field), !,
    findElement(O, Field, X).

jsonaccess(O, [Field], X) :- !,
    jsonaccess(O, Field, X).

jsonaccess(O, [Field | Altri], X) :- !,
    jsonaccess(O, [Field], Result),
    jsonaccess(Result, Altri, X).

jsonaccess(jsonobj([(Field, X) | _]), Field, X) :- !.

jsonaccess(jsonobj([_ | Os]), Field, X) :- !,
    jsonaccess(jsonobj(Os), Field, X).

% findElement(List, Number, Value)
findElement([X | _], 0, X) :- !.
findElement([_ | Xs], P, X) :-
    P > 0,
    Q is P - 1,
    findElement(Xs, Q, X).

% jsondump(Term, Atom)
jsondump(JsonText, File) :-
    open(File, write, Out),
    jsonReverse(JsonText, JsonReverse),
    term_string(JsonReverse, JsonString),
    jsonFixReverse(JsonString, JsonFixed),
    write(Out, JsonFixed),
    close(Out).

% jsonread(Atom, String)
jsonread(File, JsonParsed) :-
    open(File, read, In),
    read_string(In, _, String),
    term_string(Term, String),
    jsonparse(Term, JsonParsed),
    close(In).

% jsonReverse(jsonobj(List), Term)
jsonReverse(jsonobj([]), {}) :- !.

jsonReverse(jsonobj(Obj), Result) :-
    jsonReverse(Obj, ObjReverse),
    Result =.. [{},  ObjReverse].

jsonReverse([(Field, Attribute)], Result) :-
    jsonReverse(Attribute, ObjReverse), !,
    Result =.. [':', Field, ObjReverse].

jsonReverse([(Field, Attribute)], Result) :- !,
    Result =.. [':', Field, Attribute].

jsonReverse([(Field, Attribute) | Objs], (Result, Results)) :-
    jsonReverse(Attribute, ObjReverse), !,
    Result =.. [':', Field, ObjReverse],
    jsonReverse(Objs, Results).

jsonReverse([(Field, Attribute) | Objs], (Result, Results)) :- !,
    Result =.. [':', Field, Attribute],
    jsonReverse(Objs, Results).

% jsonReverse(jsonarray(List), List)
jsonReverse([], []) :- !.

jsonReverse(jsonarray(List), Result) :-
    jsonReverse(List, Result).

jsonReverse([Element], [Result]) :-
    jsonReverse(Element, Result), !.

jsonReverse([Element], [Element]) :- !.

jsonReverse([Element | Elements], [ElementReverse | Results]) :-
    jsonReverse(Element, ElementReverse), !,
    jsonReverse(Elements, Results).

jsonReverse([Element | Elements], [Element | Results]) :-
    jsonReverse(Elements, Results).

jsonFixReverse(String, FixedString) :- !,
    string_chars(String, Chars),
    jsonFix(Chars, FixedChars),
    string_chars(FixedString, FixedChars).
jsonFix([], []) :- !.
jsonFix([',' | Elements], [',', ' ' | FixedElements]) :- !,
    jsonFix(Elements, FixedElements).
jsonFix([':' | Elements], [' ', ':', ' ' | FixedElements]) :- !,
    jsonFix(Elements, FixedElements).
jsonFix([Element | Elements], [Element | FixedElements]) :-
    jsonFix(Elements, FixedElements).

% 42
