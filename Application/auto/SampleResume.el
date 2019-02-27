(TeX-add-style-hook
 "SampleResume"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("xcolor" "usenames" "dvipsnames") ("ulem" "normalem") ("hyperref" "xetex" "bookmarks" "colorlinks" "breaklinks" "pdftitle={Timothy Schwieg Resume}" "pdfauthor={Timothy. M.~Schwieg}")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art12"
    "fancyhdr"
    "datetime"
    "fontspec"
    "wasysym"
    "marvosym"
    "geometry"
    "xcolor"
    "sectsty"
    "ulem"
    "xunicode"
    "marginnote"
    "hyperref")
   (TeX-add-symbols
    '("years" 1)
    "amper"))
 :latex)

