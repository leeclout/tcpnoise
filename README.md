# tcpnoise
upstream metadata retention log inflation engine

Lee Clout 2016
Licensed under GNU GENERAL PUBLIC LICENSE Version 3

Designed to make pseudo-random, meaningful connections to all hosts on the internet.
Randomisation has been added to avoid multiple connections to the same network.
A meaningful connection is understood as a TCP 3 way handshake.

Still very much under development.

Current build is doing 5 connections per host, but these can be easily commented out, back to the random single port per host model.

Also it's logging connection info to an indivdual host file, so it makes a bunch of file in a child folder

Happy for anyone's input
