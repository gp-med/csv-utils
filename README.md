csv-utils
=========

ruby scripts to perform various csv operations

#### count.rb ####

counts the provided file.

    ruby count.rb source.csv

#### pick.rb ####

creates a new csv file picking the provided fields.

    ruby pick.rb source.csv target.csv email first_name phone_mobile

will ignore unmatched columns.

#### split.rb ####

splits the provided csv file into desired number of files. arguments are source
file, target file, number of files and whether to include header (1 or 0),
respectively.

    ruby split.rb source.csv target.csv 12

here the header is omitted because it includes header by default. the default
number of files is 10.

#### mail.rb ####

takes the email column from a csv and writes it to the provided filename.

    ruby mail.rb email.csv

#### fix.rb ####

performs normalizations on the csv file exported from silverpop. this is data
specific and complies with the turkish columns, could be used as a reference
for other data.

