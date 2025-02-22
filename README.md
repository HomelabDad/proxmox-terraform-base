<p align="center">
  <img src="assets/banner.png" alt="Homelab Automation Banner" width="600">
</p>

# Homelab Automation Base
```
 _    _                      _       _     
| |  | |                    | |     | |    
| |__| | ___  _ __ ___   ___| | __ _| |__  
|  __  |/ _ \| '_ ` _ \ / _ \ |/ _` | '_ \ 
| |  | | (_) | | | | | |  __/ | (_| | |_) |
|_|  |_|\___/|_| |_| |_|\___|_|\__,_|_.__/ 
    _         _                        _   _             
   / \  _   _| |_ ___  _ __ ___   __ _| |_(_) ___  _ __  
  / _ \| | | | __/ _ \| '_ ` _ \ / _` | __| |/ _ \| '_ \ 
 / ___ \ |_| | || (_) | | | | | | (_| | |_| | (_) | | | |
/_/   \_\__,_|\__\___/|_| |_| |_|\__,_|\__|_|\___/|_| |_|
```

## Overview
This repository serves as a foundation for automating various aspects of my homelab infrastructure. It provides boilerplate configurations and templates for different infrastructure-as-code tools, making it easier to manage and deploy services in a home lab environment.

## Repository Structure
- `/terraform` - Templates and configurations for Proxmox VM deployments
- _(future directories for other automation tools)_

## Getting Started
Each directory contains its own README with specific setup instructions and requirements for that automation tool.

### Current Features
- Proxmox VM automation using Terraform
  - Automated Ubuntu VM deployments
  - Cloud-init integration
  - Customizable VM specifications

### Prerequisites
- Proxmox hypervisor
- Basic understanding of infrastructure-as-code concepts
- Required credentials for your homelab environment

## Usage
Clone the repository and navigate to the specific tool's directory you want to use and follow the README instructions there:
```sh
git clone https://github.com/HomelabDad/proxmox-terraform-base.git
cd terraform/
# Follow terraform-specific README instructions
```

## Contributing
Feel free to submit issues and enhancement requests!

## Author
Jared Wilson

## License
_(Add your preferred license)_
