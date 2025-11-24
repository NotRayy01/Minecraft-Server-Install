#!/bin/bash

# ==============================================================================
# RAY INDUSTRIES - SERVER MANAGER
# Author: Ray
# Version: 1.0 
# ==============================================================================

# --- Colors & Styling ---
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# --- Utility Functions ---

animate_text() {
    text="$1"
    delay="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo ""
}

print_header() {
    clear
    echo -e "${RED}${BOLD}"
    echo "  RRRRRRR    AAAAA   YY     YY "
    echo "  RR    RR  AA   AA   YY   YY  "
    echo "  RRRRRRR   AAAAAAA    YYYYY   "
    echo "  RR  RR    AA   AA     YYY    "
    echo "  RR   RR   AA   AA     YYY    "
    echo -e "${NC}"
    echo -e "${CYAN}      Powered by: Ray Industries${NC}"
    echo -e "${BLUE} ========================================${NC}"
    echo ""
}

check_deps() {
    echo -e "${YELLOW}[!] Checking dependencies...${NC}"
    if ! command -v jq &> /dev/null || ! command -v gpg &> /dev/null; then
        echo -e "${YELLOW}Installing missing tools (jq, curl, gpg)...${NC}"
        sudo apt-get update && sudo apt-get install -y jq curl gnupg
    fi

    if type -p java > /dev/null; then
        return
    else
        echo -e "${RED}[X] Java is NOT installed.${NC}"
        echo -e "${WHITE}Installing OpenJDK 21 (Recommended for 1.21+)...${NC}"
        sudo apt-get update && sudo apt-get install -y openjdk-21-jre-headless
    fi
}

# --- Main Logic Blocks ---

setup_java_server() {
    print_header
    echo -e "${MAGENTA}--- CREATE NEW JAVA SERVER ---${NC}"
    
    echo -n "Enter New Server Name (No spaces): "
    read server_name
    folder_name=${server_name// /_}

    echo -e "${CYAN}Creating folder [${folder_name}]...${NC}"
    if [ ! -d "$folder_name" ]; then mkdir -p "$folder_name"; fi
    cd "$folder_name" || return

    echo ""
    echo "Select Software:"
    echo "1) Paper (Recommended)"
    echo "2) Vanilla"
    echo -n "Selection: "
    read software_choice

    if [ "$software_choice" == "1" ]; then
        echo -e "${CYAN}Fetching versions...${NC}"
        versions=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-5:] | .[]') 
        echo -e "${YELLOW}Recent Versions: ${versions}${NC}"
        echo -n "Enter version (e.g. 1.21.1): "
        read mc_version

        latest_build=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds" | jq -r '.builds[-1].build')
        jar_name="paper-${mc_version}-${latest_build}.jar"
        download_url="https://api.papermc.io/v2/projects/paper/versions/$mc_version/builds/$latest_build/downloads/$jar_name"

        echo -e "${GREEN}Downloading...${NC}"
        curl -o server.jar "$download_url"
    elif [ "$software_choice" == "2" ]; then
        echo -n "Paste Vanilla server.jar URL: "
        read vanilla_url
        if [ ! -z "$vanilla_url" ]; then curl -o server.jar "$vanilla_url"; fi
    fi

    # IMMEDIATE START LOGIC
    echo ""
    echo -e "${RED}WARNING: You must accept the Minecraft EULA to run the server.${NC}"
    echo -n "Do you accept the EULA? (y/n): "
    read eula_ans

    if [[ "$eula_ans" == "y" || "$eula_ans" == "Y" ]]; then
        echo "eula=true" > eula.txt
        echo -e "${GREEN}EULA accepted. Starting Server...${NC}"
        echo -e "${CYAN}Press Ctrl+C to stop the server later.${NC}"
        sleep 2
        # Start Server with 2GB RAM
        java -Xmx2G -Xms2G -jar server.jar nogui
    else
        echo -e "${RED}EULA declined. Server created but not started.${NC}"
    fi

    cd ..
    read -p "Press Enter to return to menu..."
}

start_existing_server() {
    print_header
    echo -e "${MAGENTA}--- START EXISTING SERVER ---${NC}"
    echo -e "${CYAN}Scanning directories...${NC}"
    echo ""

    dirs=(*/)
    if [ ! -d "${dirs[0]}" ]; then
        echo -e "${RED}No server folders found.${NC}"
        read -p "Press Enter..."
        return
    fi

    count=0
    for dir in "${dirs[@]}"; do
        count=$((count+1))
        clean_name=${dir%/}
        echo -e "${YELLOW}$count)${NC} $clean_name"
    done

    echo ""
    echo -n "Select Server ID to start: "
    read server_id

    if [[ "$server_id" -gt 0 && "$server_id" -le "$count" ]]; then
        index=$((server_id-1))
        target_dir="${dirs[$index]}"
        
        echo -e "${GREEN}Entering ${target_dir}...${NC}"
        cd "$target_dir" || return

        if [ -f "server.jar" ]; then
            echo -e "${MAGENTA}Detected Java Server.${NC}"
            echo -e "${CYAN}Starting... (Press Ctrl+C to stop)${NC}"
            sleep 1
            if [ ! -f "eula.txt" ]; then echo "eula=true" > eula.txt; fi
            java -Xmx2G -Xms2G -jar server.jar nogui
        elif [ -f "bedrock_server" ]; then
            echo -e "${MAGENTA}Detected Bedrock Server.${NC}"
            echo -e "${CYAN}Starting... (Press Ctrl+C to stop)${NC}"
            export LD_LIBRARY_PATH=.
            ./bedrock_server
        else
            echo -e "${RED}[Error] No 'server.jar' or 'bedrock_server' found.${NC}"
        fi
        
        cd ..
    else
        echo -e "${RED}Invalid ID.${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

setup_playit() {
    print_header
    echo -e "${MAGENTA}--- PLAYIT.GG INSTALLATION (APT) ---${NC}"

    if command -v playit &> /dev/null; then
        echo -e "${GREEN}Playit is already installed!${NC}"
    else
        echo -e "${CYAN}Adding Playit GPG Key...${NC}"
        curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null
        
        echo -e "${CYAN}Adding Repository...${NC}"
        echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | sudo tee /etc/apt/sources.list.d/playit-cloud.list
        
        echo -e "${YELLOW}Updating APT and Installing Playit...${NC}"
        sudo apt update
        sudo apt install -y playit
        
        echo -e "${GREEN}Installation Complete!${NC}"
    fi

    echo ""
    echo -n "Do you want to run playit now? (y/n): "
    read run_p
    if [[ "$run_p" == "y" || "$run_p" == "Y" ]]; then
        playit
    fi
    
    read -p "Press Enter to return to menu..."
}

# --- Main Loop ---

clear
echo -e "${RED}${BOLD}"
animate_text "Loading Ray Industries Protocol v1.0..." 0.05
check_deps

while true; do
    print_header
    echo -e "${WHITE}Select an option:${NC}"
    echo -e "${GREEN}1)${NC} Create Java Server"
    echo -e "${CYAN}2)${NC} Start Existing Server"
    echo -e "${GREEN}3)${NC} Playit (Download & Run)"
    echo -e "${RED}4)${NC} Exit"
    echo ""
    echo -n "root@ray-industries:~# "
    read choice

    case $choice in
        1) setup_java_server ;;
        2) start_existing_server ;;
        3) setup_playit ;;
        4) echo -e "${CYAN}Goodbye, Ray.${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid.${NC}"; sleep 1 ;;
    esac
done
