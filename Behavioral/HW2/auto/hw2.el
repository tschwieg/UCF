(TeX-add-style-hook
 "hw2"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt")))
   (TeX-run-style-hooks
    "latex2e"
    "Rplots"
    "1bp1"
    "paper"
    "paper12"
    "amssymb"
    "amsmath"
    "geometry"
    "tikz"
    "float"))
 :latex)

