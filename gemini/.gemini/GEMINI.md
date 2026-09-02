# User Preferences

## Terraform Commands

When running verbose or high-output Terraform commands (such as `terraform apply` or `terraform plan`), always filter out noisy state refreshing and reading messages to keep the session history clean and relevant.

Use the following pattern:
`terraform apply 2>&1 | grep --line-buffered -v -E "Refreshing state|Reading\.\.\.|Read complete"`
