#!/bin/bash

## Script to take raw password cracking  data and perform some metrics on it
## Version 1.01 By Knightmare (C) 2018 Licensed Under GPL 3.0
## Version 1.01		Initial version with output                                       - knightmare
## Version 1.02		Percentages & Requests file input                                 - knightmare
## Version 1.03		Metrics & Cracked Percentages                                     - knightmare
## Version 1.04		Check for cracked Domain Admin LM & NTLM password hashes          - knightmare
## Version 1.05		Fixed password length metrics & modified for new cracked.txt file - mrb3n
## Version 1.06		Output which DAs and percentage of total DAs we have cracked too  - knightmare
## Version 1.07		Same as above but this time for Enterprise Admins too (optional)  - knightmare
## Version 1.08		Redid script to take command line parameters			  - mrb3n
## Version 1.09         Minor tweaks: added banner and output directory option		  - mrb3n
## Version 1.10		Fixed count totals for each password length			  - mrb3n
## Version 1.11		Fixed DA/EA group search to grep exact match on username	  - mrb3n
## Version 1.12		Added function for password length			   	  - mrb3n
## Version 1.13		Added in user command line parameters + password search	 	  - mrb3n
## Version 1.14		Changed unique NTLM/LM calculation to ignore blank hashes	  - mrb3n
## Version 1.15		Added in help menu and refined command line parameters		  - mrb3n
## Version 1.16		Started implementing error handling				  - mrb3n
## Version x.xx		TO-DO: add in HTML report output option				  - mrb3n

cat << "EOF"

  _    _           _         _        _       
 | |  | |         | |       | |      | |      
 | |__| | __ _ ___| |__  ___| |_ __ _| |_ ___ 
 |  __  |/ _` / __| '_ \/ __| __/ _` | __/ __|
 | |  | | (_| \__ \ | | \__ \ || (_| | |_\__ \
 |_|  |_|\__,_|___/_| |_|___/\__\__,_|\__|___/
                                             
EOF
echo
echo "A little utility for performing password analysis on Active Directory passwords cracked with Hashcat"

echo
print_usage() {
  echo ""
  echo "Usage: $0 -n ntds file -c cracked hashes file -g domain admins file [enterprise admin file] -d name of output directory in your current working directory"
  echo "e.g. $0 -n ntds.txt -c cracked.txt -d domain_admins.txt -d acme_corp_hashstats"
  echo
  echo "Requires NTDS file, Hashcat cracked file and listing of Domain Admins in the format acme.com\rrunner"
  echo
  echo "Generate your cracked file with this command: ./hashcat -m 1000 client.ntds --show --username > cracked.txt"
  echo "parameter [enterprise admin file] is optional"
  echo
cat << "EOF"
Command line options:
	[Required]
	 -n NTDS file		File containing all hashes dumped from the domain controller
	 -c Cracked file	File containing all cracked passwords

	[Optional]
	 -d  DA group file	PowerView output of users in Domain Admins group
	 -e  EA group file	Powerview output of users in Enterprise Admins group
	 -o  Output directory	Directory name for HTML report (creates in current working directory)
	 -s  User search	Search for a user in the cracked output (./hashstats.sh -c file -s username)
	 -r  HTML report	Generate an HTML report to drill down on various metrics
EOF
  exit 3
}

case "$1" in
  --help)
    print_usage
  ;;
  -h)
    print_usage
  ;;
esac

## Take user parameters
workingdir=`pwd`

while getopts ":n:c:d:e:o:s:" opt; do
  case $opt in
   n) ntds_file=$OPTARG ;;
   c) cracked_file=$OPTARG ;;
   d) group_file=$OPTARG ;;
   e) ea_file=$OPTARG ;;
   o) outdir=$OPTARG ;;
   s) user_search=$OPTARG 
    user_found=`grep -w "$user_search" "$cracked_file" | /usr/bin/awk -F: '{ print $1 }'`
    hash_found=`grep -w "$user_search" "$cracked_file" | /usr/bin/awk -F: '{ print $2 }'`
    password_found=`grep -w "$user_search" "$cracked_file" | /usr/bin/awk -F: '{ print $3 }'`
    echo "[+] Password found for $user_found"
    echo "[+] NTLM hash is: $hash_found"
    echo "[+] Cleartext password is: $password_found"
    exit 0
  ;;
  : ) echo "Missing argument for -$OPTARG"
      print_usage
      exit 0
  ;;
  esac
done

if [ $OPTIND -eq 1 ]; then print_usage; else


## Move onto next argument
shift $((OPTIND-1))

if [ ! -d "$workingdir/$outdir" ]; then
  mkdir -p "$outdir"

fi

## Pre flight checks, do we have the binaries we need...?
for binary in awk bc cat head sed sort wc uniq; do
location=`/usr/bin/which "$binary" > /dev/null 2>&1`
  if [ "$?" -eq 1 ]; then
      echo "Error: $binary command not found in path... cannot proceed"
      echo
      exit 0
  fi
done

## TODO: this code has some enumeration issues. You need to tell bash it's an array
## TODO: which will then replace those password_length(x) lines below too
## Number of passwords ordered by length (how many 6, 7, 8,9,10,11, 12 etc character passwords)
## TODO: Much better ways to do this, but this works for now...

function password_length() {

cat "$cracked_file" |/usr/bin/awk -F: '{ print $3 }'
}

password_length5=`password_length | /usr/bin/awk 'length($0) == 5' | /usr/bin/wc -l`
password_length6=`password_length | /usr/bin/awk 'length($0) == 6' | /usr/bin/wc -l`
password_length7=`password_length | /usr/bin/awk 'length($0) == 7' | /usr/bin/wc -l`
password_length8=`password_length | /usr/bin/awk 'length($0) == 8' | /usr/bin/wc -l`
password_length9=`password_length | /usr/bin/awk 'length($0) == 9' | /usr/bin/wc -l`
password_length10=`password_length | /usr/bin/awk 'length($0) == 10' | /usr/bin/wc -l`
password_length11=`password_length | /usr/bin/awk 'length($0) == 11' | /usr/bin/wc -l`
password_length12=`password_length | /usr/bin/awk 'length($0) == 12' | /usr/bin/wc -l`
password_length13=`password_length | /usr/bin/awk 'length($0) == 13' | /usr/bin/wc -l`
password_length14=`password_length | /usr/bin/awk 'length($0) == 14' | /usr/bin/wc -l`
password_length15=`password_length | /usr/bin/awk 'length($0) == 16' | /usr/bin/wc -l`
password_length16=`password_length | /usr/bin/awk 'length($0) == 16' | /usr/bin/wc -l`
password_length17=`password_length | /usr/bin/awk 'length($0) == 17' | /usr/bin/wc -l`
password_length18=`password_length | /usr/bin/awk 'length($0) == 18' | /usr/bin/wc -l`
password_length19=`password_length | /usr/bin/awk 'length($0) == 19' | /usr/bin/wc -l`
password_length20=`password_length | /usr/bin/awk 'length($0) == 20' | /usr/bin/wc -l`
password_length21=`password_length | /usr/bin/awk 'length($0) == 21' | /usr/bin/wc -l`
password_length22=`password_length | /usr/bin/awk 'length($0) == 22' | /usr/bin/wc -l`
password_length23=`password_length | /usr/bin/awk 'length($0) == 23' | /usr/bin/wc -l`
password_length24=`password_length | /usr/bin/awk 'length($0) == 24' | /usr/bin/wc -l`
password_length25=`password_length | /usr/bin/awk 'length($0) == 25' | /usr/bin/wc -l`

## Get the total password hashes and the number of unique hashes
## Total NTLM hashes (non-blanK)
total_ntlm_hashes=`/bin/cat "$ntds_file" | /usr/bin/awk -F: '{ print $4 }' | /usr/bin/sort -u | /bin/grep -v 31d6cfe0d16ae931b73c59d7e0c089c0 | /usr/bin/wc -l`
## Total LM hashes (non-blank)
total_lm_hashes=`/bin/cat "$ntds_file" | /usr/bin/awk -F: '{ print $3 }' | /usr/bin/sort -u |  /bin/grep -v aad3b435b51404eeaad3b435b51404ee | /usr/bin/wc -l`

## Total dumped password hashes
total_hashes=`/bin/cat "$ntds_file" | /usr/bin/wc -l`

## Cracked password metrics
## Total cracked overall (non-unique)
total_cracked_passwords=`/bin/cat "$cracked_file" | /usr/bin/wc -l`

## Total percentage cracked
total_cracked_percent=`echo "scale=2;($total_cracked_passwords)/($total_hashes)*100"|bc`

## Total unique cracked
total_unique_cracked=`/bin/cat "$cracked_file" | /usr/bin/awk -F:  '{ print $2 }' | /usr/bin/sort -u | /usr/bin/wc -l`

## Top 10 repeated passwords (i.e. how many instances of Password1!, Welcome1, etc)
top_ten_passwords=`/bin/cat "$cracked_file" |cut -f3 -d":" |  grep -v "^\s*$" | sort | uniq -c | sort -bnr | head -n 10`

## Number of Domain Admins & Number Cracked
## Number of users in the domain admins group file
total_da=`/bin/cat "$group_file" | /usr/bin/sort -u | /usr/bin/wc -l`

## Output the findings
echo
echo " -----====[ Domain Password Metrics ]====-----"
echo
echo " [*] Total Password Hashes: $total_hashes"
echo " [*] Total NTLM Hashes (Non-blank): $total_ntlm_hashes"
echo " [*] Total LM Hashes (Non-Blank): $total_lm_hashes"
echo " [*] Total Passwords Cracked: $total_cracked_passwords"
echo " {*] Total % of Passwords Cracked: $total_cracked_percent"
echo " [*] Total Unique Passwords Cracked: $total_unique_cracked"

## Total users in the domain admins group file cracked
let da_found=0;
let found=0;

while read -r da
  do
    domain=`echo "$da" | /usr/bin/awk -F '\\' '{ print $1 }'`
    userid=`echo "$da" | /usr/bin/awk -F '\\' '{ print $2 }'`
    found=`/bin/grep -w "$userid" "$cracked_file" | /usr/bin/wc -l`
  #  da_pass=`/bin/grep -w "userid" "$cracked_file" | /usr/bin/awk -F: '{ print $3 }'`
    if [ "$found" -eq "1" ]; then
    echo '  - Domain Admin password for' "$domain"'\'"$userid" 'was cracked'
      let "da_found=da_found+1"
    fi
  done < "$group_file"

## % of users in the domain admins group file cracked
cracked_da_percent=`echo "scale=2;($da_found)/($total_da)*100"|/usr/bin/bc`

echo " [*] Total number of Domain Admins: $total_da"
echo " [*] Total number of Domain Admin hashes Cracked: $da_found ($cracked_da_percent% DA Passwords Cracked)"

## TODO: Print this only if there was an enterprise admins file specified
if [ -f "$ea_file" ]; then
  let ea_found=0;
  let ea_found=0;
  total_ea=`/bin/cat "$ea_file" | /usr/bin/sort -u | /usr/bin/wc -l`

while read -r ea
  do
    domain=`echo "$ea" | /usr/bin/awk -F '\\' '{ print $1 }'`
    userid=`echo "$ea" | /usr/bin/awk -F '\\' '{ print $2 }'`
    found=`/bin/grep -w "$userid" "$cracked_file" | /usr/bin/wc -l`
    if [ "$found" -eq "1" ]; then
    echo '  - Enterprise Admin password for' "$domain"'\'"$userid" 'was cracked'
      let "ea_found=ea_found+1"
    fi
  done < "$ea_file"

  ## % of users in the domain admins group file cracked
  cracked_ea_percent=`echo "scale=2;($ea_found)/($total_ea)*100"|/usr/bin/bc`
  echo " [*] Total number of Enterprise Admins: $total_ea"
  echo " [*] Total number of Enterprise Admin hashes Cracked: $ea_found ($cracked_ea_percent% DA Passwords Cracked)"
fi
## Print password length info now
echo " [*] Password Metrics:"
echo "  - Total Passwords of length  5: $password_length5"
echo "  - Total Passwords of length  6: $password_length6"
echo "  - Total Passwords of length  7: $password_length7"
echo "  - Total Passwords of length  8: $password_length8"
echo "  - Total Passwords of length  9: $password_length9"
echo "  - Total Passwords of length 10: $password_length10"
echo "  - Total Passwords of length 11: $password_length11"
echo "  - Total Passwords of length 12: $password_length12"
echo "  - Total Passwords of length 13: $password_length13"
echo "  - Total Passwords of length 14: $password_length14"
echo "  - Total Passwords of length 15: $password_length15"
echo "  - Total Passwords of length 16: $password_length16"
echo "  - Total Passwords of length 17: $password_length17"
echo "  - Total Passwords of length 18: $password_length18"
echo "  - Total Passwords of length 19: $password_length19"
echo "  - Total Passwords of length 20: $password_length20"
echo "  - Total Passwords of length 21: $password_length21"
echo "  - Total Passwords of length 22: $password_length22"
echo "  - Total Passwords of length 23: $password_length23"
echo "  - Total Passwords of length 24: $password_length24"
echo "  - Total Passwords of length 25: $password_length25"

## % unique cracked
echo " [*] Top 10 Cracked Passwords with count:"
echo "$top_ten_passwords"

fi
