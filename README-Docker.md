# Running Stixy Legacy (Rails 2.1) in Docker

This legacy Rails 2.1 application from 2005-2013 has been containerized for modern development environments.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Build and run the application:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   - Web application: http://localhost:3000
   - MySQL database: localhost:3306

## Manual Setup (if needed)

If the automatic setup doesn't work, you can run commands manually:

1. **Build the containers:**
   ```bash
   docker-compose build
   ```

2. **Start the database:**
   ```bash
   docker-compose up -d db
   ```

3. **Wait for MySQL to be ready, then create and migrate the database:**
   ```bash
   docker-compose run --rm web rake db:create
   docker-compose run --rm web rake db:migrate
   ```

4. **Start the web server:**
   ```bash
   docker-compose up web
   ```

## Technical Details

### Ruby & Rails Versions
- Ruby 1.8.7-p374 (last stable version compatible with Rails 2.1)
- Rails 2.1.0
- RubyGems 1.3.7

### Database
- MySQL 5.7 (compatible with the original MySQL 5.0/5.1 era)
- Database: `stixy_dev`
- Username: `mysql`
- Password: `passw0rd`

### Gems Installed
- rails 2.1.0
- mysql 2.8.1
- icalendar 1.1.6
- aws-s3 0.6.3
- mini_magick 1.3.3
- paginator 1.1.1
- tzinfo 0.3.15
- mocha 0.9.8

## Troubleshooting

### Database Connection Issues
If you get database connection errors:
```bash
# Check if MySQL is running
docker-compose ps

# View MySQL logs
docker-compose logs db

# Restart the database
docker-compose restart db
```

### Gem Installation Issues
If gems fail to install, you may need to build with verbose output:
```bash
docker-compose build --no-cache
```

### Ruby Version Issues
This setup uses Ruby 1.8.7, which is the last version that works reliably with Rails 2.1. If you encounter issues, the Ruby installation in the Dockerfile may need adjustments.

## Development Workflow

### Running Rails Commands
```bash
# Rails console
docker-compose run --rm web script/console

# Database migrations
docker-compose run --rm web rake db:migrate

# Run tests
docker-compose run --rm web rake test

# View logs
docker-compose logs -f web
```

### File Changes
The application directory is mounted as a volume, so changes to your local files will be reflected in the container immediately.

## Notes

- This is a legacy application from 2005-2013 era
- Some modern security practices may not be implemented
- The application uses very old versions of Ruby and Rails for compatibility
- ImageMagick is installed for image processing (mini_magick gem)
- The original socket-based MySQL connection has been changed to TCP for Docker compatibility 