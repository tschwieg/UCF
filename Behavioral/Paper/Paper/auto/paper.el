(TeX-add-style-hook
 "paper"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt" "letterpaper")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem") ("geometry" "margin=1in")))
   (add-to-list 'LaTeX-verbatim-environments-local "minted")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "paper12"
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
    "minted"
    "natbib"
    "geometry")
   (TeX-add-symbols
    "BigO")
   (LaTeX-add-labels
    "sec-1"
    "sec-2"
    "sec-2-1"
    "sec-2-2"
    "Likelihood"
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
    "sec-5"
    "fig:single-valuation"
    "fig:single-prob"
    "sec-5-1"
    "fig:double-valuation"
    "fig:double-prob"
    "sec-5-2"
    "sec-5-3"
    "sec-6"
    "sec-7")
   (LaTeX-add-bibliographies
    "biblio"))
 :latex)

