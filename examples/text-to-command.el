;; https://beta.openai.com/examples/default-text-to-command

;; I suppose the idea is I put some prompts for the usage of my own programs. ?

(let ((input "Convert this text to a programmatic command:

Example: Ask Constance if we need some bread
Output: send-msg `find constance` Do we need some bread?

Reach out to the ski store and figure out if I can get my skis fixed before I leave on Thursday
Oputput: "))
  (openai-api-sync
   (list
    `((model . "text-davinci-003")
      (prompt . ,input)
      (top_p . 1)
      (max_tokens . 100)
      (temperature . 0)
      (presence_penalty . 0.2)
      (stop . ["\n"])))))

'(" send-msg `find ski store` Can I get my skis fixed before I leave on Thursday?")
