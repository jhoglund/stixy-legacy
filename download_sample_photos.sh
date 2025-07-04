#!/bin/bash

# Download sample photos for Stixy photo widgets
# This script downloads Creative Commons / free photos for demonstration

echo "=== Downloading Sample Photos for Stixy ==="

# Create directory
mkdir -p public/system/photos

# Function to download with fallback to placeholder
download_photo() {
    local url="$1"
    local filename="$2"
    local description="$3"
    
    echo "Downloading $description..."
    if curl -f -s -o "public/system/photos/$filename" "$url"; then
        echo "✓ Downloaded: $filename"
    else
        echo "✗ Failed to download from $url"
        # Create placeholder instead
        echo "Creating placeholder for $description" > "public/system/photos/${filename}.txt"
        echo "→ Created placeholder: ${filename}.txt"
    fi
}

# Travel Planning photos
echo -e "\n--- Travel Planning ---"
download_photo "https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=400&h=300&fit=crop" \
               "paris_eiffel_tower.jpg" "Eiffel Tower"
download_photo "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=300&fit=crop" \
               "hotel_room.jpg" "Hotel Room"
download_photo "https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=400&h=300&fit=crop" \
               "travel_map.jpg" "Travel Map"

# Recipe Collection photos  
echo -e "\n--- Recipe Collection ---"
download_photo "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400&h=300&fit=crop" \
               "pasta_dish.jpg" "Pasta Dish"
download_photo "https://images.unsplash.com/photo-1506368249639-73a05d6f6488?w=400&h=300&fit=crop" \
               "ingredients.jpg" "Fresh Ingredients"
download_photo "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=300&fit=crop" \
               "cooking_kitchen.jpg" "Kitchen"

# Home Renovation photos
echo -e "\n--- Home Renovation ---"
download_photo "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop" \
               "living_room_before.jpg" "Living Room"
download_photo "https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400&h=300&fit=crop" \
               "paint_colors.jpg" "Paint Colors"
download_photo "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=300&fit=crop" \
               "furniture_inspiration.jpg" "Furniture Inspiration"

# Wedding Planning photos
echo -e "\n--- Wedding Planning ---"
download_photo "https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=400&h=300&fit=crop" \
               "wedding_venue.jpg" "Wedding Venue"
download_photo "https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=400&h=300&fit=crop" \
               "wedding_dress.jpg" "Wedding Dress"
download_photo "https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400&h=300&fit=crop" \
               "flower_bouquet.jpg" "Flower Bouquet"

# Team Project photos
echo -e "\n--- Team Project ---"
download_photo "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400&h=300&fit=crop" \
               "team_photo.jpg" "Team Photo"
download_photo "https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=400&h=300&fit=crop" \
               "project_timeline.jpg" "Project Timeline"
download_photo "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=400&h=300&fit=crop" \
               "presentation_mockup.jpg" "Presentation Mockup"

echo -e "\n=== Summary ==="
echo "Downloaded photos to public/system/photos/"
echo "You can now:"
echo "1. Upload these through the Stixy photo widget interface"
echo "2. Move them to the appropriate system directories" 
echo "3. Use them to populate your photo widgets"

ls -la public/system/photos/ 