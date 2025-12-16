# Preventing Secret Commits

This repository includes a configuration for `pre-commit` to help prevent accidental commits of sensitive information (secrets, keys, tokens, etc.).

## Setup

1.  **Install `pre-commit`**:
    ```bash
    pip install pre-commit
    ```
    or
    ```bash
    brew install pre-commit
    ```

2.  **Install the git hook**:
    Run the following command in the root of the repository:
    ```bash
    pre-commit install
    ```

Now, `pre-commit` will run automatically on `git commit`.

## Tools Configured

### detect-secrets
[detect-secrets](https://github.com/Yelp/detect-secrets) is an enterprise-friendly way of identifying potential secrets in code.

To generate a baseline (whitelist existing false positives):
```bash
detect-secrets scan > .secrets.baseline
```

### gitleaks
[gitleaks](https://github.com/gitleaks/gitleaks) is a SAST tool for detecting hardcoded secrets like passwords, api keys, and tokens in git repos.

## Other Alternatives

- **git-secrets**: Prevents you from committing secrets and credentials into your git repositories. [Link](https://github.com/awslabs/git-secrets)
- **TruffleHog**: Searches through git repositories for secrets, digging deep into commit history. [Link](https://github.com/trufflesecurity/trufflehog)
