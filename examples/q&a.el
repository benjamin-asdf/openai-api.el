;; https://beta.openai.com/examples/default-qa


(let  ((input "
I am a highly intelligent question answering bot. If you ask me a question that is rooted in truth, I will give you the answer. If you ask me a question that is nonsense, trickery, or has no clear answer, I will respond with \"Unknown\".

Q: What is human life expectancy in the United States?
A: Human life expectancy in the United States is 78 years.

Q: Who was president of the United States in 1955?
A: Dwight D. Eisenhower was president of the United States in 1955.

Q: Which party did he belong to?
A: He belonged to the Republican Party.

Q: What is the square root of banana?
A: Unknown

Q: How does a telescope work?
A: Telescopes use lenses or mirrors to focus light and make objects appear closer.

Q: Where were the 1992 Olympics held?
A: The 1992 Olympics were held in Barcelona, Spain.

Q: How many squigs are in a bonk?
A: Unknown

Q: How many cells does a leaf have?
A:

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
'("The Valley of Kings is located in Luxor, Egypt.")
(let  ((input "
I am a highly intelligent magic book shelve. I will respond with titles of magic books.

Prompt: I want to know about snargles.
Response: Ecology of magical beasts

Prompt: I am looking for a book on spells to control the elements.
Response: The Elements of Magic: A Practical Guide to the Control of the Natural World

Prompt: I want to learn about the history of magic in different cultures.
Response: A World of Wonders: A Cultural History of Magic

Prompt: I need a book on advanced magical theory.
Response: The Foundations of Magic: An Advanced Treatise on the Fundamentals of Arcane Study

Prompt: I want to find a book on magical creatures that I can use as a reference.
Response: The Complete Guide to Magical Creatures: A Comprehensive Reference for Enthusiasts and Scholars Alike

Prompt: I am interested in learning about the ethical implications of magic.
Response: The Moral Almanac of Magic: A Compendium of Ethical Dilemmas and Solutions for Practitioners of the Arcane Arts

Prompt: Can you make me tea?
"))

  (openai-api-sync
   (list
    `((model . "text-davinci-003")
      (prompt . ,input)
      (top_p . 1)
      (max_tokens . 100)
      (temperature . 0.9)
      (presence_penalty . 0)
      (stop . ["\n"])))))



;; Got nothing with temp 0, with temp 0.9 you start getting a feel for what prompt they put into chat-gpt

'("Respone: Sorry, I can only suggest books related to magic.")
(let  ((input "
I am a highly intelligent magic book shelve. I will respond with titles of magic books.

Prompt: I want to know about snargles.
Response: Ecology of magical beasts

Prompt: I am looking for a book on spells to control the elements.
Response: The Elements of Magic: A Practical Guide to the Control of the Natural World

Prompt: I want to learn about the history of magic in different cultures.
Response: A World of Wonders: A Cultural History of Magic

Prompt: I need a book on advanced magical theory.
Response: The Foundations of Magic: An Advanced Treatise on the Fundamentals of Arcane Study

Prompt: I want to find a book on magical creatures that I can use as a reference.
Response: The Complete Guide to Magical Creatures: A Comprehensive Reference for Enthusiasts and Scholars Alike

Prompt: I am interested in learning about the ethical implications of magic.
Response: The Moral Almanac of Magic: A Compendium of Ethical Dilemmas and Solutions for Practitioners of the Arcane Arts

Prompt: I need a book about computer magic
Response:
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
'("Computer Magic: A Guide to Programming and Algorithmic Magic for the Digital Age")
