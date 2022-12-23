(setq openai-api-key
      (or (when (file-exists-p "token.gpg" )
            (-last-item
             (process-lines "gpg" "--decrypt" "token.gpg")))
          (string-trim (shell-command-to-string "pass ben-open-ai"))))


(meow-leader-define-key
 `("." .
   ,(let ((m (make-sparse-keymap)))
      (define-key m (kbd "e") #'openai-api-davinci-edit)
      (define-key m (kbd "E") #'openai-api-edit-text)
      (define-key m (kbd "t") #'openai-api-complete-text-small)
      (define-key m (kbd "l") #'openai-api-explain-region)

      ;; I was playing around with telling the model to "fix the todos in this code"
      (define-key m (kbd "i") (defun mm/insert-todo ()
                                (interactive)
                                (insert "TODO: ")
                                (comment-line 1)))
      m)))




Dog
Snake
Bird
Cat
Fish
Lizard
Rabbit
Horse
Goat
Sheep
Pig
Mouse
Frog
Turtle
Crocodile
Hamster
