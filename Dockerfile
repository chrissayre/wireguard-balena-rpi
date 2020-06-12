FROM balenalib/raspberrypi4-64-debian as build
ENV RPI3_VERSION '2.47.0+rev1'
ENV RPI4_VERSION '2.51.1+rev1'
WORKDIR /usr/src/app

RUN install_packages curl wget build-essential libelf-dev awscli bc flex libssl-dev python bison

COPY . ./

# RPI3
RUN BALENA_MACHINE_NAME=raspberrypi3-64 ./build.sh build --device raspberrypi3-64 --os-version "$RPI3_VERSION" --src wireguard-linux-compat/src

# RPI4
RUN BALENA_MACHINE_NAME=raspberrypi4-64 ./build.sh build --device raspberrypi4-64 --os-version "$RPI4_VERSION" --src wireguard-linux-compat/src

# Note: This image runs on 4 and 3.
FROM balenalib/raspberrypi4-64-debian
WORKDIR /usr/src/app
COPY --from=build /usr/src/app/output/ /usr/src/app/output/
COPY ./run.sh .

CMD ["./run.sh"]
