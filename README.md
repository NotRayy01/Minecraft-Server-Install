# ⚡ Ray Industries - Minecraft Server Installer

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Minecraft](https://img.shields.io/badge/Game-Minecraft-success?style=for-the-badge&logo=minecraft)

A powerful, automated CLI tool designed to deploy, manage, and tunnel Minecraft Java servers on Linux. Built for speed and ease of use. 

**Powered by: [Ray Industries](https://notray.fun)**

## ✨ Features

* **☕ Auto-Dependency Check:** Automatically installs Java (OpenJDK 21), jq, and other requirements.
* **📂 Smart Organization:** Creates isolated folders for every server instance.
* **🚀 Immediate Start:** Downloads the server jar and starts it immediately (with EULA auto-handling).
* **📜 PaperMC API:** Fetches the absolute latest builds of PaperMC dynamically.
* **🌐 Playit.gg Integration:** One-click installation of Playit.gg for port forwarding.
* **🔄 Multi-Server Manager:** Detects existing server folders and lets you start them via a simple menu.

## 🛠️ Installation

Run the following command in your terminal. This will launch the Minecraft Server Installer immediately without downloading files manually.

```bash
bash <(curl -sL [https://raw.githubusercontent.com/YOUR_USERNAME/Ray-Server-Manager/main/ray_manager.sh](https://raw.githubusercontent.com/YOUR_USERNAME/Ray-Server-Manager/main/ray_manager.sh))
