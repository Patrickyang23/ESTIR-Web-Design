#!/usr/bin/perl 
#
#   edsearch.pl
#
#   driver to search ESTIR and DICT, and return link to files
#   method post
#
#   zn.   2/12/01.  mod: 8/1/01,  March 3, 2003.  
#   zn. 3-12-03. problems due to empty lines appearing randomly in files.
#                all subs changed to ignore all empty lines within records.
#   zn. 9-10-04. added printout to common logfile
#   zn. 6-14-2009, changed  “/ed/encycl” to “/encycl”
#   zn. 8-27-2009 changed “encycl/index-search.html” to 
#                          “encycl/index.html\#search”
#    zn. 12-3-2012      top(nospace),  etc
#
#    zn. 10-08-2014  ECS CHANGES  updated with the help of Anthony of ECS

#require "d:/zn-estir/scripts/zn-formats.pl";
require "/home/vhosts/knowledge.electrochem.org/estir/search/formats.pl"; #ECS CHANGE

($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime(time);
$current_year = 1900 + $year;
$current_month = 1 + $mon;
$name_start = "s_";
$name_end = ".log";
$name_insert = "_";
if ($current_month < 10) {$name_insert = "_0";}
$logname = $name_start.$current_year.$name_insert.$current_month.$name_end;
$logfile="/home/vhosts/knowledge.electrochem.org/estir/search/$logname";

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
$ffound = 0;
if ( ($key eq "") || ($key !~ /\w+/i) ) {goto NOKEY;}
@quest = split (/=/, $NameValuePairs[2]);
$coupling = $quest[1];
@quest = split (/=/, $NameValuePairs[3]);
$key_alt = $quest[1];
$key_alt =~ tr/+/ /;
$key_alt =~ s/%([\dA-Fa-f][\dA-Fa-f])/ pack ("C", hex ($1))/eg;
@keys_alt = [NULL,NULL,NULL,NULL];
@keys_alt = split(" ",$key_alt);
$alt_search =0 ;
if ($key_alt ne "") {$alt_search = 1;}
if ($key_alt !~ /\w+/i) {$alt_search = 0;}
#$listfile="d:/zn-estir/HTM-test/filelist.txt";
$listfile="/home/vhosts/knowledge.electrochem.org/estir/search/filelist.txt";
open (FLIST, "$listfile")||
      die("Cannot open list file, $! \n");
$il = 0;
while (!eof(FLIST))
 {
  $line = <FLIST>;
  $line =~ s/\n/ /;
  $filenames[$il] = $line;
  $il++;
 }
close FLIST;
$numberoffiles = @filenames;
for ($i = 0; $i <= ($numberoffiles - 1); $i++)
   {
     $filen = @filenames[$i];
     $foundkey = 0;
     if ( ($search_type eq "omit") && ($alt_search == 0) ) {&filesearch;}
     if ( ($search_type eq "no_omit") && ($alt_search == 0) ) {&filesearchn_o;}
     if ( ($search_type eq "omit") && ($alt_search == 1) ) {&filesearch_alt;}
     if ( ($search_type eq "no_omit") && ($alt_search == 1) ) 
           {&filesearchn_o_alt;}
     if ($foundkey == 1 )
       {
        $linkfile[$ffound] = $filen;
        $filetitle[$ffound] = $ftitle;
        $ffound++;
        }
   }
NOKEY:
#
#   print into logfile

open (LOGS, ">>$logfile")||
      die("Cannot open log file, $! \n");
print LOGS scalar localtime."\n";
print LOGS "Search term used: \" $keys[0] $keys[1] $keys[2] $keys[3] \" ";
if ($alt_search == 1 ) {print LOGS "$coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \"\n";}
if ($search_type eq "no_omit") {print LOGS "Exact search. (No \"wildcards\" as leading or trailing characters.)\n";}
print LOGS "ffound: $ffound.\n";
close LOGS;

#   print out results into an html file with ESTIR heading and footing
#
#
print "Content-type: text/html", "\n\n";
print "<html>\n";
print "<head>\n";
print "<title>Electrochemistry Encyclopedia</title>\n";
print "</head>\n";
print "<body>\n";
print "<div align =\"center\"><a name=\"top\"></a><a href=\"http://knowledge.electrochem.org/estir/\"><img src=\"/images/banner_estir.jpg\" width=\"980\" height=\"107\" border=\"0\"></a></div>\n";
print  "<h3>SEARCH RESULTS</h3><hr>\n";
print   scalar localtime," (US Eastern time).<p>\n";

if ($search_type eq "no_omit") {print "Exact search. (No \"wildcards\" as leading or trailing characters.)<br>\n";}

if ( ($ffound == 0) && ($alt_search == 0 ) )
{print  "Sorry, no files were found that contain the search term: \" $keys[0] $keys[1] $keys[2] $keys[3] \".<p>\n";}

if ( ($ffound == 0) && ($alt_search == 1 ) )
{print  "Sorry, no files were found that contain the search terms: \" $keys[0] $keys[1] $keys[2] $keys[3] \" $coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \".<p>\n";}

if ( ($ffound == 1) && ($alt_search == 0 ) )
{
print  "Only the following one file was found that contains the search term: \" $keys[0] $keys[1] $keys[2] $keys[3] \".<p>\n";
print "<a href=\"http://knowledge.electrochem.org/$linkfile[0] \">
         $filetitle[0] </a><p>\n";

print "You can search the individual files. The large files (Review chapters, Books, Proceedings volumes, and Graduate schools) have a built-in search capability that you can reach through the files or through <a href=\"http://knowledge.electrochem.org/estir/\">ESTIR Home Page</a>. You can search the smaller files with the EDIT/FIND feature of your browser.<p>\n";
}

if ( ($ffound == 1) && ($alt_search == 1 ) )
{
print  "Only the following one file was found that contains the search terms: \" $keys[0] $keys[1] $keys[2] $keys[3] \" $coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \".<p>\n";
print "<a href=\"http://knowledge.electrochem.org/$linkfile[0] \">
         $filetitle[0] </a><p>\n";

print "You can search the individual files. The large files (Review chapters, Books, Proceedings volumes, and Graduate schools) have a built-in search capability that you can reach through the files or through <a href=\"http://knowledge.electrochem.org/estir/\">ESTIR Home Page</a>. You can search the smaller files with the EDIT/FIND feature of your browser.<p>\n";
}

if ( ($ffound > 1) && ($alt_search == 0 ) )
{
print  "The following $ffound files were found that contain the search term: \" $keys[0] $keys[1] $keys[2] $keys[3] \".<p>\n";
print "You can search the individual files. The large files (Review chapters, Books, Proceedings volumes, and Graduate schools) have a built-in search capability that you can reach through the files or through <a href=\"http://knowledge.electrochem.org/estir/\">ESTIR Home Page</a>. You can search the smaller files with the EDIT/FIND feature of your browser.<p>\n";

for ($i = 0; $i <= ($ffound - 1); $i++)
 {print "<a href=\"http://knowledge.electrochem.org/$linkfile[$i] \">
         $filetitle[$i] </a> <p>\n";}
}

if ( ($ffound > 1) && ($alt_search == 1 ) )
{
print  "The following $ffound files were found that contain the search terms: \" $keys[0] $keys[1] $keys[2] $keys[3] \" $coupling \" $keys_alt[0] $keys_alt[1] $keys_alt[2] $keys_alt[3] \".<p>\n";
print "You can search the individual files. The large files (Review chapters, Books, Proceedings volumes, and Graduate schools) have a built-in search capability that you can reach through the files or through <a href=\"http://knowledge.electrochem.org/estir/\">ESTIR Home Page</a>. You can search the smaller files with the EDIT/FIND feature of your browser.<p>\n";

for ($i = 0; $i <= ($ffound - 1); $i++)
 {print "<a href=\"http://knowledge.electrochem.org/$linkfile[$i] \">
         $filetitle[$i] </a> <p>\n";}
}

print  "<p>This search did not cover articles in the \"Encylopedia\".<br>
You can 
<a href=\"http://knowledge.electrochem.org/encycl/index.html\#search\">search the Encyclopedia</a> separately.<p>\n";

print " <hr><span style=\"font-family: verdana; font-size: 12px;\">Return to:
<a href=\"/estir/#search\">New search</a> &#150;  
<a href=\"http://knowledge.electrochem.org/estir/\">ESTIR Home Page</a> &#150;  
<a href=\"http://www.electrochem.org/\"> ECS Home Page</a></span><hr>\n";

&search_foot;

print  "</body></html>\n";
#
#   end of site.pl
#
sub filesearch
{
#
#    filesearch
#
#    a search program for files
#    with search for one, or a string of up to four, keywords
#    assuming that the search term is in one or at most two lines
#    leading and trailing characters of search term can be omitted
#    Beginning of file is not searched
#
#    zn. 06-28-2000. mod: 8/1/01.
#    zn. 3-12-03. changed to ignore all empty lines within records
#
#$filename="d:/zn-estir/HTM-test/$filen";
$filename="/home/vhosts/knowledge.electrochem.org/$filen";
open (SEARCHFILE, "$filename")||
      die("Cannot open $filen file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
  {
   $line = <SEARCHFILE>;
   last if ($line =~ /xxyz/);
  }
#                                 #    extract file title
$positf = index($line, "xxyz");
$positl = index($line, "yyzx");
$posite = $positf + 5;
$slength = $positl - $posite - 1;
$ftitle = substr($line, $posite, $slength);
$record = <SEARCHFILE>;
$record =~ s/\n/ /;
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i)
     {
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
#
#    end of sub filesearch
#
}
#
sub filesearchn_o
{
#
#    filesearchn_o
#
#    a search program for files
#    with search for one, or a string of up to four, keywords
#    assuming that the search term is in one or at most two lines
#    EXACT, leading and trailing characters of search term cannot be omitted
#    Beginning of file is not searched
#
#    zn. 06-28-2000. mod: 8/1/01.
#    zn. 3-12-03. changed to ignore all empty lines within records
#
#$filename="d:/zn-estir/HTM-test/$filen";
$filename="/home/vhosts/knowledge.electrochem.org/$filen";
open (SEARCHFILE, "$filename")||
      die("Cannot open $filen file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
  {
   $line = <SEARCHFILE>;
   last if ($line =~ /xxyz/);
  }
#                                 #    extract file title
$positf = index($line, "xxyz");
$positl = index($line, "yyzx");
$posite = $positf + 5;
$slength = $positl - $posite - 1;
$ftitle = substr($line, $posite, $slength);
$record = <SEARCHFILE>;
$record =~ s/\n/ /;
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i)
     {
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
#
#    end of sub filesearchn_o
#
}
#
sub filesearch_alt
{
#
#    filesearch_alt
#
#    a search program for files
#    with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    assuming that the search term is in one or at most two lines
#    leading and trailing characters of search term can be omitted
#    Beginning of file is not searched
#
#    zn. 06-28-2000. mod: 8/1/01.
#    zn. 3-12-03. changed to ignore all empty lines within records
#
#$filename="d:/zn-estir/HTM-test/$filen";
$filename="/home/vhosts/knowledge.electrochem.org/$filen";
open (SEARCHFILE, "$filename")||
      die("Cannot open $filen file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
  {
   $line = <SEARCHFILE>;
   last if ($line =~ /xxyz/);
  }
#                                 #    extract file title
$positf = index($line, "xxyz");
$positl = index($line, "yyzx");
$posite = $positf + 5;
$slength = $positl - $posite - 1;
$ftitle = substr($line, $posite, $slength);
$record = <SEARCHFILE>;
$record =~ s/\n/ /;
$found1 = 0 ;
$found2 = 0 ;
if ($coupling eq "AND") {goto ANDCASE;}
if ($coupling eq "NOT") {goto NOTCASE;}
#
# ORCASE
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) 
          { $found1 = 1 ;}
   if ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) 
          { $found2 = 1 ;}
   if( ($found1 == 1 ) || ($found2 == 1 ) )
     {
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
return;
#   end orcase
#
ANDCASE:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) 
          { $found1 = 1 ;}
   if ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) 
          { $found2 = 1 ;}
   if( ($found1 == 1 ) && ($found2 == 1 ) )
     {
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
   if ( ($found1 == 1 ) && ($found2 == 0 )) {goto FOUNDONE;}
   if ( ($found1 == 0 ) && ($found2 == 1 )) {goto FOUNDTWO;}
  }
close SEARCHFILE;
return;
#
FOUNDONE:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) 
     {
       $found2 = 1 ;
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
return;
#  end  foundone
#
FOUNDTWO:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) 
     {
       $found1 = 1 ;
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
$record = $line;
  }
close SEARCHFILE;
return;
#  end  foundtwo
#  end andcase
#
NOTCASE:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) 
          {
            $found2 = 1 ;
            close SEARCHFILE;
            return;
          }
   if ($record =~ /\b\w*$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\w*\b/i) 
          {
            $found1 = 1 ;
            $record = $line;
            goto FOUNDONEA;
          }
   $record = $line;
  }
close SEARCHFILE;
if( ($found1 == 1 ) && ($found2 == 0 ) ) { $foundkey = 1; }
return;
#
FOUNDONEA:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ 
    /\b\w*$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\w*\b/i) 
     { 
       $found2 = 1; 
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
if( ($found1 == 1 ) && ($found2 == 0 ) ) { $foundkey = 1; }
return;
#  end fondonea
#  end notcase
#
#    end of sub filesearch_alt
#
}
sub filesearchn_o_alt
#
{
#    filesearchn_o_alt

#
#    a search program for files
#    with search for one, or a string of up to four, keywords
#    and/or/not second, similar search term
#    assuming that the search term is in one or at most two lines
#    leading and trailing characters of search term can be omitted
#    Beginning of file is not searched
#
#    zn. 06-28-2000. mod: 8/1/01.
#    zn. 3-12-03. changed to ignore all empty lines within records
#
#$filename="d:/zn-estir/HTM-test/$filen";
$filename="/home/vhosts/knowledge.electrochem.org/$filen";
open (SEARCHFILE, "$filename")||
      die("Cannot open $filen file, $! \n");
while (!eof(SEARCHFILE))         # find the beginning of search
  {
   $line = <SEARCHFILE>;
   last if ($line =~ /xxyz/);
  }
#                                 #    extract file title
$positf = index($line, "xxyz");
$positl = index($line, "yyzx");
$posite = $positf + 5;
$slength = $positl - $posite - 1;
$ftitle = substr($line, $posite, $slength);
$record = <SEARCHFILE>;
$record =~ s/\n/ /;
$found1 = 0 ;
$found2 = 0 ;
if ($coupling eq "AND") {goto ANDCASEA;}
if ($coupling eq "NOT") {goto NOTCASEA;}
#
# ORCASEA
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) 
          { $found1 = 1 ;}
   if ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) 
          { $found2 = 1 ;}
   if( ($found1 == 1 ) || ($found2 == 1 ) )
     {
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
return;
#  end orcasea
#
ANDCASEA:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) 
          { $found1 = 1 ;}
   if ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) 
          { $found2 = 1 ;}
   if( ($found1 == 1 ) && ($found2 == 1 ) )
     {
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
   if ( ($found1 == 1 ) && ($found2 == 0 )) {goto FOUNDONEB;}
   if ( ($found1 == 0 ) && ($found2 == 1 )) {goto FOUNDTWOB;}
  }
close SEARCHFILE;
return;
#
FOUNDONEB:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) 
     {
       $found2 = 1;
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
return;
#  end foundoneb
#
FOUNDTWOB:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) 
     {
       $found1 = 1 ;
       $foundkey = 1;
       close SEARCHFILE;
       return;
     }
$record = $line;
  }
close SEARCHFILE;
return;
#  end  foundtwob
#  end  andcasea
#
NOTCASEA:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) 
          {
            $found2 = 1 ;
            close SEARCHFILE;
            return;
          }
   if ($record =~ /\b$keys[0]\s*$keys[1]\s*$keys[2]\s*$keys[3]\b/i) 
          {
            $found1 = 1 ;
            $record = $line;
            goto FOUNDONEC;
          }
   $record = $line;
  }
close SEARCHFILE;
if( ($found1 == 1 ) && ($found2 == 0 ) ) { $foundkey = 1; }
return;
#
FOUNDONEC:
while (!eof(SEARCHFILE))   # search two lines at a time: ab, bc, cd, etc
#                            but ignore all empty lines
  {
   $line = <SEARCHFILE>;
   next if ($line =~ /^\s*\n/);
   $line =~ s/\n/ /;
   $record = $record.$line;
#                              check record for keyword match
   if ($record =~ 
    /\b$keys_alt[0]\s*$keys_alt[1]\s*$keys_alt[2]\s*$keys_alt[3]\b/i) 
     { 
       $found2 = 1; 
       close SEARCHFILE;
       return;
     }
   $record = $line;
  }
close SEARCHFILE;
if( ($found1 == 1 ) && ($found2 == 0 ) ) { $foundkey = 1; }
return;
#  end foundonec
#  end notcaseb
#
#
#    end of sub filesearchn_o_alt
#
}
#
