# justfile — common dotfiles tasks. Run `just` (or `just --list`) to see them.
# just is a command runner (like make, but simpler): https://github.com/casey/just

# show available recipes
default:
    @just --list

# symlink all configs into ~/.config and ~ (backs up anything existing)
install:
    ./install.sh

# install / update everything from the Brewfile
brew:
    brew bundle --file=Brewfile

# pull latest, re-link, update Homebrew + fish plugins
update:
    git pull --rebase
    ./install.sh
    brew bundle --file=Brewfile
    fish -c 'fisher update'

# lint shell scripts + Lua + claude/ frontmatter (same checks CI runs)
lint:
    shellcheck bootstrap.sh install.sh bin/claude git/hooks/pre-commit macos/defaults.sh sonarqube/setup-mcp.sh x/setup-mcp.sh claude/install-templates.sh claude/install-plumbline.sh claude/validate-frontmatter.sh
    stylua --check nvim/lua
    ./claude/validate-frontmatter.sh

# install the community Claude Code agents/skills (aitmpl.com)
claude-templates:
    ./claude/install-templates.sh

# install/update my Plumbline design-review plugin (Claude Code + Grok)
plumbline:
    ./claude/install-plumbline.sh

# auto-format Lua
fmt:
    stylua nvim/lua

# apply macOS system defaults
macos:
    ./macos/defaults.sh

# start the local SonarQube server + wire the Claude Code MCP bridge
sonar:
    docker compose -f sonarqube/docker-compose.yml up -d
    ./sonarqube/setup-mcp.sh

# register X's official MCP servers with Claude Code (docs + api)
x:
    ./x/setup-mcp.sh

# catch up the whole AI layer in one go: community templates, Plumbline, and
# the SonarQube/X MCPs. Not folded into `update` — sonar starts Docker and x
# can need an API key, neither of which should fire unattended.
ai-sync: claude-templates plumbline sonar x
    @echo "✓ AI layer synced"
