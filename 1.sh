In directory there is 3 files. redirect error all three files to new files


#!/bin/bash

for file in file1 file2 file3; do
    if [ -f "$file" ]; then
        grep -i "error" "$file" >> "${file}.err"
    fi
done
