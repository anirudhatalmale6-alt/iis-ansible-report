# IIS Website & Binding Report — Ansible Playbook

Ansible playbook that connects to multiple Windows/IIS servers, collects website and binding details, and generates a consolidated CSV report.

## What It Collects

| Field | Description |
|-------|-------------|
| Server | Windows hostname |
| Server IPs | All IPv4 addresses on the server |
| Site Name | IIS website name |
| Site ID | IIS site identifier |
| Status | Started / Stopped |
| Protocol | http / https |
| Binding IP | Bound IP or "All Unassigned" |
| Port | Listening port (80, 443, etc.) |
| Host Header | Host header value |
| Physical Path | Website root directory |

## Prerequisites

1. **Ansible control node** (Linux/macOS) with Python 3.8+
2. **ansible.windows collection**:
   ```bash
   ansible-galaxy collection install ansible.windows
   ```
3. **pywinrm** on the control node:
   ```bash
   pip install pywinrm
   ```
4. **WinRM** enabled on target Windows servers:
   ```powershell
   # Run on each Windows server (Admin PowerShell):
   winrm quickconfig -force
   Enable-PSRemoting -Force
   ```
5. **IIS** installed on target servers

## Quick Start

1. **Edit `inventory.yml`** — add your server IPs/hostnames and credentials:
   ```yaml
   hosts:
     web-server-01:
       ansible_host: 10.0.0.50
     web-server-02:
       ansible_host: 10.0.0.51
   vars:
     ansible_user: administrator
     ansible_password: YourPassword
   ```

2. **Run the playbook**:
   ```bash
   ansible-playbook -i inventory.yml iis_report.yml
   ```

3. **Check the output** — a timestamped CSV file is created:
   ```
   iis_report_20260310_143022.csv
   ```

## Securing Credentials

Use Ansible Vault instead of plaintext passwords:

```bash
# Encrypt the inventory file
ansible-vault encrypt inventory.yml

# Run with vault prompt
ansible-playbook -i inventory.yml iis_report.yml --ask-vault-pass
```

Or use a vault-encrypted variable file:

```bash
# Create encrypted vars file
ansible-vault create group_vars/iis_servers/vault.yml
# Add: vault_ansible_password: YourSecurePassword

# Reference in inventory.yml:
# ansible_password: "{{ vault_ansible_password }}"
```

## Sample CSV Output

```csv
Server,Server IPs,Site Name,Site ID,Status,Protocol,Binding IP,Port,Host Header,Physical Path
WEB-01,10.0.0.50;10.0.0.51,Default Web Site,1,Started,http,All Unassigned,80,,C:\inetpub\wwwroot
WEB-01,10.0.0.50;10.0.0.51,Default Web Site,1,Started,https,All Unassigned,443,,C:\inetpub\wwwroot
WEB-01,10.0.0.50;10.0.0.51,MyApp,2,Started,https,10.0.0.50,443,myapp.example.com,D:\WebApps\MyApp
WEB-02,10.0.1.20,Intranet,1,Started,http,All Unassigned,8080,,C:\inetpub\intranet
```

## Customization

- **Add/remove CSV columns**: Edit the `host_rows` set_fact task in the playbook and the `csv_headers` variable
- **Filter by site status**: Add a `when: site.State == 'Started'` condition
- **Email the report**: Add a `community.general.mail` task at the end
- **Change output path**: Modify the `report_file` variable
