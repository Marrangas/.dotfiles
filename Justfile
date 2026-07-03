set shell := ["bash", "-c"]

# Show available tasks
default:
    @just --list

# Show currently active profile and exposed variables
info:
    #!/usr/bin/env python3
    import os

    def load_yaml(path):
        try:
            import yaml
            with open(path) as fh: return yaml.safe_load(fh) or {}
        except ImportError:
            data = {}
            in_profiles, current_profile = False, None
            if os.path.isfile(path):
                with open(path) as fh:
                    for line in fh:
                        raw = line.split('#')[0].strip()
                        if not raw: continue
                        indent = len(line) - len(line.lstrip())
                        if indent == 0: in_profiles, current_profile = False, None
                        if raw.endswith(':'):
                            k = raw[:-1].strip()
                            if k == 'profiles': in_profiles = True; data['profiles'] = {}
                            elif in_profiles: current_profile = k; data['profiles'][current_profile] = []
                        elif ':' in raw:
                            k, v = raw.split(':', 1)
                            data[k.strip()] = v.strip().strip('\"').strip("'")
                        elif raw.startswith('-') and in_profiles and current_profile:
                            data['profiles'][current_profile].append(raw[1:].strip().strip('\"').strip("'"))
            return data

    def load_secrets(path):
        secrets = {}
        if os.path.isfile(path):
            with open(path) as fh:
                for line in fh:
                    line = line.split('#')[0].strip()
                    if not line: continue
                    if line.startswith('export '): line = line[7:].strip()
                    if '=' in line:
                        k, v = line.split('=', 1)
                        secrets[k.strip()] = v.strip().strip('\"').strip("'")
        return secrets

    cfg = load_yaml('config.yml')
    local_cfg = load_yaml('local.yml') if os.path.isfile('local.yml') else {}
    cfg.update(local_cfg)

    profile = os.environ.get('DOTFILES_PROFILE') or cfg.get('profile', 'standard')
    packages = cfg.get('profiles', {}).get(profile, [])

    print(f'Active Profile:  {profile}')
    print(f'Exposed Theme:   {cfg.get("theme", "default")}')
    print(f'Exposed Font:    {cfg.get("font_family", "default")} (size: {cfg.get("font_size", "default")})')
    print('Packages to Link:')
    for pkg in packages:
        print(f'  - {pkg}')

    secrets = load_secrets('../.secrets')
    if secrets:
        print(f'Secrets detected (will be merged from ../.secrets): {list(secrets.keys())}')

# Link dotfiles for the active profile (or specific packages if passed)
link *packages:
    #!/usr/bin/env python3
    import os
    import sys
    import subprocess

    def load_yaml(path):
        try:
            import yaml
            with open(path) as fh: return yaml.safe_load(fh) or {}
        except ImportError:
            data = {}
            in_profiles, current_profile = False, None
            if os.path.isfile(path):
                with open(path) as fh:
                    for line in fh:
                        raw = line.split('#')[0].strip()
                        if not raw: continue
                        indent = len(line) - len(line.lstrip())
                        if indent == 0: in_profiles, current_profile = False, None
                        if raw.endswith(':'):
                            k = raw[:-1].strip()
                            if k == 'profiles': in_profiles = True; data['profiles'] = {}
                            elif in_profiles: current_profile = k; data['profiles'][current_profile] = []
                        elif ':' in raw:
                            k, v = raw.split(':', 1)
                            data[k.strip()] = v.strip().strip('\"').strip("'")
                        elif raw.startswith('-') and in_profiles and current_profile:
                            data['profiles'][current_profile].append(raw[1:].strip().strip('\"').strip("'"))
            return data

    def load_secrets(path):
        secrets = {}
        if os.path.isfile(path):
            with open(path) as fh:
                for line in fh:
                    line = line.split('#')[0].strip()
                    if not line: continue
                    if line.startswith('export '): line = line[7:].strip()
                    if '=' in line:
                        k, v = line.split('=', 1)
                        secrets[k.strip()] = v.strip().strip('\"').strip("'")
        return secrets

    cfg = load_yaml('config.yml')
    local_cfg = load_yaml('local.yml') if os.path.isfile('local.yml') else {}
    cfg.update(local_cfg)

    profile = os.environ.get('DOTFILES_PROFILE') or cfg.get('profile', 'standard')
    pkgs_to_link = sys.argv[1:] if len(sys.argv) > 1 else cfg.get('profiles', {}).get(profile, [])

    if not pkgs_to_link:
        print('Error: No packages to link.')
        sys.exit(1)

    # Write ~/.config/dotfiles/env
    env_path = os.path.expanduser('~/.config/dotfiles/env')
    print(f'Generating consolidated environment file: {env_path}')
    os.makedirs(os.path.dirname(env_path), exist_ok=True)
    with open(env_path, 'w') as fh:
        fh.write('# Generated by justfile link. Do not edit.\n')
        fh.write(f'export DOTFILES_PROFILE="{profile}"\n')
        for k, v in cfg.items():
            if k != 'profiles' and not isinstance(v, (dict, list)):
                fh.write(f'export DOTFILES_{k.upper()}="{v}"\n')
                
        secrets = load_secrets('../.secrets')
        if secrets:
            fh.write('\n# Secrets merged from ../.secrets\n')
            for k, v in secrets.items():
                fh.write(f'export {k}="{v}"\n')

    print(f'Stowing packages: {" ".join(pkgs_to_link)}')
    subprocess.run(['stow', '--target', os.path.expanduser('~'), '--dotfiles', '--verbose', '1'] + pkgs_to_link)

# Unlink dotfiles for the active profile (or specific packages if passed)
unlink *packages:
    #!/usr/bin/env python3
    import os
    import sys
    import subprocess

    def load_yaml(path):
        try:
            import yaml
            with open(path) as fh: return yaml.safe_load(fh) or {}
        except ImportError:
            data = {}
            in_profiles, current_profile = False, None
            if os.path.isfile(path):
                with open(path) as fh:
                    for line in fh:
                        raw = line.split('#')[0].strip()
                        if not raw: continue
                        indent = len(line) - len(line.lstrip())
                        if indent == 0: in_profiles, current_profile = False, None
                        if raw.endswith(':'):
                            k = raw[:-1].strip()
                            if k == 'profiles': in_profiles = True; data['profiles'] = {}
                            elif in_profiles: current_profile = k; data['profiles'][current_profile] = []
                        elif ':' in raw:
                            k, v = raw.split(':', 1)
                            data[k.strip()] = v.strip().strip('\"').strip("'")
                        elif raw.startswith('-') and in_profiles and current_profile:
                            data['profiles'][current_profile].append(raw[1:].strip().strip('\"').strip("'"))
            return data

    cfg = load_yaml('config.yml')
    local_cfg = load_yaml('local.yml') if os.path.isfile('local.yml') else {}
    cfg.update(local_cfg)

    profile = os.environ.get('DOTFILES_PROFILE') or cfg.get('profile', 'standard')
    pkgs_to_unlink = sys.argv[1:] if len(sys.argv) > 1 else cfg.get('profiles', {}).get(profile, [])

    if not pkgs_to_unlink:
        print('Error: No packages to unlink.')
        sys.exit(1)

    print(f'Unstowing packages: {" ".join(pkgs_to_unlink)}')
    subprocess.run(['stow', '-D', '--target', os.path.expanduser('~'), '--dotfiles', '--verbose', '1'] + pkgs_to_unlink)

# Configure Git sparse-checkout for the active profile
sparse:
    #!/usr/bin/env python3
    import os
    import subprocess

    def load_yaml(path):
        try:
            import yaml
            with open(path) as fh: return yaml.safe_load(fh) or {}
        except ImportError:
            data = {}
            in_profiles, current_profile = False, None
            if os.path.isfile(path):
                with open(path) as fh:
                    for line in fh:
                        raw = line.split('#')[0].strip()
                        if not raw: continue
                        indent = len(line) - len(line.lstrip())
                        if indent == 0: in_profiles, current_profile = False, None
                        if raw.endswith(':'):
                            k = raw[:-1].strip()
                            if k == 'profiles': in_profiles = True; data['profiles'] = {}
                            elif in_profiles: current_profile = k; data['profiles'][current_profile] = []
                        elif ':' in raw:
                            k, v = raw.split(':', 1)
                            data[k.strip()] = v.strip().strip('\"').strip("'")
                        elif raw.startswith('-') and in_profiles and current_profile:
                            data['profiles'][current_profile].append(raw[1:].strip().strip('\"').strip("'"))
            return data

    cfg = load_yaml('config.yml')
    local_cfg = load_yaml('local.yml') if os.path.isfile('local.yml') else {}
    cfg.update(local_cfg)

    profile = os.environ.get('DOTFILES_PROFILE') or cfg.get('profile', 'standard')
    pkgs = cfg.get('profiles', {}).get(profile, [])

    required_paths = ['Justfile', 'README.md', 'LICENSE.md', '.gitignore', '.stow-local-ignore', '.githooks/', 'scripts/', 'config.yml', 'ansible/']
    sparse_paths = required_paths + [f'{pkg}/' for pkg in pkgs]

    print(f'Configuring Git sparse-checkout for profile {profile}...')
    # check if sparse checkout already enabled
    res = subprocess.run(['git', 'sparse-checkout', 'list'], capture_output=True, text=True)
    if res.returncode != 0:
        subprocess.run(['git', 'sparse-checkout', 'init', '--cone'])
    subprocess.run(['git', 'sparse-checkout', 'set'] + sparse_paths)

# Set up git configuration and download plugins
config:
    #!/usr/bin/env python3
    import os
    import subprocess

    # Set up git configurations and hooks
    subprocess.run(['git', 'config', 'core.hooksPath', '.githooks'])

    # Chmod scripts
    try:
        subprocess.run('chmod +x .githooks/pre-commit scripts/.local/bin/helpers/*', shell=True, stderr=subprocess.DEVNULL)
    except Exception:
        pass

    def load_yaml(path):
        try:
            import yaml
            with open(path) as fh: return yaml.safe_load(fh) or {}
        except ImportError:
            data = {}
            in_profiles, current_profile = False, None
            if os.path.isfile(path):
                with open(path) as fh:
                    for line in fh:
                        raw = line.split('#')[0].strip()
                        if not raw: continue
                        indent = len(line) - len(line.lstrip())
                        if indent == 0: in_profiles, current_profile = False, None
                        if raw.endswith(':'):
                            k = raw[:-1].strip()
                            if k == 'profiles': in_profiles = True; data['profiles'] = {}
                            elif in_profiles: current_profile = k; data['profiles'][current_profile] = []
                        elif ':' in raw:
                            k, v = raw.split(':', 1)
                            data[k.strip()] = v.strip().strip('\"').strip("'")
                        elif raw.startswith('-') and in_profiles and current_profile:
                            data['profiles'][current_profile].append(raw[1:].strip().strip('\"').strip("'"))
            return data

    cfg = load_yaml('config.yml')
    local_cfg = load_yaml('local.yml') if os.path.isfile('local.yml') else {}
    cfg.update(local_cfg)

    profile = os.environ.get('DOTFILES_PROFILE') or cfg.get('profile', 'standard')
    pkgs = cfg.get('profiles', {}).get(profile, [])

    if 'tmux' in pkgs:
        print('Initializing Tmux Plugin Manager (TPM)...')
        subprocess.run(['scripts/.local/bin/helpers/manage_plugin.sh', 'TPM', 'https://github.com/tmux-plugins/tpm', os.path.expanduser('~/.config/tmux/plugins/tpm')])
    if 'zsh' in pkgs:
        print('Initializing Zsh plugins...')
        os.makedirs(os.path.expanduser('~/.config/zsh'), exist_ok=True)
        subprocess.run(['scripts/.local/bin/helpers/manage_plugin.sh', 'zsh-autosuggestions', 'https://github.com/zsh-users/zsh-autosuggestions', os.path.expanduser('~/.config/zsh/zsh-autosuggestions')])
        subprocess.run(['scripts/.local/bin/helpers/manage_plugin.sh', 'zsh-syntax-highlighting', 'https://github.com/zsh-users/zsh-syntax-highlighting', os.path.expanduser('~/.config/zsh/zsh-syntax-highlighting')])
        subprocess.run(['scripts/.local/bin/helpers/manage_plugin.sh', 'zsh-transient-prompt', 'https://github.com/olets/zsh-transient-prompt', os.path.expanduser('~/.config/zsh/zsh-transient-prompt'), 'v1'])

# Build and run the dotfiles deployment in a clean, isolated Docker test container
test-env:
    @docker build -f ansible/Dockerfile -t dotfiles-ansible-test .
    @docker run -it --rm dotfiles-ansible-test
