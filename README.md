# autolink

Autolink is a simple tool to put Linux programs distributed as a tarball/etc. somewhere that makes sense. By default, autolink will move any program to install to `~/.autolink/`, and then create symlinks to `/usr/local/bin/`.

## Usage

`autolink -flags source_path [symlink destination] [file move destination.]`

Files from source path are moved to file move destination, and then executable files are symlinked to the symlink destination path.

Defaults:
        
        symlink destination:    /usr/local/bin/
        move destination:       /home/$(logname)/.autolink/

Flags:
        
        i: Install
        t: Unpack tar.gz
        c: Change owner of installation directory to $(logname), use this if using autolink as root to own your program installation directory


### Example:

Installing Tor browser from a file called `tor-browser.tar.gz`

`# autolink -itc ./tor-browser.tar.gz`

This will install Tor browser from the specified file. To run the installed browser:

`$ start-tor-browser`

## Help command

Help can be viewed with `autolink --help`

## Compiling

You can compile the `.sh` script to a binary executable with [shc](https://github.com/neurobin/shc).

`$ shc -f autolink.sh -o autolink`

Now you can even install autolink with itself!

`# ./autolink.sh -itc ./autolink`
