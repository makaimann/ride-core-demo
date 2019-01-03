## Installation Information
This directory contains everything you need to start running the examples.

There are two options:

* linux-install.sh: Builds and installs necessary dependencies assuming you are on a Debian-based system (apt-get)
  * This script requires sudo and must be sourced (`source linux-install.sh`)
  * It should be easy to adapt this to other operating systems if necessary
  * __Important Note__: This script sets environmental variables but does not modify any startup files. If you would like to run this in a new shell, it might be good to copy the environmental exports into your .profile or .bashrc files
  
* Dockerfile: You can use this file to build a docker image and then run it interactively to try the demo

Both of these will take about 20 minutes to install all the dependencies.

## More information on Docker

* [Docker installation](https://hub.docker.com/search/?type=edition&offering=community)
* On linux, you will probably need to preface every docker command with `sudo`. Unless you take extra steps to avoid this.
* To build an image, run `docker build -t <name of your choice> <path to the directory with Dockerfile>`
  * For example, from this directory I would run `docker build -t sqed .`
* We've provided a script for Linux which will run docker with X support: `run_docker_with_x.sh <image name>`. You will probably need to run it with `sudo`.
* If you cannot use that script, the regular run command is the following `docker run -it <name of image>`
  * For example, `docker run -it sqed`
  * To setup X for viewing the gtkwave gui, see this reference: http://wiki.ros.org/docker/Tutorials/GUI
* We use [gtkwave](http://gtkwave.sourceforge.net/) for viewing waveforms
