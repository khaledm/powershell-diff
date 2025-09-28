

# Implementation Plan: Machine-Readable Diff Analysis for XML Webservice Responses

**Branch**: `001-i-m-building` | **Date**: 2025-09-28 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-i-m-building/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from file system structure or context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Fill the Constitution Check section based on the content of the constitution document.
4. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
5. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
6. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, `GEMINI.md` for Gemini CLI, `QWEN.md` for Qwen Code or `AGENTS.md` for opencode).
7. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
8. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
9. STOP - Ready for /tasks command
```

**IMPORTANT**: The /plan command STOPS at step 7. Phases 2-4 are executed by other commands:
- Phase 2: /tasks command creates tasks.md
- Phase 3-4: Implementation execution (manual or via tools)


## Summary
This feature delivers a PowerShell 7.5.x script that sends a user-supplied XML request to two insurance quote web services (Service-PoC and Service-NonPoC), receives and validates their XML responses, and performs a machine-readable diff analysis. The diff report highlights all differences (including decimal/monetary/float values, which must be preserved exactly) and is presented in a human-readable HTML format. The script uses Microsoft best practices and modern PowerShell features.


## Technical Context
**Language/Version**: PowerShell 7.5.x  
**Primary Dependencies**: None (built-in PowerShell modules, System.Xml)  
**Storage**: N/A (in-memory processing)  
**Testing**: Pester (unit and integration tests)  
**Target Platform**: Windows, cross-platform PowerShell Core  
**Project Type**: Single script/CLI utility  
**Performance Goals**: Handle XML payloads up to 10MB with <2s diff time  
**Constraints**: Must preserve all decimal/monetary/float values exactly; must use provided service URIs; must use Microsoft best practices for PowerShell 7.5.x  
**Scale/Scope**: Single-user, local execution; extensible for future endpoints


## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- XML Response Integrity: No transformation of XML data before diff; schema validation required.
- Deterministic Diff Analysis: Same input yields same diff; output is machine-readable and versioned.
- Comprehensive Comparison: All XML structure, values, and order differences must be detected.
- Error Handling & Validation: All error types (HTTP, XML, schema, diff) must be handled and reported.
- Output Standards: HTML report required; machine-readable output for future automation; include metadata (timestamp, service URIs, request context).
- Quality Standards: Pester tests for core logic; integration tests for end-to-end; performance benchmarks for large XML; memory usage optimized.
- Development Workflow: Modular functions, parameter validation, error handling, documentation, code review, test coverage, performance analysis.

## Project Structure

### Documentation (this feature)
```
specs/[###-feature]/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->
```
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
ios/ or android/
directories captured above]

src/
├── diff-report.ps1         # Main PowerShell script
└── modules/
   ├── XmlDiff.psm1        # Diff logic module
   └── Utils.psm1          # Utility functions
tests/
├── unit/
│   └── XmlDiff.Tests.ps1   # Unit tests for diff logic
├── integration/
│   └── EndToEnd.Tests.ps1  # Integration tests for service calls and diff
└── contract/
   └── Contract.Tests.ps1  # Contract tests for XML structure/validation
```

**Structure Decision**: Single-project CLI utility with modular PowerShell code (src/ and modules/), plus Pester-based tests (tests/). All scripts and modules are designed for PowerShell 7.5.x and follow Microsoft best practices.


## Phase 0: Outline & Research
1. Research PowerShell 7.5.x XML handling, decimal/monetary value preservation, and HTTP best practices.
2. Research robust diff algorithms for XML in PowerShell (including open-source and Microsoft-recommended approaches).
3. Research Pester test patterns for PowerShell modules and CLI scripts.
4. Document all findings and decisions in research.md:
   - Decision: Use System.Xml for parsing; preserve all numeric values as strings for diff; use Invoke-RestMethod for HTTP; use Pester for tests.
   - Rationale: Ensures accuracy, reliability, and maintainability.
   - Alternatives: Considered third-party XML diff tools, but prioritized built-in and open-source PowerShell solutions for maintainability.

**Output**: research.md with all research and decisions.


## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. Extract entities from feature spec → data-model.md:
   - XML Request Payload: string (XML)
   - Service Response: string (XML), must preserve all numeric values as-is
   - Diff Report: HTML (human-readable), machine-readable (future)
   - Validation rules: XML schema validation, HTTP status check

2. Generate API contracts:
   - Service-PoC: POST http://localhost:7072/quotes/api/poc
   - Service-NonPoC: POST http://localhost:7072/quotes/api/non-poc
   - Request: XML payload; Response: XML (schema-validated)
   - Output OpenAPI-style contract to /contracts/

3. Generate contract tests:
   - Contract.Tests.ps1: Validate request/response structure, schema, and numeric value preservation

4. Extract test scenarios from user stories:
   - EndToEnd.Tests.ps1: Valid request → both services succeed → HTML diff report
   - Error scenarios: Service failure, invalid XML, identical responses

5. Update agent file incrementally:
   - Run `.specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot`

**Output**: data-model.md, /contracts/*, failing tests, quickstart.md, agent-specific file

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `.specify/templates/tasks-template.md` as base
- Generate tasks from Phase 1 design docs (contracts, data model, quickstart)
- Each contract → contract test task [P]
- Each entity → model creation task [P] 
- Each user story → integration test task
- Implementation tasks to make tests pass

**Ordering Strategy**:
- TDD order: Tests before implementation 
- Dependency order: Models before services before UI
- Mark [P] for parallel execution (independent files)

**Estimated Output**: 25-30 numbered, ordered tasks in tasks.md

**IMPORTANT**: This phase is executed by the /tasks command, NOT by /plan

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)  
**Phase 4**: Implementation (execute tasks.md following constitutional principles)  
**Phase 5**: Validation (run tests, execute quickstart.md, performance validation)


## Complexity Tracking
No constitution violations or complexity deviations identified. All requirements and constraints are justified and aligned with the project constitution.


## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [ ] Phase 0: Research complete (/plan command)
- [ ] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [ ] Initial Constitution Check: PASS
- [ ] Post-Design Constitution Check: PASS
- [ ] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*
