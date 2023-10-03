FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /source

# Copy csproj and restore as distinct layers.
COPY src/DotNetCoreSqlDb/*.csproj ./DotNetCoreSqlDb/
RUN dotnet restore ./DotNetCoreSqlDb/DotNetCoreSqlDb.csproj

# Copy everything else and build app.
COPY src/DotNetCoreSqlDb/. ./DotNetCoreSqlDb/
WORKDIR /source/DotNetCoreSqlDb
RUN dotnet publish -c release -o /app --no-restore

# Final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "DotNetCoreSqlDb.dll"]
