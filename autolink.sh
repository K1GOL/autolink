#!/bin/bash
set -e

scriptVersion="autolink v1.0.5"

echo "------"
echo $scriptVersion
echo "------"

# Extract flags from first arg.
flags=$1

# Second arg is source directory.
src=$2

# Third arg is link destination directory. (optional)
lnkdst=$3

# Fourth arg is app installation directory. (optional)
appdst=$4

# Help command
if [[ "$flags" == "--help" ]]
then
	echo ""
	echo "autolink -flags source_path [symlink destination] [file move destination.]"
	echo ""
	echo "Files from source path are moved to file move destination, and then executable files are symlinked to the symlink destination path."
	echo ""
	echo "Defaults:"
	echo "	symlink destination:	/usr/local/bin/"
	echo "	move destination:	/home/$(logname)/.autolink/"
	echo ""
	echo "Flags:"
	echo "	i: Install"
	echo "	t: Unpack tar.gz"
	echo "	c: Change owner of installation directory to $(logname), use this if using autolink as root"
	echo ""
	echo "Example:"
	echo "# autolink -ict helloworld.tar.gz /usr/local/bin /home/user123/my/cool/directory"
	echo "i flag is always required because I can't be arsed to handle a no flags case."
	exit
fi

# Check if flags include t.
if [[ $flags =~ "t" ]]
then
	# Unpack tar, then get extracted directory name and set that as the source directory.
	tarpath=$src
	echo "Extracting $tarpath"
	src=$(tar -tzf $src | head -1 | cut -f1 -d"/" )
	tar -xzf $tarpath
fi

# Check if flags include i.
if [[ ! $flags =~ "i" ]];
then
	echo "i flag not present, exiting."
	exit
fi

# Check source is set.
if [ -z $src ]
then
	# Source was not set, exit.
	echo "No source path provided."
	exit
fi

# Check symlink destination is set.
if [ -z $lnkdst ]
then
	# Destination was not set, use default.
	lnkdst="/usr/local/bin/"
fi

# Change to source directory.
cd $src

# Relocate app to installation dir.

# Determine source.
appsrc=$PWD

# Get app directory name.
appdir=$(basename $appsrc)

# Change out of source dir.
cd ..

# Determine destination
# Check unset destination, use default.
if [ -z $appdst ]
then
	appdst="/home/$(logname)/.autolink/"
fi

echo "Installing app to ${appdst}"

# Move directory and create non-existent directories.
mkdir --parents $appdst; mv $appsrc $_

# Change ownership of created directory if requested.
if [[ $flags =~ "c" ]]
then
	chown -R $(logname):$(logname) $appdst
fi

# Change into installation dir.
cd $appdst
cd $appdir

# Command used to find executable program files to symlink

# List all executable programs in directory.
# Loop over all results.
for f in $(find . -exec which {} \;)
do
	# Absolute path of file to link.
	abspath=$(readlink -f $f)

	# Get filename from path.
	fname=$(basename $f)

	# Determine symlink destination path combination from directory and filename.
	fulldst="${lnkdst}/${fname}"

	# If the destination path ends in a slash, remove duplicate.
	if [ ${lnkdst: -1} == "/" ]
	then
		fulldst="${lnkdst}${fname}"
	fi

	# Ready to symlink.
	# Check that file to link is not empty
	if [ ! -z abspath ]
	then
		# Check that link destination is set.
		if [ ! -z fulldst ]
		then
			echo "Creating symlink from ${abspath} to ${fulldst}"
			ln -s "${abspath}" "${fulldst}"
		fi
	fi
done
