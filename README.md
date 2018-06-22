# Scope
This is a painfully dumb script that all it does is launches a `screen` session that is broadcasted over `http://YOURIP:8080` so you can run `screen -xr potato` in a second terminal/putty session and then send your servers IP address to the person who's going to help you and magically you can get help.

## Requirements
  Most operating systems come with bash but you may have to install `curl`.  If you can't do this lord help you why are you messing with a linux command line go read some stuff.  Screen is automatically installed in most `debian` and `centos` linux versions however you may need to install them so I'm including them in this list regardless.  I might upgrade this to an actual package at some point and put it on GitHub for some reason publicly.
* curl
* bash
* screen
* two separate terminal/putty sessions open or accessible to you.

## Usage
`source <(curl -s https://raw.githubusercontent.com/chamunks/clishare/master/clishare.sh)`

To close the session you must press `CTRL+C` twice on the original terminal/putty window
