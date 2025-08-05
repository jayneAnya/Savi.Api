# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

# Build image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src

# Copy and restore project
COPY Savi.Api/Savi.Api.csproj Savi.Api/
RUN dotnet restore Savi.Api/Savi.Api.csproj

# Copy the entire solution
COPY . .

# Build the project
WORKDIR /src/Savi.Api
RUN dotnet build Savi.Api.csproj -c Release -o /app/build

# Publish the project
FROM build AS publish
RUN dotnet publish Savi.Api.csproj -c Release -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENV ASPNETCORE_URLS=http://+:80
CMD ["dotnet", "Savi.Api.dll"]
