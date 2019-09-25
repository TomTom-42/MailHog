# stage 0
FROM golang:alpine as builder

RUN apk --no-cache add git \
&& mkdir -p /go/src/mailhog

COPY . /go/src/mailhog

RUN export GOPATH=/go && export GOBIN=/go/bin \
&& cd /go/src/mailhog && go get && go fmt && CGO_ENABLED=0 go install -ldflags='-s -w'


# stage 1
FROM alpine:3.10

RUN adduser -D -u 1000 mailhog \
&& mkdir -p /home/mailhog

COPY --from=builder /go/bin/mailhog /home/mailhog/MailHog
RUN chown mailhog:mailhog /home/mailhog/MailHog \
&& chmod +x /home/mailhog/MailHog

WORKDIR /home/mailhog
USER mailhog

ENTRYPOINT [ "/home/mailhog/MailHog" ]

# Expose the SMTP and HTTP ports:
EXPOSE 1025 8025
