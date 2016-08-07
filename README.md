# tcpnoise
upstream metadata retention log inflation engine

Lee Clout 2016
Licensed under GNU GENERAL PUBLIC LICENSE Version 3

Designed to make pseudo-random, meaningful connections to all hosts on the internet.
Randomisation has been added to avoid multiple connections to the same network. A meaningful connection is understood as a TCP 3 way handshake.

In light of data retention laws passed in Australia forcing telecommunications providers to log a very ambiguously described "metadata" in association with your internet service; they describe it as capturing the outside of the envelope but not seeing inside. Though as you can imagine if you receive a lot of mail from the aids clinic then one can paint a pretty plain picture.

So as more or less a joke, not to mention a chance to play with some big numbers, I wrote this to randomly attempt TCP connections across the IPv4 internet, using netcat, it just sends an empty TCP SYN packet, followed by a ACK on successful, nothing special, hopefully not viewed as intrusive either.  All this means my data retention logs are going to be filled with so much noise and crap, though to be honest it probably doesn't even hide your meaningful traffic as it would present such a different pattern to say visiting google, but hey it's got some fun applications for research and easily built to be slow and noiseless to the remote end.

It works by breaking down the range of IP addresses (4 bytes) and the range of ports (2 bytes) and quite simply using some creatively arranged counters to avoid similar Autonomous Systems (or people who own huge amounts of addresses).  By cycling through these numbers it happily just goes along creating noise, using negligible bandwidth.

A dear friend Mr Rugge, highlighted the fun when using etherape with increased timings when running this script.

Still very much under development. Enjoy.

Current build is attempting 5 connections per host, but these can be easily commented out, back to the random single port per host model.

The script logs connection into an individual host file, a text document named by the IP address, stored in a subdirectory of the script named tcpnoise/*
This method creates a lot of files within that folder, though I found it a better solution than piping everything to a single file and using logrotate or similar.  For example if you use the random port only and leave the program running long enough you will eventually hit the same machine on a different port, this subsequent hit will be appended to the same host file and help create a better profile.  I find it great when using grep against the folder to search for open or refused ports.


Happy for anyone's input
