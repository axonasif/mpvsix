# mpvsix

Easily install any proprietary marketplace.visualstudio.com/ extension in third-party VSCODE clients.

## Examples

You can either use the full url or just the extension id/codename. Specify as many extensions you want.

> From your CLI in a live system

```bash
curl -sL https://git.io/mpvsix | bash -s -- \
  "GitHub.copilot" \
  "https://marketplace.visualstudio.com/items?itemName=WallabyJs.wallaby-vscode"

```

> With Dockerfile

```dockerfile
# ...

RUN curl -sL https://git.io/mpvsix-gp | bash -s -- \
      "GitHub.copilot" \
      "https://marketplace.visualstudio.com/items?itemName=WallabyJs.wallaby-vscode"
```