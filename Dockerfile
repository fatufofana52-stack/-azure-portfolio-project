# Use a lightweight Python base image
FROM python:3.11-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the local files into the container
COPY . /app

# Install Flask so our app.py script can run
RUN pip install --no-cache-dir flask

# Expose port 8080 for web traffic
EXPOSE 8080

# Command to execute our app when the container starts
CMD ["python", "app.py"]
