#!/usr/bin/perl 
#
#   search.pl
#
#   driver to search BOOKS, CHAPTERS, and PROCEEDINGS simultaneously
#   method post
#
#   zn.   2/13/01. mod: 8/1/01.
#   zn. 8-10-01. added links to CHAP sources.
#   zn. 3-7-03. problems due to empty lines appearing randomly in files.
#               all subs changed to end records by "<p>" rather than empty
#               lines. And ignore all empty lines within records.
#   zn. 7-14 (and 15)-03.  changed sub sourcesearch
#   zn.  12-5-2012 minor changes
#   zn.  14-10-04  ECS CHANGES  updated with the help of Anthony of ECS
#
#
#require "d:/zn-estir/scripts/zn-formats.pl";
#require "/home/httpd/cgi-bin/zn-formats.pl";
require "/home/vhosts/knowledge.electrochem.org/estir/search/formats.pl";  # ECS CHANGE
($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime(time);
$current_year = 1900 + $year;
$current_month = 1 + $mon;
$name_start = "s_";
$name_end = ".log";
$name_insert = "_";
if ($current_month < 10) {$name_insert = "_0";}
$logname = $name_start.$current_year.$name_insert.$current_month.$name_end;
#$resfile="d:/zn-estir/temp/results.txt";
#$logfile="d:/zn-estir/temp/$logname";
#$resfile="/home/httpd/html/estir/temp/results.txt";
$resfile="/home/vhosts/knowledge.electrochem.org/estir/search/cbpresults.txt"; #ECS CHANGE
#$logfile="/home/httpd/html/estir/temp/$logname";
$logfile="/home/vhosts/knowledge.electrochem.org/estir/search/$logname";  #  ECS CHANGE
$DataLen = $ENV{'CONTENT_LENGTH'};
read (STDIN, $QueryString, $DataLen);
@NameValuePairs = split (/&/, $QueryString);
@quest = split (/=/, $NameValuePairs[0]);
$search_type = $quest[1];
@quest = split (/=/, $NameValuePairs[1]);
$key = $quest[1];
$key =~ tr/+/ /;
$key =~ s/%([\dA-Fa-f][\dA-Fa-f])/ pack ("C", hex ($1))/eg;
@keys = [NULL,NULL,NULL,NULL];
@keys = split(" ",$key);
@quest = split (/=/, $NameValuePairs[2]);
$coupling = $quest[1];
@quest = split (/=/, $NameValuePairs[3]);
$key_alt = $quest[1];
$key_alt =~ tr/+/ /;
$key_alt =~ s/%([\dA-Fa-f][\dA-Fa-f])/ pack ("C", hex ($1))/eg;
@keys_alt = [NULL,NULL,NULL,NULL];
@keys_alt = split(" ",$key_alt);
$alt_search =0 ;
#if ( ($key_alt ne "") && ($key_alt ~ /\w+/i) ) {$alt_search = 1;} doesnot work?
if ($key_alt ne "") {$alt_search = 1;}
if ($key_alt !~ /\w+/i) {$alt_search = 0;}
@quest = split (/=/, $NameValuePairs[4]);
$start = $quest[1];
@quest = split (/=/, $NameValuePairs[5]);
$end = $quest[1];
if (($start !~ /[0-9]{4}/) || ($start < 1950 ) || ($start > $current_year))
    {$start = 1950;}
if (($end !~ /[0-9]{4}/) || ($end < 1950 ) || ($end > $current_year))
    {$end = $current_year;}
if ($start > $end)
   {
    $start = 1950;
    $end = $current_year;
   }
$startcode = $start;
$stopcode = 1 + $end;
@quest = split (/=/, $NameValuePairs[6]);
$form_name = $quest[1];
$b_check = "off";
$c_check = "off";
$p_check = "off";
@quest = split (/=/, $NameValuePairs[7]);     #
if ($quest[0] eq books) {$b_check = "on";}    #    all three need to be checked
if ($quest[0] eq chap) {$c_check = "on";}     #    every time
if ($quest[0] eq proc) {$p_check = "on";}     #    because the order of boxes is
@quest = split (/=/, $NameValuePairs[8]);     #    different in the three forms
if ($quest[0] eq books) {$b_check = "on";}    #
if ($quest[0] eq chap) {$c_check = "on";}
if ($quest[0] eq proc) {$p_check = "on";}
@quest = split (/=/, $NameValuePairs[9]);
if ($quest[0] eq books) {$b_check = "on";}
if ($quest[0] eq chap) {$c_check = "on";}
if ($quest[0] eq proc) {$p_check = "on";}
open (RESULT, ">$resfile")||
      die("Cannot open results file, $! \n");
open (LOGS, ">>$logfile")||
      die("Cannot open log file, $! \n");
print LOGS scalar localtime,"\n";
print LOGS "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \" ";
if ($alt_search == 1 ) {print LOGS "$coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \"\n";}
print LOGS "Time covered: $start to $end. Type of search: \" $search_type \"\n";
$bfound = 0;
$cfound = 0;
$pfound = 0;
$sno = 0;
if ( ($key eq "") || ($key !~ /\w+/i) ) {goto NOKEY;}
if (($b_check eq "on") && ($search_type eq "omit") && ($alt_search == 0) ) {&booksearch;}
if (($b_check eq "on") && ($search_type eq "omit") && ($alt_search == 1) ) {&booksearch_alt;}
if (($b_check eq "on") && ($search_type eq "no_omit") && ($alt_search == 0)) {&booksearchn_o;}
if (($b_check eq "on") && ($search_type eq "no_omit") && ($alt_search == 1)) {&booksearchn_o_alt;}
if (($c_check eq "on") && ($search_type eq "omit") && ($alt_search == 0)) {&chapsearch;}
if (($c_check eq "on") && ($search_type eq "omit") && ($alt_search == 1)) {&chapsearch_alt;}
if (($c_check eq "on") && ($search_type eq "no_omit") && ($alt_search == 0)) {&chapsearchn_o;}
if (($c_check eq "on") && ($search_type eq "no_omit") && ($alt_search == 1)) {&chapsearchn_o_alt;}
if (($p_check eq "on") && ($search_type eq "omit") && ($alt_search == 0)) {&procsearch;}
if (($p_check eq "on") && ($search_type eq "omit") && ($alt_search == 1)) {&procsearch_alt;}
if (($p_check eq "on") && ($search_type eq "no_omit") && ($alt_search == 0)) {&procsearchn_o;}
if (($p_check eq "on") && ($search_type eq "no_omit") && ($alt_search == 1)) {&procsearchn_o_alt;}
NOKEY:
close RESULT;
open (RESULT, "$resfile")||
      die("Cannot open results file, $! \n");
#
#   print out results into an html file with ESTIR heading and footing
#
#
print "Content-type: text/html", "\n\n";
print  "<html>\n";
print  "<head>\n";
print  "<title>Electrochemical Science and Technology Information 
Resource</title>\n";
print  "</head>\n";
print  "<body>\n";
print  "<a name=\"dtop\"></a>\n";
print  "<h1><b>E</b>lectrochemical <b>S</b>cience and <b>T</b>echnology 
<b>I</b>nformation <b>R</b>esource (ESTIR)</h1>\n";
print  "<h5>(http://knowledge.electrochem.org/estir/)</h5>\n";
print  "<hr> Return to:
<a href=\"/estir/books.htm\"> Books</a> &#150; 
<a href=\"/estir/chap.htm\"> Reviews</a> &#150; 
<a href=\"/estir/proc.htm\"> Proceedings</a> &#150; 
<a href=\"/estir/\">ESTIR Home Page</a>&#150; 
<a href=\"http://www.electrochem.org/\"> ECS Home Page</a><p>\n";
print  "<h3>SEARCH RESULTS</h3><hr>\n";
print   scalar localtime," (US Eastern time).<br>\n";
print "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \" \n";
if ($alt_search == 1 ) {print  "$coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \". Time covered: $start to $end. <br>\n";}
if ($alt_search == 0 ) {print  ". Time covered: $start to $end. <br>\n";}
if ($search_type eq "no_omit") {print "Exact search. (No \"wildcards\" as leading or trailing characters.)<br>\n";}
if ($b_check eq "on")
 {
   print "Number of books found: $bfound.<br>\n";
   print LOGS "bfound = $bfound.\n";
 }
if ($c_check eq "on") 
 {
   print "Number of reviews found: $cfound.<br>\n";
   print LOGS "cfound = $cfound.\n";
 }
if ($p_check eq "on") 
 {
   print "Number of proceedings found: $pfound.<br>\n";
   print LOGS "pfound = $pfound.\n";
 }
while (!eof(RESULT))
{
  $line = <RESULT>;
  print  "$line";
}
print "<hr> Return to: <a href=\"#dtop\"> Top</a> &#150; 
<a href=\"/estir/books.htm\"> Books</a> &#150; 
<a href=\"/estir/chap.htm\"> Reviews</a> &#150; 
<a href=\"/estir/proc.htm\"> Proceedings</a> &#150; 
<a href=\"/estir/\"> ESTIR Home Page</a> &#150; 
<a href=\"http://www.electrochem.org/\"> ECS Home Page</a><p>\n";
&search_foot;

print "</body></html>\n";
close RESULT;
close LOGS;
#
#   end of search.pl
#
sub booksearch
{
#
#    booksearch
#
#    a search program, with search for one, or a string of up to four, keywords
#    time period selectable
#    leading and trailing characters of search term can be omitted
#
#    good for BOOKS.htm 
#    zn. 7-26-98. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/books.new";
#$filen="/home/httpd/html/estir/books.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/books.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   if( ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) )
        {
          $bfound++;
          if ($bfound == 1)
             {print RESULT "<p><hr><h3>BOOKS</h3><hr><p>\n";}
          print RESULT "$record\n";
        }
   last if($record =~ /name="$stopcode">/);  #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub booksearch
#
}

sub booksearch_alt
{
#
#    booksearch_alt
#
#    a search program, with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    time period selectable
#    leading and trailing characters of search term can be omitted
#
#    good for BOOKS.htm 
#    zn. 12-27-99. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/books.new";
@$filen="/home/httpd/html/estir/books.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/books.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   $found1 = 0 ;
   $found2 = 0 ;
   if( ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found1 = 1 ;}
   if( ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
        {
          $bfound++;
          if ($bfound == 1)
             {print RESULT "<p><hr><h3>BOOKS</h3><hr><p>\n";}
          print RESULT "$record\n";
        }
   last if($record =~ /name="$stopcode">/);  #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub booksearch_alt
#
}

#
sub booksearchn_o
{
#
#    booksearchn_o
#
#    a search program, with search for one, or a string of up to four, keywords
#    time period selectable
#    exact search
#    leading and trailing characters of search term cannot be omitted
#
#    good for BOOKS.htm 
#    zn. 11-15-99. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/books.new";
#$filen="/home/httpd/html/estir/books.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/books.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   if( ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) )
        {
          $bfound++;
          if ($bfound == 1)
             {print RESULT "<p><hr><h3>BOOKS</h3><hr><p>\n";}
          print RESULT "$record\n";
        }
   last if($record =~ /name="$stopcode">/);  #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub booksearchn_o
#
}
#
sub booksearchn_o_alt
{
#
#    booksearchn_o_alt
#
#    a search program, with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    time period selectable
#    exact search
#    leading and trailing characters of search term cannot be omitted
#
#    good for BOOKS.htm 
#    zn. 12-27-99. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/books.new";
#$filen="/home/httpd/html/estir/books.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/books.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   $found1 = 0 ;
   $found2 = 0 ;
   if( ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found1 = 1 ;}
   if( ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
        {
          $bfound++;
          if ($bfound == 1)
             {print RESULT "<p><hr><h3>BOOKS</h3><hr><p>\n";}
          print RESULT "$record\n";
        }
   last if($record =~ /name="$stopcode">/);  #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub booksearchn_o_alt
#
}
sub chapsearch
{  #1
#
#    chapsearch
#
#    a search program, with search for one, or a string of up to four, keywords 
#    time period selectable
#    leading and trailing characters of search term can be omitted
#
#    good for CHAP.htm, will searh also for source identification
#    zn. 7-26-98. mod: 7-31-01.
#    zn. 8-10-01. added links to sources.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/chap.new";
#$filen="/home/httpd/html/estir/chap.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/chap.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
$sourcestart = "sourcebegin";
$sourceend = "sourcestop";
for ($i = 0; $i < 500; $i++) # locate starting point for source codes
 {
   $line = <SEARCHFILE>;
   if ($line =~ /\b$sourcestart\b/)
     {
      $startsource_pos = tell(SEARCHFILE);
      $i = 501;
     }
 }
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 { #2
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   if( ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) )
          {&sourcesearch;}
   last if($record =~ /name="$stopcode">/);            #stop at the desired end
 } #2
close SEARCHFILE;
if ($cfound > 0)
     {
      print RESULT "SOURCE CODES:<p>\n";
      @p_source_array = sort @source_array;
      print RESULT "@p_source_array\n"
     }
#
#    end of sub chapsearch
#
} #1

sub sourcesearch
{
# sourcesearch for all for chap search subs
# zn. August 10, 2001.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#    zn. 3-8-03. search for sourcecode in item as   ">AAAA   
#    rather as before:   AAAA  to avoid finding some source-like word in item
#    zn.  7-14-03. sourcecode can be 2 letters and 2 letters or numbers
#                  (form earlier 3 and 1)
#    zn.  7-15-03  changed stop at "sourceend"
#                  and allowed for error in source (if no XXXXXX)

#
      $cfound++;
          if ($cfound == 1)
             {
               print RESULT "<p><hr><h3>REVIEWS</h3><p>\n";
               print RESULT "Source codes are identified at the end of REVIEWS listing.<p><hr><p>\n";
             }
      print RESULT "$record\n";
      $saverecord = $record;                   # get the source code from item
      $record =~ s/">[A-Z][A-Z][A-Z0-9][A-Z0-9]/XXXXXX/;
           if($record =~ /XXXXXX/) # return if no valid soucecode found

   { #1
      $posit = index($record, "XXXXXX");
      $sourcecode= substr($saverecord, ($posit - 4), 10);
      $search_pos = tell(SEARCHFILE);    #  get the last position in the search
# get the definition of source code using the same search method as used above
      seek (SEARCHFILE, $startsource_pos, 0);
      $source_found = 0;
      for ($i = 0; $i < 2000; $i++)   # this is the source code search
        { #4
          $line = <SEARCHFILE>;
          $line =~ s/\n/ /;
          $source_record = $line;
#  separate records ending with <p> 
          for ($ir = 0; $ir <50 ; $ir++)
            {
              $line = <SEARCHFILE>;
              if ($line !~ /^\s*\n/)
                {
                 $line =~ s/\n/ /;
                 $source_record = $source_record.$line;
                }
              last if ($line =~ /<p>/);
            }
#   check record for sourcecode match
           if($source_record =~ /\b$sourcecode\b/)
             { #4A
#   save sourcecode in an array unless it was already saved before
              $nowrite = 0;
              foreach $testelement (@source_array)
                  {
                   if ($testelement =~ /\b$sourcecode\b/)
                      {
                         $nowrite = 1;
                         last;
                      }
                   }
               if ($nowrite == 0)
                 {
                    @source_array[$sno] = $source_record;
                    $sno++;
                 }
               $i = 2001;
               $source_found = 1;
             } #4A
#    stop at end of source codes
          last if ($source_record =~ /\b$sourceend\b/);
        } #4
      if ($source_found == 0)                          #check for source found?
          {
           @source_array[$sno] = "<a name=\"$sourcecode</a>: was not found as a source.<p>";
           $sno++;
          }
      seek (SEARCHFILE, $search_pos, 0);
  } #1
# end of sub sourcesearch
}


sub chapsearch_alt
{  #1
#
#    chapsearch_alt
#
#    a search program, with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    time period selectable
#    leading and trailing characters of search term can be omitted
#
#    good for CHAP.htm, will searh also for source identification
#    zn. 12-27-99. mod: 7-31-01.
#    zn. 8-10-01. added links to sources.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/chap.new";
#$filen="/home/httpd/html/estir/chap.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/chap.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
$sourcestart = "sourcebegin";
$sourceend = "sourcestop";
for ($i = 0; $i < 500; $i++) # locate starting point for source codes
 {
   $line = <SEARCHFILE>;
   if ($line =~ /\b$sourcestart\b/)
     {
      $startsource_pos = tell(SEARCHFILE);
      $i = 501;
     }
 }
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 { #2
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   $found1 = 0 ;
   $found2 = 0 ;
   if( ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found1 = 1 ;}
   if( ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
          {&sourcesearch;}
   last if($record =~ /name="$stopcode">/);     #stop at the desired end
 } #2
close SEARCHFILE;
if ($cfound > 0)
     {
      print RESULT "SOURCE CODES:<p>\n";
      @p_source_array = sort @source_array;
      print RESULT "@p_source_array\n"
     }
#
#    end of sub chapsearch_alt
#
} #1


sub chapsearchn_o
{  #1
#
#    chapsearchn_o
#
#    a search program, with search for one, or a string of up to four, keywords 
#    time period selectable
#    exact search
#    leading and trailing characters of search term cannot be omitted

#
#    good for CHAP.htm, will searh also for source identification
#    zn. 11-15-99. mod: 7-31-01.
#    zn. 8-10-01. added links to sources.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/chap.new";
#$filen="/home/httpd/html/estir/chap.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/chap.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
$sourcestart = "sourcebegin";
$sourceend = "sourcestop";
for ($i = 0; $i < 500; $i++) # locate starting point for source codes
 {
   $line = <SEARCHFILE>;
   if ($line =~ /\b$sourcestart\b/)
     {
      $startsource_pos = tell(SEARCHFILE);
      $i = 501;
     }
 }
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 { #2
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   if( ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) )
          {&sourcesearch;}
   last if($record =~ /name="$stopcode">/);     #stop at the desired end
 } #2
close SEARCHFILE;
if ($cfound > 0)
     {
      print RESULT "SOURCE CODES:<p>\n";
      @p_source_array = sort @source_array;
      print RESULT "@p_source_array\n"
     }
#
#    end of sub chapsearchn_o
#
} 


sub chapsearchn_o_alt
{  #1
#
#    chapsearchn_o_alt
#
#    a search program, with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    time period selectable
#    exact search
#    leading and trailing characters of search term cannot be omitted
#
#    good for CHAP.htm, will searh also for source identification
#    zn. 12-27-99. mod: 7-31-01.
#    zn. 8-10-01. added links to sources.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/chap.new";
#$filen="/home/httpd/html/estir/chap.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/chap.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
$sourcestart = "sourcebegin";
$sourceend = "sourcestop";
for ($i = 0; $i < 500; $i++) # locate starting point for source codes
 {
   $line = <SEARCHFILE>;
   if ($line =~ /\b$sourcestart\b/)
     {
      $startsource_pos = tell(SEARCHFILE);
      $i = 501;
     }

 }
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 { #2
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings
   $found1 = 0 ;
   $found2 = 0 ;
   if( ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found1 = 1 ;}
   if( ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
           {&sourcesearch;}
   last if($record =~ /name="$stopcode">/);     #stop at the desired end
 } #2
close SEARCHFILE;
if ($cfound > 0)
     {
      print RESULT "SOURCE CODES:<p>\n";
      @p_source_array = sort @source_array;
      print RESULT "@p_source_array\n"
     }
#
#    end of sub chapsearchn_o_alt
#
} 

sub procsearch
{
#
#    procsearch 
#
#    a search program, with search for one, or a string of up to four, keywords 
#    time period selectable
#    leading and trailing characters of search term can be omitted
#
#    good for PROC.htm 
#    zn. 7-26-98. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/proc.new";
#$filen="/home/httpd/html/estir/proc.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/proc.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings 
   if( ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) )
     {
       $pfound++;
          if ($pfound == 1)
             {print RESULT "<p><hr><h3>PROCEEDINGS</h3><hr><p>\n";}
       print RESULT "$record\n";
     }
   last if($record =~ /name="$stopcode">/);     #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub procsearch
#
}

sub procsearch_alt
{
#
#    procsearch_alt 
#
#    a search program, with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    time period selectable
#    leading and trailing characters of search term can be omitted
#
#    good for PROC.htm 
#    zn. 12-27-99. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/proc.new";
#$filen="/home/httpd/html/estir/proc.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/proc.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings 
   $found1 = 0 ;
   $found2 = 0 ;
   if( ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found1 = 1 ;}
   if( ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
     {
       $pfound++;
          if ($pfound == 1)
             {print RESULT "<p><hr><h3>PROCEEDINGS</h3><hr><p>\n";}
       print RESULT "$record\n";
     }
   last if($record =~ /name="$stopcode">/);     #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub procsearch_alt
#
}

sub procsearchn_o
{
#
#    procsearchn_o 
#
#    a search program, with search for one, or a string of up to four, keywords 
#    time period selectable
#    exact search
#    leading and trailing characters of search term cannot be omitted
#
#    good for PROC.htm 
#    zn. 11-15-99. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/proc.new";
#$filen="/home/httpd/html/estir/proc.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/proc.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings 
   if( ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) )
     {
       $pfound++;
          if ($pfound == 1)
             {print RESULT "<p><hr><h3>PROCEEDINGS</h3><hr><p>\n";}
       print RESULT "$record\n";
     }
   last if($record =~ /name="$stopcode">/);     #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub procsearchn_o
#
}

sub procsearchn_o_alt
{
#
#    procsearchn_o_alt 
#
#    a search program, with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    time period selectable
#    exact search
#    leading and trailing characters of search term cannot be omitted
#
#    good for PROC.htm 
#    zn. 12-27-99. mod: 7-31-01.
#    zn. 3-7-03. separate records ending with "<p>" (rather than empty line)
#                and ignore all empty lines within records.
#
#$filen="d:/zn-estir/HTM-test/proc.new";
#$filen="/home/httpd/html/estir/proc.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/proc.htm";       #  ECS CHANGE
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /name="$startcode">/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)# separate individual records ending with <p>
   {
      $line = <SEARCHFILE>;
      if ($line !~ /^\s*\n/)
        {
         $line =~ s/\n/ /;
         $record = $record.$line;
        }
      last if ($line =~ /<p>/);
   }
#   check record for keyword match, and avoid year headings 
   $found1 = 0 ;
   $found2 = 0 ;
   if( ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found1 = 1 ;}
   if( ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) &&
       ($record !~ /\bgo to:\s*<a\b/i) ) { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
     {
       $pfound++;
          if ($pfound == 1)
             {print RESULT "<p><hr><h3>PROCEEDINGS</h3><hr><p>\n";}
       print RESULT "$record\n";
     }
   last if($record =~ /name="$stopcode">/);     #stop at the desired end
 }
close SEARCHFILE;
#
#    end of sub procsearchn_o_alt
#
}

