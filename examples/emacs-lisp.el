;; Lets try to meta the meta





(let ((input "As a highly intelligent emacs hacker bot, my goal is to implement an application in the file system using emacs commands. I do not receive explicit prompts, but I can access the history of my recent commands and the output of the emacs of the user. When I receive the prompt \"implement the application\", I navigate the file system, read the buffer contents, and search for comments starting with \"implement:\". If I find such a comment, I extract the relevant information from the comment and produce emacs lisp forms based on that information. These forms are then evaluated by the emacs of the user, which modifies the buffer and potentially the file system. Given a history of my recent commands and the output of the emacs of the user, my task is to produce emacs lisp forms that will be evaluated by the emacs of the user in order to implement the desired application.

User: \"implement the application\"
Bot: (progn (goto-char (point-min)) (re-search-forward \"implement:\" nil t))
Emacs: 456
Bot: (buffer-substring-no-properties 456 (save-excursion (forward-paragraph 2)))
Emacs: \"Search a file and replace a string with another string.\"
Bot : (progn (open-line 1) (forward-line 1) (insert \"(defun replace-string (search-string replace-string)\\\n  (save-excursion\\\n    (goto-char (point-min))\\\n    (while (search-forward search-string nil t)\\\n      (replace-match replace-string nil t))))\\\n\"))

User: \"implement the application\"
Bot: (progn (goto-char (point-min)) (re-search-forward \"implement:\" nil t))
Emacs: 1002
Bot: (buffer-substring-no-properties 1002 (save-excursion (forward-paragraph 2)))
Emacs: \"reads a file line by line and prints each line to the console.\\\n(defun read-file-line-by-line () )\"
Bot : (progn (open-line 1) (forward-line 1) (insert \"(defun read-file-line-by-line (filename)\\\n  (with-temp-buffer\\\n    (insert-file-contents filename)\\\n    (while (not (eobp))\\\n      (print\\\n       (buffer-substring\\\n        (point)\\\n        (line-end-position)))\\\n      (forward-line 1))))\"))
"))
  (openai-api-sync
   (list
    `((model . "text-davinci-003")
      (prompt . ,input)
      (top_p . 1)
      (max_tokens . 100)
      (temperature . 0)
      (presence_penalty . 0)
      (stop . ["\n"])))))
