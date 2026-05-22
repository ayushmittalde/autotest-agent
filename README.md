# Artifact folder for the Research Project FA 3910 A Proof-of-Concept for LLM-Assisted Generation of API Integration Tests for Interfaces in Software-Defined Systems

This folder stores project artifacts for planning, representations, prompts, setup scripts, and test exploration work.

## Top-level contents

### Experiment-1
- `plan/`: markdown plans for agent-blocks, create-basic-agent, and delete-agent representations.
- `representation/`: markdown representation documents for the same three features.
- `testscases/`: feature test folders.
- `testscases/feature_agent_blocks/`: `agent-blocks-core.spec.ts`, `coverage-report.md`.
- `testscases/feature_create_basic_agent/`: `create-basic-agent.spec.ts`, `coverage-report.md`.
- `testscases/feature_delete_agent/`: empty folder.

### Experiment-2
- `Claudesonnet/`: delete-agent representation files, test folder, and reference notes.
- `codex/`: delete-agent decision and structured representation files, execution report, test folder, and reference notes.
- `opus4.6/`: delete-agent representation and execution report, plus plan, test, and reference folders.

### Installer
- `setup-all.bat`
- `setup-autogpt-runtime.bat`
- `setup-testing-repo.bat`

### Prompts
- `dec_to_rep.prompt.md`
- `doc_to_dec.prompt.md`
- `rep_to_testv4.prompt.md`
- `test_exec_report_gen.prompt.md`

### Test Explore
- `autogpt_agent_testcodegen/`: test-generation workspace with AutoGPT source, docs, resources, Playwright config, TypeScript config, and npm package files.
- `autogpt_codebase_rp/`: AutoGPT codebase snapshot with repository metadata, policies, assets, and `autogpt_platform/` source.

### Sample Interaction Log
- `rep_to_test.md`: sample interaction log for the representation-to-test generation process with gpt-5.1-codex-max LLM Model. 

Author: Ayush Mittal