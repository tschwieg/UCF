(TeX-add-style-hook
 "dist"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("standalone" "landscape")))
   (TeX-run-style-hooks
    "latex2e"
    "standalone"
    "standalone10"
    "amssymb"
    "amsmath"
    "array"
    "bm"
    "setspace")
   (LaTeX-add-array-newcolumntypes
    "L"))
 :latex)

