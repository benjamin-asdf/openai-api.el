;;; openai.el --- openai api bindings for interactive development  -*- lexical-binding: t; -*-

;;; Commentary:

;; This package provides bindings for openai apis
;;
;; - edit
;; - completions
;;
;; You need to set `openai-api-key`


;; right now it is your problem to manually
;; fix the code from the result buff
;; but I don't want to override your buffer file
;; maybe some scratch experience
;; with hist

;;; Code:


(defcustom openai-api-key
  nil
  "Credentials for openai.

This can be set to a string or a function that returns a string.

If you use `auth-sources' (eg.  pass) then you can set this to a
function that calls `auth-source-user-or-password' with the
appropriate parameters."
  :type 'string
  :group 'openai)

(defvar openai-api-urls `(:edit "https://api.openai.com/v1/edits"
                                :completion "https://api.openai.com/v1/completions"))

(defcustom openai-api-eval-spinner-type
  'progress-bar-filled
  "Appearance of the instruction edit spinner.

See `spinner-types' variable."
  :type '(choice (vector :tag "Custom")
                 (symbol :tag "Predefined" :value 'progress-bar-filled)
                 (list :tag "List"))
  :group 'openai-api)

(defcustom openai-api-show-eval-spinner t
  "When true, show the evaluation spinner in the mode line."
  :type 'boolean
  :group 'openai-api)

(defcustom openai-api-eval-spinner-delay 1
  "Amount of time, in seconds, after which the evaluation spinner will be shown."
  :type 'integer
  :group 'openai-api)


(defcustom openai-api-response-buffer-ediff-key "C-c C-e"
  "A kbd key for `openai-api-edit-ediff-buffers'.
This is locally bound in edit response buffers.
Set this to `nil' to disable this behaviour."
  :type 'string
  :group 'openai-api)

(defconst openai-api-edit-buffer "*ai-instructions*"
  "Buffer to use for the openai edit instructions prompt")

(defvar-local openai-api-edit-target-buffer nil)

(defvar openai-api-edit-instructions-history nil)

(defcustom openai-api-balance-parens-fn
  (if (fboundp 'lispy--balance) #'lispy--balance
    #'openai-api-balance-parens)
  "Function to balance parens.")

(defvar openai-api-edit-models
  '((code-davinci . "code-davinci-edit-001")
    (text-davinci . "text-davinci-edit-001")))

(defvar openai-api-completion-models
  '((text-davinci . "text-davinci-003")
    (code-davinci . "code-davinci-002")))

(defun openai-api-balance-parens (str)
  (let ((parens-count 0)
	(brackets-count 0)
	(braces-count 0)
	(new-str ""))
    (dolist (char (string-to-list str))
      (cond ((eq char ?\()
	     (setq parens-count (1+ parens-count))
	     (setq new-str (concat new-str (char-to-string char))))
	    ((eq char ?\))
	     (setq parens-count (1- parens-count))
	     (setq new-str (concat new-str (char-to-string char))))
	    ((eq char ?\[)
	     (setq brackets-count (1+ brackets-count))
	     (setq new-str (concat new-str (char-to-string char))))
	    ((eq char ?\])
	     (setq brackets-count (1- brackets-count))
	     (setq new-str (concat new-str (char-to-string char))))
	    ((eq char ?\{)
	     (setq braces-count (1+ braces-count))
	     (setq new-str (concat new-str (char-to-string char))))
	    ((eq char ?\})
	     (setq braces-count (1- braces-count))
	     (setq new-str (concat new-str (char-to-string char))))
	    (t
	     (setq new-str (concat new-str (char-to-string char))))))
    (while (> parens-count 0)
      (setq new-str (concat new-str ")"))
      (setq parens-count (1- parens-count)))
    (while (< parens-count 0)
      (setq new-str (concat "(" new-str))
      (setq parens-count (1+ parens-count)))
    (while (> brackets-count 0)
      (setq new-str (concat new-str "]"))
      (setq brackets-count (1- brackets-count)))
    (while (> braces-count 0)
      (setq new-str (concat new-str "}"))
      (setq braces-count (1- braces-count)))
    new-str))

(defun opanai-api-split-words (string)
  "Split STRING into a list of substrings, each containing one more word."
  (let ((words (split-string string " " t)))
    (cl-loop for i from 1 to (length words)
             collect (mapconcat 'identity (cl-subseq words 0 i) " "))))

(defun openai-api-choices ()
  "Return a list of choices from the current buffer."
  (let ((s (buffer-string)))
    (with-temp-buffer
      (setq buffer-file-coding-system
            'utf-8)
      (insert s)
      (decode-coding-region
       (point-min)
       (point-max)
       'utf-8)
      (goto-char (point-min))
      (let ((data (when (re-search-forward
                         "\n\n"
                         nil
                         t)
                    (json-read))))
        (when (or (not data)
                  (assoc-default 'error data))
          (pop-to-buffer
           (current-buffer))
          (error
           "Error response from openai"))
        (assoc-default 'choices data)))))

(defun openai-api-choices-text-1 (choices)
  ""
  (cl-map 'list (lambda (d) (assoc-default 'text d)) choices))

(defun openai-api-choices-text ()
  "Return a list of choices from the current buffer."
  (openai-api-choices-text-1 (openai-api-choices)))

(defun openai-api-retrieve (data cb &optional cbargs endpoint)
  "Retrieve DATA from the openai API.

CB is a function to call with the results.

CBARGS is a list of arguments to pass to CB.

ENDPOINT is the API endpoint to use."
  (let ((url-request-method "POST")
        (url-request-extra-headers `(("Content-Type" . "application/json")
                                     ("Authorization" . ,(concat
                                                          "Bearer "
                                                          openai-api-key))))
        (url-request-data (json-encode data)))
    (url-retrieve
     (plist-get openai-api-urls (or endpoint :completion))
     cb
     cbargs)))

(defun openai-api-retrieve-sync (data &optional endpoint)
  "Retrieve DATA from the openai API.

ENDPOINT is the API endpoint to use."
  (let*
      ((url-request-method "POST")
       (url-request-extra-headers `(("Content-Type" . "application/json")
                                    ("Authorization" . ,(concat
                                                         "Bearer "
                                                         openai-api-key))))
       (endpoint
        (plist-get
         openai-api-urls
         (or (assoc-default 'endpoint data)
             (let ((model (assoc-default 'model data)))
               (cond
                ((rassoc model openai-api-completion-models) :completion)
                ((rassoc model openai-api-edit-models) :edit)
                (t  :completion))))))
       (data (assq-delete-all :endpoint data))
       (url-request-data (json-encode data)))
    (url-retrieve-synchronously endpoint)))

(defun openai-api-sync (strategies)
  (cl-loop
   for strat in strategies
   append (with-current-buffer (openai-api-retrieve-sync strat)
            (mapcar openai-api-balance-parens-fn (openai-api-choices-text)))))

(defun openai-api-completions ()
  "Try to use a fast model for completions of smaller size."
  (interactive)
  (let* ((beg (min
               (save-excursion
                 (backward-paragraph 1)
                 (point))
               (save-excursion
                 (beginning-of-defun)
                 (point))))
         (end (point))
         (prompt (buffer-substring beg end)))
    (insert
     (completing-read
      "code-cushman-001: "
      (with-current-buffer
          (openai-api-retrieve-sync
           `((model . "code-cushman-001")
             (max_tokens . 30)
             (temperature . 0)
             (prompt . ,prompt)))
        (mapcar openai-api-balance-parens-fn
                (mapcan
                 #'opanai-api-split-words
                 (openai-api-choices-text))))))))

(defun openai-api-buffer-backwards-dwim ()
  (if
      (region-active-p)
      (buffer-substring
       (region-beginning)
       (region-end))
      (let* ((beg (save-excursion
                    (cl-loop for i from (point) downto (1+ (point-min))
                             do (forward-char -1)
                             finally return (point))))
             (end (point))
             (input))
        (buffer-substring beg end))))

(defun openai-api-completion-completing-read-1 (strategies)
  (insert
   (completing-read
    "AI completions: "
    (openai-api-sync strategies))))

(defun openai-api-complete-text-small ()
  (interactive)
  (insert
   (completing-read
    "AI completions: "
    (mapcan (lambda (s) (split-string s "\n"))
	    (openai-api-sync
	     (list
	      `((model . ,(assoc-default
			   'text-davinci
			   openai-api-completion-models))
		(prompt . ,(openai-api-buffer-backwards-dwim))
		(max_tokens . 100)
		(temperature . 0)
		(top_p . 1)
		(frequency_penalty . 0)
		(presence_penalty . 0))))))))

(defun openai-api-complete-code-thoroughly ()
  "Complete code using OpenAI API."
  (interactive)
  (let ((prompt (openai-api-buffer-backwards-dwim)))
    (openai-api-completion-completing-read-1
     `((model .  "code-davinci-002")
       (max_tokens . ,(* 4 256))
       (temperature . 0)
       (prompt . ,prompt)))))

(defun openai-api-edit-response-finnish ()
  "Finish editing and insert response into the target buffer."
  (interactive)
  (let ((s (buffer-string)))
    (with-current-buffer openai-api-edit-target-buffer
      (goto-char (point-max))
      (insert s))))

(defun openai-api-spinner-start (buffer)
  "Start the evaluation spinner in BUFFER.
Do nothing if `openai-api-show-eval-spinner' is nil."
  (when openai-api-show-eval-spinner
    (with-current-buffer buffer
      (spinner-start openai-api-eval-spinner-type nil
                     openai-api-eval-spinner-delay))))

;; and then we can try to merge the resp and the target buffer
;; with options to add to top or bottom, or try the merge

(defun opanai-api-latest-used-buffer (buffs)
  (car
   (mapcar #'cdr (sort (mapcan
                        (lambda (b)
                          (with-current-buffer b
                            (if-let ((w (get-buffer-window b)))
                                (list (cons (window-use-time w)
                                            (current-buffer))))))
                        buffs)
                       (lambda (a b) (> (car a) (car b)))))))

(defun openai-api-edit-resp-buffer-p (buffer)
  (with-current-buffer buffer openai-api-edit-target-buffer))

;; maybe make you select buffer with prefix command

(defun openai-api-read-instruction ()
  (read-from-minibuffer
   "Instruction: "
   nil
   nil
   nil
   'openai-api-edit-instructions-history
   (car openai-api-edit-instructions-history)))

(defun openai-api-davinci-edit (&optional instruction target-buffer model)
  "Send INSTRUCTION to OpenAI API.

INSTRUCTION is a string.

TARGET-BUFFER is a buffer.

The response is displayed in a buffer named
*openai-edit-TARGET-BUFFER-NAME*."
  (interactive (list
                (openai-api-read-instruction)
                (or openai-api-edit-target-buffer
                    (current-buffer))))
  (let* ((mode (with-current-buffer target-buffer major-mode))
         (model (assoc-default
                 (or model 'code-davinci)
                 openai-api-edit-models))
         (called-from-resp-buffer (openai-api-edit-resp-buffer-p
                                   (current-buffer)))
         (resp-buffer (cond (called-from-resp-buffer
                             (current-buffer))
                            (t
                             (generate-new-buffer (concat "*openai-edit-" (buffer-name target-buffer) "*")))))
         (input
          (with-temp-buffer
            (insert
             (with-current-buffer
                 (if called-from-resp-buffer
                     resp-buffer
                   target-buffer)
               (buffer-string)))
            ;; I am considerig putting <file> ends here but always?
            (buffer-string))))
    ;; not sure such a thing somewhere
    ;; (when (< 3000 (length input
    ;;          (message "Your input is large, consider narrowing your buffer.")))
    (with-current-buffer resp-buffer
      (local-set-key
       (kbd openai-api-response-buffer-ediff-key)
       #'openai-api-edit-ediff-buffers)
      (openai-api-spinner-start resp-buffer)
      (pop-to-buffer (current-buffer))
      (openai-api-retrieve
       `((model . ,model)
         (temperature . 0)
         (input . ,input)
         (instruction . ,instruction))
       (lambda (state)
         (unwind-protect
             (if (plist-get state :error)
                 (progn
                   (pop-to-buffer
                    (current-buffer))
                   (error
                    "Error when sending edit instructions: %s"
                    (plist-get state :error-message)))
               (let ((response (openai-api-choices-text)))
                 (with-current-buffer
                     resp-buffer
                   (let ((inhibit-read-only t))
                     (erase-buffer)
                     (dolist (choice
                              (mapcar
                               openai-api-balance-parens-fn
                               response))
                       (insert choice))
                     (funcall mode))
                   (setf openai-api-edit-target-buffer target-buffer)
                   (pop-to-buffer (current-buffer)))))
           (with-current-buffer
               resp-buffer
             (when spinner-current
               (spinner-stop)))))
       nil
       :edit))))

(defun openai-api-edit-ediff-buffers ()
  (interactive)
  (let ((buffers
         (if (openai-api-edit-resp-buffer-p (current-buffer))
             (list openai-api-edit-target-buffer (current-buffer))
           (when-let ((resp-buffer (car (cl-loop for buffer in (buffer-list)
                                               when (= (current-buffer)
                                                       (with-current-buffer buffer openai-api-edit-target-buffer))
                                               collect buffer))))
             (list (current-buffer) resp-buffer)))))
    (unless buffers
      (error "Don't know what response buffer you want to ediff with."))
    (apply #'ediff-buffers buffers)))

(defun openai-api-cleanup-resp-buffers ()
  (interactive)
  (cl-loop for buffer in (buffer-list)
           when (openai-api-edit-resp-buffer-p buffer)
           do (kill-buffer buffer)))

(defun openai-api-edit-text ()
  "Use davinci for edit."
  (interactive)
  (openai-api-davinci-edit
   (openai-api-read-instruction) (current-buffer) 'text-davinci))

;; https://beta.openai.com/examples/default-time-complexity
;; see examples/time-complexity.el
(defvar openai-api-explain-data-list
  '(("The time complexity of this function is: "
     .
     (((model . "text-davinci-003")
       (top_p . 1)
       (max_tokens . 64)
       (temperature . 0))))
    ;; this one works well when you select a single function
    ;; Like a further explanation doc
    ("What does this do?"
     .
     (((model . "text-davinci-003")
       (top_p . 1)
       (max_tokens . 64)
       (temperature . 0))))
    ("This code can be improved in the following ways:"
     .
     (((model . "text-davinci-003")
       (max_tokens . 64)
       (temperature . 0.8))))
    ("Does this code make sense?"
     .
     (((model . "text-davinci-003")
       (max_tokens . 64)
       (temperature . 0.8)))))
  "Define prompts and req data for `openai-api-explain-region`.
You can provide a list of input data, then you get multiple output.
You could for example try with increasing temperature.
The value is allowed to be a function of input to request list.")

(defun openai-api-explain-api-input (prompt input)
  "Return the API input for PROMPT and INPUT."
  (let ((api-input
          (or
           (assoc-default prompt openai-api-explain-data-list)
           (list
            '((model . "text-davinci-003")
              (max_tokens . 256)
              (temperature . 0.8))))))
    (if (functionp api-input)
        (funcall api-input input)
      (mapcar (lambda (lst) (cons `(prompt . ,input) lst)) api-input))))

(defun openai-api-explain-region (&optional beg end)
  "Explain the code in the region.
You do not need to put a matching prompt, free form will ask text-davinci-003."
  (interactive "r")
  (let* ((mode major-mode)
         (prompt (completing-read "AI prompt: " (mapcar #'car openai-api-explain-data-list)))
         (input (buffer-substring beg end))
         (input (with-temp-buffer
                  (insert (format ";; %s\n" mode))
                  (insert (format "%s\n%s" input prompt))
                  (funcall mode)
                  (comment-region (point-at-bol) (point-at-eol))
                  (buffer-string)))
         (api-input (openai-api-explain-api-input prompt input)))
    (with-current-buffer-window
        (concat "output-"
                (substring prompt 0 (min 10 (length prompt))))
        nil
        nil
      (cl-loop for res in (openai-api-sync api-input) do (insert (string-trim res))))))

(defun openai-api-fact-bot (&optional question)
  "What is the square root of banana?
The square root of banana is not a real number."
  (interactive "sQuestion: ")
  (let  ((input (format
                 "I am a highly intelligent question answering bot.

Q: What is human life expectancy in the United States?
A: Human life expectancy in the United States is 78 years.

Q: Who was president of the United States in 1955?
A: Dwight D. Eisenhower was president of the United States in 1955.

Q: Which party did he belong to?
A: He belonged to the Republican Party.

Q: How does a telescope work?
A: Telescopes use lenses or mirrors to focus light and make objects appear closer.

Q: Where were the 1992 Olympics held?
A: The 1992 Olympics were held in Barcelona, Spain.

Q: %s
A:

" question)))
    (message "%s"
             (car (openai-api-sync
                   (list
                    `((model . "text-davinci-003")
                      (prompt . ,input)
                      (top_p . 1)
                      (max_tokens . 100)
                      (temperature . 0)
                      (presence_penalty . 0)
                      (stop . ["\n"]))))))))

(defun openai-current-commit-msg (&optional git-diff)
  "Make a commit msg from your stages changes.
This inserts 2 variations currently so you can choose."
  (interactive)
  (let* ((git-diff
          (or git-diff
              (shell-command-to-string
               "git diff --cached")))
         (input
          (format
           "I am a commit message generator designed to produce professional and informative messages based on a git diff. Given a diff, I will analyze the changes made and generate a commit message that accurately describes the modifications made to the code. My goal is to provide clear and concise commit messages that are useful for other developers who are reviewing the code.

Diff: --- a/main.py
+++ b/main.py
@@ -1,5 +1,5 @@
 def foo():
-  print(\"foo\")
+  print(\"bar\")

Message: Updated foo function to print bar instead.

Diff: %s

Message: " git-diff)))
    (cl-loop
     for
     answer
     in
     (openai-api-sync
      (list
       `((model . "text-davinci-003")
         (prompt . ,input)
         (max_tokens . 60)
         (temperature . 0.6)
         (presence_penalty . 0)
         (stop . ["\n"]))
       `((model . "text-davinci-003")
         (prompt . ,input)
         (max_tokens . 60)
         (temperature . 0.8)
         (presence_penalty . 0)
         (stop . ["\n"]))))
     do
     (insert (string-trim answer) "\n"))))

(defvar openai-api-keymap
  (let ((m (make-sparse-keymap)))
    (define-key m (kbd "e") #'openai-api-davinci-edit)
    (define-key m (kbd "E") #'openai-api-edit-text)
    (define-key m (kbd "t") #'openai-api-complete-text-small)
    (define-key m (kbd "f") #'openai-api-fact-bot)
    (define-key m (kbd "l") #'openai-api-explain-region)
    m)
  "Keymap for openai-api.")

(provide 'openai-api)

;;; openai.el ends here
