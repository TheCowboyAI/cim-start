<!-- Copyright (c) 2025 - Cowboy AI, LLC. -->

# CIM-Start Template Initialization

This file contains instructions for Claude Code to customize the CIM-Start template for the user's specific project during `claude init`.

## Project Customization Tasks

When a user runs `claude init` in their new repository (created from the CIM-Start template), perform these customization tasks:

### 1. Determine Project Information

Extract the following information from the current environment:
- **Current repository name**: Parse from `git remote get-url origin` or current directory name
- **Project name**: Convert repository name to appropriate formats (kebab-case, title-case, etc.)
- **User/organization**: Extract from git remote URL

### 2. Replace Template References

Update all references to "cim-start" with the actual project name:

**Primary files to update:**

1. **README.md**:
   - Line 19: Change `cim-start/` directory structure to `{project-name}/`
   - Any example paths or references to cim-start
   - Update project title and descriptions as appropriate

2. **CONTRIBUTING.md**:
   - Line 30: Update git clone URL to actual repository URL  
   - Line 31: Update directory name from `cim-start` to `{project-name}`

3. **doc/domain-collection-agent.md**:
   - Line 67: Update path `/path/to/cim-start` to `/path/to/{project-name}`

4. **scripts/test-domain-events.sh**:
   - Lines 65, 70, 95, 99, 122, 145, 170: Update test messages from "cim-start" to "{project-name}"
   - Update source identifiers from "cim-start-test" to "{project-name}-test"

5. **.claude/agents/cim-expert.md**:
   - Line 28: Update path reference from `/git/thecowboyai/cim-start/doc/` to current project path

**Additional files with "CIM-Start" references:**
- CLAUDE.md
- All documentation files in `/doc/` 
- Agent configuration files in `/agents/`
- GitHub workflow and issue templates in `.github/`
- SECURITY.md and other project files

**Note**: Focus on project-specific paths and identifiers. Preserve references to "CIM-Start" when referring to the framework/methodology itself.

### 3. Update Documentation Context

Replace template-specific language with project-specific language:

**In README.md:**
- Update the project description to reference the user's project name
- Update example repository names in clone instructions
- Replace "CIM-Start" references with the actual project name where appropriate

**In CLAUDE.md:**
- Update any hardcoded paths to match the new project structure
- Update project name references in development commands

### 4. Initialize NATS Configuration

If the project name affects NATS subject patterns:
- Update stream names to include project-specific prefixes
- Update subject algebra patterns to reflect the project name  
- Ensure environment configurations match the project context

### 5. Update Agent Context

Update the domain-expert agent to be aware of the current project:
- Update references to file paths in agent instructions
- Ensure schema paths and example formats point to correct locations
- Update any hardcoded project names in agent prompts

### 6. Environment-Specific Updates

Check and update any environment-specific configurations:
- Docker compose service names if they include "cim-start"
- Makefile targets that reference the project name
- Any configuration files with project-specific settings

### 7. Validation Steps

After making changes, verify:
- All file paths resolve correctly
- No broken references to "cim-start" remain
- Git remote URLs are correct
- Project-specific naming is consistent throughout

## Example Transformations

If the user creates a project called "my-ecommerce-cim":

```bash
# Before (template):
git clone https://github.com/thecowboyai/cim-start.git
cd cim-start

# After (customized):
git clone https://github.com/username/my-ecommerce-cim.git  
cd my-ecommerce-cim
```

```yaml
# Before (template):
source: "cim-start-test"

# After (customized):
source: "my-ecommerce-cim-test"
```

```markdown
# Before (template):
Reference specific documentation sections in /git/thecowboyai/cim-start/doc/

# After (customized):
Reference specific documentation sections in /path/to/my-ecommerce-cim/doc/
```

## Post-Initialization Message

After completing the customization, display this message to the user:

```
✅ CIM-Start template successfully customized for your project!

📋 What was updated:
- Project references changed from 'cim-start' to '{project-name}'
- File paths updated to match your repository
- Test scripts customized for your project
- Documentation references updated

🚀 Ready to start! Try:
  claude "@domain-expert Help me create my first domain"
  claude "@cim-expert Explain the Object Store architecture"

📖 Your agents have access to all CIM-Start documentation and are ready to guide you through domain creation.
```

## Notes for Claude Code

- Use the `git remote get-url origin` command to determine the actual repository URL
- Parse repository names carefully (handle both SSH and HTTPS git URLs)
- Preserve the mathematical and architectural content while updating project-specific references
- Ensure all agents continue to work properly after customization
- Maintain the integrity of the `.claude/agents/` directory structure