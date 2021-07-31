ENV RPI4_VERSION '2.82.10+rev1'
ENV BALENA_MACHINE_NAME 'rp4'

FROM balenalib/raspberrypi4-64-debian as build
RUN install_packages curl build-essential libelf-dev libssl-dev pkg-config git flex bison bc python kmod

WORKDIR /usr/src/app

RUN git clone https://git.zx2c4.com/wireguard-linux-compat && git clone https://git.zx2c4.com/wireguard-tools
RUN curl -L -o headers.tar.gz $(echo "https://files.balena-cloud.com/images/$BALENA_MACHINE_NAME/$VERSION/kernel_modules_headers.tar.gz" | sed -e 's/+/%2B/') && tar -xf headers.tar.gz 

RUN ln -s /lib64/ld-linux-x86-64.so.2  /lib/ld-linux-x86-64.so.2 || true  
RUN make -C kernel_modules_headers -j$(nproc) modules_prepare

RUN make -C kernel_modules_headers M=$(pwd)/wireguard-linux-compat/src -j$(nproc)  
RUN make -C $(pwd)/wireguard-tools/src -j$(nproc) && \  
    mkdir -p $(pwd)/tools && \
    make -C $(pwd)/wireguard-tools/src DESTDIR=$(pwd)/tools install

FROM balenalib/amd64-debian 
WORKDIR /wireguard  
COPY --from=build /usr/src/app/wireguard-linux-compat/src/wireguard.ko .  
COPY --from=build /usr/src/app/tools / 
RUN install_packages kmod  

COPY client.sh ./  
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]  
CMD [ "/wireguard/client.sh" ]
