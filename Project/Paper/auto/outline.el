(TeX-add-style-hook
 "outline"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "12pt" "letterpaper")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("inputenc" "utf8") ("fontenc" "T1") ("ulem" "normalem") ("geometry" "margin=1in")))
   (add-to-list 'LaTeX-verbatim-environments-local "minted")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "paper"
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
    "tikz"
    "minted"
    "natbib"
    "geometry"
    "caption"
    "subcaption"
    "mathtools"
    "bm")
   (TeX-add-symbols
    "argmin"
    "BigO")
   (LaTeX-add-labels
    "sec-1"
    "sec-2"
    "sec-2-1"
    "sec-2-1-1"
    "sec-2-1-2"
    "sec-2-2"
    "sec-2-2-1"
    "sec-2-3"
    "sec-3"
    "sec-4"
    "sec-4-1"
    "sec-4-2"
    "sec-4-2-1"
    "sec-4-3"
    "sec-4-4"
    "sec-4-5"
    "sec-4-5-1"
    "sec-4-5-2"
    "fig:test1"
    "fig:test2"
    "fig:test3"
    "fig:test4"
    "sec-4-6"
    "sec-4-6-1"
    "sec-4-6-2"
    "sec-4-6-3"
    "sec-5"
    "sec-6"
    "sec-7")
   (LaTeX-add-bibliographies
    "biblio")
   (LaTeX-add-mathtools-DeclarePairedDelimiters
    '("ceil" "")))
 :latex)

