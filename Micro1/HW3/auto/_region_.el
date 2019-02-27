(TeX-add-style-hook
 "_region_"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("paper" "10pt" "letterpaper")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=0.5in") ("inputenc" "utf8")))
   (TeX-run-style-hooks
    "latex2e"
    "paper"
    "paper10"
    "geometry"
    "graphicx"
    "amsmath"
    "amssymb"
    "mathrsfs"
    "blindtext"
    "inputenc"
    "forest"
    "float")
   (TeX-add-symbols
    "maxi")))

