# FROM --platform=amd64 mcr.microsoft.com/dotnet/aspnet:6.0 AS base
# WORKDIR /app
# EXPOSE 80

# # Copy the published content of your ASP.NET application into the container
# FROM --platform=amd64 mcr.microsoft.com/dotnet/sdk:6.0 AS build
# WORKDIR /src
# COPY . .
# #RUN dotnet publish -c Release -o /app
# RUN dotnet publish -r linux-x64 --self-contained -o /app

# # Use the base image and copy the published files
# FROM --platform=amd64 base AS final
# WORKDIR /blp
# COPY --from=build /app .
# ENTRYPOINT ["dotnet", "myblazorapp.dll"]


# Use the official .NET 6 SDK as a build image
FROM --platform=amd64 mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY . .

# Build and publish the ASP.NET application
RUN dotnet publish -c Release -o /app

# Use the official .NET 6 runtime as the base image
FROM --platform=amd64 mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /usr/share/nginx/app
EXPOSE 80
ENV ASPNETCORE_URLS "http://localhost:5000"
# Copy the published ASP.NET application
COPY --from=build /app .

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Copy the Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Install Supervisor
RUN apt-get install -y supervisor

# Copy the Supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
