;; https://beta.openai.com/examples/default-tldr-summary

(defun openai-tl-dr-bot (&optional prompt)
  (interactive)
  (let* ((prompt
          (or prompt
              (when (region-active-p)
                (buffer-substring (region-beginning)
                                  (region-end)))
              (buffer-substring (point-at-bol) (point))))
         (input
          (concat prompt "\n\nTl;dr")))
    (with-current-buffer-window
        "*openai-tl-dr*"
        nil
        nil
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
               do (insert answer))
      (buffer-string))))

(openai-tl-dr-bot

 "A neutron star is the collapsed core of a massive supergiant star, which had a total mass of between 10 and 25 solar masses, possibly more if the star was especially metal-rich.[1] Neutron stars are the smallest and densest stellar objects, excluding black holes and hypothetical white holes, quark stars, and strange stars.[2] Neutron stars have a radius on the order of 10 kilometres (6.2 mi) and a mass of about 1.4 solar masses.[3] They result from the supernova explosion of a massive star, combined with gravitational collapse, that compresses the core past white dwarf star density to that of atomic nuclei.")
