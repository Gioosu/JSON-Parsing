; Formisano Giuseppe Lorenzo 885862
; Pretali Riccardo 870452

; jsonparse.lisp

; (jsonparse String)
(defun jsonparse (JSONString)
  (cond ((stringp JSONString) 
         (matching-parens (clean-list (string-to-list JSONString))))
        (T (error "syntax error"))))

; (string-to-list String)
(defun string-to-list (JSONString)
  (cond ((= (length JSONString) 0) nil)
        (T (cons (char JSONString 0)
                 (string-to-list (subseq JSONString 1))))))

; (list-to-string List)
(defun list-to-string (charList)
  (cond ((null charList) "")
        (T (concatenate 'string
                        (string (car charList))
                        (list-to-string (cdr charList))))))

; (matching-parens List)
(defun matching-parens (JSONCharList)
  (cond ((and (eq (car JSONCharList) #\{)
              (eq (car (last JSONCharList)) #\}))
         (jsonobj JSONCharList))
        ((and (eq (car JSONCharList) #\[)
              (eq (car (last JSONCharList)) #\]))
         (jsonarray JSONCharList))
        (T (error "syntax error"))))

; (clean-list List)
(defun clean-list (JSONCharList)
 (remove #\Tab 
         (remove #\NewLine 
                 (remove-spaces JSONCharList 0 nil))))

; (remove-parens List Number Number)
(defun remove-spaces (JSONCharList BQuotes NoSpaceList)
  (cond ((and (null JSONCharList) (null NoSpaceList)) nil)
        ((null JSONCharList) NoSpaceList)
        ((and (eq (car JSONCharList) #\") (eq BQuotes 0)) 
         (remove-spaces (cdr JSONCharList) 
                        1 
                        (append NoSpaceList (list (car JSONCharList)))))
        ((and (eq (car JSONCharList) #\") (eq BQuotes 1)) 
         (remove-spaces (cdr JSONCharList) 
                        0 
                        (append NoSpaceList (list (car JSONCharList)))))
        ((and (eq (car JSONCharList) #\Space) (zerop BQuotes))
         (remove-spaces (cdr JSONCharList) 
                        BQuotes 
                        NoSpaceList))
        (T (remove-spaces (cdr JSONCharList) 
                          BQuotes 
                          (append NoSpaceList (list (car JSONCharList)))))))

; (split List Number Number List)
(defun split (CleanCharList NParens BQuotes PairsList)
  (cond ((and (null CleanCharList) (null PairsList)) nil)
        ((null CleanCharList) (list (pairs-function PairsList 0 0 nil)))
        ((or (eq (car CleanCharList) #\{) 
             (eq (car CleanCharList) #\[) 
             (and (eq (car CleanCharList) #\") 
                  (eq BQuotes 0)))
         (split (cdr CleanCharList)
                (+ NParens 1)
                1
                (append PairsList (list (car CleanCharList)))))
        ((or (eq (car CleanCharList) #\}) 
             (eq (car CleanCharList) #\]) 
             (and (eq (car CleanCharList) #\") 
                  (eq BQuotes 1)))
         (split (cdr CleanCharList)
                (- NParens 1)
                0
                (append PairsList (list (car CleanCharList)))))
        ((and (eq (car CleanCharList) #\,) 
              (zerop NParens) 
              (zerop BQuotes))
         (append (list (pairs-function PairsList 0 0 nil))  
                 (pairs-function (split (cdr CleanCharList) 
                                        NParens
                                        BQuotes
                                        nil)
                                 0
                                 0
                                 nil)))
        (T (split (cdr CleanCharList) 
                  NParens 
                  BQuotes 
                  (append PairsList (list (car CleanCharList)))))))

; (pairs-function List Number Number List)
(defun pairs-function (PairsList NParens BQuotes Result)
  (cond ((and (null PairsList) (null Result)) nil)
        ((null PairsList) Result)
        ((or (eq (car PairsList) #\{) 
             (eq (car PairsList) #\[) 
             (and (eq (car PairsList) #\") 
                  (eq BQuotes 0)))
         (pairs-function (cdr PairsList)
                         (+ NParens 1)
                         1
                         (append Result (list (car PairsList)))))
        ((or (eq (car PairsList) #\}) 
             (eq (car PairsList) #\]) 
             (and (eq (car PairsList) #\") 
                  (eq BQuotes 1)))
         (pairs-function (cdr PairsList)
                         (- NParens 1)
                         0
                   (append Result (list (car PairsList)))))
        ((and (eq (car PairsList) #\:) 
              (zerop NParens) 
              (zerop BQuotes))
         (append (list (jsonstring Result)) 
                 (list (jsonvalue (pairs-function (cdr PairsList)
                                                  0
                                                  0
                                                  nil)))))
        (T (pairs-function (cdr PairsList)
                           NParens 
                           BQuotes 
                           (append Result (list (car PairsList)))))))

; (jsonvalue List)
(defun jsonvalue (List)
  (cond ((null List) (error "syntax error"))
        ((eq (car List) #\") (jsonstring List))
        ((or (eq (car List) #\t) (eq (car List) #\f) (eq (car List) #\n))
         (jsonboolean List))
        ((and (is-number List 0))
         (jsonnumber List))
        ((or (eq (car List) #\{) (eq (car List) #\[))
         (matching-parens List))
        (T  (error "syntax error"))))

; (jsonstring List)
(defun jsonstring (List)
  (cond ((and (eq (car List) #\") (eq (car (last List)) #\"))
         (list-to-string (remove #\" List)))
        (T (error "syntax error"))))

; (jsonboolean List)
(defun jsonboolean (List)
  (cond ((equal (list-to-string List) "true") 'true)
        ((equal (list-to-string List) "false") 'false)
        ((equal (list-to-string List) "null") 'null)
        (T (error "syntax error"))))

;(jsonnumber List)
(defun jsonnumber (List)
 (cond ((null (find #\. List)) (parse-integer (list-to-string List)))
       ((and (not (eq (car List) #\.)) (not (eq (car (last List)) #\.)))
        (parse-float (list-to-string List)))
       (T (error "syntax error"))))

; (is-number List Number)
(defun is-number (List BPoint)
  (cond ((null List) T)
        ((and (not (= (char-int (car List)) 46))
              (or (< (char-int (car List)) 48)
                  (> (char-int (car List)) 57)))
              nil)
        ((and (eq (car List) #\.) (not (zerop BPoint))) nil)
        ((and (eq (car List) #\.) (zerop BPoint)) 
         (is-number (cdr List) 1))
        (T (is-number (cdr List) BPoint))))

; (jsonobj List)
(defun jsonobj (JSONCharList)
  (append (list 'jsonobj)
          (pairs-function (split (remove-parens JSONCharList) 0 0 nil)
                                 0
                                 0
                                 nil)))

; (jsonarray List)
(defun jsonarray (JSONCharList)
  (append (list 'jsonarray)
          (jsonvalue-list (split (remove-parens JSONCharList) 0 0 nil) nil)))

; (jsonvalue-list List List)
(defun jsonvalue-list (List ValuedList)
  (cond ((null List) ValuedList)
        (T (jsonvalue-list (cdr List)
                           (append ValuedList 
                                   (list (jsonvalue (car List))))))))

; (remove-parens List)
(defun remove-parens (List)
  (string-to-list (subseq (list-to-string List)
                          1
                          (- (length (list-to-string List)) 1))))

; (jsonaccesee List Number/String Number/String)
(defun jsonaccess (JSONParse Field &rest Fields)
  (cond ((numberp Field) (jsonaccess-array JSONParse Field Fields))
        ((stringp Field) (jsonaccess-object JSONParse Field Fields))
        (T (error "syntax error"))))

; (jsonaccess-array List Number Number)
(defun jsonaccess-array (JSONArray Position &optional PositionList)
  (cond ((null JSONArray) nil)
        ((stringp Position)
         (jsonaccess-object JSONArray Position PositionList))
        ((or (<= (+ Position 1) 0) (>= (+ Position 1) (length JSONArray)))
         (error "array index out of bound"))
        ((null (car PositionList)) (nth (+ Position 1) JSONArray))
        ((listp (nth (+ Position 1) JSONArray))
         (jsonaccess-array (nth (+ Position 1) JSONArray)
                           (car PositionList)
                           (cdr PositionList)))
        (T (error "syntax error"))))

; (jsonaccess-object List String String)
(defun jsonaccess-object (JSONObj Field &optional PositionList)
  (cond ((null JSONObj) nil)
        ((equal (car JSONObj) 'jsonobj) 
         (jsonaccess-object (cdr JSONObj) Field PositionList))
        ((and (equal (car (car JSONObj)) Field)
              (not (null (car PositionList))))
         (jsonaccess-array (car (cdr (car JSONObj)))
                           (car PositionList)
                           (cdr PositionList)))
        ((equal (car (car JSONObj)) Field) (car (cdr (car JSONObj))))
        (T (jsonaccess-object (cdr JSONObj) Field PositionList))))

; (jsonread String)
(defun jsonread (FileName)
  (with-open-file (In FileName
                      :direction :input
                      :if-does-not-exist :error)
    (jsonparse (list-to-string (read-input In)))))

(defun read-input (In)
  (cond ((listen In) (append (list (read-char In)) (read-input In)))))

; (jsondump List String)
(defun jsondump (JSONParse FileName)
  (with-open-file (out FileName
                      :direction :output
                      :if-exists :supersede
                      :if-does-not-exist :create)
    (format out (jsonreverse JSONParse)) FileName))

; (jsonreverse List)
(defun jsonreverse (JSONParse)
  (list-to-string (jsonvalue-reverse JSONParse)))

; (jsonvalue-reverse List)
(defun jsonvalue-reverse (JSONParse)
  (cond ((null JSONParse) nil)
        ((stringp JSONParse) (append (list #\")
                                     (string-to-list JSONParse) (list #\")))
        ((equal JSONParse 'true) (string-to-list "true"))
        ((equal JSONParse 'false) (string-to-list "false"))
        ((equal JSONParse 'null) (string-to-list "null"))
        ((numberp JSONParse) (string-to-list (write-to-string JSONParse)))
        ((equal (car JSONParse) 'jsonarray)
         (append (list #\[)
                 (fix-array (mapcar 'jsonvalue-reverse (cdr JSONParse)) nil)
                 (list #\])))
        ((equal (car JSONParse) 'jsonobj)
         (append (list #\{)
                 (fix-object (mapcar 'jsonvalue-reverse (cdr JSONParse)) nil)
                 (list #\})))
        (T (mapcar 'jsonvalue-reverse JSONParse))))

; (fix-object List List)
(defun fix-object (List FixedList)
  (cond ((null List) FixedList)
        ((null FixedList) (fix-object (cdr List) (fix-pairs (car List))))
        (T (fix-object (cdr List)
                       (append FixedList (list #\,)
                                         (list #\Space)
                                         (fix-pairs (car List)))))))

; (fix-pairs List)
(defun fix-pairs (List)
  (append (first List) (list #\Space) (list #\:)
                       (list #\Space) (second List)))

; (fix-array List List)
(defun fix-array (List FixedList)
  (cond ((null List) FixedList)
        ((null FixedList) (fix-array (cdr List) (first List)))
        (T (fix-array (cdr List)
                      (append FixedList (list #\,)
                                        (list #\Space) (first List))))))

; 42