#!/bin/bash

# SPYK3-PHISH v11.0.0 Installation Script for Linux/macOS
# Author: Ian Carter Kulani

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🌿 SPYK3-PHISH v11.0.0 - Installation Script         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            DISTRO=$ID
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        echo -e "${RED}Unsupported OS${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Detected OS: $OS${NC}"
}

# Check Python version
check_python() {
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        echo -e "${GREEN}✓ Python $PYTHON_VERSION found${NC}"
        if [[ $(echo $PYTHON_VERSION | cut -d'.' -f2) -lt 7 ]]; then
            echo -e "${YELLOW}⚠ Python 3.7+ recommended${NC}"
        fi
    else
        echo -e "${RED}✗ Python3 not found. Please install Python 3.7+${NC}"
        exit 1
    fi
}

# Install system dependencies
install_deps() {
    echo -e "${BLUE}📦 Installing system dependencies...${NC}"
    
    if [[ "$OS" == "linux" ]]; then
        if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]]; then
            sudo apt-get update
            sudo apt-get install -y \
                python3-pip python3-dev \
                nmap nikto traceroute dnsutils \
                openssh-client curl wget \
                tcpdump libpcap-dev \
                chromium-browser chromium-chromedriver \
                build-essential libssl-dev libffi-dev \
                iptables net-tools
        elif [[ "$DISTRO" == "alpine" ]]; then
            apk add --no-cache \
                python3 py3-pip nmap nikto \
                bind-tools traceroute openssh-client \
                tcpdump libpcap-dev chromium chromium-chromedriver \
                build-base libffi-dev openssl-dev iptables
        elif [[ "$DISTRO" == "fedora" ]] || [[ "$DISTRO" == "centos" ]] || [[ "$DISTRO" == "rhel" ]]; then
            sudo dnf install -y \
                python3-pip python3-devel \
                nmap nikto traceroute bind-utils \
                openssh-clients curl wget \
                tcpdump libpcap-devel \
                chromium chromium-driver \
                gcc openssl-devel libffi-devel \
                iptables net-tools
        fi
    elif [[ "$OS" == "macos" ]]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${YELLOW}Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install python3 nmap nikto traceroute bind tcpdump
        brew install --cask chromedriver
    fi
}

# Create virtual environment
create_venv() {
    echo -e "${BLUE}🔧 Creating Python virtual environment...${NC}"
    python3 -m venv venv
    source venv/bin/activate
    echo -e "${GREEN}✓ Virtual environment created${NC}"
}

# Install Python packages
install_python_packages() {
    echo -e "${BLUE}📦 Installing Python packages...${NC}"
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install requirements
    pip install \
        cryptography \
        requests \
        psutil \
        colorama \
        paramiko \
        python-nmap \
        python-whois \
        scapy \
        qrcode[pil] \
        pyshorteners \
        discord.py \
        telethon \
        slack-sdk \
        selenium \
        webdriver-manager \
        aiohttp \
        pyOpenSSL \
        dnspython \
        netifaces
    
    echo -e "${GREEN}✓ Python packages installed${NC}"
}

# Create configuration directories
setup_directories() {
    echo -e "${BLUE}📁 Setting up directories...${NC}"
    
    mkdir -p .spyk3_phish/{payloads,workspaces,scans,nikto_results,whatsapp_session,phishing_pages,reports,traffic_logs,phishing_templates,captured_credentials,ssh_keys,ssh_logs,time_history,wordlists}
    
    echo -e "${GREEN}✓ Directories created${NC}"
}

# Setup systemd service (Linux only)
setup_service() {
    if [[ "$OS" == "linux" ]]; then
        echo -e "${BLUE}⚙️ Setting up systemd service...${NC}"
        
        SERVICE_FILE="/etc/systemd/system/spyk3-phish.service"
        
        sudo bash -c "cat > $SERVICE_FILE << EOF
[Unit]
Description=SPYK3-PHISH Cybersecurity Tool
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)
Environment="PATH=$(pwd)/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=$(pwd)/venv/bin/python3 spyk3_phish.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"
        
        sudo systemctl daemon-reload
        echo -e "${GREEN}✓ Service file created${NC}"
        echo -e "${YELLOW}To enable service: sudo systemctl enable spyk3-phish${NC}"
        echo -e "${YELLOW}To start service: sudo systemctl start spyk3-phish${NC}"
    fi
}

# Create desktop entry
create_desktop_entry() {
    if [[ "$OS" == "linux" ]]; then
        echo -e "${BLUE}🖥️ Creating desktop entry...${NC}"
        
        DESKTOP_FILE="$HOME/.local/share/applications/spyk3-phish.desktop"
        
        mkdir -p "$HOME/.local/share/applications"
        
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=SPYK3-PHISH
Comment=Ultimate Cybersecurity & Phishing Command Center
Exec=$(pwd)/venv/bin/python3 $(pwd)/spyk3_phish.py
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Development;Security;
EOF
        
        chmod +x "$DESKTOP_FILE"
        echo -e "${GREEN}✓ Desktop entry created${NC}"
    fi
}

# Create wrapper script
create_wrapper() {
    echo -e "${BLUE}🔧 Creating wrapper script...${NC}"
    
    cat > spyk3 << 'EOF'
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/venv/bin/activate"
python3 "$DIR/spyk3_phish.py" "$@"
EOF
    
    chmod +x spyk3
    
    # Create symlink
    if [[ -d "$HOME/.local/bin" ]]; then
        ln -sf "$(pwd)/spyk3" "$HOME/.local/bin/spyk3"
        echo -e "${GREEN}✓ Wrapper script created (spyk3 command available)${NC}"
    fi
}

# Main installation
main() {
    detect_os
    check_python
    
    echo -e "\n${YELLOW}This script will install SPYK3-PHISH and its dependencies.${NC}"
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Installation cancelled${NC}"
        exit 1
    fi
    
    install_deps
    create_venv
    install_python_packages
    setup_directories
    setup_service
    create_desktop_entry
    create_wrapper
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          ✅ SPYK3-PHISH Installation Complete!              ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo -e "\n${BLUE}🚀 To run SPYK3-PHISH:${NC}"
    echo -e "   ${YELLOW}./spyk3${NC} or ${YELLOW}python3 spyk3_phish.py${NC}"
    echo -e "\n${BLUE}📖 Documentation:${NC}"
    echo -e "   Type ${YELLOW}help${NC} for command list"
    echo -e "   Type ${YELLOW}crunch_charset${NC} for CRUNCH character sets"
    echo -e "   Type ${YELLOW}traffic_help${NC} for traffic generation"
    echo -e "\n${BLUE}💡 Tip: Run with sudo for full functionality (raw sockets, firewall)${NC}"
}

# Run main
main "$@"