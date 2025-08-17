# syntax=docker/dockerfile:1
FROM ruby:3.4-slim

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT="development test" \
    APP_USER=app

WORKDIR /app

# Toolchain + libyaml for psych; Nokogiri will usually use precompiled ARM64 gem
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential git curl libyaml-dev ca-certificates tzdata \
    libxml2-dev libxslt1-dev \
 && rm -rf /var/lib/apt/lists/*

# Install gems (don’t force ruby platform; let ARM64 prebuilt nokogiri be used)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# App code
COPY . .

# Non-root user
RUN useradd -m -s /usr/sbin/nologin $APP_USER \
 && chown -R $APP_USER:$APP_USER /app
USER $APP_USER

EXPOSE 3000
CMD ["bash","-lc","bundle exec rails server -b 0.0.0.0 -p 3000"]
