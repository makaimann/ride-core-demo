FROM ubuntu:18.04
WORKDIR /home/ride-demo

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y clang cmake python3-dev python3-pip libpcre* wget unzip build-essential python3 automake libgmp-dev curl nano libboost-dev default-jdk libclang-dev llvm llvm-dev lbzip2 libncurses5-dev git libtool iverilog bison flex libreadline-dev gawk tcl-dev libffi-dev graphviz xdot pkg-config gtkwave

RUN git clone https://github.com/YosysHQ/yosys.git
RUN cd yosys && make -j16 && make install
ENV PATH="/home/ride-demo/yosys/:${PATH}"

RUN git clone https://github.com/Boolector/boolector.git
RUN pip3 install cython
RUN cd boolector && ./contrib/setup-lingeling.sh && ./contrib/setup-btor2tools.sh && ./configure.sh --python --py3 && cd build && make -j16
ENV PYTHONPATH="/home/ride-demo/boolector/build/lib:${PYTHONPATH}"

RUN git clone -b dev https://github.com/cristian-mattarei/CoSA
RUN cd CoSA && pip3 install -e .

RUN git clone -b sqed https://github.com/makaimann/pysmt
RUN cd pysmt && pip3 install -e .
ENV PYTHONPATH="/home/ride-demo/pysmt/bindings:${PYTHONPATH}"
ENV LD_LIBRARY_PATH="/home/ride-demo/pysmt/bindings:${LD_LIBRARY_PATH}"

RUN git clone https://github.com/makaimann/ride-core-demo.git

RUN CoSA --help
