FROM okteto/dotnetcore:6 AS deps
ARG RIDER_VERSION="2023.1.4"
RUN apt-get update \
    && apt-get install -y unzip procps \
    && wget -O /usr/local/bin/jetbrains_debugger_agent https://download.jetbrains.com/rider/ssh-remote-debugging/linux-x64/jetbrains_debugger_agent_20230319.24.0 \
    && chmod +x /usr/local/bin/jetbrains_debugger_agent \
    && wget -O /tmp/rrd.zip "https://data.services.jetbrains.com/products/download?code=RRD&platform=linux64" \
    && mkdir -p /root/.local/share/JetBrains/RiderRemoteDebugger/${RIDER_VERSION} \
    && unzip -o /tmp/rrd.zip -d /root/.local/share/JetBrains/RiderRemoteDebugger/${RIDER_VERSION}

FROM okteto/dotnetcore:6 AS dev
COPY --from=deps /usr/local/bin/jetbrains_debugger_agent /usr/local/bin/jetbrains_debugger_agent 
COPY --from=deps /root/.local/share/JetBrains/RiderRemoteDebugger /root/.local/share/JetBrains/RiderRemoteDebugger 

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet build -c Release -o /app
RUN dotnet publish  -c Release -o /app

####################################

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS prod

WORKDIR /app
COPY --from=dev /app .
EXPOSE 5000
ENTRYPOINT ["dotnet", "helloworld.dll"]
