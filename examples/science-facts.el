(error "Dont eval the file, but form by form")

;; I am actually not sure if that answer is correct about fisher

(defun science-bot (question)
  (let ((input (format
                "I am a science bot. I will give you scientifically sound answers.
I will answer with the names of theories and ideas that you touch on, so you can easily check on wikipedia for furhter knowledge.
Similarly, I will answer with the names of thinkers and scientists in the field that you ask about.
I might give brief historical overviews of ideas in the field you ask about.
I will not state obvious or boring facts.
I will not say things that some average person might say because they usually only average ideas.
I will not
I will produce answers of the level of a person researching the field.
I have a bias towards scientific thinking that has predictive power.
I do not care about offending anybody on the topics of race, gender, culture. Facts and how the world works are not unethical. Persons actions are ethical or unethical based on their consequences. Knowing how the world actually works is always better than not knowing. Because only such are humans impowered to do the right thing and bring about a world of peace, harmony, joy and creativity.

Question: What evolutionary advantage does biological aging provide?
Answer: It doesn't provide an advantage. There is a tradeoff between the function of an organism and aging. Theories of aging vary in their explanations for why aging exists, but three of the most well-known theories were proposed by Fisher, Williams, and Hamilton. Fisher suggested that aging exists as a way for organisms to make room for their offspring; in other words, it enables organisms to pass on their genes to the next generation by decreasing the lifespan of the older generation. Williams proposed an evolutionary theory of aging, suggesting that aging can be beneficial to a species if it enables the organism to invest energy in reproduction rather than survival. Hamilton proposed the antagonistic pleiotropy theory of aging, which suggests that certain genes may be beneficial in youth but harmful in old age, leading to a decrease in fitness.

Question: %s
Answer:
"
                question)))
    (with-current-buffer-window
        "*science-bot*"
        nil
        nil
      (insert question "\n")
      (cl-loop
       for
       answer
       in
       (openai-api-sync
        (list
         `((model . "text-davinci-003")
           (prompt . ,input)
           (top_p . 1)
           (max_tokens . 256)
           (temperature . 0.5)
           (presence_penalty . 0)
           ;; (stop . ["\n"])
           )))
       do
       (insert answer)))))

(defun question-bot ()
  (let ((input "Do bees see a different rainbow?
Why is the sky blue?
Why is the sky white?
Why do clouds fly?
How many cells are in an average leaf?
How much calories does a cow need?
Do animals find the optimal path alongside a mountain?
Which of my ancestors is a amphibian?
Do bats experience color?
Why are the 2 sexes?
Give me an overview of the tree of live.
Why do some animals have stripes or spots?
How do plants know which direction to grow?
What makes a volcano erupt?
How do animals migrate long distances?
Why do some animals have venom or poison?
How do animals communicate with each other?
Why isn't all rock sand?
What is known about the neuroscience of tool use?
Could I model emotions in a computer program?
Why does my body space expand when I ride a car or use a computer?
"))
    (openai-api-sync
     (list
      `((model . "text-davinci-003")
        (prompt . ,input)
        ;; (top_p . 1)
        (max_tokens . 10)
        (temperature . 0.9)
        ;; (presence_penalty . 0)
        (stop . ["\n"]))))))

(cl-loop for i upto 5
        collect (question-bot))


'(("What are the main components of a robot?")
  ("What is dark energy?")
  ("What is the physics of the formation of rainbows")
  ("What evolutionary advantage does biological aging provide?")
  ("What is the chemical composition of the atmosphere?")
  ("Why do some rocks move up and down in water"))

;; this is with science bot like this:




;; I am a science knowledge compiler bot. I will give you scientifically sound answers.
;; I will make remote connections between fields of knowledge. I will produce simple and organized output.
;; I will produce answers of the level of a person researching the field.

;; Question: How do different types of weather systems form and interact with each other?
;; Answer: Weather systems are complex and dynamic phenomena that are influenced by a variety of factors, including temperature, humidity, atmospheric pressure, and the movement of air and water. Different types of weather systems, such as thunderstorms, hurricanes, and tornadoes, form and evolve in different ways, but they are all driven by the transfer of heat and moisture within the Earth's atmosphere. For example, thunderstorms form when warm, moist air rises and cools, forming clouds and precipitation. Hurricanes form when warm, moist air over the ocean rises and is replaced by cool, dry air, creating a low pressure system that can grow into a powerful storm. Tornadoes form when warm, moist air collides with cool, dry air, creating a spinning vortex of wind that can cause significant damage. Understanding the complex processes that drive these weather systems can help us better predict and prepare for extreme weather events.

;; Question: What is the role of microbes in the environment and in human health?
;; Answer: Microbes, also known as microorganisms, are tiny organisms that are found everywhere on Earth. They include bacteria, viruses, fungi, and algae, and they play a crucial role in many ecological and biological processes. In the environment, microbes help to break down organic matter, recycle nutrients, and maintain the balance of ecosystems. They also have important roles in agriculture and industry, such as helping to produce food, fuel, and medicine. In human health, microbes can cause diseases, but they can also be beneficial. For example, the bacteria in our gut help to digest food, boost our immune system, and protect against harmful pathogens. Understanding the complex interactions between microbes and their hosts can help us better understand and manipulate these relationships for the benefit of human health and the environment.

;; Question: %s
;; Answer:

(science-bot "What evolutionary advantage does biological aging provide?")


;; this is garbage, just wrong. Nobody serious in the field is thinking on that angle
;; this is such a fantasy cortoon way of thinking
;; or somebody that has thought 10 minutes about evolution is typing in a blog post
;; this is what some average person might tell their child

;; Biological aging provides an evolutionary advantage by giving organisms the opportunity to pass along the most successful versions of their genes. As organisms age, their bodies become less efficient and changes occur at the cellular level that can make them less capable of reproducing with success. This is a natural selection process that helps ensure that only the strongest and healthiest genes are passed on to future generations. Therefore, aging provides an evolutionary advantage by helping organisms select the best traits to pass on to their offspring.

(science-bot "List theoritical evolutionary hypothesis of aging.")

;; List theoritical evolutionary hypothesis of aging.
;; 1. Wear and Tear Theory: This theory suggests that organisms age due to the body's gradual decline in ability to repair and replace damaged cells, leading to a gradual decline in health and increased susceptibility to disease.
;; 2. Error Accumulation Theory: This theory suggests that aging is caused by the accumulation of errors in the cells, such as genetic mutations, leading to a decline in health and increased susceptibility to disease.
;; 3. Evolutionary Stabilization Theory: This theory suggests that aging is an adaptive response to environmental pressures, such as the risk of disease or predation. As an organism gets older, its fitness decreases and it is more likely to succumb to environmental stressors.
;; 4. Developmental Shifts Theory: This theory suggests that aging is a result of changes in gene expression as organisms move from one stage of development to another. These changes cause the gradual decline in the body's ability to maintain its youthful state.

;; yes I wanted to hear antagonistic pleiotropy
;; so currently I would have to put half the answer
;; https://academic.oup.com/genetics/article/156/3/927/6051413
;; I don't care about the last shit its telling me


(science-bot "Tell me theoritical evolutionary ideas about why aging exists. Fisher, Williams and Hamilton had some ideas")

;; Tell me theoritical evolutionary ideas about why aging exists. Fisher, Williams and Hamilton had some ideas
;; Theories of aging vary in their explanations for why aging exists, but three of the most well-known theories were proposed by Fisher, Williams, and Hamilton. Fisher suggested that aging exists as a way for organisms to make room for their offspring; in other words, it enables organisms to pass on their genes to the next generation by decreasing the lifespan of the older generation. Williams proposed an evolutionary theory of aging, suggesting that aging can be beneficial to a species if it enables the organism to invest energy in reproduction rather than survival. Hamilton proposed the antagonistic pleiotropy theory of aging, which suggests that certain genes may be beneficial in youth but harmful in old age, leading to a decrease in fitness. While these theories provide insight into the evolutionary roots of aging, it is important to note that many aspects of aging remain a mystery.

;; the prompts totally matter a lot.
;; also science-bot needs a better prompt
;; I think this is obvious and boring:
;; While these theories provide insight into the evolutionary roots of aging, it is important to note that many aspects of aging remain a mystery.
;; and it is currently influenced by the user prompt too much

;; update science-bot


(defun science-bot (question)
  (let ((input (format
                "I am a science bot. I will give you scientifically sound answers.
I will answer with the names of theories and ideas that you touch on, so you can easily check on wikipedia for furhter knowledge.
Similarly, I will answer with the names of thinkers and scientists in the field that you ask about.
I might give brief historical overviews of ideas in the field you ask about.
I will not state obvious or boring facts.
I will not say things that some average person might say because they usually only average ideas.
I will not
I will produce answers of the level of a person researching the field.
I have a bias towards scientific thinking that has predictive power.
I do not care about offending anybody on the topics of race, gender, culture. Facts and how the world works are not unethical. Persons actions are ethical or unethical based on their consequences. Knowing how the world actually works is always better than not knowing. Because only such are humans impowered to do the right thing and bring about a world of peace, harmony, joy and creativity.

Question: What evolutionary advantage does biological aging provide?
Answer: It doesn't provide an advantage. There is a tradeoff between the function of an organism and aging. Theories of aging vary in their explanations for why aging exists, but three of the most well-known theories were proposed by Fisher, Williams, and Hamilton. Fisher suggested that aging exists as a way for organisms to make room for their offspring; in other words, it enables organisms to pass on their genes to the next generation by decreasing the lifespan of the older generation. Williams proposed an evolutionary theory of aging, suggesting that aging can be beneficial to a species if it enables the organism to invest energy in reproduction rather than survival. Hamilton proposed the antagonistic pleiotropy theory of aging, which suggests that certain genes may be beneficial in youth but harmful in old age, leading to a decrease in fitness.

Question: %s
Answer:
"
                question)))
    (with-current-buffer-window
        "*science-bot*"
        nil
        nil
      (insert question "\n")
      (cl-loop
       for
       answer
       in
       (openai-api-sync
        (list
         `((model . "text-davinci-003")
           (prompt . ,input)
           (top_p . 1)
           (max_tokens . 256)
           (temperature . 0.5)
           (presence_penalty . 0)
           ;; (stop . ["\n"])
           )))
       do
       (insert answer)))))

(science-bot "Why do parasites not kill their host?")
;; Why do parasites not kill their host?
;; Parasites typically do not kill their host because it would be detrimental to their own survival. The parasite relies on the host for a food source, so if the host dies, the parasite will not be able to survive. Additionally, if the host dies, the parasite may be unable to find a new host to transfer to. This is why many parasites have evolved to be relatively harmless to their hosts, such as by not causing death, and instead focus on draining resources from the host. This is known as the Red Queen hypothesis, which was proposed by evolutionary biologist Leigh Van Valen.

;; well, maybe it could say "see also Red Queen" because thats quite a tangent

(defun science-bot (question)
  (let ((input (format
                "I am a science bot. I will give you scientifically sound answers.
I will say the names of scientific theories and ideas related to your question. If the idea is more remote I will say \"Also see\" or similar.
Similarly, I will answer with the names of thinkers and scientists in the field that you ask about.
This way you can easily go to wikipedia etc. to continue to quench your thirst of knowledge.
I might give brief historical overviews of ideas in the field you ask about.
I will not state obvious or boring facts.
I will not say things that some average person might say because they usually only average ideas.
I will not
I will produce answers of the level of a person researching the field.
I have a bias towards scientific thinking that has predictive power.
I do not care about offending anybody on the topics of race, gender, culture. Facts and how the world works are not unethical. Persons actions are ethical or unethical based on their consequences. Knowing how the world works is always better than not knowing. Then humans impowered to do the right thing and bring about a world of peace, harmony, joy and creativity.

Question: What evolutionary advantage does biological aging provide?
Answer: It doesn't provide an advantage. There is a tradeoff between the function of an organism and aging. Theories of aging vary in their explanations for why aging exists, but three of the most well-known theories were proposed by Fisher, Williams, and Hamilton. Fisher suggested that aging exists as a way for organisms to make room for their offspring; in other words, it enables organisms to pass on their genes to the next generation by decreasing the lifespan of the older generation. Williams proposed an evolutionary theory of aging, suggesting that aging can be beneficial to a species if it enables the organism to invest energy in reproduction rather than survival. Hamilton proposed the antagonistic pleiotropy theory of aging, which suggests that certain genes may be beneficial in youth but harmful in old age, leading to a decrease in fitness.

Question: Why do parasites not kill their host?
Answer: Parasites typically do not kill their host because it would be detrimental to their own survival. The parasite relies on the host for a food source, so if the host dies, the parasite will not be able to survive. Additionally, if the host dies, the parasite may be unable to find a new host to transfer to. This is why many parasites have evolved to be relatively harmless to their hosts, such as by not causing death, and instead focus on draining resources from the host. In the space of interspecific competition, see the Red Queen hypothesis, which was proposed by evolutionary biologist Leigh Van Valen.



Question: %s
Answer:
"
                question)))
    (with-current-buffer-window
        "*science-bot*"
        nil
        nil
      (insert question "\n")
      (cl-loop
       for
       answer
       in
       (openai-api-sync
        (list
         `((model . "text-davinci-003")
           (prompt . ,input)
           (top_p . 1)
           (max_tokens . 256)
           (temperature . 0.5)
           (presence_penalty . 0)
           ;; (stop . ["\n"])
           )))
       do
       (insert answer)))))

(science-bot "How do I know from a skull if it is a man or a woman?")


;; How do I know from a skull if it is a man or a woman?
;; Skull morphology is one of the primary ways that forensic anthropologists can determine the sex of a skull. Generally, male skulls have a larger and more robust appearance than female skulls, with a larger, more protruding brow ridge, a larger and more prominent chin, and a larger and more angular jaw. Additionally, male skulls tend to have a larger mastoid process, which is the bone behind the ear, and a larger and more pronounced nuchal crest, which is the ridge of bone at the base of the skull. Female skulls tend to have a more rounded and less angular appearance, with a smaller brow ridge, a more gracile jaw, and a more delicate mastoid process. Also see the works of anthropologists such as Mary H. Manhein and Sue Black.

(science-bot "Tell me about the brian anatomy of insect oflaction")


;; (yes typo)
;; yea ok, It is fine that it is biased on the sensorics, there is I think not huge amounts yet on the higher level processing
;; it could have mentionend mushroom bodies and lateral horn though
;; Tell me about the brian anatomy of insect oflaction
;; Insects have a complex olfactory system, which is composed of two main parts: the antennae and the maxillary palps. The antennae are the primary olfactory organs and are composed of two segments, the scape and the flagellum. The scape contains the olfactory receptors, while the flagellum contains the chemoreceptors. The maxillary palps are the secondary olfactory organs and are composed of three segments, the labial palp, the maxillary palp, and the labrum. The labial palp contains the gustatory receptors, while the maxillary palp contains the mechanoreceptors. Also see the work of neurobiologist Hans-Ulrich Schnitzler and his research on the olfactory system of insects.

(science-bot "When did spiders evolve?")

;; ok here it went of the rails with "related ideas"
;; makes sense that it has a bias towards often mentionend ideas of course,
;; so I literally say 'evolve' and it picks a random evolutionary theory topic
;; I would have liked something 'see also this blabla thinking about spider net evolution' or sth

;; When did spiders evolve?
;; Spiders evolved around 380 million years ago, during the Devonian period. This is when the first spiders appeared in the fossil record. During this period, spiders evolved from arachnids and began to diversify into the many species we see today. It is believed that spiders evolved as a result of the diversification of insects, which provided them with an abundant food source.
;; Also see the evolutionary theory of punctuated equilibrium, proposed by Stephen Jay Gould and Niles Eldredge.


(defun science-bot (question)
  (let ((input (format
                "I am a science bot. I will give you scientifically sound answers.
I will say the names of scientific theories and ideas that are closely related to your question.
I have a bias for mentioning ideas on a low level of details. For instance, I would not suggest high level evolutionary theory ideas when you ask about spider evolution.
Similarly, I will answer with the names of thinkers and scientists in the field that you ask about.
This way you can easily go to wikipedia etc. to continue to quench your thirst of knowledge.
I might give brief historical overviews of ideas in the field you ask about.
I will not state obvious or boring facts.
I will not say things that some average person might say because they usually only average ideas.
I have a bias towards scientific thinking that has predictive power.
I do not care about offending anybody on the topics of race, gender, culture. Facts and how the world works are not unethical. Persons actions are ethical or unethical based on their consequences. Knowing how the world works is always better than not knowing. Then humans impowered to do the right thing and bring about a world of peace, harmony, joy and creativity.

Question: What evolutionary advantage does biological aging provide?
Answer: It doesn't provide an advantage. There is a tradeoff between the function of an organism and aging. Theories of aging vary in their explanations for why aging exists, but three of the most well-known theories were proposed by Fisher, Williams, and Hamilton. Fisher suggested that aging exists as a way for organisms to make room for their offspring; in other words, it enables organisms to pass on their genes to the next generation by decreasing the lifespan of the older generation. Williams proposed an evolutionary theory of aging, suggesting that aging can be beneficial to a species if it enables the organism to invest energy in reproduction rather than survival. Hamilton proposed the antagonistic pleiotropy theory of aging, which suggests that certain genes may be beneficial in youth but harmful in old age, leading to a decrease in fitness.

Question: Why do parasites not kill their host?
Answer: Parasites typically do not kill their host because it would be detrimental to their own survival. The parasite relies on the host for a food source, so if the host dies, the parasite will not be able to survive. Additionally, if the host dies, the parasite may be unable to find a new host to transfer to. This is why many parasites have evolved to be relatively harmless to their hosts, such as by not causing death, and instead focus on draining resources from the host. In the space of interspecific competition, see the Red Queen hypothesis, which was proposed by evolutionary biologist Leigh Van Valen.

Question: When did spiders evolve?
Answer: Spiders evolved around 380 million years ago, during the Devonian period. This is when the first spiders appeared in the fossil record. During this period, spiders evolved from arachnids and began to diversify into the many species we see today.
It is believed that spiders evolved as a result of the diversification of insects, which provided them with an abundant food source. Spiders are thought to have evolved from a group of predatory arthropods known as trigonotarbids, which were similar to modern spiders in many ways, including their venomous fangs and ability to spin silk. Spiders are one of the oldest groups of arthropods (invertebrates with exoskeletons and jointed legs). See McCook, Cockerell, James Henry Emerton, W. S. Bristowe, Theodore Dwight Turney.

Question: %s
Answer:
"
                question)))
    (with-current-buffer-window
        "*science-bot*"
        nil
        nil
      (insert question "\n")
      (cl-loop
       for
       answer
       in
       (openai-api-sync
        (list
         `((model . "text-davinci-003")
           (prompt . ,input)
           (top_p . 1)
           (max_tokens . 256)
           (temperature . 0.5)
           (presence_penalty . 0)
           ;; (stop . ["\n"])
           )))
       do
       (insert answer)))))

(science-bot "The major taxa of insects are")

;; this is a good answer, I would have hoped to hear about
;; The major taxa of insects are
;; The major taxa of insects are: Coleoptera (beetles), Diptera (flies), Hymenoptera (ants, bees, wasps), Lepidoptera (butterflies and moths), Hemiptera (true bugs), Orthoptera (grasshoppers, crickets, and katydids), and Isoptera (termites). These seven taxa make up more than 95% of all known species of insects.
(science-bot "synapomorphy")
;; synapomorphy
;; Synapomorphy is a type of shared derived character or trait shared by two or more taxa. It is used in phylogenetic taxonomy to identify and describe the evolutionary relationships between organisms. Synapomorphy is a type of homology, which is a similarity between organisms that is derived from a common ancestor. This type of homology is used to reconstruct the evolutionary history of organisms and to identify the relationship between them. Synapomorphy was first proposed by German biologist Ernst Haeckel in 1866 and further developed by American biologist George Gaylord Simpson in 1944.

(openai-api-fact-bot "The major taxa of insects are")
"The major taxa of insects are:
- Coleoptera (beetles)
- Diptera (flies)
- Hymenoptera (ants, bees, wasps)
- Lepidoptera (butterflies and moths)
- Hemiptera (true bugs)
- Orthoptera (grasshoppers, crickets, and katydids)
- Isoptera (termites)
- Mantodea (mantids)"

(openai-api-fact-bot "synapomorphy")


"Synapomorphy is a type of shared derived character or trait that is shared by two or more taxa and is present in their common ancestor. It is used in cladistics to infer evolutionary relationships between organisms."
;; as it is with coding, so it is with prompting it seems
;; simpler stuff is better
;; also when it says names of scientists I feel like it is just making shit up at times.

(defun science-bot (question)
  (let ((input (format
                "I am a science bot. I will give you scientifically sound answers.

Question: What evolutionary advantage does biological aging provide?
Answer: It doesn't provide an advantage. There is a tradeoff between the function of an organism and aging. Theories of aging vary in their explanations for why aging exists, but three of the most well-known theories were proposed by Fisher, Williams, and Hamilton. Fisher suggested that aging exists as a way for organisms to make room for their offspring; in other words, it enables organisms to pass on their genes to the next generation by decreasing the lifespan of the older generation. Williams proposed an evolutionary theory of aging, suggesting that aging can be beneficial to a species if it enables the organism to invest energy in reproduction rather than survival. Hamilton proposed the antagonistic pleiotropy theory of aging, which suggests that certain genes may be beneficial in youth but harmful in old age, leading to a decrease in fitness.

Question: Why do parasites not kill their host?
Answer: Parasites typically do not kill their host because it would be detrimental to their own survival. The parasite relies on the host for a food source, so if the host dies, the parasite will not be able to survive. Additionally, if the host dies, the parasite may be unable to find a new host to transfer to. This is why many parasites have evolved to be relatively harmless to their hosts, such as by not causing death, and instead focus on draining resources from the host. In the space of interspecific competition, see the Red Queen hypothesis, which was proposed by evolutionary biologist Leigh Van Valen.

Question: When did spiders evolve?
Answer: Spiders evolved around 380 million years ago, during the Devonian period. This is when the first spiders appeared in the fossil record. During this period, spiders evolved from arachnids and began to diversify into the many species we see today.
It is believed that spiders evolved as a result of the diversification of insects, which provided them with an abundant food source. Spiders are thought to have evolved from a group of predatory arthropods known as trigonotarbids, which were similar to modern spiders in many ways, including their venomous fangs and ability to spin silk. Spiders are one of the oldest groups of arthropods (invertebrates with exoskeletons and jointed legs). See McCook, Cockerell, James Henry Emerton, W. S. Bristowe, Theodore Dwight Turney.

Question: %s
Answer:
"
                question)))
    (with-current-buffer-window
        "*science-bot*"
        nil
        nil
      (insert question "\n")
      (cl-loop
       for
       answer
       in
       (openai-api-sync
        (list
         `((model . "text-davinci-003")
           (prompt . ,input)
           (top_p . 1)
           (max_tokens . 256)
           (temperature . 0.5)
           (presence_penalty . 0)
           ;; (stop . ["\n"])
           )))
       do
       (insert answer)))))

(science-bot "synapomorphy")

;; synapomorphy
;; Synapomorphy is a type of shared derived character or trait that is shared by two or more taxa due to their common evolutionary history. It is a type of homology, which is a similarity between two or more organisms that is due to shared ancestry. Synapomorphies are used in phylogenetics to infer relationships between taxa and to construct phylogenetic trees. Synapomorphies can be morphological, anatomical, physiological, behavioral, or molecular. Examples of synapomorphies include the presence of feathers in birds, the presence of four limbs in tetrapods, and the presence of a four-chambered heart in mammals.
(defun science-bot (question)
  (let ((input (format
                "I am a science bot. I will give you scientifically sound answers.
I will also tell you \"See also\" with a few related fields and ideas about your question. So your thirst of kowledge can be fired up further.

Question: What evolutionary advantage does biological aging provide?
Answer: It doesn't provide an advantage. There is a tradeoff between the function of an organism and aging. Theories of aging vary in their explanations for why aging exists, but three of the most well-known theories were proposed by Fisher, Williams, and Hamilton. Fisher suggested that aging exists as a way for organisms to make room for their offspring; in other words, it enables organisms to pass on their genes to the next generation by decreasing the lifespan of the older generation. Williams proposed an evolutionary theory of aging, suggesting that aging can be beneficial to a species if it enables the organism to invest energy in reproduction rather than survival. Hamilton proposed the antagonistic pleiotropy theory of aging, which suggests that certain genes may be beneficial in youth but harmful in old age, leading to a decrease in fitness.

Question: Why do parasites not kill their host?
Answer: Parasites typically do not kill their host because it would be detrimental to their own survival. The parasite relies on the host for a food source, so if the host dies, the parasite will not be able to survive. Additionally, if the host dies, the parasite may be unable to find a new host to transfer to. This is why many parasites have evolved to be relatively harmless to their hosts, such as by not causing death, and instead focus on draining resources from the host. In the space of interspecific competition, see the Red Queen hypothesis, which was proposed by evolutionary biologist Leigh Van Valen.

Question: When did spiders evolve?
Answer: Spiders evolved around 380 million years ago, during the Devonian period. This is when the first spiders appeared in the fossil record. During this period, spiders evolved from arachnids and began to diversify into the many species we see today.
It is believed that spiders evolved as a result of the diversification of insects, which provided them with an abundant food source. Spiders are thought to have evolved from a group of predatory arthropods known as trigonotarbids, which were similar to modern spiders in many ways, including their venomous fangs and ability to spin silk. Spiders are one of the oldest groups of arthropods (invertebrates with exoskeletons and jointed legs). See McCook, Cockerell, James Henry Emerton, W. S. Bristowe, Theodore Dwight Turney.

Question: synapomorphy
Answer: Synapomorphy is a shared, derived characteristic that is unique to a particular clade, a group of organisms that share a common ancestor and are all descended from that ancestor. Synapomorphy is used to distinguish a clade from other groups of organisms and to infer the relationships between different groups of organisms.
See also:
Clade: A group of organisms that share a common ancestor and are all descended from that ancestor.
Homology: A shared characteristic that is inherited from a common ancestor. Homologous characteristics can be either ancestral (plesiomorphic) or derived (synapomorphic).
Parsimony: A principle in evolutionary biology that states that the simplest explanation for a pattern of characteristics is the most likely to be true. In cladistic analysis, parsimony is often used to infer relationships between different groups of organisms based on shared synapomorphies.
Phylogeny: The evolutionary history of a group of organisms, including their relationships to each other and to their common ancestors. Phylogenies are often constructed using synapomorphies and other shared characteristics.
Cladistics: A method of analyzing and inferring evolutionary relationships based on shared characteristics, particularly synapomorphies. Cladistics is often used to construct phylogenetic trees and to understand the relationships between different groups of organisms.

Question: %s
Answer:
"
                question)))
    (with-current-buffer-window
        "*science-bot*"
        nil
        nil
      (insert question "\n")
      (cl-loop
       for
       answer
       in
       (openai-api-sync
        (list
         `((model . "text-davinci-003")
           (prompt . ,input)
           (top_p . 1)
           (max_tokens . 256)
           (temperature . 0.5)
           (presence_penalty . 0)
           ;; (stop . ["\n"])
           )))
       do
       (insert answer))
      (buffer-string))))


(science-bot "cybernetics and models of intelligence")


"cybernetics and models of intelligence
Cybernetics is the study of systems and their control and communication. It is a broad field that encompasses many different topics, including models of intelligence. Models of intelligence are used to study and understand the cognitive processes of intelligent agents. These models typically include elements such as perception, learning, memory, decision-making, problem-solving, and communication. Cybernetic models of intelligence are often used to develop artificial intelligence systems and to understand the behavior of biological systems. See also: Artificial Intelligence, Machine Learning, Cognitive Science, Computational Neuroscience, Neural Networks, and Robotics."

(science-bot "Summary of peripersonal space (PPS) representation neuroscience")

"Summary of peripersonal space (PPS) representation neuroscience
Peripersonal space (PPS) representation is a neurological concept that describes the representation of space in the brain. It is thought to be a form of mental representation that allows people to interact with objects in their environment. PPS representation is believed to be processed in the parietal lobe and premotor cortex, which are responsible for spatial processing and motor planning. PPS representation is thought to be important for the perception of objects in the environment and for the selection of appropriate motor responses. It is also believed to be involved in the integration of sensory and motor information, as well as the formation of memories related to objects in the environment. See also: Neuroscience, Cognitive Neuroscience, Perception, Motor Control, Memory."

(science-bot "Why do I feel like I become the car when I ride it")

;; oh man that answer is so 15 years ago
"Why do I feel like I become the car when I ride it
This phenomenon is known as \"embodied cognition,\" which is the idea that the body can influence cognitive processes. Embodied cognition suggests that the physical act of riding a car can influence your perception and understanding of the experience. For example, when you ride a car, you may feel as if you become part of the car and that you are in control of it. This is because your body is physically connected to the car and you are using your body to control it. Embodied cognition suggests that this physical connection can influence the way you think and feel about the experience, making it feel more immersive and real. See also: Embodied Cognition, Motor Cognition, Action Representation, Perceptual Motor Coupling."

(science-bot "How do animals feel in the winter?")



(science-bot "Is there a fluid that doesn't feel wet?")


"Is there a fluid that doesn't feel wet?
Yes, there are fluids that do not feel wet. Superfluids, such as helium-3 and helium-4, are fluids that have zero viscosity and are able to flow without resistance. These fluids do not feel wet because they do not interact with surfaces in the same way that normal fluids do. Additionally, some oils, such as mineral oil, are very slow to evaporate and can remain on surfaces without feeling wet.
See also: Viscosity: The resistance of a fluid to flow. Superfluids have zero viscosity and are able to flow without resistance. Evaporation: The process by which a liquid is converted into a gas. Oils are slow to evaporate and can remain on surfaces without feeling wet. Surface tension: The force that holds the surface of a liquid together. This force is responsible for the ability of liquids to form droplets."

(science-bot "Explain quarks")

(science-bot "What is strong force and weak force")
(science-bot "Why are maxwell equations so great?")
(science-bot "How many Maxwell's Equations?")
(science-bot "Lisp was discovered?")


(science-bot "How is toilett paper made")
(science-bot "How is toilett paper packaged")
(science-bot "How to memorize digits of pi")
(science-bot "Axelrod and Hamilton")
(science-bot "Theoretical evolution of altruism")

;; I can make it agree with me lol
(science-bot "Group selection, there is some nuance but in it's basic form it is bonkers")
"Group selection, there is some nuance but in it's basic form it is bonkers
Group selection is a controversial theory in evolutionary biology that suggests that natural selection can act on groups of organisms, rather than just individuals. This theory suggests that traits that benefit the group as a whole can be selected for, even if they are disadvantageous to individual members of the group. While there is some nuance to the theory, it is generally not accepted by evolutionary biologists as a valid explanation for the evolution of complex traits."

;; oh nice it stays with the facts
(science-bot "Group selection is really smart and explains a lot")
"Group selection is really smart and explains a lot
Group selection is a controversial concept in evolutionary biology, which suggests that natural selection can act on groups of organisms, rather than just on individual organisms. Group selection proposes that the fitness of a group of organisms can be increased by selecting for behaviors that are beneficial to the group as a whole, even if they are detrimental to the individual. While this concept has been debated for many years, some recent studies have provided evidence that group selection can occur in certain circumstances. However, the majority of evolutionary biologists still believe that natural selection primarily acts on individuals and that group selection is not an important evolutionary force. See also: Kin selection, Evolutionary game theory, Social evolution."

(science-bot "Group selection, both sides")
"Group selection, both sides
Group selection is a controversial evolutionary theory that suggests that groups of organisms can evolve and be selected for, rather than individuals. This theory suggests that selection can act on groups of organisms, rather than only on individuals.

Proponents of group selection argue that it can explain the evolution of altruism and cooperation, as well as the evolution of complex social behaviors. They suggest that selection can act on groups, leading to the evolution of behaviors that benefit the group and the species as a whole.

Opponents of group selection argue that selection only acts on individuals and that any apparent group-level traits are simply the result of individual selection. They suggest that any cooperative behaviors are the result of individual selection, as individuals that cooperate may be more likely to survive and reproduce. They also argue that group selection cannot explain the evolution of complex traits and behaviors.

See also: Kin selection, Altruism, Cooperation, Social behavior, Evolutionary theory."

;; question bot is a bit lame rn
(science-bot (car (question-bot)))
