# Specifications

## Overall goal

Allow a user to write characters to a file descriptor in several different fashions.

## Requirements

* 3 modes of input :
  * Character mode
  * Line mode
  * Block mode

## Tools

* C++ with only the standard library.

## Target

* All \*nix flavors
* Windows

## Breakdown

* Get command line parameters
  * Output file descriptor
  * Input mode 
* Open output file descriptor
* Get input from user (stdin)
  * Character mode
    * Each character triggers a write
  * Line mode
    * Each _Enter_ key triggers a write
  * Block mode
    * Each _Ctrl+D_ key triggers a write
* Close ouptut file descriptor
