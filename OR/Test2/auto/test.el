(TeX-add-style-hook
 "test"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "10pt" "letterpaper")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper10"
    "graphicx"
    "amsmath"
    "amssymb"
    "mathrsfs"
    "float"))
 :latex)

