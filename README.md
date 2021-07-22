# qemu-scripts

## Description

N.B. - very rough draft. It works but it was really for my own use and I thought I'd share for others as there are things I had working that others didn't seem to have any method to do right now (i.e. NAT over wifi on Mac).

Scripts I use to start QEmu under different configurations on my Mac. It currently supports both NAT networking over wifi (even though people say this cannot be done on a Mac, it can), and also bridged adapter. Currently configurations for x86_64 and i386 as that's all I needed so far.

## Pre-requisites

``brew install tuntap``
Install MacPorts (if you already have qemu installed on brew, remove it first!)
``sudo port install qemu``
``codesign -s - --entitlements app.entitlements --force /opt/local/bin/qemu-system-x86_64``

QEMU spice clipboard support:
https://johnsiu.com/blog/macos-qemu-spice/

### Networking configuration (for NAT network)

Networking configuration
Click Manage Virtual Interfaces... using the (...) button at the bottom
Create interface "qemu-bridge", "bridge1"
Open Sharing configuration
Tick and select Internet Sharing, tick qemu-bridge to share over the new bridged adapter

## Usage

Launch an image for x86_64 using NAT networking
``./qemustart.sh <s|m|l> <image1> -d``
note in ^ -d is currently required as there is a bug in the script without using it. The idea was that without -d it would hide the output, but just use -d for now

Launch an image for x86_64 with a secondary image mapped as a second drive using NAT networking
``./qemustart.sh <s|m|l> <image1> <image2> -d``

Launch an i386 machine
As above but using ``-3`` instead of ``-d``

Bridged adapter - use this only if you want the VM to be launched directly on your networking - useful if you are wanting to work within your networks subnet
``./qemustart.sh <s|m|l> <image1> [<image2>] -n``

s = small image 2GB RAM, 1 core
m = medium image 4GB RAM, 2 cores
l = large image 8GB RAM, 4 cores
