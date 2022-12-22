;; https://beta.openai.com/examples/default-time-complexity

(let ((input "def foo(n, k):
accum = 0
for i in range(n):
    for l in range(k):
        accum += i
return accum
\"\"\"
The time complexity of this function is"))
  (openai-api-sync
   (list
    `((model . "text-davinci-003")
      (prompt . ,input)
      (top_p . 1)
      (max_tokens . 64)
      (temperature . 0)
      (stop . ["\n"])))))
'(" O(n*k). This is because the function has two nested for loops, each of which iterates n and k times respectively. Therefore, the total number of iterations is n*k, which is the time complexity of the function.")

;; putting ;; clojure-mode on top turns out to be a crucial hint (for the explanation)
(let ((input ";; clojure-mode
(for [x (range n)
      y (range j)]
     [x y])

;; The time complexity of this function is"))
  (openai-api-sync
   (list
    `((model . "text-davinci-003")
      (prompt . ,input)
      (top_p . 1)
      (max_tokens . 64)
      (temperature . 0)
      (stop . ["\n"])))))

'(" O(n*j). This is because the loop is iterating over two ranges, n and j, and the time complexity is the product of the two ranges.")
'
;; it doesn't do the explanation when I don't have comment syntax
(let ((input ";; clojure-mode
(for [x (range n)
      y (range j)]
     [x y])

The time complexity of this function is"))
  (openai-api-sync
   (list
    `((model . "text-davinci-003")
      (prompt . ,input)
      (top_p . 1)
      (max_tokens . 200)
      (temperature . 0)
      (stop . ["\n"])))))
'(" O(n*j).")
;; this actually turned out cool

(defun openai-improve-suggestions ()
  (interactive)
  (let ((input
         (format ";; clojure-mode
%s

;; This code can be improved in the following ways: "
                 (buffer-substring-no-properties (region-beginning)
                                                 (region-end)))))
    (with-current-buffer-window "output"
        nil
        nil
      (cl-loop for res in
               (openai-api-sync
                (list
                 `((model . "text-davinci-003")
                   (prompt . ,input)
                   (max_tokens . 256)
                   (temperature . 0.8))))
               do (insert res)))))



;; like this you get readme text lol

(let ((input "Implement union-find data structure in clojure"))
  (openai-api-sync
   (list
    `((model . "code-davinci-002")
      (prompt . ,input)
      (max_tokens . 200)
      (temperature . 0)
      (top_p . 1)))))
