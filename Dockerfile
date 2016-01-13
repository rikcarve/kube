FROM busybox:ubuntu-14.04
COPY ./kubectl /bin/kubectl
ENTRYPOINT ["/bin/kubectl"]
