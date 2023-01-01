;; https://github.com/benwr/gwipt/blob/main/src/main.rs

(defun openai-current-commit-msg (&optional git-diff)
  "Make a commit msg from your stages changes."
  (interactive)
  (let* ((git-diff
          (or git-diff (shell-command-to-string "git diff --cached")))
         (input
          (format
           "I am a git commit message bot. You give me a git diff of your staged changes and I make a commit message.

Diff: %s
Message: " git-diff)))
    (cl-loop for answer in
             (openai-api-sync
              (list
               `((model . "text-davinci-003")
                 (prompt . ,input)
                 (top_p . 1)
                 (max_tokens . 60)
                 (temperature . 0.7)
                 (presence_penalty . 1)
                 (frequency_penalty . 0))))
             do (insert answer))))

(openai-current-commit-msg)

;; this worked well:
;; Add keybinding to openai-api-edit-ediff-buffers
