;; https://beta.openai.com/docs/guides/code/inserting-code


(let  ((input
        "(m/shift [[1 0] [1 0] [0 0]] 1 (- 1))\n[[0 1] [0 1] [0 0]]\n(m/shift [[0 1] [0 1] [0 0]]\n      \n        \n")
       (suffix
        ")\n[[0 0]\n [0 1]\n [0 1]]"))
  (cl-loop for i below 5 append
           (with-current-buffer
               (openai-api-retrieve-sync
                `((model . "text-davinci-003")
                  (prompt . ,input)
                  (suffix . ,suffix)
                  (max_tokens . 500)
                  (temperature . ,(* i 0.1))
                  ;; (top_p . 1)
                  ;; (presence_penalty . 0)
                  ;; (stop . ["\n"])
                  ))
             (openai-api-choices-text-1
              (cl-remove-if-not
               (lambda (d)
                 (equal "stop"
                        (assoc-default
                         'finish_reason
                         d)))
               (openai-api-choices))))))
;; lol
'("1
(- 1)"
  "1
(- 1)"
  "        1
        (- 1)"
  "1 (- 1)"
  "        1
        (- 1)")

(let  ((input
        "(m/shift [[1 0] [1 0] [0 0]] 1 (- 1))\n[[0 1] [0 1] [0 0]]\n(m/shift [[0 1] [0 1] [0 0]]\n      \n        \n")
       (suffix
        ")\n[[0 0]\n [0 1]\n [0 1]]"))
  (cl-loop for i below 5 append
           (with-current-buffer
               (openai-api-retrieve-sync
                `((model . "text-davinci-003")
                  (prompt . ,input)
                  (suffix . ,suffix)
                  (max_tokens . 500)
                  (temperature . ,(* i 0.1))
                  ;; (top_p . 1)
                  ;; (presence_penalty . 0)
                  ;; (stop . ["\n"])
                  ))
             (openai-api-choices-text-1
              (cl-remove-if-not
               (lambda (d)
                 (equal "stop"
                        (assoc-default
                         'finish_reason
                         d)))
               (openai-api-choices))))))
