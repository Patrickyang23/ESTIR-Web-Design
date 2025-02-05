#!/usr/bin/perl 
#
#    isearch.pl        method = post
#
#    a search program 
#    with search for one, or a string of up to four, keywords 
#    a second keyword can be added with AND/OR/NOT modifiers
#    EXACT searches permitted, (no wildcards at the beginning or end of a word).
#
#    to search the file "Electrochemistry and related subjects on the Internet" 
#
#    zn. 11-23-06.
#    zn.  12-5-2012 minor changes
#    zn. 10-01-2014  ECS CHANGES  updated with the help of Anthony of ECS
#    zn.  10-04-2104    corrected    
#
#require "d:\\zn-estir\\scripts\\zn-formats.pl";
#require "/home/httpd/cgi-bin/zn-formats.pl";
require "/home/vhosts/knowledge.electrochem.org/estir/search/formats.pl";  # ECS CHANGE
#
#$resfile="d:\\zn-estir\\temp\\iresults.txt";
#$filen="d:\\zn-estir\\HTM-test\\inet.new";
#$resfile="/home/httpd/html/estir/temp/iresults.txt";
$resfile="/home/vhosts/knowledge.electrochem.org/estir/search/iresults.txt"; #ECS CHANGE
#$filen="/home/httpd/html/estir/inet.htm";
$filen="/home/vhosts/knowledge.electrochem.org/estir/inet.htm";       #  ECS CHANGE

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime(time);
$current_year = 1900 + $year;
$current_month = 1 + $mon;
$name_start = "s_";
$name_end = ".log";
$name_insert = "_";
if ($current_month < 10) {$name_insert = "_0";}
$logname = $name_start.$current_year.$name_insert.$current_month.$name_end;
$logfile="/home/httpd/html/estir/temp/$logname";
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
$startcode = "starthere";
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
open (RESULT, ">$resfile")||
      die("Cannot open results file, $! \n");
$ifound = 0;
if ( ($key eq "") || ($key !~ /\w+/i) ) {goto NOKEY;}
while (!eof(SEARCHFILE))       # locate starting point for search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /\b$startcode\b/);
 }
while (!eof(SEARCHFILE))         # this is the search
 {#1
   $line = <SEARCHFILE>;
   $line =~ s/\n/ /;
   $record = $line;
   for ($i = 0; $i < 50; $i++)     # reading in records ending with empty lines
     {
        $line = <SEARCHFILE>;
        last if ($line =~ /^\s*\n/);
        $line =~ s/\n/ /;
        $record = $record.$line;
     }
#                            selecting only records that are "list items"
#
   if ($record =~ /<li>/)
{#4
#    check record for one keyword match
#    leading and trailing characters of search term can be omitted
#
   if( ($search_type eq "omit") && ($alt_search == 0) &&
       ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) )
        {
          $ifound++;
          print RESULT "$record\n";
        }
#
#    check record for one keyword match
#    EXACT, leading and trailing characters of search term cannot be omitted
#
   if ( ($search_type eq "no_omit") && ($alt_search == 0) && 
      ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) )
       {
         $ifound++;
         print RESULT "$record\n";
       }
#
#    check record for two keyword matches, with and/or/not modifiers
#    leading and trailing characters of search term can be omitted
#
if ( ($search_type eq "omit") && ($alt_search == 1) ) 
  {#2
   $found1 = 0 ;
   $found2 = 0 ;
   if ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) 
      { $found1 = 1 ;}
   if ($record 
      =~/\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i)
      { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
      {
         $ifound++;
         print RESULT "$record\n";
      }
  }#2
#
#    check record for two keyword matches, with and/or/not modifiers
#    EXACT, leading and trailing characters of search term can be omitted
#
if ( ($search_type eq "no_omit") && ($alt_search == 1) )
  {#3
   $found1 = 0 ;
   $found2 = 0 ;
   if ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) 
      { $found1 = 1 ;}
   if ($record 
      =~ /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i)
      { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
       {
         $ifound++;
         print RESULT "$record\n";
       }
  }#3
}#4
 }#1
NOKEY:
close (SEARCHFILE);
close (RESULT);
#

#   print into logfile

open (LOGS, ">>$logfile")||
      die("Cannot open log file, $! \n");
print LOGS scalar localtime,"\n";
print LOGS "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \" ";
if ($alt_search == 1 ) {print LOGS "$coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \"\n";}
if ($search_type eq "no_omit") {print LOGS "Exact search. (No \"wildcards\" as leading or trailing characters.)\n";}
print LOGS "ifound: $ifound.\n";
close LOGS;

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
<a href=\"http://knowledge.electrochem.org/estir/search/i_form.htm\">New search</a> &#150; 
<a href=\"/estir/inet.htm\">Electrochemistry on the Internet</a> &#150; 
<a href=\"/estir/\">ESTIR Home Page</a> &#150; 
<a href=\"http://www.electrochem.org/\"> ECS Home Page</a><p>\n";
print  "<h3>Search results for \" Electrochemistry and related files on the Internet \" file</h3><hr>\n";
print   scalar localtime," (US Eastern time).<br>\n";
if ($alt_search == 0 ) { print "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \". <br>\n"; }
if ($alt_search == 1 ) {print "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \" $coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \". <br>\n";}
if ($search_type eq "no_omit") {print "Exact search. (No \"wildcards\" as leading or trailing characters.)<br>\n";}
print "Number of entries found: $ifound.\n";
print "<p><hr><p>\n";
print "<ul>\n";
open (RESULT, "$resfile")||
      die("Cannot open results file, $! \n");
while (!eof(RESULT))
{
  $line = <RESULT>;
  print  "$line";
}
print "</ul>\n";
print  "<hr>Return to: <a href=\"#dtop\"> Top</a> &#150; 
<a href=\"/estir/i_form.htm\">New search</a> &#150; 
<a href=\"/estir/\">ESTIR Home Page</a> &#150; 
<a href=\"http://www.electrochem.org/\"> ECS Home Page</a><hr>\n";

&search_foot;

print  "</body></html>\n";
close RESULT;
#
#   end of isearch.pl
#



