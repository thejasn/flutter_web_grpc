# Install dependencies
FROM debian:latest AS build-env

ARG TARGET

RUN apt-get update && apt-get install -yq curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 psmisc \
    && rm -rf /var/lib/apt/lists/*

# Set flutter path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Clone the flutter repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter \
    && flutter channel stable \
    && flutter upgrade \
    && flutter config --no-analytics --enable-web --no-enable-android --no-enable-ios \
    && flutter precache --web \
    && flutter doctor -v

# Copy the app files to the container
COPY . /usr/local/bin/app

# Set the working directory to the app files within the container
WORKDIR /usr/local/bin/app

# Get App Dependencies
RUN flutter pub get && flutter build web


# Stage 2 - Create the run-time image
FROM nginx

COPY --from=build-env /usr/local/bin/app/configs/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build-env /usr/local/bin/app/build/web /usr/share/nginx/html