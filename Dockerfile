FROM anapsix/alpine-java:8_jdk

LABEL maintainer=@qgadrian

########################
# INSTALL COMMON TOOLS
########################
RUN apk add --update \
  unzip

########################
# INSTALL ANDROID SDK
########################
ENV ANDROID_SDK_TOOLS_VERSION 3859397
ENV ANDROID_COMPONENTS "build-tools;25.0.2"

RUN wget http://dl.google.com/android/repository/sdk-tools-linux-$ANDROID_SDK_TOOLS_VERSION.zip
RUN unzip sdk-tools-linux-$ANDROID_SDK_TOOLS_VERSION.zip
RUN mkdir /usr/local/android-sdk
RUN mv tools /usr/local/android-sdk/tools
RUN rm sdk-tools-linux-$ANDROID_SDK_TOOLS_VERSION.zip

RUN echo y | /usr/local/android-sdk/tools/bin/sdkmanager "platform-tools"
RUN echo y | /usr/local/android-sdk/tools/bin/sdkmanager ${ANDROID_COMPONENTS}
RUN echo y | usr/local/android-sdk/tools/bin/sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2"
RUN yes | /usr/local/android-sdk/tools/bin/sdkmanager --licenses

########################
# SET ANDROID SDK PATHS
########################
ENV ANDROID_SDK_HOME /usr/local/android-sdk
ENV ANDROID_HOME /usr/local/android-sdk
ENV ANDROID_LICENSES $ANDROID_SDK_HOME/licenses

ENV PATH ${PATH}:${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/platform-tools:${ANDROID_SDK_HOME}/tools/bin

RUN chmod 777 -R $ANDROID_SDK_HOME

################################
# ACCEPT ANDROID SDK LICENSES
################################
RUN [ -d $ANDROID_LICENSES ] || mkdir $ANDROID_LICENSES \
  && [ -f $ANDROID_LICENSES/android-sdk-license ] || echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_LICENSES/android-sdk-license \
  && [ -f $ANDROID_LICENSES/android-sdk-preview-license ] || echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_LICENSES/android-sdk-preview-license \
  && [ -f $ANDROID_LICENSES/intel-android-extra-license ] || echo d975f751698a77b662f1254ddbeed3901e976f5a > $ANDROID_LICENSES/intel-android-extra-license

########################
# FIREBASE
########################
RUN mkdir -p /android/
COPY content/firebase_test.sh /android/
RUN chmod 777 /android/content/firebase_test.sh && chmod +x /android/content/firebase_test.sh

########################
# COPY ANDROID APP SRC
########################
COPY . .

########################
# BUILD ENVIRONMENT SETUP
########################
VOLUME ["./app/build"]

ARG ENV
ENV ENV ${ENV}

########################
# BUILD ANDROID APP
########################
CMD ./gradlew clean build assembleAndroidTest -Penv=${ENV}
