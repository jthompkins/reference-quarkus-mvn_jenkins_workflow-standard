#NOTE: maybe replace this image with a TSSC openjdk image if such a thing ever needs to exist
FROM registry.redhat.io/ubi8/openjdk-8

USER 0

# WARNING: currently disabled due to:
#
#  RAN: /usr/bin/buildah bud --storage-driver=vfs --format=oci --tls-verify=true --layers -f Dockerfile -t localhost/reference-quarkus-mvn-jenkins/fruit:1.0.2-feature_jenkins-refactor42 --authfile /home/tssc/.buildah-auth.json .
#
#  STDOUT:
#
#  STDERR:
#Getting image source signatures
#Copying blob sha256:e2d73fb87e44338b692e4e37d7edb5060b0517066c168e2256b9790ee52a0190
#Copying blob sha256:0fd3b5213a9b4639d32bf2ef6a3d7cc9891c4d8b23639ff7ae99d66ecb490a70
#Copying blob sha256:aebb8c5568533b57ee3da86262f7bff81383a2a624b9f54b9da3418705009901
#Copying config sha256:f4654f7979745097de44f0a3ecc887f0bebd27b0272328c567130d598d827c77
#Writing manifest to image destination
#Storing signatures
#Error:
# Problem: cannot install both rpm-libs-4.14.3-4.el8.x86_64 and rpm-libs-4.14.2-37.el8.x86_64
#  - package rpm-plugin-systemd-inhibit-4.14.2-37.el8.x86_64 requires rpm-libs(x86-64) = 4.14.2-37.el8, but none of the providers can be installed
#  - cannot install the best update candidate for package rpm-libs-4.14.2... (273 more, please see e.stderr)
##############################
# vulenerability remediation #
##############################
#RUN dnf update -y && \
#    dnf clean all

##########################
# compliance remediation #
##########################
# NOTE / WARNING / IMPORTANT:
#   This is NOT the right way to do this.
#   The RIGHT way would be to not use Dockerfile and use a real buildah build where we can
#   run oscap remediation against the mounted file system and then close up the file system
#   into an image.
#   But.....right now.....just trying to get a reference working....
COPY compliance/ /var/lib/compliance/
RUN /var/lib/compliance/xccdf_org.ssgproject.content_rule_no_empty_passwords.sh \
    && /var/lib/compliance/xccdf_org.ssgproject.content_rule_rpm_verify_permissions.sh

# NOTE / WARNING / IMPORTANT:
#   work around for https://bugzilla.redhat.com/show_bug.cgi?id=1798685
RUN rm -f /var/log/lastlog

###############
# install app #
###############
RUN mkdir /app
ADD target/*.jar /app/app.jar
RUN chown -R 1001:0 /app && chmod -R 774 /app
EXPOSE 8080

###########
# run app #
###########
USER 1001
ENTRYPOINT ["java", "-jar"]
CMD ["/app/app.jar"]
