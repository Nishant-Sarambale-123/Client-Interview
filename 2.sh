there is one directory inside that number of files. direct all error of that directory to one file

#!/bin/bash
 
DIR="/tmp"
 
for file in "$DIR"/* ; do
    if [ -f $file ]; then
        grep -i "error" "$file" >> "file. Err"
    fi
done
