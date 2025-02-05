
aa-readme-grads-index.txt                                 October 21, 2014.

Notes/information for someone who may want to continue to edit ESTIR.



This subdirectory "/estir/grads index files" contains files
needed to create three-column tables for many country indices in "grads.htm".
For ten or less entries: a single column index is created manually in grads.

The index for countries having more than ten listings is converted.

For more than 10 entries the table is created with a perl script. I copy all the
countryname-list.txt files and countryname-table.txt files here for safekeeping.

Files:

nocr.pl       perl program to remove "carriage returns" from files copied
                   from some other computer to the UNIX system.

indext3g.pl   perl program to create the table
 if this needs to be changed copy over indext3g.txt then convert:
   "perl nocr.pl indext3g.txt > indext3g.pl"



many   ...countryname-list.txt and countryname-table.txt files
                  these contain all the names with links
                  from a single column index in ALPHABETICAL order.
                  In a format: e.g., <a href="#fran4"> Claude P. Andrieux</a>
          these are copied from my PC and contain "carriage returns".
          The last number (e.g., fran4) is shown in the last line at the end
             of these files, and also at the end of each country’s index
             in the "grads" file as a comment line.

Convert list to table as follows:
(If I have problems with perl at my home PC I do the conversions here)


1. Remove all "carriage returns" from the file, e.g.:
   "perl nocr.pl canada-list-pc.txt > canada-list.txt"

2. Create the table, e.g.:
   "perl indext3g.pl canada"

3. Copy the table to my PC and into "grads.htm" replacing the previous table.
       e.g.: "canada-table.txt"


