#!/bin/bash

# Script to update translation files
# Generates ruletemplates/messages.h and calls lupdate on the entire project
# Ideally this would eventually be called in the CI when building the packages
# However, this will break not find all translations when ran with Qt < 5.9
# so for now this is ran manually all the time and results are committed to the
# repository

OUT="nymea-app/ruletemplates/messages.h"

echo "// This file is generated. Update it using ./messages.sh in the root source directory" > $OUT
echo "#include <QString>" >> $OUT
echo "const QString translations[] {" >> $OUT


for INPUTFILE in `ls nymea-app/ruletemplates/*json`; do
  echo "Extracting strings from ruletemplate file $INPUTFILE"

  FILEBASENAME=$(basename -- "$INPUTFILE")
  FILEBASENAME="${FILEBASENAME%.*}"

  while IFS= read -r LINE
  do
    if [[ $LINE == *"\"description\""* ]] || [[ $LINE == *"\"ruleNameTemplate\""* ]]; then
      if [ $HASCONTENT -eq 1 ]; then
        echo "," >> $OUT
      fi
      TYPE=`echo $LINE | cut -d ":" -f 1 | sed 's/"//g'`
      STRING=`echo $LINE | cut -d ":" -f 2 | sed 's/,$//'`
      echo -n "QT_TRANSLATE_NOOP(" >> $OUT
      echo -n "\"$TYPE for $FILEBASENAME\", " >> $OUT
      echo -n $STRING >> $OUT
      echo -n ")" >> $OUT
      HASCONTENT=1
    fi
  done < "$INPUTFILE"

done

echo "" >> $OUT
echo "};" >> $OUT


lupdate -no-obsolete nymea-app.pro
