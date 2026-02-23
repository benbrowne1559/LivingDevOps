#Dockerfile
FROM python:3.13-alpine

WORKDIR /app

# Copy the python dependency file into the container at /app
COPY requirements.txt /app

RUN pip install -r requirements.txt

# Copy the rest of app files into the container at /app
COPY . /app

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run app.py when the container launches
CMD ["python", "app.py"]