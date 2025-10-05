#!/bin/bash

# --- Configuration ---
# NOTE: The latest version is determined from the search results (v3.5.5)
LOKI_VERSION="v3.5.5"
ARCH="amd64"

LOKI_BIN_NAME="loki-linux-${ARCH}"
PROMTAIL_BIN_NAME="promtail-linux-${ARCH}"

LOKI_ZIP="loki-linux-${ARCH}.zip"
PROMTAIL_ZIP="promtail-linux-${ARCH}.zip"

LOKI_CONFIG_URL="https://raw.githubusercontent.com/grafana/loki/${LOKI_VERSION}/cmd/loki/loki-local-config.yaml"
PROMTAIL_CONFIG_URL="https://raw.githubusercontent.com/grafana/loki/${LOKI_VERSION}/clients/cmd/promtail/promtail-local-config.yaml"

# --- 1. Setup Environment ---
echo "⚙️ Setting up working directory..."
mkdir loki-local-install
cd loki-local-install

# Check for necessary tools
if ! command -v wget &> /dev/null || ! command -v unzip &> /dev/null; then
    echo "⚠️ wget and/or unzip not found. Installing necessary tools..."
    sudo apt update && sudo apt install -y wget unzip
fi

# --- 2. Download Assets (Loki and Promtail) ---
echo "⬇️ Downloading Loki and Promtail version ${LOKI_VERSION} for Linux/${ARCH}..."

# Download Loki
wget "https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/${LOKI_ZIP}"

# Download Promtail
wget "https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/${PROMTAIL_ZIP}"

# --- 3. Extract and Configure Permissions ---
echo "📦 Extracting files and setting permissions..."

# Extract the archives
unzip "${LOKI_ZIP}"
unzip "${PROMTAIL_ZIP}"

# Make binaries executable (names might drop the .zip extension)
chmod +x "${LOKI_BIN_NAME}"
chmod +x "${PROMTAIL_BIN_NAME}"

# Clean up zip files
rm "${LOKI_ZIP}" "${PROMTAIL_ZIP}"

# --- 4. Download Configuration Files (Version-Specific) ---
echo "📄 Downloading version-specific configuration files (using ${LOKI_VERSION} branch)..."

# Download Loki configuration
wget "${LOKI_CONFIG_URL}" -O loki-local-config.yaml

# Download Promtail configuration
wget "${PROMTAIL_CONFIG_URL}" -O promtail-local-config.yaml

# --- 5. Run Loki ---
echo "🚀 Starting Loki..."
echo "Loki logs will display here. Loki metrics available at http://localhost:3100/metrics"
echo "Press Ctrl+C to stop Loki."

# Start Loki using the correct binary name and configuration file
# Note: The command provided in the original prompt is used here.
./"${LOKI_BIN_NAME}" -config.file=loki-local-config.yaml