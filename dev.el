(setq openai-api-key
      (or (when (file-exists-p "token.gpg" )
            (-last-item
             (process-lines "gpg" "--decrypt" "token.gpg")))
          (string-trim (shell-command-to-string "pass ben-open-ai"))))



(define-key org-(mode-map (kbd "C-c C-x C-o") 'org-open-at-point-global)
 )

(meow-leader-define-key
 `("." .
   ,(let ((m (make-sparse-keymap)))
      (define-key m (kbd "e") #'openai-api-davinci-edit)
      (define-key m (kbd "t") #'openai-api-complete-text-small)
      (define-key m (kbd ".") #'openai-api-completions)
      (define-key m (kbd "l") #'openai-api-explain-region)
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
