FROM okteto/dotnetcore:6 AS dev
RUN wget -O /usr/local/bin/jetbrains_debugger_agent https://download.jetbrains.com/rider/ssh-remote-debugging/linux-x64/jetbrains_debugger_agent_20230319.24.0 \
      && chmod +x /usr/local/bin/jetbrains_debugger_agent

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
