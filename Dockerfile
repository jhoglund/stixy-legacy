# Use Ruby 2.7 which is more modern but can still run Rails 2.1
FROM ruby:2.7-slim

# Set environment variables
ENV RAILS_ENV=development
ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ROOT=/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libxml2-dev \
    libxslt1-dev \
    sqlite3 \
    libsqlite3-dev \
    imagemagick \
    libmagickwand-dev \
    nodejs \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy compatibility patches first
COPY config/initializers/activesupport_patches.rb config/initializers/
COPY config/initializers/compatibility_fix.rb config/initializers/
COPY config/initializers/rails21_ruby27_patches.rb config/initializers/
COPY patches/ patches/

# Copy Gemfile and install dependencies
COPY Gemfile* ./
RUN bundle install

# Apply comprehensive Rails 2.1 + Ruby 2.7 compatibility patches
RUN ruby patches/rails21_comprehensive_fix.rb

# Copy the rest of the application
COPY . .

# Create necessary directories with proper permissions
RUN mkdir -p log tmp/pids tmp/cache tmp/sessions public/uploads && \
    chmod -R 755 log tmp public/uploads && \
    chmod +x script/*

# Install remaining gems with error handling
RUN gem install sqlite3 -v=1.3.13 --no-document || echo "Warning: sqlite3 install failed" && \
    gem install icalendar -v=1.1.6 --no-document || echo "Warning: icalendar install failed" && \
    gem install aws-s3 -v=0.6.3 --no-document || echo "Warning: aws-s3 install failed" && \
    gem install mini_magick -v=3.8.1 --no-document || echo "Warning: mini_magick install failed" && \
    gem install paginator -v=1.1.1 --no-document || echo "Warning: paginator install failed" && \
    gem install tzinfo -v=0.3.61 --no-document || echo "Warning: tzinfo install failed" && \
    gem install mocha -v=0.14.0 --no-document || echo "Warning: mocha install failed"

# Copy startup script
COPY docker/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Default command
CMD ["/usr/local/bin/startup.sh"] 