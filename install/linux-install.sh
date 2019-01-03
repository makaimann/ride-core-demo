# Install script for Ubuntu for the Ride-Demo
# It should be easy to adapt this to other operating systems if necessary
# There is also a Dockerfile if you prefer to use a container

# This script does require sudo, and needs to be sourced (source linux-install.sh)

# Note: There are some minor changes to pysmt, so this demo uses a fork
#       In the near future, we hope these changes will be merged into the master branch of pysmt
# Note 2: This is using the dev branch of CoSA which has several improvements over master and will also be merged soon

SRCING="no"
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    SRCING="yes"
fi

set -e

sudo apt-get update
sudo apt-get install -y clang cmake libpcre3 wget unzip build-essential python3 python3-pip automake libgmp-dev curl nano python3-dev libboost-dev default-jdk libclang-dev llvm llvm-dev lbzip2 libncurses5-dev git libtool iverilog bison flex libreadline-dev gawk tcl-dev libffi-dev graphviz xdot pkg-config gtkwave

SDIR=`pwd`

# upgrade pip and setuptools
sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install --upgrade setuptools

cd $SDIR
git clone https://github.com/YosysHQ/yosys.git
cd yosys && make -j16
export PATH="${SDIR}/yosys/:${PATH}"

cd $SDIR
git clone https://github.com/Boolector/boolector.git
sudo python3 -m pip install cython
cd boolector && ./contrib/setup-lingeling.sh && ./contrib/setup-btor2tools.sh && ./configure.sh --python --py3 && cd build && make -j16
export LD_LIBRARY_PATH="${SDIR}/boolector/build/lib:${LD_LIBRARY_PATH}"
export PYTHONPATH="${SDIR}/boolector/build/lib:${PYTHONPATH}"

cd $SDIR
if [ ! -d "./boolector/build/lib" ]; then
    echo "Boolector build failed"
    exit 1
fi

cd $SDIR
git clone -b dev https://github.com/cristian-mattarei/CoSA
cd CoSA && sudo python3 -m pip install -e .
# add local and virtualenv bin directories to path (where python3 -m pip puts CoSA)
export PATH="${HOME}/.local/bin:${PATH}"
if [ "${VIRTUAL_ENV}" != "" ]; then
    export PATH="${VIRTUAL_ENV}/bin:${PATH}"
fi

# overwrite the master version of pysmt that CoSA installed with the fork
cd $SDIR
sudo python3 -m pip uninstall --yes pysmt
git clone -b sqed https://github.com/makaimann/pysmt
cd pysmt && sudo python3 -m pip install -e .
cd $SDIR

echo -e "Now run: CoSA --help
to make sure everything was installed correctly.
Note: The first time it may be slow to respond, but if you run it again it should be quicker.

IMPORTANT: This script has modified your environment variables for this session, but they will
not automatically be saved. If you would like to run this demo in new sessions, please view
the contents of $0 and set the necessary environment variables in a startup file, e.g.
.bashrc, .profile, .bashrc.user, etc...
"

if [[ $SRCING != "yes" ]]; then
    echo "Warning: It looks like you didn't source this file, so your environment variables won't be set."
    echo "Consider looking through this script and exporting the necessary environment variables"
fi
