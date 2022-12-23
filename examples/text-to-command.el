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


(let ((input "I am a intelligent bot computer system.
I will respond in json.
If you tell me to generate dialogue, I will respond in json objects.

Q: Make a diologue with a man and a woman about ballet.
A:
{
   \"dialogue\": {\"Man\": \"Have you ever been to a ballet?\" },
}

Q: Make diologue of 3 old friends having a comming togeter. Use shakespear language.
A:

"))
  (openai-api-sync
   (list
    `((model . "text-davinci-003")
      (prompt . ,input)
      ;; (top_p . 1)
      (max_tokens . 100)
      (temperature . 1)
      ;; (presence_penalty . 0.2)
      ;; (stop . ["\n"])
      ))))
'("{
    \"dialogue\": {
        \"Friend1\": \"Haste thee, nymph, and bring with thee Jest and youthful jollity!\",
        \"Friend2\": \"Quips and cranks, and wanton wiles, Nods and becks, and wreathÃ¨d smiles\",
        \"Friend3\": \"Such as hang on Hebeâs cheek, And love to live in dimple sleek!\"
    }
}")
