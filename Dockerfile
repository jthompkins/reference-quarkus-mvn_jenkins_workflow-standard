#NOTE: maybe replace this image with a TSSC openjdk image if such a thing ever needs to exist
FROM registry.redhat.io/ubi8/openjdk-8

USER 0

# vulenerability remediation
RUN dnf update -y && \
    dnf clean all

# install app
RUN mkdir /app
ADD target/*.jar /app/app.jar
RUN chown -R 1001:0 /app && chmod -R 774 /app
EXPOSE 8080

# run app
USER 1001
ENTRYPOINT ["java", "-jar"]
CMD ["/app/app.jar"]
