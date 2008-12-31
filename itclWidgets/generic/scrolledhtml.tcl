#
# Scrolledhtml
# ----------------------------------------------------------------------
# Implements a scrolled html text widget by inheritance from scrolledtext
# Import reads from an html file, while export still writes plain text
# Also provides a render command, to display html text passed in as an
# argument.
#
# This widget is HTML3.2 compliant, with the following exceptions:
#   a) nothing requiring a connection to an HTTP server is supported
#   b) some of the image alignments aren't supported, because they're not
#      supported by the text widget
#   c) the br attributes that go with the image alignments aren't implemented
#   d) background images are not supported, because they're not supported
#      by the text widget
#   e) automatic table/table cell sizing doesn't work very well.
#
# WISH LIST:
#   This section lists possible future enhancements.
#
#   1) size tables better using dlineinfo.
#   2) make images scroll smoothly off top like they do off bottom. (limitation
#      of text widget?)
#   3) add ability to get non-local URLs
#       a) support forms
#       b) support imagemaps
#   4) keep track of visited links
#   5) add tclets support
#
# BUGS:
#   Cells in a table can be caused to overlap. ex:
#      <table border width="100%">
#      <tr><td>cell1</td><td align=right rowspan=2>cell2</td></tr>
#      <tr><td colspan=2>cell3 w/ overlap</td>
#      </table>
#   It hasn't been fixed because 1) it's a pain to fix, 2) the fix would slow
#   tables down by a significant amount, and 3) netscape has the same
#   bug, as of V3.01, and no one seems to care.
#
#   In order to size tables properly, they must be visible, which causes an
#   annoying jump from table to table through the document at render time.
#
# Author: Arnulf P. Wiedemann
# Copyright (c) 2008 for the reimplemented version
#
# see file license.terms in the top directory
#
# ----------------------------------------------------------------------
# This code is derived/reimplemented from the ::itcl::widgets package Scrolledhtml
# written by:
#
#    Kris Raney                    EMAIL: kraney@spd.dsccc.com
#    Copyright (c) 1995 DSC Technologies Corporation
# ----------------------------------------------------------------------
#
#   @(#) $Id: scrolledhtml.tcl,v 1.1.2.1 2008/12/29 15:54:43 wiede Exp $
# ======================================================================

# Acknowledgements:
#
# Special thanks go to Sam Shen(SLShen@lbl.gov), as this code is based on his
# tkhtml.tcl code from tk inspect. The original code is copyright 1995
# Lawrence Berkeley Laboratory.
#
# This software is copyright (C) 1995 by the Lawrence Berkeley Laboratory.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that: (1) source code distributions
# retain the above copyright notice and this paragraph in its entirety, (2)
# distributions including binary code include the above copyright notice and
# this paragraph in its entirety in the documentation or other materials
# provided with the distribution, and (3) all advertising materials mentioning
# features or use of this software display the following acknowledgement:
# ``This product includes software developed by the University of California,
# Lawrence Berkeley Laboratory and its contributors.'' Neither the name of
# the University nor the names of its contributors may be used to endorse
# or promote products derived from this software without specific prior
# written permission.
#
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# This code is based on Angel Li's (angel@flipper.rsmas.miami.edu) HTML

 
#
# Default resources.
#
option add *Scrolledhtml.borderWidth 2 widgetDefault
option add *Scrolledhtml.relief sunken widgetDefault
option add *Scrolledhtml.scrollMargin 3 widgetDefault
option add *Scrolledhtml.width 500 widgetDefault
option add *Scrolledhtml.height 600 widgetDefault
option add *Scrolledhtml.visibleItems 80x24 widgetDefault
option add *Scrolledhtml.vscrollMode static widgetDefault
option add *Scrolledhtml.hscrollMode static widgetDefault
option add *Scrolledhtml.labelPos n widgetDefault
option add *Scrolledhtml.wrap word widgetDefault

namespace eval ::itcl::widgets {

#
# Provide a lowercased access method for the Scrolledhtml class.
#
proc ::itcl::widgets::scrolledhtml {pathName args} {
    uplevel ::itcl::widgets::Scrolledhtml $pathName $args
}

# ------------------------------------------------------------------
#                           SCROLLEDHTML
# ------------------------------------------------------------------
::itcl::extendedclass Scrolledhtml {
  inherit ::itcl::widgets::Scrolledtext

  option [list -feedback feedBack FeedBack] -default {}
  option [list -linkcommand linkCommand LinkCommand] -default {}
  option [list -fontname fontname FontName] -default times -configuremethod configFontname
  option [list -fixedfont fixedFont FixedFont] -default courier -configuremethod configFixedfont
  option [list -fontsize fontSize FontSize] -default medium -configuremethod configFontsize
  option [list -link link Link] -default blue
  option [list -alink alink ALink] -default red
  option [list -linkhighlight alink ALink] -default red -configuremethod configLinkhighlight
  option [list -unknownimage unknownimage File] -default {} -configuremethod configUnknownimage
  option [list -textbackground textBackground Background] -default {} -configuremethod configTextbackground
  option [list -update update Update] -default 1 -configuremethod configUpdate
  option [list -debug debug Debug] -default 0 -configuremethod configDebug

  private variable _initialized 0

  private variable _defUnknownImg [::image create photo -data {
R0lGODdhHwAgAPQAAP///wAAAMzMzC9PT76+vvnTogCR/1WRVaoAVf//qvT09OKdcWlcx19f
X9/f339/f8vN/J2d/aq2qoKCggAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ACwAAAAAHwAgAAAF/iAgjqRDnmiKmqOkqsTaToDjvudTttLjOITJbTQhGI+iQE0xMvZqQIDw
NAEiAcqRVdKAGh0NyVCkuyqZBEmwofgRrFIxSaI0JmuA9KTrthIicWMTAQ8xWHgSe15AVgcJ
eVMjDwECOkome22Mb0cHCzEPOiQPgwGXCjomakedA0VgY1IPDZcuP3l5YkcRDwMHqDQoEzq2
Pz8IQkK7Bw8HDg+xO26PCAgRDcpGswEK2Dh9ItUMDdirPYUKwTKMjwDV1gHlR2oCkSmcI9UE
BabYrGnQoolgBCGckX7yWJWDYaUMAYSRFECAwMXeiU1BHpKTB4CBR4+oBOb5By1UNgUfXj0C
8HaP079sBCCkZIAKWst/OGPOhNBNHQmXOeftJBASRVCcEiIojQDBwIOeRo+SpGXKFFGbP6Xi
nLWxEMsmWpEOC9XDYtigYtKSwsH2xdq2cEfRmFS1rt27eE09CAEAOw==
}]

  protected variable _title {}             ;# The title of the html document
  protected variable _licount 1            ;# list element count
  protected variable _listyle bullet       ;# list element style
  protected variable _lipic {}             ;# picture to use as bullet
  protected variable _color black          ;# current text color
  protected variable _bgcolor #d9d9d9      ;# current background color
  protected variable _link blue            ;# current link color
  protected variable _alink red            ;# current highlight link color
  protected variable _smallpoints "60 80 100 120 140 180 240"   ;# font point
  protected variable _mediumpoints "80 100 120 140 180 240 360" ;# sizes for
  protected variable _largepoints "100 120 140 180 240 360 480" ;# various
  protected variable _hugepoints "120 140 180 240 360 480 640"  ;# fontsizes
  protected variable _font times           ;# name of current font
  protected variable _rulerheight 6        ;#
  protected variable _indentincr 4         ;# increment to indent by
  protected variable _counter -1           ;# counter to give unique numbers
  protected variable _left 0               ;# initial left margin
  protected variable _left2 0              ;# subsequent left margin
  protected variable _right 0              ;# right margin
  protected variable _justify L            ;# text justification
  protected variable _offset 0             ;# text offset (super/subscript)
  protected variable _textweight 0         ;# boldness of text
  protected variable _textslant 0          ;# whether to use italics
  protected variable _underline 0          ;# whether to use underline
  protected variable _verbatim 0           ;# whether to skip formatting
  protected variable _pre 0                ;# preformatted text
  protected variable _intitle 0            ;# in <title>...</title>
  protected variable _anchorcount 0        ;# number of anchors
  protected variable _stack                ;# array of stacks
  protected variable _pointsndx 2          ;# 
  protected variable _fontnames            ;# list of accepted font names
  protected variable _fontinfo             ;# array of font info given font name
  protected variable _tag                  ;# 
  protected variable _tagl                 ;#
  protected variable _tagfont              ;#
  protected variable _cwd .                ;# base directory of current page
  protected variable _anchor               ;# array of indexes by anchorname
  protected variable _defaulttextbackground;# default text background
  protected variable _intable 0            ;# whether we are in a table now
  protected variable _hottext              ;# widget where text currently goes
  protected variable _basefontsize 2       ;# as named
  protected variable _unknownimg {}        ;# name of unknown image
  protected variable _images {}            ;# list of images we created
  protected variable _prevpos {}           ;# temporary used for table updates
  protected variable _prevtext {}          ;# temporary used for table updates

  constructor {args} {}
  destructor {}

  protected method _setup {}
  protected method _set_tag {}
  protected method _reconfig_tags {}
  protected method _append_text {text}
  protected method _do {text}
  protected method _definefont {name foundry family weight slant registry}
  protected method _peek {instack}
  protected method _push {instack value}
  protected method _pop {instack}
  protected method _parse_fields {array_var string}
  protected method _href_click {cmd href}
  protected method _set_align {align}
  protected method _fixtablewidth {hottext table multiplier}
  protected method _header {level args}
  protected method _/header {level}
  protected method _entity_a {args}
  protected method _entity_/a {}
  protected method _entity_address {}
  protected method _entity_/address {}
  protected method _entity_b {}
  protected method _entity_/b {} 
  protected method _entity_base {{args {}}}
  protected method _entity_basefont {{args {}}}
  protected method _entity_big {}
  protected method _entity_/big {} 
  protected method _entity_blockquote {}
  protected method _entity_/blockquote {} 
  protected method _entity_body {{args {}}}
  protected method _entity_/body {}
  protected method _entity_br {{args {}}}
  protected method _entity_center {}
  protected method _entity_/center {}
  protected method _entity_cite {}
  protected method _entity_/cite {}
  protected method _entity_code {}
  protected method _entity_/code {}
  protected method _entity_dir {{args {}}}
  protected method _entity_/dir {}
  protected method _entity_div {{args {}}}
  protected method _entity_dl {{args {}}}
  protected method _entity_/dl {}
  protected method _entity_dt {}
  protected method _entity_dd {}
  protected method _entity_dfn {}
  protected method _entity_/dfn {}
  protected method _entity_em {}
  protected method _entity_/em {}
  protected method _entity_font {{args {}}}
  protected method _entity_/font {}
  protected method _entity_h1 {{args {}}}
  protected method _entity_/h1 {}
  protected method _entity_h2 {{args {}}}
  protected method _entity_/h2 {}
  protected method _entity_h3 {{args {}}}
  protected method _entity_/h3 {}
  protected method _entity_h4 {{args {}}}
  protected method _entity_/h4 {}
  protected method _entity_h5 {{args {}}}
  protected method _entity_/h5 {}
  protected method _entity_h6 {{args {}}}
  protected method _entity_/h6 {}
  protected method _entity_hr {{args {}}}
  protected method _entity_i {}
  protected method _entity_/i {}
  protected method _entity_img {{args {}}}
  protected method _entity_kbd {}
  protected method _entity_/kbd {}
  protected method _entity_li {{args {}}}
  protected method _entity_listing {}
  protected method _entity_/listing {}
  protected method _entity_menu {{args {}}}
  protected method _entity_/menu {}
  protected method _entity_ol {{args {}}}
  protected method _entity_/ol {}
  protected method _entity_p {{args {}}}
  protected method _entity_pre {{args {}}}
  protected method _entity_/pre {}
  protected method _entity_samp {}
  protected method _entity_/samp {}
  protected method _entity_small {}
  protected method _entity_/small {} 
  protected method _entity_sub {}
  protected method _entity_/sub {} 
  protected method _entity_sup {}
  protected method _entity_/sup {} 
  protected method _entity_strong {}
  protected method _entity_/strong {}
  protected method _entity_table {{args {}}}
  protected method _entity_/table {}
  protected method _entity_td {{args {}}}
  protected method _entity_/td {}
  protected method _entity_th {{args {}}}
  protected method _entity_/th {}
  protected method _entity_title {}
  protected method _entity_/title {}
  protected method _entity_tr {{args {}}}
  protected method _entity_/tr {}
  protected method _entity_tt {}
  protected method _entity_/tt {}
  protected method _entity_u {}
  protected method _entity_/u {}
  protected method _entity_ul {{args {}}}
  protected method _entity_/ul {}
  protected method _entity_var {}
  protected method _entity_/var {}

  protected method configFontname {option value}
  protected method configFixedfont {option value}
  protected method configFontsize {option value}
  protected method configLinkhighlight {option value}
  protected method configUnknownimage {option value}
  protected method configTextbackground {option value}
  protected method configUpdate {option value}
  protected method configDebug {option value}

  public method import {args}
  public method clear {}
  public method render {html {wd .}}
  public method title {} {return $_title}
  public method pwd {} {return $_cwd}

}

# ------------------------------------------------------------------
#                        CONSTRUCTOR
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::constructor {args} {
  # define the fonts we're going to use
  set _fontnames ""
  _definefont helvetica adobe helvetica "medium bold" "r o" iso8859
  _definefont courier adobe courier "medium bold" "r o" iso8859
  _definefont times adobe times "medium bold" "r i" iso8859
  _definefont symbol adobe symbol "medium medium" "r r" adobe

  $text configure -state disabled

  if {[llength $args] > 0} {
      uplevel 0 configure $args
  }
  if {[lsearch -exact $args -linkcommand] == -1} {
    configure -linkcommand [itcl::code $this import -link]
  }
  set _initialized 1
}

# ------------------------------------------------------------------
#                        DESTRUCTOR
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::destructor {} {
    foreach x $_images {
        ::image delete $x
    }
    if {$_unknownimg != $_defUnknownImg} {
        ::image delete $_unknownimg
    }
}

# ------------------------------------------------------------------
#                             OPTIONS
# ------------------------------------------------------------------
 
# ------------------------------------------------------------------
# OPTION: -fontsize
#
# Set the general size of the font.
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::configFontsize {option value} {
    switch $value {
    small {
      }
    medium {
      }
    large {
      }
    huge {
      }
    default {
        error "bad fontsize option \"$value\": should\
               be small, medium, large, or huge"
      }
    }
    _reconfig_tags
    set itcl_options($option) $value
}

# ------------------------------------------------------------------
# OPTION: -fixedfont
#
# Set the fixed font name
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::configFixedfont {option value} {
   if {[lsearch -exact $_fontnames $value] == -1} {
       error "Invalid font name \"$value\". Must be one of $_fontnames"
   }
   set itcl_options($option) $value
}

# ------------------------------------------------------------------
# OPTION: -fontname
#
# Set the default font name
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::configFontname {option value} {
   if {[lsearch -exact $_fontnames $value] == -1} {
       error "Invalid font name \"$value\". Must be one of $_fontnames"
   }
   set itcl_options($option) $value
}

# ------------------------------------------------------------------
# OPTION: -textbackground
#
# Set the default text background
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::configTextbackground {option value} {
    set _defaulttextbackground $value
    set itcl_options($option) $value
}

# ------------------------------------------------------------------
# OPTION: -linkhighlight
#
# same as alink
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::configLinkhighlight {option value} {
    configure -alink $value
    set itcl_options($option) $value
}

# ------------------------------------------------------------------
# OPTION: -unknownimage
#
# set image to use as substitute for images that aren't found
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::configUnknownimage {option value} {
    set oldimage $_unknownimg
    if {$value != {}} {
        set uki $value
        if [catch { set _unknownimg [::image create photo -file $uki] } err] {
            error "Couldn't create image $uki:\n$err\nUnknown image not found"
        }
    } else {
        set _unknownimg $_defUnknownImg
    }
    if {$oldimage != {} && $oldimage != $_defUnknownImg} {
       ::image delete $oldimage
    }
    set itcl_options($option) $value
}

# ------------------------------------------------------------------
# OPTION: -update
#
# boolean indicating whether to update during rendering
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::configUpdate {option value} {
    switch -- $value {
    0 {
      }
    1 {
      }
    true {
        configure -update 1
      }
    yes {
        configure -update 1
      }
    false {
        configure -update 0
      }
    yes {
        configure -update 0
      }
    default {
        error "invalid -update; must be boolean"
      }
    }
    set itcl_options($option) $value
}

# ------------------------------------------------------------------
#                            METHODS
# ------------------------------------------------------------------
 
# ------------------------------------------------------------------
# METHOD: clear
#
# Clears the text out
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::clear {} {
    $text configure -state normal
    $text delete 1.0 end
    foreach x $_images {
        ::image delete $x
    }
    set _images {}
    _setup
    $text configure -state disabled
}

# ------------------------------------------------------------------
# METHOD import ?-link? filename?#anchorname?
#
# read html text from a file (import filename) if the keyword link is present, 
# pathname is relative to last page, otherwise it is relative to current 
# directory. This allows the user to use a linkcommand of 
# "<widgetname> import -link"
#
# if '#anchorname' is appended to the filename, the page is displayed starting
# at the anchor named 'anchorname' If an anchor is specified without a filename,
# the current page is assumed.
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::import {args} {
    update idletasks
    set len [llength $args]
    if {$len != 1 && $len != 2} {
        error "wrong # args: should be \
              \"$itcl_hull import ?-link? filename\""
    }
    set linkname [lindex $args [expr {$len - 1}]]

    #
    # Seperate filename#anchorname
    #
    if {![regexp {(.*)#(.*)} $linkname dummy filename anchorname]} {
        set filename $linkname
    }
    if {$filename ne ""} {
        #
        # Check for -link option
        #
        switch -- $len {
        1 {
            #
            # open file & set cwd to that file's directory
            #
            set f [open $filename r]
            set _cwd [file dirname $filename]
          }
        2 {
            switch -- [lindex $args 0] {
            -link {
                #
                # got -link, so set path relative to current locale, if path
                # is a relative pathname
                #
                if {[string compare "." [file dirname $filename]] == 0} {
                    set f [open $_cwd/$filename r]
                } else {
                    if {[string index [file dirname $filename] 0] != "/" &&\
                          [string index [file dirname $filename] 0] != "~"} {
                        set f [open $_cwd/$filename r]
                        append _cwd /
                        append _cwd [file dirname $filename]
                    } else {
                        set f [open $filename r]
                        set _cwd [file dirname $filename]
                    }
                }
              }
            default {
                # got something other than -link
                error "invalid format: should be \
                      \"$itcl_hull import ?-link? filename\""
              }
            }
          }
        }
        set txt [read $f]
        close $f
        render $txt $_cwd
    }

    #
    # if an anchor was requested, move that anchor into view
    #
    if [ info exists anchorname] {
        if {$anchorname!=""} {
            if [info exists _anchor($anchorname)] {
                $text see end
                $text see $_anchor($anchorname)
            }
        } else {
            $text see 0.0
        }
    }
}

# ------------------------------------------------------------------
# METHOD: render text ?wd?
#
# Clear the text, then render html formatted text. Optional wd argument 
# sets the base directory for any links or images. 
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::render {html {wd .}} {
    update idletasks
    #
    # blank text and reset all state variables
    #
    clear
    set _cwd $wd
    #
    # make text writable
    #
    $text configure -state normal
    set continuerendering 1
    _set_tag
    while {$continuerendering} {
	# normal state
	while {[set len [string length $html]]} {
	    # look for text up to the next <> element
	    if {[regexp -indices "^\[^<\]+" $html match]} {
		set my_text [string range $html 0 [lindex $match 1]]
		_append_text "$my_text"
		set html \
		    [string range $html [expr {[lindex $match 1]+1}] end]
	    }
	    # we're either at a <>, or at the eot
	    if {[regexp -indices "^<((\[^>\"\]+|(\"\[^\"\]*\"))*)>" $html match entity]} {
		regsub -all "\n" [string range $html [lindex $entity 0] \
			    [lindex $entity 1]] "" entity
		set cmd [string tolower [lindex $entity 0]]
		if {[info command _entity_$cmd]!=""} {
		  if {[catch {eval _entity_$cmd [lrange $entity 1 end]} bad]} {
		    if {$itcl_options(-debug)} {
		      global errorInfo
		      puts stderr "render: _entity_$cmd [lrange $entity 1 end] = Error:$bad\n$errorInfo"
		    }
		  }
		}
		set html \
		    [string range $html [expr {[lindex $match 1] + 1}] end]
	    }
	    if {$itcl_options(-feedback) != {} } {
	        eval $itcl_options(-feedback) $len
	    }
	    if {$_verbatim} {
	        break
	    }
	}
	# we reach here if html is empty, or _verbatim is 1
	if {!$len} {
	    break
	}
	# _verbatim must be 1
	# append text until next tag is reached
	if {[regexp -indices "<.*>" $html match]} {
	    set my_text [string range $html 0 [expr {[lindex $match 0] - 1}]]
	    set html [string range $html [expr {[lindex $match 0]}] end]
	} else {
	    set my_text $html
	    set html ""
	}
	_append_text "$my_text"
    }
    $text configure -state disabled
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _setup
#
# Reset all state variables to prepare for a new page.
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_setup {} {
    set _font $itcl_options(-fontname)
    set _left 0
    set _left2 0
    set _right 0
    set _justify L
    set _textweight 0
    set _textslant 0
    set _underline 0
    set _verbatim 0
    set _pre 0
    set _title {}
    set _intitle 0
    set _anchorcount 0
    set _intable 0
    set _hottext $text
    set _stack(font) {}
    set _stack(color) {}
    set _stack(bgcolor) {}
    set _stack(link) {}
    set _stack(alink) {}
    set _stack(justify) {}
    set _stack(listyle) {}
    set _stack(lipic) {}
    set _stack(href) {}
    set _stack(pointsndx) {}
    set _stack(left) {}
    set _stack(left2) {}
    set _stack(offset) {}
    set _stack(table) {}
    set _stack(tablewidth) {}
    set _stack(row) {}
    set _stack(column) {}
    set _stack(hottext) {}
    set _stack(tableborder) {}
    set _stack(cellpadding) {}
    set _stack(cellspacing) {}
    set _stack(licount) {}
    set _basefontsize 2
    set _pointsndx 2
    set _counter -1
    set _bgcolor $_defaulttextbackground
    set _color $itcl_options(-foreground)
    set _link $itcl_options(-link)
    set _alink $itcl_options(-alink)
    configure -textbackground $_bgcolor
    foreach x [array names _anchor] {
        unset _anchor($x)
    }
    $text tag configure hr -relief sunken -borderwidth 2 \
            -font -*-*-*-*-*-*-$_rulerheight-*-*-*-*-*-*-*
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _definefont name foundry family weight slant registry
#
# define font information used to generate font value from font name
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_definefont {name foundry family weight slant registry} {
    if {[lsearch -exact $_fontnames $name] == -1 } {
      lappend _fontnames $name
    }
    set _fontinfo($name) \
	[list $foundry $family $weight $slant $registry]
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _append_text text
#
# append text in the format described by the state variables
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_append_text {text} {
    if {!$_intable && $itcl_options(-update)} {
        update
    }
    if {[string first "&" $text] != -1} {
       regsub -nocase -all "&amp;" $text {\&} text
       regsub -nocase -all "&lt;" $text "<" text
       regsub -nocase -all "&gt;" $text ">" text
       regsub -nocase -all "&quot;" $text "\"" text
    }
    if {!$_verbatim} {
	if !$_pre {
            set text [string trim $text "\n\r"]
	    regsub -all "\[ \n\r\t\]+" $text " " text
	}
	if ![string length $text] return
    }
    if {!$_pre && !$_intitle} {
     	if {[catch {$_hottext get "end - 2c"} p]} {
     	    set p ""
     	}
	set n [string index $text 0]
        if {$n == " " && $p == " "} {
            set text [string range $text 1 end]
        }
 	if {[catch {$_hottext insert end $text $_tag}]} {
 	    set pht [winfo parent $_hottext]
 	    catch {$pht insert end $text $_tag}
 	}
	return
    }
    if {$_pre && !$_intitle} {
 	if {[catch {$_hottext insert end $text $_tag}]} {
 	    set pht [winfo parent $_hottext]
 	    catch {$pht insert end $text $_tag}
 	}
	return
    }
    append _title $text
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _set_tag
#
# generate a tag
# ------------------------------------------------------------------
# a tag is constructed as: font?B?I?U?Points-LeftLeft2RightColorJustify
::itcl::body Scrolledhtml::_set_tag {} {
    set i -1
    foreach var {foundry family weight slant registry} {
	set $var [lindex $_fontinfo($_font) [incr i]]
    }
    set x_font "-$foundry-$family-"
    set _tag $_font
    set args {}
    if {$_textweight > 0} {
	append _tag "B"
	append x_font [lindex $weight 1]-
    } else {
	append x_font [lindex $weight 0]-
    }
    if {$_textslant > 0} {
	append _tag "I"
	append x_font [lindex $slant 1]-
    } else {
	append x_font [lindex $slant 0]-
    }
    if {$_underline > 0} {
	append _tag "U"
	append args " -underline 1"
    }
    switch $_justify {
    L {
        append args " -justify left"
      }
    R {
        append args " -justify right"
      }
    C {
        append args " -justify center"
      }
    }
    append args " -offset $_offset"
    set pts [lindex [set [format "_%spoints" $itcl_options(-fontsize)]] \
        $_pointsndx]
    append _tag $_pointsndx - $_left \
	$_left2 $_right \
	$_color $_justify
    append x_font "normal-*-*-$pts-*-*-*-*-$registry-*"
    if {$_anchorcount} {
	set href [_peek href]
	set href_tag href[incr _counter]
	set tags [list $_tag $href_tag]
	if {$itcl_options(-linkcommand) != {}} {
	    $_hottext tag bind $href_tag <1> \
		[list uplevel #0 $itcl_options(-linkcommand) $href]
	}
	$_hottext tag bind $href_tag <Enter> \
	    [list $_hottext tag configure $href_tag -foreground $_alink]
	$_hottext tag bind $href_tag <Leave> \
	    [list $_hottext tag configure $href_tag -foreground $_color]
    } else {
	set tags $_tag
    }
    if {![info exists _tagl($_tag)]} {
	set _tagfont($_tag) 1
	eval $_hottext tag configure $_tag \
	    -foreground ${_color} \
	    -lmargin1 ${_left}m \
	    -lmargin2 ${_left2}m $args
	if [catch {eval $_hottext tag configure $_tag \
	        -font $x_font} err] {
            _definefont $_font * $family $weight $slant *
            regsub \$foundry $x_font * x_font
            regsub \$registry $x_font * x_font
	    catch {eval $_hottext tag configure $_tag -font $x_font}
        }
    }
    if {[info exists href_tag]} {
	$_hottext tag raise $href_tag $_tag
    }
    set _tag $tags
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _reconfig_tags
#
# reconfigure tags following a configuration change
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_reconfig_tags {} {
    if {$_initialized} {
        foreach tag [$text tag names] {
	    foreach efont $_fontnames {
	        if [regexp "${efont}(B?)(I?)(U?)(\[1-9\]\[0-9\]*)-" $tag t b i u points] {
		    set j -1
		    set _font $efont
		    foreach var {foundry family weight slant registry} {
		        set $var [lindex $_fontinfo($_font) [incr j]]
		    }
		    set x_font "-$foundry-$family-"
		    if {$b == "B"} {
		        append x_font [lindex $weight 1]-
		    } else {
		        append x_font [lindex $weight 0]-
		    }
		    if {$i == "I"} {
		        append x_font [lindex $slant 1]-
		    } else {
		        append x_font [lindex $slant 0]-
		    }
		    set pts [lindex [set [format \
                         "_%spoints" $itcl_options(-fontsize)]] $points]
		    append x_font "normal-*-*-$pts-*-*-*-*-$registry-*"
		    $text tag configure $tag -font $x_font
		    break
	        }
	    }
        }
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _push instack value
#
# push value onto stack(instack)
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_push {instack value} {
    set _stack($instack) [linsert $_stack($instack) 0 $value]
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _pop instack
#
# pop value from stack(instack)
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_pop {instack} {
    if {$_stack($instack) == ""} {
	error "popping empty _stack $instack"
    }
    set val [lindex $_stack($instack) 0]
    set _stack($instack) [lrange $_stack($instack) 1 end]
    return $val
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _peek instack
#
# peek at top value on stack(instack)
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_peek {instack} {
    return [lindex $_stack($instack) 0]
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _parse_fields array_var string
#
# parse fields from a href or image tag. At the moment, doesn't support
# spaces in field values. (e.g. alt="not avaliable")
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_parse_fields {array_var string} {
    upvar $array_var array
    if {$string != "{}" } {
        regsub -all "( *)=( *)" $string = string
        regsub -all {\\\"} $string \" string
        while {$string != ""} {
            if ![regexp "^ *(\[^ \n\r=\]+)=\"(\[^\"\n\r\t\]*)(.*)" $string \
                      dummy field value newstring] {
                if ![regexp "^ *(\[^ \n\r=\]+)=(\[^\n\r\t \]*)(.*)" $string \
                          dummy field value newstring] {
                    if ![regexp "^ *(\[^ \n\r\]+)(.*)" $string dummy field newstring] {
                        error "malformed command field; field = \"$string\""
                        continue
                    }
                    set value ""
                }
            }
            set array([string tolower $field]) $value
            set string "$newstring"
        }
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _href_click
#
# process a click on an href
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_href_click {cmd href} {
    uplevel #0 $cmd $href
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _set_align
#
# set text alignment
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_set_align {align} {
    switch [string tolower $align] {
    center {
        set _justify C
      }
    left {
        set _justify L
      }
    right {
        set _justify R
      }
    default {
      }
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _fixtablewidth
#
# fix table width & height
# essentially, with nested tables the outer table must be configured before
# the inner table, but the idle tasks get queued up in the opposite order, 
# so process later idle tasks before sizing yourself.
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_fixtablewidth {hottext table multiplier} {
    update idletasks
    $hottext see $_anchor($table)
    update idletasks
    $table configure  \
           -width [expr {$multiplier * [winfo width $hottext] - \
                       	2 * [$hottext cget -padx] - \
			2 * [$hottext cget -borderwidth]} ] \
           -height [winfo height $table]
    grid propagate $table 0
}
		 

# ------------------------------------------------------------------
# PRIVATE METHOD: _header level
#
# generic entity to set state for <hn> tag
# Accepts argument of the form ?align=[left,right,center]? ?src=<image pname>?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_header {level args} {
    eval _parse_fields ar $args
    _push justify $_justify
    if {[info exists ar(align)]} {
        _entity_p align=$ar(align)
    } else {
        _entity_p 
    }
    if [info exists ar(src)] {
        _entity_img src=$ar(src)
    }
    _push pointsndx $_pointsndx
    set _pointsndx [expr {7-$level}]
    incr _textweight
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _/header level
#
# generic entity to set state for </hn> tag
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_/header {level} {
    set _justify [_pop justify]
    set _pointsndx [_pop pointsndx]
    incr _textweight -1
    _set_tag
    _entity_p
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_a
#
# add an anchor. Accepts arguments of the form ?href=filename#anchorpoint?
# ?name=anchorname?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_a {args} {
    _parse_fields ar $args
    _push color $_color
    if {[info exists ar(href)]} {
        _push href $ar(href)
        incr _anchorcount
        set _color $_link
        _entity_u
    } else {
        _push href {}
    }
    if [info exists ar(name)] {
        set _anchor($ar(name)) [$text index end]
    }
    if [info exists ar(id)] {
        set _anchor($ar(id)) [$text index end]
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/a
#
# End anchor
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/a {} {
    set href [_pop href]
    if {$href != {}} {
        incr _anchorcount -1
        set _color [_pop color]
        _entity_/u
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_address
#
# display an address
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_address {} {
    _entity_br
    _entity_i
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/address
#
# change state back from address display
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/address {} {
    _entity_/i
    _entity_br
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_b
#
# Change current font to bold
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_b {} { 
    incr _textweight
    _set_tag 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/b
#
# change current font back from bold
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/b {} {
    incr _textweight -1
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_base
#
# set the cwd of the document
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_base {{args {}}} { 
    _parse_fields ar $args
    if {[info exists ar(href)]} {
        set _cwd [file dirname $ar(href)]
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_basefont
#
# set base font size
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_basefont {{args {}}} { 
    _parse_fields ar $args
    if {[info exists ar(size)]} {
        set _basefontsize $ar(size)
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_big
#
# Change current font to a bigger size
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_big {} { 
    _push pointsndx $_pointsndx
    if {[incr _pointsndx 2] > 6} {
        set _pointsndx 6
    }
    _set_tag 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/big
#
# change current font back from bigger size
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/big {} {
    set _pointsndx [_pop pointsndx]
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_blockquote
#
# display a block quote
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_blockquote {} { 
    _entity_p
    _push left $_left
    incr _left $_indentincr
    _push left2 $_left2
    set _left2 $_left
    _set_tag 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/blockquote
#
# change back from blockquote
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/blockquote {} {
    _entity_p
    set _left [_pop left]
    set _left2 [_pop left2]
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_body
#
# begin body text. Takes argument of the form ?bgcolor=<color>? ?text=<color>?
# ?link=<color>?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_body {{args {}}} {
    _parse_fields ar $args
    if {[info exists ar(bgcolor)]} {
        set _bgcolor $ar(bgcolor)
        set temp $itcl_options(-textbackground)
        configure -textbackground $_bgcolor
        set _defaulttextbackground $temp
    }
    if {[info exists ar(text)]} {
        set _color $ar(text)
    }
    if {[info exists ar(link)]} {
        set _link $ar(link)
    }
    if {[info exists ar(alink)]} {
        set _alink $ar(alink)
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/body
#
# end body text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/body {} {
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_br
#
# line break
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_br {{args {}}} {
    $_hottext insert end "\n"
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_center
#
# change justification to center
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_center {} {
    _push justify $_justify
    set _justify C
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/center
#
# change state back from center
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/center {} {
    set _justify [_pop justify]
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_cite
#
# display citation
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_cite {} {
    _entity_i
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/cite
#
# change state back from citation
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/cite {} {
    _entity_/i
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_code
#
# display code listing
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_code {} {
    _entity_pre
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/code
#
# end code listing
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/code {} {
    _entity_/pre
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_dir
#
# display dir list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_dir {{args {}}} {
    _entity_ul plain $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/dir
#
# end dir list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/dir {} {
    _entity_/ul
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_div
#
# divide text. same as <p>
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_div {{args {}}} {
    _entity_p $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_dl
#
# begin definition list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_dl {{args {}}} {
    if {$_left == 0} {
        _entity_p
    }
    _push left $_left
    _push left2 $_left2
    if {$_left2 == $_left } {
        incr _left2 [expr {$_indentincr+3}]
    } else {
        incr _left2 $_indentincr
    }
    incr _left $_indentincr
    _push listyle $_listyle
    _push licount $_licount
    set _listyle none
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/dl
#
# end definition list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/dl {} {
    set _left [_pop left]
    set _left2 [_pop left2]
    set _listyle [_pop listyle]
    set _licount [_pop licount]
    _set_tag
    if {$_left == 0} {
        _entity_p
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_dt
#
# definition term
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_dt {} {
    set _left [expr {$_left2 - 3}]
    _set_tag
    _entity_p
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_dd
#
# definition definition
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_dd {} {
    set _left $_left2
    _set_tag
    _entity_br
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_dfn
#
# display defining instance of a term
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_dfn {} {
    _entity_i
    _entity_b
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/dfn
#
# change state back from defining instance of term
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/dfn {} {
    _entity_/b
    _entity_/i
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_em
#
# display emphasized text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_em {} {
    _entity_i
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/em
#
# change state back from emphasized text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/em {} {
    _entity_/i
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_font
#
# set font size and color
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_font {{args {}}} {
    _parse_fields ar $args
    _push pointsndx $_pointsndx
    _push color $_color
    if {[info exists ar(size)]} {
        if {![regexp {^[+-].*} $ar(size)]} {
            set _pointsndx $ar(size)
        } else {
            set _pointsndx [expr $_basefontsize $ar(size)]
        }
      if { $_pointsndx > 6 } {
         set _pointsndx 6
      } else {
          if { $_pointsndx < 0 } {
              set _pointsndx 0
          }
      }
    }
    if {[info exists ar(color)]} {
        set _color $ar(color)
    }
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/font
#
# close current font size
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/font {} {
    set _pointsndx [_pop pointsndx]
    set _color [_pop color]
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_h1
#
# display header level 1. 
# Accepts argument of the form ?align=[left,right,center]? ?src=<image pname>?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_h1 {{args {}}} {
    _header 1 $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/h1
#
# change state back from header 1
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/h1 {} {
    _/header 1
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_h2
#
# display header level 2
# Accepts argument of the form ?align=[left,right,center]? ?src=<image pname>?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_h2 {{args {}}} {
    _header 2 $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/h2
#
# change state back from header 2
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/h2 {} {
    _/header 2 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_h3
#
# display header level 3
# Accepts argument of the form ?align=[left,right,center]? ?src=<image pname>?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_h3 {{args {}}} {
    _header 3 $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/h3
#
# change state back from header 3
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/h3 {} {
    _/header 3 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_h4
#
# display header level 4
# Accepts argument of the form ?align=[left,right,center]? ?src=<image pname>?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_h4 {{args {}}} { 
    _header 4 $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/h4
#
# change state back from header 4
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/h4 {} {
    _/header 4
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_h5
#
# display header level 5
# Accepts argument of the form ?align=[left,right,center]? ?src=<image pname>?
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_h5 {{args {}}} {
    _header 5 $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/h5
#
# change state back from header 5
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/h5 {} {
    _/header 5
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_h6
#
# display header level 6
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_h6 {{args {}}} {
    _header 6 $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/h6
#
# change state back from header 6
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/h6 {} {
    _/header 6
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_hr
#
# Add a horizontal rule
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_hr {{args {}}} {
    _parse_fields ar $args
    if {[info exists ar(size)]} {
        set font "-font -*-*-*-*-*-*-$ar(size)-*-*-*-*-*-*-*"
    } else {
        set font "-font -*-*-*-*-*-*-2-*-*-*-*-*-*-*"
    }
    if {[info exists ar(width)]} {
    }
    if {[info exists ar(noshade)]} {
        set relief "-relief flat"
        set background "-background black"
    } else {
        set relief "-relief sunken"
        set background ""
    }
#    if {[info exists ar(align)]} {
#         $_hottext tag configure hr$_counter -justify $ar(align)
#         set justify -justify $ar(align)
#    } else {
#         set justify ""
#    }
    eval $_hottext tag configure hr[incr _counter] $relief $background $font \
            -borderwidth 2
    _entity_p
    $_hottext insert end " \n" hr$_counter
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_i
#
# display italicized text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_i {} {
    incr _textslant
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/i
#
# change state back from italicized text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/i {} {
    incr _textslant -1
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_img
#
# display an image. takes argument of the form img=<filename>
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_img {{args {}}} {
    _parse_fields ar $args
    set alttext "<image>"

    #
    # If proper argument exists
    #
    if {[info exists ar(src)]} {
        set imgframe $_hottext.img[incr _counter]
        #
        # if this is an anchor
        #
        if {$_anchorcount} {
            # create link colored border
            frame $imgframe -borderwidth 2 -background $_link
            bind $imgframe <Enter> \
                  [list $imgframe configure -background $_alink]
            bind $imgframe <Leave> \
                  [list $imgframe configure -background $_link]
        } else {
            # create plain frame
            frame $imgframe -borderwidth 0 -background $_color
        }

        #
        # try to load image
        #
        if {[string index $ar(src) 0] == "/" || [string index $ar(src) 0] == "~"} {
           set file $ar(src)
        } else {
           set file $_cwd/$ar(src)
        }
        if {[catch {set img [::image create photo -file $file]} err]} {
            if {[info exists ar(width)] && [info exists ar(height)] } {
                # suggestions exist, so make frame appropriate size and add a border
                $imgframe configure -width $ar(width) -height $ar(height) -borderwidth 2
                pack propagate $imgframe false
            }

            #
            # If alt text is specified, display that
            #
            if {[info exists ar(alt)]} {
                # add a border
                $imgframe configure -borderwidth 2
                set win $imgframe.text
                label $win -text "$ar(alt)" -background $_bgcolor \
                       -foreground $_color
            } else {
                #
                # use 'unknown image'
                set win $imgframe.image#auto
                #
                # make label containing image
                #
                label $win -image $_unknownimg -borderwidth 0 -background $_bgcolor
            }
            pack $win -fill both -expand true
 
        } else {   ;# no error loading image
            lappend _images $img
            set win $imgframe.$img

            #
            # make label containing image
            #
            label $win -image $img -borderwidth 0
        }
        pack $win

        #
        # set alignment
        #
        set align bottom
        if {[info exists ar(align)]} {
            switch $ar(align) {
            middle {
                set align center
              }
            right {
                set align center
              }
            default {
                set align [string tolower $ar(align)]
              }
            }
        }

        #
        # create window in text to display image
        #
        $_hottext window create end -window \
                $imgframe -align $align

        #
        # set tag for window
        #
        $_hottext tag add $_tag $imgframe
        if {$_anchorcount} {
            set href [_peek href]
            set href_tag href[incr _counter]
            set tags [list $_tag $href_tag]
            if {$itcl_options(-linkcommand) ne {}} {
                bind $win <1> [list uplevel #0 $itcl_options(-linkcommand) $href]
            }
        }
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_kbd
#
# Display keyboard input
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_kbd {} {
    incr _textweight
    _entity_tt 
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/kbd
#
# change state back from displaying keyboard input
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/kbd {} {
    _entity_/tt
    incr _textweight -1
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_li
#
# begin new list entry
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_li {{args {}}} {
    _parse_fields ar $args
    if {[info exists ar(value)]} {
       set _licount $ar(value)
    }
    _entity_br
    switch -exact $_listyle {
    bullet {
        set old_font $_font
        set _font symbol
        _set_tag
        $_hottext insert end "\xb7" $_tag
        set _font $old_font
        _set_tag
      }
    none {
      }
    picture {
        _entity_img src="$_lipic" width=4 height=4 align=middle
      }
    A {
        _entity_b
        $_hottext insert end [format "%c) " [expr {$_licount + 0x40}]] $_tag
        _entity_/b
        incr _licount
      }
    a {
        _entity_b
        $_hottext insert end [format "%c) " [expr {$_licount + 0x60}]] $_tag
        _entity_/b
        incr _licount
      }
    I {
        _entity_b
        $_hottext insert end "[::::itcl::widgets::roman $_licount]) " $_tag
        _entity_/b
        incr _licount
      }
    i {
        _entity_b
        $_hottext insert end "[::::itcl::widgets::roman $_licount lower])] " $_tag
        _entity_/b
        incr _licount
      }
    default {
        _entity_b
        $_hottext insert end "$_licount) " $_tag
        _entity_/b
        incr _licount
      }
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_listing
#
# diplay code listing
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_listing {} {
    _entity_pre
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/listing
#
# end code listing
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/listing {} {
    _entity_/pre
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_menu
#
# diplay menu list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_menu {{args {}}} {
    _entity_ul plain $args
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/menu
#
# end menu list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/menu {} {
    _entity_/ul
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_ol
#
# begin ordered list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_ol {{args {}}} {
    _parse_fields ar $args
    if {$_left} {
        _entity_br
    } else {
        _entity_p
    }
    if {![info exists ar(type)]} {
        set ar(type) 1
    }
    _push licount $_licount
    if {[info exists ar(start)]} {
        set _licount $ar(start)
    } else {
        set _licount 1
    }
    _push left $_left
    _push left2 $_left2
    if {$_left2 == $_left } {
        incr _left2 [expr {$_indentincr+3}]
    } else {
        incr _left2 $_indentincr
    }
    incr _left $_indentincr
    _push listyle $_listyle
    set _listyle $ar(type)
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/ol
#
# end ordered list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/ol {} {
    set _left [_pop left]
    set _left2 [_pop left2]
    set _listyle [_pop listyle]
    set _licount [_pop licount]
    _set_tag
    _entity_p
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_p
#
# paragraph break
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_p {{args {}}} {
    _parse_fields ar $args
    if {[info exists ar(align)]} {
       _set_align $ar(align)
    } else {
       set _justify L
    }
    _set_tag
    if {[info exists ar(id)]} {
        set _anchor($ar(id)) [$text index end]
    }
    set x [$_hottext get end-3c]
    set y [$_hottext get end-2c]
    if {$x == "" && $y == ""} {
        return
    }
    if {$y == ""} {
        $_hottext insert end "\n\n"
        return
    }
    if {$x == "\n" && $y == "\n"} {
        return
    }
    if {$y == "\n"} {
        $_hottext insert end "\n"
        return
    }
    $_hottext insert end "\n\n"
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_pre
#
# display preformatted text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_pre {{args {}}} { 
    _entity_tt
    _entity_br
    incr _pre
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/pre
#
# change state back from preformatted text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/pre {} {
    _entity_/tt
    set _pre 0
    _entity_p
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_samp
#
# display sample text.
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_samp {} {
    _entity_kbd
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/samp
#
# switch back to non-sample text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/samp {} {
   _entity_/kbd
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_small
#
# Change current font to a smaller size
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_small {} { 
    _push pointsndx $_pointsndx
    if {[incr _pointsndx -2] < 0} {
        set _pointsndx 0
    }
    _set_tag 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/small
#
# change current font back from smaller size
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/small {} {
    set _pointsndx [_pop pointsndx]
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_sub
#
# display subscript
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_sub {} {
    _push offset $_offset
    incr _offset -2
    _entity_small
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/sub
#
# switch back to non-subscript
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/sub {} {
    set _offset [_pop offset]
    _entity_/small
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_sup
#
# display superscript
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_sup {} {
    _push offset $_offset
    incr _offset 4
    _entity_small
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/sup
#
# switch back to non-superscript
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/sup {} {
    set _offset [_pop offset]
    _entity_/small
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_strong
#
# display strong text. (i.e. make font bold)
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_strong {} {
    incr _textweight
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/strong
#
# switch back to non-strong text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/strong {} {
    incr _textweight -1
    _set_tag 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_table
#
# display a table.
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_table {{args {}}} {
    _parse_fields ar $args
    _entity_p
    set _intable 1

    _push row -1
    _push column 0
    _push hottext $_hottext
    _push justify $_justify
    _push justify L
    # push color information for master of table, then push info for table
    _push color $_color
    _push bgcolor $_bgcolor
    _push link $_link
    _push alink $_alink
    if {[info exists ar(bgcolor)]} {
        set _bgcolor $ar(bgcolor)
    }
    if {[info exists ar(text)]} {
        set _color $ar(text)
    }
    if {[info exists ar(link)]} {
        set _link $ar(link)
    }
    if {[info exists ar(alink)]} {
        set _alink $ar(alink)
    }
    _push color $_color
    _push bgcolor $_bgcolor
    _push link $_link
    _push alink $_alink
    # push fake first row to avoid using optional /tr tag
    # (This needs to set a real color - not the empty string
    # becaule later code will try to use those values.)
    _push color $_color
    _push bgcolor $_bgcolor
    _push link {}
    _push alink {}

    if {[info exists ar(align)]} {
        _set_align $ar(align)
        _set_tag
        _append_text " "
    }
    set _justify L

    if {[info exists ar(id)]} {
        set _anchor($ar(id)) [$text index end]
    }
    if {[info exists ar(cellpadding)]} {
        _push cellpadding $ar(cellpadding)
    } else {
        _push cellpadding 0
    }
    if {[info exists ar(cellspacing)]} {
        _push cellspacing $ar(cellspacing)
    } else {
        _push cellspacing 0
    }
    if {[info exists ar(border)]} {
        _push tableborder 1
        set relief raised
        if {$ar(border)==""} {
            set ar(border) 2
        }
    } else {
        _push tableborder 0
        set relief flat
        set ar(border) 2
    }
    _push table [set table $_hottext.table[incr _counter]]
    ::itcl::widgets::labeledwidget $table -foreground $_color -background $_bgcolor -labelpos n
    if {[info exists ar(title)]} {
        $table configure -labeltext $ar(title)
    }
    #
    # create window in text to display table
    #
    $_hottext window create end -window $table

    set table [$table childsite]
    set _anchor($table) [$_hottext index "end - 1 line"]
    $table configure -borderwidth $ar(border) -relief $relief

    if {[info exists ar(width)]} {
        _push tablewidth $ar(width)
    } else {
        _push tablewidth 0
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/table
#
# end table
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/table {} {
    if {$_intable} {
        _pop tableborder
        set table [[_pop table] childsite]
        _pop row
        _pop column
        _pop cellspacing
        _pop cellpadding
        # pop last row's defaults
        _pop color
        _pop bgcolor
        _pop link
        _pop alink
        # pop table defaults
        _pop color
        _pop bgcolor
        _pop link
        _pop alink
        # restore table master defaults
        set _color [_pop color]
        set _bgcolor [_pop bgcolor]
        set _link [_pop link]
        set _alink [_pop alink]
        foreach x [grid slaves $table] {
 	    set text [$x get 1.0 end]
 	    set tl [split $text \n]
 	    set max 0
 	    foreach l $tl {
 	        set len [string length $l]
 	        if {$len > $max} {
 	            set max $len
 	        }
 	    }
 	    if {$max > [$x cget -width]} {
 	        $x configure -width $max
 	    }
	    if {[$x cget -height] == 1} {
                $x configure -height [lindex [split [$x index "end - 1 chars"] "."] 0]
            }
        }
        $_hottext configure -state disabled
        set _hottext [_pop hottext]
        $_hottext configure -state normal
        if {[set tablewidth [_pop tablewidth]]!="0"} {
	    if {[string index $tablewidth \
		 [expr {[string length $tablewidth] -1}]] == "%"} {
                set multiplier [expr {[string trimright $tablewidth "%"] / 100.0}]
	        set idletask [after idle [itcl::code "$this _fixtablewidth $_hottext $table $multiplier"]]
            } else {
                $table configure -width $tablewidth
                grid propagate $table 0
            }
        }
        _pop justify
        set _justify [_pop justify]
        _entity_br
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_td
#
# start table data cell
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_td {{args {}}} {
    if $_intable {
        _parse_fields ar $args
        set table [[_peek table] childsite]
        if {![info exists ar(colspan)]} {
	    set ar(colspan) 1
        }
        if {![info exists ar(rowspan)]} {
	    set ar(rowspan) 1
        }
        if {![info exists ar(width)]} {
	    set ar(width) 10
        }
        if {![info exists ar(height)]} {
	    set ar(height) 0
        }
        if {[info exists ar(bgcolor)]} {
            set _bgcolor $ar(bgcolor)
        } else {
            set _bgcolor [_peek bgcolor]
        }
        if {[info exists ar(text)]} {
            set _color $ar(text)
        } else {
            set _color [_peek color]
        }
        if {[info exists ar(link)]} {
            set _link $ar(link)
        } else {
            set _link [_peek link]
        }
        if {[info exists ar(alink)]} {
            set _alink $ar(alink)
        } else {
            set _alink [_peek alink]
        }
        $_hottext configure -state disabled
        set cellpadding [_peek cellpadding]
        set cellspacing [_peek cellspacing]
        set _hottext $table.cell[incr _counter]
        text $_hottext -relief flat -width $ar(width) -height $ar(height) \
	     -highlightthickness 0 -wrap word -cursor $itcl_options(-cursor) \
             -wrap word -cursor $itcl_options(-cursor) \
             -padx $cellpadding -pady $cellpadding
        if {$_color != ""} {
            $_hottext configure -foreground $_color
        }
        if {$_bgcolor != ""} {
            $_hottext configure -background $_bgcolor
        }
        if {[info exists ar(nowrap)]} {
	    $_hottext configure -wrap none
        }
        if {[_peek tableborder]} {
            $_hottext configure -relief sunken
        }
        set row [_peek row]
        if {$row < 0} {
            set row 0
        }
        set column [_pop column]
        if {$column < 0} {
            set column 0
        }
        while {[grid slaves $table -row $row -column $column] != ""} {
            incr column
        }
        grid $_hottext -sticky nsew -row $row -column $column \
                -columnspan $ar(colspan) -rowspan $ar(rowspan) \
                -padx $cellspacing -pady $cellspacing
        grid columnconfigure $table $column -weight 1
        _push column [expr {$column + $ar(colspan)}]
        if [info exists ar(align)] {
            _set_align $ar(align)
        } else {
            set _justify [_peek justify]
        }
        _set_tag
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/td
#
# end table data cell
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/td {} {
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_th
#
# start table header
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_th {{args {}}} {
    if {$_intable} {
        _parse_fields ar $args
        if {[info exists ar(align)]} {
           _entity_td $args
        } else {
           _entity_td align=center $args
        }
        _entity_b
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/th
#
# end table data cell
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/th {} {
    _entity_/td
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_title
#
# begin title of document
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_title {} {
    set _intitle 1 
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/title
#
# end title
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/title {} {
    set _intitle 0
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_tr
#
# start table row
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_tr {{args {}}} {
    if {$_intable} {
        _parse_fields ar $args
        _pop justify
        if {[info exists ar(align)]} {
            _set_align $ar(align)
            _push justify $_justify
        } else {
            _push justify L
        }
        # pop last row's colors
        _pop color
        _pop bgcolor
        _pop link
        _pop alink
        if {[info exists ar(bgcolor)]} {
            set _bgcolor $ar(bgcolor)
        } else {
            set _bgcolor [_peek bgcolor]
        }
        if {[info exists ar(text)]} {
            set _color $ar(text)
        } else {
            set _color [_peek color]
        }
        if {[info exists ar(link)]} {
            set _link $ar(link)
        } else {
            set _link [_peek link]
        }
        if {[info exists ar(alink)]} {
            set _alink $ar(alink)
        } else {
            set _alink [_peek alink]
        }
        # push this row's defaults
        _push color $_color
        _push bgcolor $_bgcolor
        _push link $_link
        _push alink $_alink
        $_hottext configure -state disabled
        _push row [expr {[_pop row] + 1}]
        _pop column
        _push column 0
    }
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/tr
#
# end table row
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/tr {} {
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_tt
#
# Show typewriter text, using the font given by -fixedfont
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_tt {} {
    _push font $_font
    set _font $itcl_options(-fixedfont)
    set _verbatim 1
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/tt
#
# Change back to non-typewriter mode to display text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/tt {} {
    set _font [_pop font]
    set _verbatim 0
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_u
#
# display underlined text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_u {} { 
    incr _underline
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/u
#
# change back from underlined text
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/u {} { 
    incr _underline -1
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_ul
#
# begin unordered list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_ul {{args {}}} {
    _parse_fields ar $args
    if {$_left} {
        _entity_br
    } else {
        _entity_p
    }
    if {[info exists ar(id)]} {
        set _anchor($ar(id)) [$text index end]
    }
    _push left $_left
    _push left2 $_left2
    if {$_left2 == $_left } {
        incr _left2 [expr {$_indentincr+3}]
    } else {
        incr _left2 $_indentincr
    }
    incr _left $_indentincr
    _push listyle $_listyle
    _push licount $_licount
    if {[info exists ar(plain)]} {
        set _listyle none
    } {
        set _listyle bullet
    }
    if {[info exists ar(dingbat)]} {
        set ar(src) $ar(dingbat)
    }
    _push lipic $_lipic
    if {[info exists ar(src)]} {
        set _listyle picture
        set _lipic $ar(src)
    }
    _set_tag
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/ul
#
# end unordered list
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/ul {} {
    set _left [_pop left]
    set _left2 [_pop left2]
    set _listyle [_pop listyle]
    set _licount [_pop licount]
    set _lipic [_pop lipic]
    _set_tag
    _entity_p
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_var
#
# Display variable
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_var {} {
    _entity_i
}

# ------------------------------------------------------------------
# PRIVATE METHOD: _entity_/var
#
# change state back from variable display
# ------------------------------------------------------------------
::itcl::body Scrolledhtml::_entity_/var {} {
    _entity_/i
}

} ; # end ::itcl::widgets