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
# NOTE:
#   This is NOT the right way to do this.
#   The RIGHT way would be to not use Dockerfile and use a real buildah build where we can
#   run oscap remediation against the mounted file system and then close up the file system
#   into an image.

# Title	Prevent Login to Accounts With Empty Password
# Rule	xccdf_org.ssgproject.content_rule_no_empty_passwords
# Ident	CCE-80841-0
# Remediation Source: https://github.com/ComplianceAsCode/content/blob/master/linux_os/guide/system/accounts/accounts-restrictions/password_storage/no_empty_passwords/bash/shared.sh
RUN sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/system-auth
RUN sed --follow-symlinks -i 's/\<nullok\>//g' /etc/pam.d/password-auth

# Title	Verify and Correct File Permissions with RPM
# Rule	xccdf_org.ssgproject.content_rule_rpm_verify_permissions
# Ident	CCE-80858-4
# Result	fail
RUN declare -A SETPERMS_RPM_DICT; \
    readarray -t FILES_WITH_INCORRECT_PERMS < <(rpm -Va --nofiledigest | awk '{ if (substr($0,2,1)=="M") print $NF }'); \
    for FILE_PATH in "${FILES_WITH_INCORRECT_PERMS[@]}"; \
    do \
        RPM_PACKAGE=$(rpm -qf "$FILE_PATH"); \
        SETPERMS_RPM_DICT["$RPM_PACKAGE"]=1; \
    done; \
    for RPM_PACKAGE in "${!SETPERMS_RPM_DICT[@]}"; \
    do \
        rpm --setperms "${RPM_PACKAGE}"; \
    done

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
