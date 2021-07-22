#!/bin/bash
## Wrap Macports command (any executables installed by Macports).

if [[ -z $MACPORTS_PREFIX ]]; then
  MACPORTS_PREFIX='/opt/local'
fi

export PATH="$MACPORTS_PREFIX/bin:$MACPORTS_PREFIX/sbin:$PATH"
export CPATH="$MACPORTS_PREFIX/include:$CPATH"

if [ $1 == 's' ]
then
	mem=2048
	cores=1
elif [ $1 == 'm' ]
then
	mem=4096
	cores=2
elif [ $1 == 'l' ]
then
	mem=8192
	cores=4
fi

errorout=">/dev/null"

if [ $# -eq 3 ]
then
  file2="-drive file=$3,media=disk"
  if [ $3 == '-d' ]
  then
	  errorout="d"
		file2=""
  fi
  if [ $3 == '-n' ]
  then
	  errorout="n"
		file2=""
  fi
	if [ $3 == '-3' ]
	then
		errorout="3"
		file2=""
	fi
fi

if [ $# -eq 4 ]
then
  if [ $4 == '-d' ]
  then
	  errorout="d"
	fi
fi

if [ $# -eq 4 ]
then
	if [ $4 == '-n' ]
	then
		errorout="n"
	fi
fi

if [ $# -eq 4 ]
then
	if [ $4 == '-3' ]
	then
    file2="-hdc $3"
		errorout="3"
	fi
fi

# generate a random mac address for the qemu nic
hexchars="0123456789ABCDEF"
end=$( for i in {1..4} ; do echo -n ${hexchars:$(( $RANDOM % 16 )):1} ; done | sed -e 's/\(..\)/:\1/g' )

if [ $errorout == 'n' ]
then
	sudo ifconfig bridge5 create
  sudo ifconfig en0 down
  sudo ifconfig en0 inet delete
  sudo ifconfig bridge5 addm en0 addm tap1
  sudo ifconfig bridge5 up
  sudo ifconfig en0 up
	sudo qemu-system-x86_64 -m $mem -machine accel=hvf -smp $cores,cores=$cores,threads=1,sockets=1 -device e1000,netdev=net0,mac=DE:AD:BE:EF$end -netdev tap,id=net0,script=tapbridge5-up -drive file=$2,index=0,media=disk $file2 -vga std
elif [ $errorout == 'd' ]
then
  sudo qemu-system-x86_64 -m $mem -machine accel=hvf -smp $cores,cores=$cores,threads=1,sockets=1 -net nic,model=virtio,macaddr=DE:AD:BE:EF$end -net tap,script=tap-up -drive file=$2,index=0,media=disk $file2 -vga std 
elif [ $errorout == '3' ]
then
  sudo qemu-system-i386 -hda $2 $file2 -boot a -m $mem -vga cirrus -net nic,model=rtl8139,macaddr=DE:AD:BE:EF$end -net tap,script=tap-up -usbdevice tablet 
else
	(sudo qemu-system-x86_64 -m $mem -machine accel=hvf -smp $cores,cores=$cores,threads=1,sockets=1 -net nic,model=virtio,macaddr=DE:AD:BE:EF$end -net tap,script=tap-up -drive file=$2,index=0,media=disk $file2 -vga std &>/dev/null) &
fi
