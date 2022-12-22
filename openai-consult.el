;; capf is not so great because the latency is not there yet
;; but an async consult one that sounds great
(defun openai-api-capf ()
  (let* ((beg (min
               (save-excursion
                 (backward-paragraph 1)

                 (point))
               (save-excursion
                 (beginning-of-defun)
                 (point))))
         (end (point))
         (prompt (buffer-substring beg end))
         ;; (completions '())
         ;; (_
         ;;  (openai-api-retrieve
         ;;   `((model . "text-davinci-003")
         ;;     (max_tokens . 14)
         ;;     (temperature . 0)
         ;;     (prompt . ,prompt))
         ;;   (lambda (_status)
         ;;     (setf completions (openai-api-choices)))))
         )
    (list
     end
     end
     (completion-table-dynamic
      (lambda (_)
        (with-current-buffer
            (openai-api-retrieve-sync
             ;; `((model . "text-davinci-003")
             ;;   (max_tokens . 14)
             ;;   (temperature . 0)
             ;;   (prompt . ,prompt))
             `((model . "code-cushman-001")
               (max_tokens . 14)
               (temperature . 0)
               (prompt . ,prompt)))
          (mapcan
           #'opanai-api-split-words
           (openai-api-choices)))))
     ;; (completion-table-dynamic
     ;;  (lambda (&rest _)
     ;;    completions))
     )))

;; make a consult one
;; with -- paradigm for temparature
;; or feed async stuff
