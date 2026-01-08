# Use the .NET 9.0 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj file and restore dependencies
COPY ["CrudMvcApp.csproj", "./"]
RUN dotnet restore "CrudMvcApp.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src"
RUN dotnet build "CrudMvcApp.csproj" -c Release -o /app/build

# Publish the app
FROM build AS publish
RUN dotnet publish "CrudMvcApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Copy published app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "CrudMvcApp.dll"]

