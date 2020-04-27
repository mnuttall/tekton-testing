FROM ubuntu
RUN apt-get update

# Easy way to install yw, but wastes a lot of image size
RUN apt-get install -y software-properties-common 
RUN add-apt-repository -y ppa:rmescandon/yq
RUN apt install -y yq

RUN apt install -y git 
RUN apt install -y hub 
RUN rm -rf /var/lib/apt/lists/*

