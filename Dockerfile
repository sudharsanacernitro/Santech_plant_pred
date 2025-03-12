# Use a base image
FROM python:3.12-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the application files into the container
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Define the command to run the app
CMD ["python", "api.py"]
