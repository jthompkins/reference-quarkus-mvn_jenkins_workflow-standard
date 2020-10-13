#NOTE: maybe replace this image with a TSSC openjdk image if such a thing ever needs to exist
FROM registry.redhat.io/ubi8/openjdk-8

USER 0

##############################
# vulenerability remediation #
##############################
RUN dnf update -y && \
    dnf clean all

##########################
# compliance remediation #
##########################
# Title	Prevent Login to Accounts With Empty Password
# Rule	xccdf_org.ssgproject.content_rule_no_empty_passwords
# Ident	CCE-80841-0
# Remediation Source: https://github.com/ComplianceAsCode/content/blob/master/linux_os/guide/system/accounts/accounts-restrictions/password_storage/no_empty_passwords/bash/shared.sh
RUN sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth
RUN sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/password-auth

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
