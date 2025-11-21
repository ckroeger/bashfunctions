# Bash Helper Functions

A collection of useful bash helper functions to streamline common tasks and improve productivity in shell scripting.

## Overview

This repository contains a curated set of bash functions designed to simplify everyday command-line operations. These utilities can be sourced into your shell environment or imported into your scripts.

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/bashfunctions.git

# Source the functions in your .bashrc or .zshrc
echo "source /path/to/bashfunctions/functions.sh" >> ~/.bashrc
source ~/.bashrc
```

## Available Functions

| Usable | Function Name | Description |
|--------|--------------|-------------|
|   ❌   | `mkcd` | Create a directory and immediately change into it |
|   ❌   | `extract` | Extract various archive formats (tar, zip, gz, etc.) |
|   ❌   | `backup` | Create a timestamped backup of a file or directory |
|   ❌   | `findtext` | Search for text within files recursively |
|   ❌   | `httpserver` | Start a simple HTTP server in the current directory |
|   ❌   | `gitclean` | Remove merged git branches locally |
|   ❌   | `weather` | Display weather information for a location |
|   ❌   | `sysinfo` | Show system information summary |
|   ✅   | `docker_age` | Show creation date and age of a Docker image (from Github Container Registry Mirror). Default tag is `latest` if not specified. |

## Usage

After sourcing the functions, simply call them by name:

```bash
mkcd new-project
extract archive.tar.gz
backup important-file.txt
```

## Example: Get Docker image age

```bash
# Get age of Ubuntu image (default tag: latest)
get_docker_image_age postgres
▶️ Trying to fetch age of postgres:latest...
   🔍 Fetching manifest list for postgres:latest ...
   ✅ Digest for amd64: sha256:babcdb287bd9087f2fa7e6d59b26f90922e3fd6a9d5d944b6a737eb360ad97b1
✨ The image postgres:latest was created at: 2025-11-18T04:57:50Z
📅 Age: 3 days

# Get age of Ubuntu image with specific tag
get_docker_image_age postgres 12
▶️ Trying to fetch age of postgres:12...
   🔍 Fetching manifest list for postgres:12 ...
   ✅ Digest for amd64: sha256:4bf4eb8e5932534db5fb9d3d91a212a91406aecf1fa626a60df4a9e2781d73ae
✨ The image postgres:12 was created at: 2024-11-21T20:05:42Z
📅 Age: 12 month(s) and 4 days
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use these functions in your own projects.