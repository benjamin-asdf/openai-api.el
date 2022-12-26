;; https://beta.openai.com/examples/default-mood-color

(defun openai-mood-to-color-bot (&optional prompt)
  (insert
   (car
    (openai-api-sync
     (list
      `((model . "text-davinci-003")
        (prompt .
                ,(concat "A css color for a color like "
                         prompt))
        (top_p . 1)
        (max_tokens . 64)
        (temperature . 0)
        (presence_penalty . 0)
        (frequency_penalty . 0)
        (stop . [";"])))))))

(openai-mood-to-color-bot "A super nova")
#FFF5F9
(openai-mood-to-color-bot "A magical super nova")
#FFA3FF
(openai-mood-to-color-bot "A banana in jungle")
#F9D44A
(openai-mood-to-color-bot "Earth in the spring")
#A2C176
(openai-mood-to-color-bot "Solid earth")
#8B4513
(openai-mood-to-color-bot "Precise, deadly lightning from a highly skilled firebender")
#FFCF00
(openai-mood-to-color-bot "Precise, deadly lightning")
#f5f9ff
(openai-mood-to-color-bot "Comic book lightning")
#FFCF40

;; And the lord spoke "It shall be colored"

(require 'css-mode)
(let ((css-fontify-colors t))
  (css--fontify-region
   (point-min)
   (point-max)))
