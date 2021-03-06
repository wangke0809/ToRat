FROM lu4p/torat-pre

COPY setup_docker.sh /
COPY . /go/src/github.com/lu4p/ToRat
RUN mkdir -p /dist/server && mkdir -p /dist/client

RUN ./setup_docker.sh && rm ./setup_docker.sh

# Build ToRat_server
RUN cd /go/src/github.com/lu4p/ToRat/cmd/server && go build -o /dist/server/ToRat_server && cp banner.txt /dist/server/

RUN cd /go/src/github.com/cretz/tor-static && tar -xf libs_linux.tar.gz
RUN cd /go/src/github.com/lu4p/ToRat/cmd/client && go build --ldflags "-s -w" -tags "tor" -o /dist/client/client_linux && upx /dist/client/client_linux

RUN cd /go/src/github.com/cretz/tor-static && unzip -o tor-static-windows-amd64.zip 

RUN /go/bin/xgo --targets=windows/amd64 --ldflags '-s -w -H windowsgui' -tags "tor" github.com/lu4p/ToRat/cmd/client

RUN mv /build/client-windows-4.0-amd64.exe /dist/client && upx /dist/client/client-windows-4.0-amd64.exe
RUN mkdir /dist_ext

CMD (tor -f /torrc&) && cp /dist /dist_ext -rf && cd /dist/server/ && ./ToRat_server
