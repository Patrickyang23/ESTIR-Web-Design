#!/usr/bin/perl 
#
#    grads.pl        method = post
#
#    a search program 
#    with search for one, or a string of up to four, keywords 
#
#    good for GRADS.htm, searches only the "Research interests" section
#     can search all countries or a single country
#    zn. 2/13/01.  mod: 8/1/01.
#
#    zn. 3-9-03. problems due to empty lines appearing randomly in files.
#    program changed to end records by "  -->  " rather than
#    empty lines. And ignore all empty lines within records.
#
#    zn. 9-10-04. added printout to common logfile
#
#    zn. 12-30-08. changed max iteration number from 300 to 600 for the
#    “countries” counting, because in the USA section the 300 was too short
#    and stopped the counting prematurely.
#    zn.  12-5-2012   minor changes
#
#    zn.  10-01-2014       ECS CHANGE wthh the help of Anthony of ECS
#    zn.  10-04-2014    corrected 

#require "d:/zn-estir/scripts/zn-formats.pl";
#require "/home/httpd/cgi-bin/zn-formats.pl";
require "/home/vhosts/knowledge.electrochem.org/estir/search/formats.pl";  # ECS CHANGE
#$resfile="d:/zn-estir/temp/gresults.txt";
#$filen="d:/zn-estir/HTM-test/grads.new";
$filen="/home/vhosts/knowledge.electrochem.org/estir/grads.htm";  #  ECS CHANGE
$resfile="/home/vhosts/knowledge.electrochem.org/estir/search/gresults.txt"; #ECS CHANGE
#$resfile="/home/httpd/html/estir/temp/gresults.txt";
#$filen="/home/httpd/html/estir/grads.htm";

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime(time);
$current_year = 1900 + $year;
$current_month = 1 + $mon;
$name_start = "s_";
$name_end = ".log";
$name_insert = "_";
if ($current_month < 10) {$name_insert = "_0";}
$logname = $name_start.$current_year.$name_insert.$current_month.$name_end;
#$logfile="/home/httpd/html/estir/temp/$logname";
$logfile="/home/vhosts/knowledge.electrochem.org/estir/search/$logname";  #  ECS CHANGE
#
$searchcode = "Research interests";
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
$country = $quest[1];
$country =~ tr/+/ /;
$startcode = $country;
if ($country eq all) {$startcode = "starthere";}
open (SEARCHFILE, "$filen")||
      die("Cannot open source file, $! \n");
open (RESULT, ">$resfile")||
      die("Cannot open results file, $! \n");
$gfound = 0;
if ( ($key eq "") || ($key !~ /\w+/i) ) {goto NOKEY;}
while (!eof(SEARCHFILE))       # locate starting point for search
 {
   $line = <SEARCHFILE>;
   last if ($line =~ /\b$startcode\b/);
 }
$countries = 0;
while (!eof(SEARCHFILE))         # this is the search
 {
  for ($i = 0; $i <600; $i++)
   {
     $line = <SEARCHFILE>;
     if ($line =~ /^\s*<!--\s*last\b/)  {$countries++;} # count the countries
 # look for beginning of a listing
     last if (($line =~ /^\s*<a name/) ||
             (($country ne all) && ($countries == 2)));
   }
  $record = $line;
  for ($i = 0; $i <600; $i++)   # collect lines before the research interests
   {
     $line = <SEARCHFILE>;
     if ($line =~ /^\s*<!--\s*last\b/)  {$countries++;} # count the countries
     last if (($line =~ /^\s*$searchcode\b/) ||
              (($country ne all) && ($countries == 2)));
     $record = $record.$line;
     if ($line =~ /^\s*<a name/)   # look for the real beginning of a listing
 #   this is to jump over listing of names at the beginning of each contry
      {
        $record = $line;
      }
   }
  $line =~ s/\n/ /;
  $record_s = $line;
  for ($i = 0; $i <50; $i++)        # collect lines for search
   {
     $line = <SEARCHFILE>;
     if ($line !~ /^\s*\n/)
          {
           $line =~ s/\n/ /;
           $record_s = $record_s.$line;
          }
     last if (($line =~ /-->/) ||
               (($country ne all) && ($countries == 2)));
   }
#   check record for keyword match
#
#    search for one, or a string of up to four, keywords
#    leading and trailing characters of search term can be omitted
if ( ($search_type eq "omit") && ($alt_search == 0) && 
     ($record_s =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) )
   {
     print RESULT "$record$record_s<p><hr><p>\n";
     $gfound++;
   }
#
#    search for one, or a string of up to four, keywords
#    EXACT, leading and trailing characters of search term cannot be omitted
if ( ($search_type eq "no_omit") && ($alt_search == 0) && 
     ($record_s =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i)  )
   {
     print RESULT "$record$record_s<p><hr><p>\n";
     $gfound++;
   }
#
#    search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    leading and trailing characters of search term can be omitted
if ( ($search_type eq "omit") && ($alt_search == 1) ) 
  {
   $found1 = 0 ;
   $found2 = 0 ;
   if ($record_s =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) 
      { $found1 = 1 ;}
   if ($record_s 
      =~/\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i)
      { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
   {
     print RESULT "$record$record_s<p><hr><p>\n";
     $gfound++;
   }
  }
#
#    search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    EXACT, leading and trailing characters of search term can be omitted
if ( ($search_type eq "no_omit") && ($alt_search == 1) )
  {
   $found1 = 0 ;
   $found2 = 0 ;
   if ($record_s =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) 
      { $found1 = 1 ;}
   if ($record_s 
      =~ /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i)
      { $found2 = 1 ;}
   if( (($coupling eq "AND") && (($found1 == 1 ) && ($found2 == 1 ))) ||
       (($coupling eq "OR")  && (($found1 == 1 ) || ($found2 == 1 ))) ||
       (($coupling eq "NOT")  && (($found1 == 1 ) && ($found2 == 0 ))) )
   {
     print RESULT "$record$record_s<p><hr><p>\n";
     $gfound++;
   }
  }
#
last if (($country ne all) && ($countries == 2));
 }
NOKEY:
close (SEARCHFILE);
close (RESULT);
#
#   print into logfile
open (LOGS, ">>$logfile")||
      die("Cannot open log file, $! \n");
print LOGS scalar localtime,"\n";
print LOGS "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \" ";
if ($alt_search == 1 ) {print LOGS "$coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \". Country searched: $country.  \n";}
if ($alt_search == 0 ) {print LOGS ". Country searched: $country.\n";}
if ($search_type eq "no_omit") {print LOGS "Exact search. (No \"wildcards\" as leading or trailing characters.)\n";}
print LOGS "gfound: $gfound.\n";
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
<a href=\"/estir/search/g_form.htm\">New search</a> &#150; 
<a href=\"/estir/grads.htm\">Graduate Schools</a> 
&#150; <a href=\"/estir/\">ESTIR Home Page</a> &#150; 
<a href=\"http://www.electrochem.org/\"> ECS Home Page</a><p>\n";
print  "<h3>Search results for \"GRADUATE SCHOOLS\" file</h3><hr>\n";
print   scalar localtime," (US Eastern time).<br>\n";
print "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \" \n";
if ($alt_search == 1 ) {print  "$coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \". Country searched: $country.  <br>\n";}
if ($alt_search == 0 ) {print  ". Country searched: $country.   <br>\n";}
if ($search_type eq "no_omit") {print "Exact search. (No \"wildcards\" as leading or trailing characters.)<br>\n";}
print "Number of entries found: $gfound.\n";
print "<p><hr><p>\n";
open (RESULT, "$resfile")||
      die("Cannot open results file, $! \n");
while (!eof(RESULT))
{
  $line = <RESULT>;
  print  "$line";
}
print  "Return to: <a href=\"#dtop\"> Top</a> &#150; 
<a href=\"/estir/search/g_form.htm\"> New search</a> &#150; 
<a href=\"/estir/grads.htm\">Graduate Schools</a> 
&#150; <a href=\"/estir/\">ESTIR Home Page</a> &#150; 
<a href=\"http://www.electrochem.org/\"> ECS Home Page</a><p>\n";
&search_foot;

print  "</body></html>\n";
close RESULT;
#
#   end of grads.pl
#

