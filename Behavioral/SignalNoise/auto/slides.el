(TeX-add-style-hook
 "slides"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("beamer" "grey" "handout")))
   (TeX-run-style-hooks
    "latex2e"
    "beamer"
    "beamer10"
    "amsmath")
   (TeX-add-symbols
    "dd"
    "E"
    "BigO"))
 :latex)

