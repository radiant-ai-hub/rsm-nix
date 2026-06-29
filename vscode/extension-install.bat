Invoke-WebRequest -Uri https://raw.githubusercontent.com/radiant-ai-hub/rsm-nix/main/vscode/extensions.txt -OutFile extensions.txt;
cat extensions.txt |% { code --install-extension $_ --force};
del extensions.txt;
