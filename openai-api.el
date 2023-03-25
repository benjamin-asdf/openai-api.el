;;; openai.el --- openai api bindings for interactive development  -*- lexical-binding: t; -*-

;; Copyright (C) 2023 Benjamin Schwerdtner

;; Author: Benjamin Schwerdtner
;; URL: https://github.com/benjamin-asdf/openai-api.el
;; Version: 0.1

;; This package is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This package is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.


;;; Commentary:

;; This package provides bindings for openai apis
;;
;; - edit
;; - completions
;; - chat
;;
;; You need to set `openai-api-key'

;;; Code:


(defcustom openai-api-key
  nil
  "Credentials for openai.

This can be set to a string or a function that returns a string.

If you use `auth-sources' (eg.  pass) then you can set this to a
function that calls `auth-source-user-or-password' with the
appropriate parameters."
  :type '(choice string function)
  :group 'openai)

(defcustom openai-api-chat-model
   "gpt-3.5-turbo"
   ;; "gpt-4"
  "The openai model to use for chat."
  :type 'string
  :group 'openai)

(defvar openai-api-urls `(:completion
                          "https://api.openai.com/v1/completions"
                          :chat
                          "https://api.openai.com/v1/chat/completions"))

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

(defvar openai-api-response-buffer-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-e") 'openai-api-edit-ediff-buffers)
    map)
  "Keymap for `openai-api-response-buffer-mode'.")

(define-minor-mode openai-api-response-buffer-mode
  "Minor mode for OpenAI API response buffers."
  :lighter " OpenAI"
  :keymap openai-api-response-buffer-mode-map)

(defconst openai-api-edit-buffer "*ai-instructions*"
  "Buffer to use for the openai edit instructions prompt")

(defvar-local openai-api-edit-target-buffer nil)

(defvar openai-api-edit-instructions-history nil)

(defcustom openai-api-balance-parens-fn
  (if (fboundp 'lispy--balance) #'lispy--balance
    #'openai-api-balance-parens)
  "Function to balance parens.")

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

(defun openai-api-get-api-key ()
  (cond
   ((stringp openai-api-key) openai-api-key)
   ((functionp openai-api-key) (funcall openai-api-key))
   (t (user-error "openai-api-key is not set."))))

(defun opanai-api-split-words (string)
  "Split STRING into a list of substrings, each containing one more word."
  (let ((words (split-string string " " t)))
    (cl-loop for i from 1 to (length words)
             collect (mapconcat 'identity (cl-subseq words 0 i) " "))))

(defun openai-api-choices-text-1 (choices)
  ""
  (cl-map 'list (lambda (d) (assoc-default 'text d)) choices))

(defvar openai-api-content-fns
  `(:chat (lambda (choices) (cl-map 'list (lambda (d) (assoc-default 'content (assoc-default 'message d))) choices))
          :default ,#'openai-api-choices-text-1))

(defun openai-api-choices-text (&optional kind)
  "Return a list of choices from the current buffer."
  (let ((choices (openai-api-choices-or-error))
        (fn (plist-get openai-api-content-fns (or kind :default))))
    (funcall fn choices)))

(defun openai-api-headers ()
  `(("Content-Type" . "application/json")
    ("Authorization" . ,(concat
                         "Bearer "
                         (openai-api-get-api-key)))))

(defun openai-api-clj-update (alist key op)
  "Return a new version of `alist' with the value of `key'
updated by `op'."
  (let* ((r (copy-sequence alist))
        (cell (assoc key r)))
    (if cell
        (progn (setf (cdr cell) (funcall op (cdr cell))) r)
      (cons (cons key (funcall op nil)) alist))))


;; I don't know why `url-retrieve' does not handle multibyte...?
;; I frequently have this in german texts unfortunätly

(defun openai-api-encode-utf8 (v)
  (encode-coding-string v 'utf-8))

(defun openai-kludge-encoding (data)
  (let ((fix-1
         (lambda (key d)
           (openai-api-clj-update
            d key
            #'openai-api-encode-utf8))))
    (cond
     ((assoc 'prompt data)
      (funcall fix-1 'prompt data))
     ((assoc 'input data)
      (funcall fix-1 'input data))
     (t data))))

(defun openai-api-retrieve (data cb &optional cbargs endpoint)
  "Retrieve DATA from the openai API.

CB is a function to call with the results.

CBARGS is a list of arguments to pass to CB.

ENDPOINT is the API endpoint to use."
  (let* ((url-request-method "POST")
         (url-request-extra-headers (openai-api-headers))
         (endpoint (or endpoint
                       (assoc-default 'endpoint data)))
         (endpoint (plist-get
                    openai-api-urls
                    (or endpoint :completion)))
         (data (assq-delete-all
                'endpoint
                data))
         (url-request-data (json-encode
                            (openai-kludge-encoding data))))
    (url-retrieve
     endpoint
     cb
     cbargs)))

(defun openai-api-retrieve-sync (data &optional endpoint)
  "Retrieve DATA from the openai API.

ENDPOINT is the API endpoint to use."
  (let* ((url-request-method "POST")
         (url-request-extra-headers (openai-api-headers))
         (endpoint (plist-get
                    openai-api-urls
                    (or (assoc-default 'endpoint data)
                        (let ((model (assoc-default 'model data)))
                          (cond ((rassoc
                                  model
                                  openai-api-completion-models)
                                 :completion)
                                (t :completion))))))
         (data (assq-delete-all 'endpoint data))
         (url-request-data (json-encode
                            (openai-kludge-encoding data))))
    (url-retrieve-synchronously endpoint)))

(defun openai-api-choices-or-error ()
  "Return a list of choices from the current buffer."
  (let ((s (buffer-string))
        (b (current-buffer)))
    (with-temp-buffer
      (setq buffer-file-coding-system
            'utf-8)
      (insert s)
      (decode-coding-region
       (point-min)
       (point-max)
       'utf-8)
      (goto-char (point-min))
      (let* ((data (when (re-search-forward
                          "\n\n"
                          nil
                          t)
                     (json-read)))
             (err (assoc-default 'error data)))
        (when (or (not data) err)
          ;; (pop-to-buffer b)
          (error
           "Error response from openai %s" err))
        (assoc-default 'choices data)))))

(defun openai-api-sync (strategies)
  (cl-loop
   for strat in strategies
   append (with-current-buffer (openai-api-retrieve-sync strat)
            (mapcar openai-api-balance-parens-fn (openai-api-choices-text
                                                  (assoc-default 'endpoint strat))))))

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
    (mapc
     #'insert
     (openai-api-sync
      (list
       `((model . "code-cushman-001")
         (max_tokens . 30)
         (temperature . 0)
         (prompt . ,prompt)))))))

(defun openai-api-message (role content)
  `((role . ,role) (content . ,(openai-api-encode-utf8 content))))

(defun openai-chat-request (opts messages)
  `((endpoint . :chat)
   (temperature . ,(or (assoc-default 'temperature opts) 1))
   (max_tokens . ,(or (assoc-default 'max_tokens opts) 256))
   (model . ,openai-api-chat-model)
   (messages . ,messages)))

(defun openai-chat-sync (opts &rest messages)
  (openai-api-sync (list (openai-chat-request opts messages))))

;; (openai-chat-sync
;;  (openai-api-message 'system "Purpose: Pass butter")
;;  (openai-api-message 'user "What is your purpose?"))

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
      (buffer-substring-no-properties beg end))))

(defun openai-api-completion-completing-read-1 (strategies)
  (insert
   (completing-read
    "AI completions: "
    (openai-api-sync strategies))))

(defun openai-api-text-davinci-complete ()
  "Use text davinci completion with whatever is in front of
the point.
Text davinci might sometimes be better at code than codex."
  (interactive)
  (mapc
   #'insert
   (mapcar
    #'openai-api-balance-parens
    (cl-remove-if
     #'string-blank-p
     (openai-api-sync
      (list
       `((model . ,(assoc-default
		    'text-davinci
		    openai-api-completion-models))
	 (prompt . ,(string-trim (openai-api-buffer-backwards-dwim)))
	 (max_tokens . 100)
	 (temperature . 0)
	 (top_p . 1)
	 (frequency_penalty . 0)
	 (presence_penalty . 0))))))))

(defun openai-api-chat-complete ()
  "Use a chat model with whatever is in front of the point.
The model to use is `openai-api-chat-model'."
  (interactive)
  (mapc
   #'insert
   (mapcar
    #'openai-api-balance-parens
    (cl-remove-if
     #'string-blank-p
     (openai-chat-sync
      '((temperature . 0)
        (max_tokens . 30))
      (openai-api-message
       'system
       "You are helpful assistant emacs text completion package.")
      (openai-api-message
       'system
       "You complete code in precise and focused manner.")
      (openai-api-message
       'user
       (openai-api-buffer-backwards-dwim))
      (openai-api-message 'user "Complete this text, please"))))))

(defalias 'openai-api-complete-text-small #'openai-api-text-davinci-complete)

(defun openai-api-complete-code-thoroughly ()
  "Complete code using OpenAI API."
  (interactive)
  (let ((prompt (openai-api-buffer-backwards-dwim)))
    (openai-api-completion-completing-read-1
     (list
      `((model .  "code-davinci-002")
        (max_tokens . ,(* 4 256))
        (temperature . 0)
        (prompt . ,prompt))))))

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

(defun opanai-api-latest-used-buffer (buffs)
  "Return the latest used buffer from BUFFS."
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
  "Read an instruction from the minibuffer."
  (read-from-minibuffer
   "Instruction: "
   nil
   nil
   nil
   'openai-api-edit-instructions-history
   (car openai-api-edit-instructions-history)))

(defun openai-api-chat-edit (&optional instruction target-buffer)
  "Edit the code in the target buffer using OpenAI API.

Optional INSTRUCTION is a string containing the instruction to the AI.
Optional TARGET-BUFFER is the buffer containing the code to edit. If not provided, the current buffer is used.

Gets a code editing response from OpenAI API based on the instruction and inserts it in a new buffer.
The user is prompted to choose the best edit and copy it to the target buffer."

  (interactive (list (openai-api-read-instruction) nil))
  (let* ((instruction (if (functionp instruction) (funcall instruction) instruction))
         (target-buffer
          (or target-buffer
              openai-api-edit-target-buffer
              (current-buffer)))
         (mode (with-current-buffer target-buffer major-mode))
         (called-from-resp-buffer
          (openai-api-edit-resp-buffer-p
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
          (buffer-string))))
    (with-current-buffer resp-buffer
      (openai-api-spinner-start resp-buffer)
      (openai-api-retrieve
       (openai-chat-request
        '((max_tokens . 2048))
        (list
         (openai-api-message
          'system
          "Your purpose: Edit code.

Example interaction:

user: Input: (let [file \"foo\"] )
user: Instruction: Read the contents of the file

assistant: (let [file \"foo\"] (slurp file))")
         (openai-api-message
          'user
          (concat "Input: " input))
         (openai-api-message
          'user
          (concat
           "Instruction: "
           (if (string-empty-p instruction)
               "Fill in the blanks in this code in logical and useful way. Implement todos."
             instruction)))))
       (lambda (state)
         (unwind-protect
             (pop-to-buffer (current-buffer))
             (if (plist-get state :error)
                 (openai-api-choices-or-error)
               (let ((response (openai-api-choices-text :chat)))
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
                   (openai-api-response-buffer-mode 1)
                   (setf openai-api-edit-target-buffer target-buffer)
                   (pop-to-buffer (current-buffer)))))
           (with-current-buffer
               resp-buffer
             (when spinner-current
               (spinner-stop)))))))))

(make-obsolete 'openai-api-davinci-edit "Openai deleted edit models. Use `openai-api-chat-edit'")

(defun openai-api-edit-ediff-buffers ()
  (interactive)
  (let ((buffers (if (openai-api-edit-resp-buffer-p
                      (current-buffer))
                     (list
                      openai-api-edit-target-buffer
                      (current-buffer))
                   (when-let
                       ((resp-buffer
                         (car (cl-loop for buffer in (buffer-list)
                               when (when-let ((target-buff
                                               (with-current-buffer
                                                   buffer
                                                 openai-api-edit-target-buffer)))
                                      (eq (current-buffer) target-buff))
                               collect
                               buffer))))
                     (list
                      (current-buffer)
                      resp-buffer)))))
    (unless buffers
      (error "Don't know what response buffer you want to ediff with."))
    (apply #'ediff-buffers buffers)))

(defun openai-api-cleanup-resp-buffers ()
  (interactive)
  (cl-loop for buffer in (buffer-list)
           when (openai-api-edit-resp-buffer-p buffer)
           do (kill-buffer buffer)))

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
  "Make a commit msg from your staged changes.
This inserts 2 variations currently so you can choose."
  (interactive)
  (let* ((git-diff (or git-diff
                       (shell-command-to-string
                        "git diff --cached")))
         (input (format
                 "I am a commit message generator designed to produce professional and informative and concise messages based on a git diff. Given a diff, I will analyze the changes made and generate a commit message that accurately describes the modifications made to the code. My goal is to provide clear and concise commit messages that are useful for other developers who are reviewing the code.

Diff: --- a/main.py
+++ b/main.py
@@ -1,5 +1,5 @@
 def foo():
-  print(\"foo\")
+  print(\"bar\")

Message: Update foo function to print bar instead

Diff: %s

Message: "
                 git-diff)))
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

(defun openai-api-gen-shell-command ()
  "Generate a shell command using the OpenAI API."
  (interactive)
  (with-current-buffer
      (generate-new-buffer "*openai-shell-resp*")
    (pop-to-buffer (current-buffer))
    (setf openai-api-edit-target-buffer (current-buffer))
    (openai-api-davinci-edit
     (lambda ()
       (concat
        "Write a shell command that "
        (read-string "Shell command descr: ")))
     (current-buffer))))

(defvar openai-api-keymap
  (let ((m (make-sparse-keymap)))
    (define-key m (kbd "e") #'openai-api-chat-edit)
    (define-key m (kbd "t") #'openai-api-text-davinci-complete)
    (define-key m (kbd "f") #'openai-api-fact-bot)
    (define-key m (kbd "l") #'openai-api-explain-region)
    (define-key m (kbd "&") #'openai-api-gen-shell-command)
    (define-key m (kbd "j") #'openai-api-completions)
    (define-key m (kbd "c") #'openai-api-chat-complete)
    m)
  "Keymap for openai-api.")

(provide 'openai-api)

;;; openai.el ends here
