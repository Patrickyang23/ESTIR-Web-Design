
a-a-readme-dict-index.txt           October 21, 2014.

This directory contains files needed to create the three-column and
single-column tables for the indices in "dict.htm".

The index for letters having more than ten listings is converted into
a three-column table, for ten or less: into a single-column table.

Files:

nocr.pl       perl program to remove "carriage returns" from files copied
                   from some other computer to the UNIX system.

indext3d.pl   perl program to create the table
if this needs to be changed copy over indext3d.txt then convert:
   "perl nocr.pl indext3d.txt > indext3d.pl"


many   ...-list.txt files, these contain all the headings of entries for a given
              letter in ALPHABETICAL order as they appear in "dict.htm".
          these are copied from my PC and contain "carriage returns"

Convert list to table as follows:
(If I have problems with perl at my home PC I do the conversions here)


1. Remove all "carriage returns" from the file, e.g.:
   "perl nocr.pl a-list-pc.txt > a-list.txt"

2. Create the table, e.g.:
   "perl indext3g.pl a"

3. Copy the table to my PC and into "dict.htm" replacing the previous table.
       e.g.: "a-table.txt"

