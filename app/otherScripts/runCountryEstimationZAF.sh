#!/bin/sh
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

runRScript () {
  echo "running" $1 $2 "..."
  Rscript --vanilla --verbose $1 $2 >>messagesZAF.Rout 2>>errorsZAF.Rout
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "Script didn't run successfully (Error" $retVal ")"
  else
    echo "       " $1 $2 "done"
  fi
}

cd "$parent_path"

echo "updating covid19-additionalData ..."
cd "../../../covid19-additionalData"
git reset --hard HEAD
git pull

cd "$parent_path"
rm *.Rout
echo "updating BAG Data (polybox sync)"
# for development on local macOS machine (on Linux just install the owncloud cli tools)
# symlink your polybox folder to ../data/BAG
# i.e. ln -s 'path/to/polybox/shared/BAG COVID19 Data' 'path/to/app/data/BAG'
owncloudcmd -n -s ../data/BAG \
  https://polybox.ethz.ch/remote.php/webdav/BAG%20COVID19%20Data
echo "running R script to extract BAG data & calculate delays ..."
runRScript format_BAG_data.R

runRScript ReCountry.R "ZAF"

runRScript sumData.R