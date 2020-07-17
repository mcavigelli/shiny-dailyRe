#!/bin/sh
parent_path=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

runRScript () {
  echo "running" $1 $2 "..."
  Rscript --vanilla --verbose $1 $2 >>messages.Rout 2>>errors.Rout
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

for i in "CHE" "AFG" "ALB" "DZA" "ASM" "AND" "AGO" "ATG" "ARG" "ARM" \
  "ABW" "AUS" "AUT" "AZE" "BHS" "BHR" "BGD" "BRB" "BLR" "BEL" \
  "BLZ" "BEN" "BMU" "BTN" "BOL" "BIH" "BWA" "BRA" "VGB" "BRN" \
  "BGR" "BFA" "BDI" "CPV" "KHM" "CMR" "CAN" "CYM" "CAF" "TCD" \
  "CHI" "CHL" "CHN" "COL" "COM" "COD" "COG" "CRI" "CIV" "HRV" \
  "CUB" "CUW" "CYP" "CZE" "DNK" "DJI" "DMA" "DOM" "ECU" "EGY" \
  "SLV" "GNQ" "ERI" "EST" "SWZ" "ETH" "FRO" "FJI" "FIN" "FRA" \
  "PYF" "GAB" "GMB" "GEO" "DEU" "GHA" "GIB" "GRC" "GRL" "GRD" \
  "GUM" "GTM" "GIN" "GNB" "GUY" "HTI" "HND" "HKG" "HUN" "ISL" \
  "IND" "IDN" "IRN" "IRQ" "IRL" "IMN" "ISR" "ITA" "JAM" "JPN" \
  "JOR" "KAZ" "KEN" "KIR" "PRK" "KOR" "XKX" "KWT" "KGZ" "LAO" \
  "LVA" "LBN" "LSO" "LBR" "LBY" "LTU" "LUX" "MAC" "MDG" "MWI" \
  "MYS" "MDV" "MLI" "MLT" "MHL" "MRT" "MUS" "MEX" "FSM" "MDA" \
  "MCO" "MNG" "MNE" "MAR" "MOZ" "MMR" "NAM" "NRU" "NPL" "NLD" \
  "NCL" "NZL" "NIC" "NER" "NGA" "MKD" "MNP" "NOR" "OMN" "PAK" \
  "PLW" "PAN" "PNG" "PRY" "PER" "PHL" "POL" "PRT" "PRI" "QAT" \
  "ROU" "RUS" "RWA" "WSM" "SMR" "STP" "SAU" "SEN" "SRB" "SYC" \
  "SLE" "SGP" "SXM" "SVK" "SVN" "SLB" "SOM" "ZAF" "SSD" "ESP" \
  "LKA" "KNA" "LCA" "MAF" "VCT" "SDN" "SUR" "SWE" "SYR" "TJK" \
  "TZA" "THA" "TLS" "TGO" "TON" "TTO" "TUN" "TUR" "TKM" "TCA" \
  "TUV" "UGA" "UKR" "ARE" "GBR" "USA" "URY" "UZB" "VUT" "VEN" \
  "VNM" "VIR" "PSE" "YEM" "ZMB" "ZWE"
do
	runRScript ReCountry.R "$i"
  if [ "$i" = "CHE" ]
  then
    runRScript makeCHPlots.R
  fi
done
