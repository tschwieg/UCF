(TeX-add-style-hook
 "topicProposal"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "10pt")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper10"
    "amsmath"
    "float"
    "amssymb"
    "geometry"
    "setspace"))
 :latex)

