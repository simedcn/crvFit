#crvFit
#varCSV.tcl
##===================================================================
#	Copyright (c) 2020 Yuji SODE <yuji.sode@gmail.com>
#
#	This software is released under the MIT License.
#	See LICENSE or http://opensource.org/licenses/mit-license.php
##===================================================================
#CSV file dealing interface
#
#=== Synopsis ===
# - `::varCSV::lJoin list1 list2 char;`
# 	procedure that returns a list of joined elements with given character
# 	- $list1 and $list2: Tcl lists
# 	- $char: joining character
#
# - `::varCSV::getColumn fileName x y ?encoding?;`
# 	procedure that returns values of a column in a given CSV file  
#	a range of the column is defined as (x,y) to (x,y_n), and (x,y_n+1) is a blank cell
# 	- $fileName: file name of CSV file to load
# 	- $x and $y: indexed coordinates for the top of column
# 	- $encoding: an optional encoding name
#
# - `::varCSV::getRow fileName x y ?encoding;`
# 	procedure that returns values of a row in a given CSV file  
# 	a range of the row is defined as (x,y) to (x_n,y), and (x_n+1,y) is a blank cell
# 	- $fileName: file name of CSV file to load
# 	- $x and $y: indexed coordinates for the left of row
# 	- $encoding: an optional encoding name
#
# - `::varCSV::getSize fileName ?encoding?;`
# 	procedure that returns the maximum size of CSV file
# 	- $fileName: file name of CSV file to load
# 	- $encoding: an optional encoding name
#
# - `::varCSV::scan fileName ?encoding?;`
# 	procedure that returns a result of CSV structure scan
# 	- $fileName: file name of CSV file to load
# 	- $encoding: an optional encoding name
#
# 		"CSV structure"
# 		[filled cell: `C`]
# 		[blank cell: `_`]
##===================================================================
#
set auto_noexec 1;
package require Tcl 8.6;
#--------------------------------------------------------------------
#
#*** <namespace: ::varCSV> ***
namespace eval ::varCSV {};
#=== procedures ===
#
#procedure that returns a list of joined elements with given character
proc ::varCSV::lJoin {list1 list2 char} {
	# - $list1 and $list2: Tcl lists
	# - $char: joining character
	#
	set l1 [expr {[llength $list1]<[llength $list2]?$list2:$list1}];
	set l2 [expr {[llength $list1]<[llength $list2]?$list1:$list2}];
	#
	lmap A $l1 B $l2 {join "$A $B" $char;};
};
#
#procedure that returns values of a column in a given CSV file
#a range of the column is defined as (x,y) to (x,y_n), and (x,y_n+1) is a blank cell
proc ::varCSV::getColumn {fileName x y {encoding {}}} {
	# - $fileName: file name of CSV file to load
	# - $x and $y: indexed coordinates for the top of column
	# - $encoding: an optional encoding name
	#
	set CSV {};
	set 2dlist {};
	set cell {};
	set List {};
	#
	set x [expr {abs(int($x))}];
	set y [expr {abs(int($y))}];
	#
	#=== loading CSV file ===
	set C [open $fileName r];
	if {[llength $encoding]} {
		fconfigure $C -encoding $encoding;
	};
	set CSV [read -nonewline $C];
	close $C;
	#========================
	#
	set 2dList [lmap e [split $CSV \n] {split $e ,;}];
	set cell [lindex $2dList $y $x];
	while {[llength $cell]>0} {
		lappend List $cell;
		incr y 1;
		set cell [lindex $2dList $y $x];
	};
	#
	unset CSV 2dList cell C;
	return $List;
};
#
#procedure that returns values of a row in a given CSV file
#a range of the row is defined as (x,y) to (x_n,y), and (x_n+1,y) is a blank cell
proc ::varCSV::getRow {fileName x y {encoding {}}} {
	# - $fileName: file name of CSV file to load
	# - $x and $y: indexed coordinates for the left of row
	# - $encoding: an optional encoding name
	#
	set CSV {};
	set 2dlist {};
	set cell {};
	set List {};
	#
	set x [expr {abs(int($x))}];
	set y [expr {abs(int($y))}];
	#
	#=== loading CSV file ===
	set C [open $fileName r];
	if {[llength $encoding]} {
		fconfigure $C -encoding $encoding;
	};
	set CSV [read -nonewline $C];
	close $C;
	#========================
	#
	set 2dList [lmap e [split $CSV \n] {split $e ,;}];
	set cell [lindex $2dList $y $x];
	while {[llength $cell]>0} {
		lappend List $cell;
		incr x 1;
		set cell [lindex $2dList $y $x];
	};
	#
	unset CSV 2dList cell C;
	return $List;
};
#
#procedure that returns the maximum size of CSV file
proc ::varCSV::getSize {fileName {encoding {}}} {
	# - $fileName: file name of CSV file to load
	# - $encoding: an optional encoding name
	#
	set CSV {};
	set wList {};
	set w [expr {int(0)}];
	#
	#the maximum width of CSV file
	set wMax [expr {int(0)}];
	#
	#height of CSV file
	set height [expr {int(0)}];
	#
	#=== loading CSV file ===
	set C [open $fileName r];
	if {[llength $encoding]} {
		fconfigure $C -encoding $encoding;
	};
	set CSV [read -nonewline $C];
	close $C;
	#========================
	#height
	set height [llength [set wList [split $CSV \n]]];
	#
	#width
	foreach e $wList {
		set w [llength [split $e ,]];
		set wMax [expr {$w>$wMax?$w:$wMax}];
	};
	#
	unset CSV wList w C;
	return [list width $wMax height $height];
};
#
#procedure that returns a result of CSV structure scan
#	"CSV structure"
#	[filled cell: `C`]
#	[blank cell: `_`]
proc ::varCSV::scan {fileName {encoding {}}} {
	# - $fileName: file name of CSV file to load
	# - $encoding: an optional encoding name
	#
	set CSV {};
	set rowList {};
	set n 0;
	set i 0;
	set result {};
	#
	#=== loading CSV file ===
	set C [open $fileName r];
	if {[llength $encoding]} {
		fconfigure $C -encoding $encoding;
	};
	set CSV [read -nonewline $C];
	close $C;
	#========================
	#
	set rowList [split $CSV \n];
	set n [llength $rowList];
	#
	while {$i<$n} {
		foreach e [split [lindex $rowList $i] ,] {
			append result [expr {[llength $e]>0?{C}:{_}}];
		};
		append result [expr {$i<$n-1?"\n":{}}];
		incr i 1;
	};
	#
	unset CSV C rowList n i;
	return $result;
};
