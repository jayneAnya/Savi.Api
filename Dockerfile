# Stage 1: Base image for runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

# Stage 2: Build image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy the project file and restore
COPY Savi.Api/Savi.Api.csproj ./Savi.Api/
RUN dotnet restore ./Savi.Api/Savi.Api.csproj

# Copy the rest of the code
COPY . .

# Build the project
WORKDIR /src/Savi.Api
RUN dotnet build Savi.Api.csproj -c Release -o /app/build

# Stage 3: Publish the application
FROM build AS publish
RUN dotnet publish Savi.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

# Stage 4: Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Listen on port 80
ENV ASPNETCORE_URLS=http://+:80

# Run the app
CMD ["dotnet", "Savi.Api.dll"]
