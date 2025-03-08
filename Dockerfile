FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER app
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS with-node
RUN apt-get update
RUN apt-get install curl
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash
RUN apt-get -y install nodejs


FROM with-node AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["OctoCloud.Server/OctoCloud.Server.csproj", "OctoCloud.Server/"]
COPY ["octocloud.client/octocloud.client.esproj", "octocloud.client/"]
RUN dotnet restore "./OctoCloud.Server/OctoCloud.Server.csproj"
COPY . .
WORKDIR "/src/OctoCloud.Server"
RUN dotnet build "./OctoCloud.Server.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./OctoCloud.Server.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OctoCloud.Server.dll"]
