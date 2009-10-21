#!/usr/bin/env gosh

;; Copyright (c) 2009 Takashi Yamamiya
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

(use srfi-1)
(use srfi-4)
(use util.list)
(use gauche.vport)
(use binary.io)
(set! *load-path* (cons "." *load-path*))
(load "check.scm") ;; srfi-78 Lightweight testing

;; Arithmetic

(define bitwise-and logand)
(define bitwise-ior logior)
(define arithmetic-shift ash)
(define (add1 n) (+ n 1))

;; Hash

(define make-immutable-hash alist->hash-table)
(define hash-ref hash-table-get) ;; srfi hash-table-ref
(define hash-set! hash-table-put!)
(define make-hasheq
  (lambda () (make-hash-table 'eq?)))

;; Byte Array

(define bytes u8vector)
(define open-input-bytes open-input-uvector)

(define call-with-output-bytes
  (lambda (proc)
    (string->u8vector (call-with-output-string proc))))

(define string->bytes/utf-8 string->u8vector)
(define bytes->string/utf-8 u8vector->string)

(define bytes-length u8vector-length)

(define write-bytes write-block)
(define read-bytes 
  (lambda (amt in)
    (let ((vec (make-u8vector amt 0)))
      (read-block! vec in)
      vec)))

(define real->floating-point-bytes ;; size and big-endian? are ignored
  (lambda (val size-n big-endian?)
    (let ((bstr (make-u8vector 8 0)))
      (put-f64le! bstr 0 val)
      bstr)))

(define floating-point-bytes->real ;; size and big-endian? are ignored
  (lambda (bstr big-endian?)
    (get-f64le bstr 0)))

(define file-position
  (lambda (port)
    (port-tell port)))

;; List

(define build-list
  (lambda (n proc)
    (map proc (iota n))))

(load "instruction.k")
(load "abc.k")

;;; read a S-expression file
(define (read-file infile)
  (call-with-input-file infile
    (lambda (port) (read port))))

;;; write a ABC file
(define (write-file asm outfile)
  (call-with-output-file outfile
    (lambda (port)
      (write-asm asm port))))

(define (asm infile)
  (let ((outfile (string-append infile ".abc")))
    (write-file (read-file infile) outfile)))

(define (runtest)
  (load "test.scm"))

(define main
  (lambda (args)
    (if (null? (cdr args))
	(runtest)
	(asm (cadr args)))
    0))
