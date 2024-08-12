# Use the official Nginx Alpine image as the base image
FROM nginx:alpine

# Set the working directory inside the container
WORKDIR /usr/share/nginx/html

# Copy the web application files into the container
COPY ./dist /usr/share/nginx/html

# Expose port 80 to allow traffic to the web server
EXPOSE 80

# The default command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]
