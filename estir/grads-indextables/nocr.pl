#!c:/perl  
#
#  nocr.pl
#  program to delete all "carriage returns" from a file to be used with UNIX
#
#  use:   perl nocr.pl filen1.txt > filen2.txt
#
#  zn 4-28-99
while(<>)
{
  tr/\015//d;
  print;
}
# end of nocr.pl
