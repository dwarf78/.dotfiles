;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "pocket-reader" "20241225.117"
  "Client for Pocket reading list."
  '((emacs         "25.1")
    (dash          "2.13.0")
    (kv            "0.0.19")
    (peg           "1.0.1")
    (pocket-lib    "0.3-pre")
    (s             "1.10")
    (ov            "1.0.6")
    (org-web-tools "0.1")
    (ht            "2.2"))
  :url "https://github.com/alphapapa/pocket-reader.el"
  :commit "d507c376f0edaee475466e4ecdcead4d4184e5aa"
  :revdesc "d507c376f0ed"
  :keywords '("pocket")
  :authors '(("Adam Porter" . "adam@alphapapa.net"))
  :maintainers '(("Adam Porter" . "adam@alphapapa.net")))
