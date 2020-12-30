bse-docker
===

bse-docker container for build imx8mm-bse OS image

1. to install docker.io, please reference [this article](https://docs.docker.com/engine/install/ubuntu). And to add your account into docker group and launch docker

    > sudo usermod -aG docker <your account>
    >
    > \# reminds: you can reboot the host or
    >
    > \# try the below commands for launch docker service
    >
    > sudo systemctl enable docker
    >
    > sudo systemctl start docker


2. clone this repository on your local development host

    > git clone https://github.com/aaeon-kunyi/bse-docker.git

3. build the docker image

    > cd bse-docker
    >
    > ./build_container.sh # the step will build a docker image on local host and create ./works folder for place your source code

    > or pull image from github packages
    >
    > docker pull docker.pkg.github.com/aaeon-kunyi/bse-docker/bse-build-dev:latest
    >
    > docker tag docker.pkg.github.com/aaeon-kunyi/bse-docker/bse-build-dev bse-build-dev:1.0

4. put ** 'debian-bse_20201211.tgz' ** into ./works and decompress it
  
   > tar zxvf debian-bse_20201211.tgz
   >
   > MACHINE=imx8mm-bse ./aaeon_make_debian.sh -c deploy

5. run the docker image for build imx8mm-bse OS image 

    > ./run_container.sh  # the step will start a container
    >
    > sudo MACHINE=imx8mm-bse ./aaeon_make_debian.sh -c all
    >
    > sudo MACHINE=imx8mm-bse ./aaeon_make_debian.sh -c rescu

6. to check ./output folder

    > ls ./output
    >
    > \# will show the below on screen
    >
    > fw_printenv  Image.gz  imx8mm-bse.dtb  imx8mm-bse_setup.img  imx-boot-sd.bin  rootfs.tar.gz
  
