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

## Authors

* **Knightmare** - *Initial structure* - [Knightmare](https://github.com/knightmare2600)
* **mrb3n**      - *Took over and expanded upon*

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Inspired by  **clr2of8's** great work on [DPAT](https://github.com/clr2of8/DPAT)


