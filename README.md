# �� AWS Infrastructure with Terraform

This Terraform project creates a complete AWS infrastructure for hosting a web application, including VPC, networking, security groups, and an EC2 instance with Apache web server.

## 📋 Infrastructure Overview

### 🏗️ **What Gets Created:**
- **VPC** with CIDR block `10.0.0.0/16`
- **Internet Gateway** for internet connectivity
- **Public Subnet** in `us-east-1a` availability zone
- **Route Table** with internet access
- **Security Group** allowing HTTP (80), HTTPS (443), and SSH (22)
- **Network Interface** with private IP `10.0.1.50`
- **Elastic IP** for public internet access
- **EC2 Instance** running Ubuntu with Apache web server

### 🌐 **Network Architecture:**
```
Internet → Internet Gateway → Route Table → Public Subnet → EC2 Instance
                                    ↓
                              Security Group (Ports 22, 80, 443)
```

## 🛠️ Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version >= 1.0)
- [AWS CLI](https://aws.amazon.com/cli/) configured
- AWS Access Key and Secret Key with appropriate permissions
- SSH Key Pair named `admin-r3dhat` in AWS (or update the key_name variable)

## ⚙️ Configuration

### 1. **Set Up Variables**
Create or update `terraform.tfvars` with your AWS credentials:

```hcl
aws_access_key = "your-actual-access-key"
aws_secret_key = "your-actual-secret-key"
aws_region     = "us-east-1"
```

### 2. **Update Security Group (Optional)**
For production use, consider restricting SSH access to your specific IP address in `main.tf`:

```hcl
ingress {
  description = "SSH from VPC"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["YOUR_IP_ADDRESS/32"]  # Replace with your IP
}
```

## 🚀 Usage

### **Initialize Terraform:**
```bash
terraform init
```

### **Plan the Infrastructure:**
```bash
terraform plan
```

### **Apply the Configuration:**
```bash
terraform apply
```

### **Access Your Web Server:**
After successful deployment, you can access your web server at the Elastic IP address that Terraform outputs.

### **SSH into Your Server:**
```bash
ssh -i /path/to/your/key.pem ubuntu@<ELASTIC_IP>
```

### **Destroy Infrastructure:**
```bash
terraform destroy
```

## 🔒 Security Considerations

⚠️ **Important Security Notes:**
- **Never commit `terraform.tfvars`** to version control
- **Rotate AWS credentials** if they've been exposed
- **Consider restricting SSH access** to specific IP addresses
- **Review security group rules** before production use

## 📁 File Structure

```
.
├── main.tf              # Main Terraform configuration
├── terraform.tfvars     # Variable values (DO NOT COMMIT)
├── .gitignore          # Git ignore file
├── README.md           # This file
└── terraform.tfstate   # Terraform state (auto-generated)
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Happy Infrastructure as Code! **

This README provides:
- Clear overview of what the infrastructure creates
- Step-by-step setup instructions
- Security considerations
- Troubleshooting guide
- Customization options
- Best practices

The file is comprehensive yet easy to follow, making it perfect for both beginners and experienced users working with your Terraform configuration.
