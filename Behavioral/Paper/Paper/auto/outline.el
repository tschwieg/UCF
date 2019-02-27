(TeX-add-style-hook
 "outline"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "11pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art11"
    "inputenc"
    "fontenc"
    "fixltx2e"
    "graphicx"
    "longtable"
    "float"
    "wrapfig"
    "rotating"
    "ulem"
    "amsmath"
    "textcomp"
    "marvosym"
    "wasysym"
    "amssymb"
    "hyperref"
    "natbib")
   (LaTeX-add-labels
    "sec-1"
    "sec-2"
    "sec-2-1"
    "sec-2-2"
    "Liklihood"
    "sec-2-3"
    "sec-2-3-1"
    "piecewiseValuation"
    "sec-2-3-2"
    "weightFunction"
    "piWeights"
    "sec-2-3-3"
    "Valuation"
    "sec-3"
    "sec-3-1"
    "sec-3-2"
    "sec-3-3"
    "sec-4"
    "sec-4-1"
    "sec-4-2"
    "sec-4-3"
    "sec-4-3-1"
    "sec-4-3-2"
    "diffValuation"
    "sec-4-3-3"
    "sec-4-4"
    "sec-5"
    "sec-5-1"
    "sec-6")
   (LaTeX-add-bibliographies
    "biblio"))
 :latex)

