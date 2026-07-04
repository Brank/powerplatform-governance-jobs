# .NET SDK image
FROM mcr.microsoft.com/dotnet/sdk:10.0

# Install dependencies, Microsoft package repository, PowerShell, and Azure CLI
RUN wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y powershell

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash


# Install Power Platform CLI
RUN dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Make PAC CLI available in PATH
ENV PATH="${PATH}:/root/.dotnet/tools"

# Set working directory
WORKDIR /app

# Copy scripts into container
COPY Scripts ./Scripts

# Execute script when container starts
ENTRYPOINT ["pwsh", "-File", "/app/Scripts/GetPowerPlatformSettings.ps1"]