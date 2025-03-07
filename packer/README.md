# Packer Boilerplate

### How to run

```sh
packer init .
packer validate -var-file="secrets.pkrvars.hcl" proxmox-ubuntu-template.pkr.hcl
packer build -var-file="secrets.pkrvars.hcl" proxmox-ubuntu-template.pkr.hcl
```

### How to create a new template


