# Stixy Legacy Docker Setup

This Docker setup allows you to run the legacy Stixy Rails 2.1 application in a containerized environment with Ruby 2.7.

## Quick Start

1. **Build and start the application:**
   ```bash
   ./docker/dev.sh build
   ./docker/dev.sh up
   ```

2. **Access the application:**
   - Web app: http://localhost:3000
   - MySQL: localhost:3306 (user: mysql, password: passw0rd)

3. **Stop the application:**
   ```bash
   ./docker/dev.sh down
   ```

## Services

### Web Application (`web`)
- **Base Image:** Ruby 2.7-slim
- **Framework:** Rails 2.1.0
- **Port:** 3000
- **Environment:** Development by default

### Database (`db`)
- **Image:** MySQL 8.0
- **Port:** 3306
- **Databases:** stixy_dev, stixy_test
- **Credentials:** mysql/passw0rd

## Development Helper Script

The `docker/dev.sh` script provides convenient commands:

```bash
# Build Docker images
./docker/dev.sh build

# Start services
./docker/dev.sh up

# View logs
./docker/dev.sh logs
./docker/dev.sh logs web  # Specific service

# Open shell in web container
./docker/dev.sh shell

# Open MySQL shell
./docker/dev.sh db-shell

# Show service status
./docker/dev.sh status

# Restart services
./docker/dev.sh restart

# Clean up resources
./docker/dev.sh clean

# Reset everything (deletes data)
./docker/dev.sh reset
```

## Compatibility Patches

The application includes several compatibility patches for running Rails 2.1 on Ruby 2.7:

- **activesupport_patches.rb** - Core ActiveSupport compatibility fixes
- **compatibility_fix.rb** - BigDecimal YAML serialization fixes
- **rails21_ruby27_patches.rb** - Comprehensive Rails 2.1/Ruby 2.7 patches

These patches handle:
- BigDecimal `yaml_as` method issues
- Module `yaml_as` compatibility
- Time zone circular argument references
- YAML serialization changes
- Keyword argument warnings

## File Structure

```
docker/
├── startup.sh          # Container startup script
├── dev.sh             # Development helper script
└── README.md          # This file

Dockerfile              # Main container definition
docker-compose.yml      # Service orchestration
.dockerignore          # Files to exclude from build
```

## Troubleshooting

### Database Connection Issues
If the web app can't connect to MySQL:
```bash
# Check database status
./docker/dev.sh status

# View database logs
./docker/dev.sh logs db

# Restart services
./docker/dev.sh restart
```

### Rails Compatibility Issues
The application uses a simple server (`script/simple_server.rb`) when full Rails startup fails due to compatibility issues. This provides a basic web interface to verify the Docker setup is working.

### Performance Issues
For better performance in development:
- Use Docker Desktop's file sharing optimization
- Consider using Docker volumes for gem caching
- Allocate more memory to Docker Desktop

### Logs and Debugging
```bash
# Follow all logs
docker-compose logs -f

# Follow specific service logs
./docker/dev.sh logs web
./docker/dev.sh logs db

# Get shell access for debugging
./docker/dev.sh shell
```

## Environment Variables

Key environment variables:
- `RAILS_ENV` - Rails environment (default: development)
- `DATABASE_HOST` - MySQL host (default: db)
- `RUBY_VERSION` - Automatically set Ruby version

## Volumes

- `mysql_data` - Persistent MySQL data
- `bundle_cache` - Gem bundle cache for faster builds
- Application files are mounted from host for development

## Known Limitations

1. **Full Rails Environment**: Due to Rails 2.1/Ruby 2.7 compatibility issues, the application may fall back to a simple web server
2. **Gem Compatibility**: Some gems may not install correctly and will show warnings
3. **ActiveRecord**: Database migrations may need manual handling
4. **Asset Pipeline**: Static assets are served directly from the public directory

## Production Considerations

This Docker setup is designed for development. For production:
- Use multi-stage builds for smaller images
- Add proper secrets management
- Configure proper logging and monitoring
- Use production-grade database setup
- Add SSL/TLS termination
- Configure proper resource limits 