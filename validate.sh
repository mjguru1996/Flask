#!/bin/bash

# Initialize results array
declare -a results
declare -a descriptions=("Docker Build" "Docker Compose Up" "Endpoint Access" "Response Validation")

# Function to add result to the array
add_result() {
  if [ $1 -eq 0 ]; then
    results+=("PASS")
  else
    results+=("FAIL")
  fi
}

# Validate the Docker build for Flask API
echo "Building the Docker image for Flask API..."
docker build -t flask-api .
add_result $?

# Start the Flask API and Nginx using Docker Compose
echo "Starting Docker Compose..."
docker-compose up -d
add_result $?

# Wait a few seconds for the containers to be fully ready
sleep 5

# Curl to the Flask API endpoint through Nginx
echo "Curling to the Flask API endpoint through Nginx..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/api/greet)
message=$(curl -s http://localhost/api/greet | grep "Hello, World!")

# Check for a 200 response and the expected message
if [ "$response" -eq 200 ] && [[ $message == *"Hello, World!"* ]]; then
  add_result 0
else
  add_result 1
fi

# Tear down the Docker Compose services
docker-compose down
echo "Validation completed and services stopped."

# Print the summary table
echo
echo "Validation Summary:"
echo "-------------------------------"
printf "| %-20s | %-5s |\n" "Description" "Result"
echo "-------------------------------"
for i in "${!descriptions[@]}"; do
  printf "| %-20s | %-5s |\n" "${descriptions[$i]}" "${results[$i]}"
done
echo "-------------------------------"

# Exit with an appropriate status code
if [[ " ${results[@]} " =~ "FAIL" ]]; then
  exit 1
else
  exit 0
fi
