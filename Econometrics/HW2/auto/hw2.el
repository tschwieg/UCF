(TeX-add-style-hook
 "hw2"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "10pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=.5in")))
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper10"
    "amsmath"
    "listings"
    "color"
    "amssymb"
    "float"
    "geometry"
    "graphicx"))
 :latex)

