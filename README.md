# Hashstats

```
  _    _           _         _        _       
 | |  | |         | |       | |      | |      
 | |__| | __ _ ___| |__  ___| |_ __ _| |_ ___ 
 |  __  |/ _` / __| '_ \/ __| __/ _` | __/ __|
 | |  | | (_| \__ \ | | \__ \ || (_| | |_\__ \
 |_|  |_|\__,_|___/_| |_|___/\__\__,_|\__|___/
 ```

A little utility for performing password analysis on Active Directory passwords cracked with Hashcat.

## Requirements:

Mostly uses native Linux binaries but you may need to install the bc package for calculations if your system doesn't have it already.


### Setup:


```
sudo apt-get install bc
git clone https://github.com/neb2886/hashstats.git
```

## Basic Usage:

Get general Domain Password stays including number of Domain Admin account hashes cracked.

```
./hashstats.sh -n ntds_file -c cracked_hashes -d domain_admins_file 
```

### Examples

Standard output as well as number of Enterprise Admin account hashes cracked.

```
./hashstats.sh -n ntds_file -c cracked_hashes -d domain_admins_file -e enterprise_admins_file
```

Search for a user within the cracked output (useful during long engagements)

```
./hashstats.sh -c cracked_hashes -s username
```

## Full usage instructions

```
Usage: ./hashstats.sh -n ntds file -c cracked hashes file -g domain admins file [enterprise admin file] -d name of output directory in your current working directory
e.g. ./hashstats.sh -n ntds.txt -c cracked.txt -d domain_admins.txt -d acme_corp_hashstats

Requires NTDS file, Hashcat cracked file and listing of Domain Admins in the format acme.com\rrunner

Generate your cracked file with this command: ./hashcat -m 1000 client.ntds --show --username > cracked.txt
parameter [enterprise admin file] is optional

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
```

## Sample Output

```
# ./hashstats.sh -n samples/ntds.txt -c samples/cracked.txt -d samples/domain_admins.txt 

  _    _           _         _        _       
 | |  | |         | |       | |      | |      
 | |__| | __ _ ___| |__  ___| |_ __ _| |_ ___ 
 |  __  |/ _` / __| '_ \/ __| __/ _` | __/ __|
 | |  | | (_| \__ \ | | \__ \ || (_| | |_\__ \
 |_|  |_|\__,_|___/_| |_|___/\__\__,_|\__|___/
                                             

A little utility for performing password analysis on Active Directory passwords cracked with Hashcat


 -----====[ Domain Password Metrics ]====-----

 [*] Total Password Hashes: 16
 [*] Total NTLM Hashes (Non-blank): 13
 [*] Total LM Hashes (Non-Blank): 11
 [*] Total Passwords Cracked: 6
 {*] Total % of Passwords Cracked: 37.00
 [*] Total Unique Passwords Cracked: 6
  - Domain Admin password for acme.local\roadrunner was cracked
 [*] Total number of Domain Admins: 12
 [*] Total number of Domain Admin hashes Cracked: 1 (8.00% DA Passwords Cracked)
 [*] Password Metrics:
  - Total Passwords of length  5: 0
  - Total Passwords of length  6: 2
  - Total Passwords of length  7: 2
  - Total Passwords of length  8: 1
  - Total Passwords of length  9: 1
  - Total Passwords of length 10: 0
  - Total Passwords of length 11: 0
  - Total Passwords of length 12: 0
  - Total Passwords of length 13: 0
  - Total Passwords of length 14: 0
  - Total Passwords of length 15: 0
  - Total Passwords of length 16: 0
  - Total Passwords of length 17: 0
  - Total Passwords of length 18: 0
  - Total Passwords of length 19: 0
  - Total Passwords of length 20: 0
  - Total Passwords of length 21: 0
  - Total Passwords of length 22: 0
  - Total Passwords of length 23: 0
  - Total Passwords of length 24: 0
  - Total Passwords of length 25: 0
 [*] Top 10 Cracked Passwords with count:
      1 Password123!
      1 Welcome1!
      1 Spring2018
      1 Fall2018
      1 Password1
      1 Letmein!
```

## To do

```
-Add in HTML report option
-Fuzzy search for users
-Fix up code/error handling
-TBD
```

## Authors

* **Knightmare** - *Initial structure* - [Knightmare](https://github.com/knightmare2600)
* **mrb3n**      - *Took over and expanded upon*

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/neb2886/hashstats/blob/master/LICENSE) file for details

## Acknowledgments

* Inspired by  **clr2of8's** great work on [DPAT](https://github.com/clr2of8/DPAT)


