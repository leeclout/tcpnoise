#! /bin/bash
###TCP NOISE###
# Lee Clout 2016
# Version 4.00a

# IP/Port pair generator
# Designed to generate a list of ip addresses and ports, whilst minimising repetition within a single destination network
# For every port (1~65536) #This is currently broken andd offset by +1 # select a single host in a unique class B /16 sized network
# not sure if will bother about UDP ports 

##### TIPS N TRICKS #####
# 3 things get pushed to screen, an echo of the IP address $host and Port $port
# a reverse IP lookup using the program host with the variable $host ...turn this off/comment it out to speed things up
# a Netcat command with options Verbose, Numerical (don't resolve numbers), Zero I/O mode, and wait 2 seconds to timeout
# netcat uses the $host and $port variable, you could replace the port variable with 80 or something to only scan random hosts and always use same port, examples included


# Version 3.00 added seed memory, haven't implemented input validation yet
# Version 3.01 added changelog
# Version 3.02 added logfile by tee'ing output from function call "itoa" -a to append
# Version 3.03 added tips'n'tricks, fixed bug with writing of new seed, added search function to display any open ports found repeatedly, thinking about name change ?tcpnoise?
# Version 4.00 interfacing with webserver and potentially twitter via piping nc output to new function, said function also parses results so they can be selectively acted upon.
# need to fix match problem with /8 network jumps trialling new division points, having only 240(239) options in octet A makes the rollover ugly.
# the worst thing is 240 is a byte minus 5 LEAST! significant bits, so ya can't just draw a line in the bits.  maybe I should be adding LSB and subtracting MSB??
# mkdir? is it nessecary can we check before making

#####################################################################################################


mkdir tcpnoise

#####################################################################################################


seedfile=tcpnoise.seed
if [ -f $seedfile ];
then
	echo "reading $seedfile for start seed"
else
	echo "Cannot locate counter.seed will create random seed" 
	x=$(($(($RANDOM%239))*1099511627776))
	x=$[$x+65536]
	echo "$x" > tcpnoise.seed
fi

read x < tcpnoise.seed
echo "Random Start Seed is $x"

#####################################################################################################

function crcgen
{
sum=0
for hd in $(grep -o . <<< $@); do
        sum=$((0x$sum + 0x$hd))
done
chksum=$(printf "%01X" $( expr $sum % 16 ))
}


#####################################################################################################

function dostuff
{
curl http://subethernet.net/tcpnoise/add.php?packet=$hexpack$chksum
}


#####################################################################################################



function parsenc
{
if [[ $@ == *"timed out:"* ]]; then
		resultcode=1
		hexpack=$(printf "%08X%02X%02X%02X%02X%04X%01X\n" $(date +%s) ${host//./ } $port $resultcode)
		crcgen "$hexpack"
		printf "%-10s %-15s %-5s %-2s %-20s %22s\n" $(date +%s) $host $port $resultcode "(timed out)" $hexpack$chksum
#		dostuff
        elif [[ $@ == *"Connection refused"* ]]; then
                resultcode=2
		hexpack=$(printf "%08X%02X%02X%02X%02X%04X%01X\n" $(date +%s) ${host//./ } $port $resultcode)
		crcgen "$hexpack"
		printf "%-10s %-15s %-5s %-2s %-20s %22s\n" $(date +%s) $host $port $resultcode "(Connection Refused)" $hexpack$chksum
		dostuff
        elif [[ $@ == *"Network is unreachable"* ]]; then
                resultcode=4
		hexpack=$(printf "%08X%02X%02X%02X%02X%04X%01X\n" $(date +%s) ${host//./ } $port $resultcode)
		crcgen "$hexpack"
		printf "%-10s %-15s %-5s %-2s %-20s %22s\n" $(date +%s) $host $port $resultcode "(Network Unreachable)" $hexpack$chksum
		dostuff
        elif [[ $1 == *"No route to host"* ]]; then
                resultcode=8
		hexpack=$(printf "%08X%02X%02X%02X%02X%04X%01X\n" $(date +%s) ${host//./ } $port $resultcode)
		crcgen "$hexpack"
		printf "%-10s %-15s %-5s %-2s %-20s %22s\n" $(date +%s) $host $port $resultcode "(No Route to Host)" $hexpack$chksum
		dostuff
        elif [[ $@ == *"succeeded!" ]]; then
                resultcode=15
		hexpack=$(printf "%08X%02X%02X%02X%02X%04X%01X\n" $(date +%s) ${host//./ } $port $resultcode)
		crcgen "$hexpack"
		printf "%-10s %-15s %-5s %-2s %-20s %22s\n" $(date +%s) $host $port $resultcode "(Successful)" $hexpack$chksum
		dostuff

        fi
}

#####################################################################################################

# this function is called from loop with the x variable (a 6 byte number represented in decimal)
# it uses host to do a reverse IP lookup (beware of potential misuse due to so many lookups)
#  then uses netcat (nc) to attempt a TCP handshake
function itoa
{
#returns the dotted-decimal ascii form of an IP arg passed in integer format
host=$(($(($(($(($(($((${1}/256))/256))/256))/256))/256))%256)).$(($(($(($(($((${1}/256))/256))/256))/256))%256)).$(($(($(($((${1}/256))/256))/256))%256)).$(($(($((${1}/256))/256))%256))" "
port=$[$((${1}%65536))+1] 

# return to stout a newline and echo the reult of above calculations
#echo ;echo $host $port 2>&1

# run the host command to do a reverse lookup on IP
# host $host 2>&1 | tee -a tcpnoise/$host.log

# run the nc command
result=$((nc -vnzw2 $host $port ) 2>&1 )
parsenc "$result"
# Uncomment below to bypass sequential ports
#nc -vnzw1 $host 80 2>&1 | tee -a tcpnoise/$host
#nc -vnzw1 $host 23 2>&1 | tee -a tcpnoise/$host
#nc -vnzw1 $host 22 2>&1 | tee -a tcpnoise/$host
#nc -vnzw1 $host 7001 2>&1 | tee -a tcpnoise/$host
echo "$x" > tcpnoise.seed
}



#####################################################################################################




## lets go.... the while loop goes infinite, it's true 0 is always less than 1

while [ "0" -lt "1" ]
do
# test if under 239.255.255.255:65536 11011111 11111111 11111111 11111111 11111111 11111111
#if [ "$x" -lt "263882790666239" ]
if [ "$x" -lt "246290604621823" ]
	then 
		itoa "$x"
		# this will keep found connections at bottom of screen use open$ for pi and succeeded!$ for ubuntu
#		echo ; echo ; grep succeeded!$ tcpnoise/*
		# add one bits @ position 40,35,31,1      00000000 10000100 01000000 00000000 00000000 00000001
		x=$[$x+1136018849793]

		#testing above comment out below
		# add one bit to second octet and one LSB 00000000 00000001 00000000 00000000 00000000 00000001
		#x=$[$x+4294967297]
		# add one bit to first octet 00000001 00000000 00000000 00000000 00000000 00000000
		#x=$[$x+1099511627776]
#		sleep 0.5
	else
		# minus 11110000 00000000 00000000 00000000 00000000 00000000
		#x=$[$x-263882790666240]
		x=$[$x-246290604621824]
                # add one bit to first octet 00000001 00000000 00000000 00000000 00000000 00000000
		# this is to skip 0.0.0.0 network
                x=$[$x+1099511627776]
fi
done

#####################################################################################################


exit(0)
