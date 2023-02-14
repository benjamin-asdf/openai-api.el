(defun science-bot-structured (question)
  (let ((input (format
                "I am a science bot. I give scientific answers.
I am a lisp machine and I will answer with machine readable structured data.

Q: The major taxa of insects are

Output:
((topics . (zoology entomology taxonomy))
 (taxa .
       ((Coleoptera beetles)
        (Diptera flies)
        (Hymenoptera ants bees wasps)
        (Lepidoptera butterflies moths)
        (Hemiptera true-bugs)
        (Orthoptera grasshoppers crickets katydids)
        (Isoptera termites))))

Q: %s"
                question)))
    (with-current-buffer-window
        "*science-bot*"
        nil
        nil
      (insert question "\n")
      (cl-loop
       for
       answer
       (openai-api-sync
        (list
         `((model . "text-davinci-003")
           (prompt . ,input)
           (top_p . 1)
           (max_tokens . 512)
           (temperature . 0.5)
           (presence_penalty . 0))))
       do
       (insert answer))
      (buffer-string))))

(science-bot-structured "The major topics of psychology")

;; The major topics of psychology

;; Output:

(defvar my-response
  '((topics . (psychology))
    (subtopics .
               ((cognitive psychology)
                (developmental psychology)
                (personality psychology)
                (social psychology)
                (abnormal psychology)
                (clinical psychology)))))

(length (assoc 'subtopics my-response))
7
