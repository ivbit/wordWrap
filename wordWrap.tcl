#! /bin/sh
# launch \
exec tclsh "$0" ${1+"$@"}

# Intellectual property information START
#
# Copyright (c) 2025 Ivan Bityutskiy
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# Intellectual property information END

# Description START
#
# The script changes lines lengths in text. Reads from an input file, writes to
# an output file. Arguments described in 'ErrExit' procedure. Use empty line ''
# to select default value for an optional argument. Example:
#
# ./wordWrap.tcl input.txt '' '' crlf
# ./wordWrap.tcl input.txt 44 '' crlf
# ./wordWrap.tcl input.txt 44
# ./wordWrap.tcl input.txt
#
# Description END

# Define procedures START
proc ErrExit {{msg {Argument:
  1) Input file path.
Optional arguments:
  2) Line length (default 80).
  3) Output file path (default /tmp/out.txt)
  4) End of line characters: crlf, or lf (default lf)}}} {
  chan puts stderr \n$msg\n
  exit 1
}

proc FNorm fName {
  set fName [string trim $fName]
  if {[package vsatisfies [info tclversion] 9-]} then {
    set fName [file tildeexpand $fName]
  }
  file normalize $fName
}

proc AskClobber fName {
  chan puts -nonewline stderr "
File \"$fName\" already exists. Overwrite? \[y/N\]: "
  set answer [string trim [chan gets stdin]]
  if {[catch {tcl::mathfunc::bool $answer}] || !$answer} then {
    ErrExit "Not overwriting existing file \"$fName\"."
  }
}
# Define procedures END

# Check for mandatory argument
expr {$argc || [ErrExit]}

# Declare variables START
# 1st argument
set inFile [FNorm [lindex $argv 0]]
if {![file isfile $inFile]} then {ErrExit "File \"$inFile\" does not exist."}

# 2nd argument
set lineLength [scan [string trimleft [string trim [lindex $argv 1]] 0] %d]
if {$lineLength eq {} || $lineLength < 1} then {set lineLength 80}

# 3rd argument
set outFile [FNorm [lindex $argv 2]]
if {$outFile eq {}} then {set outFile [FNorm /tmp/out.txt]}
if {[file isfile $outFile]} then {AskClobber $outFile}

# 4th argument
set eol [expr {[string trim [lindex $argv 3]] eq {crlf} ? {crlf} : {lf}}]
# Declare variables END

# BEGINNING OF SCRIPT
proc makeOutput "{inFile {$inFile}} {outFile {$outFile}}
  {lineLength {$lineLength}} {eol {$eol}}" {
  set f [open $inFile]
  set t [open $outFile w]
  chan configure $t -translation $eol
  set str {}
  set sep {}
  while {[chan gets $f line] >= 0} {
    if {[regexp {^\s*$} $line]} then {
      if {[string length $str]} then {
        chan puts $t $str\n
      } else {
        chan puts $t {}
      }
      set str {}
      set sep {}
      continue
    }
    foreach word $line {
      if {[string length $str] + [string length $word] + 1 > $lineLength} then {
        if {[string length $str]} then {chan puts $t $str}
        set str {}
        set sep {}
      }
      append str $sep $word
      set sep { }
    }
  }
  chan puts $t $str
  chan close $f
  chan close $t
  chan puts stderr "\nFile \"$outFile\" was successfully created.\n"
}

makeOutput
# END OF SCRIPT

