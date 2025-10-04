# Tasks: Machine-Readable Diff Analysis for XML Webservice Responses

**Input**: Design documents from `/specs/001-i-m-building/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
2. Load optional design documents: research.md, data-model.md, contracts/
3. Generate tasks by category: setup, tests, core, integration, polish
4. Apply task rules: TDD, parallelization, dependencies
5. Number tasks sequentially (T001, T002...)
6. Validate task completeness
7. Return: SUCCESS (tasks ready for execution)
```

## Phase 3.1: Setup
- [x] T001 Create project structure per implementation plan (src/, modules/, tests/)
- [x] T002 Initialize PowerShell 7.5.x environment and ensure Pester is available
- [x] T003 [P] Add README and initial documentation in specs/001-i-m-building/quickstart.md

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
- [x] T004 [P] Write contract test for Service-PoC endpoint in tests/contract/Contract.Tests.ps1
- [x] T005 [P] Write contract test for Service-NonPoC endpoint in tests/contract/Contract.Tests.ps1
- [x] T006 [P] Write unit tests for XML diff logic in tests/unit/XmlDiff.Tests.ps1
- [x] T007 [P] Write integration test for end-to-end diff scenario in tests/integration/EndToEnd.Tests.ps1
- [x] T008 [P] Write error scenario tests (service failure, invalid XML, identical responses) in tests/integration/EndToEnd.Tests.ps1

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [x] T009 Implement XML diff logic in src/modules/XmlDiff.psm1
- [x] T010 Implement utility functions in src/modules/Utils.psm1
- [x] T011 Implement main script for service calls and diff in src/diff-report.ps1

## Phase 3.4: Integration & Polish
- [x] T012 Add logging and error handling to src/diff-report.ps1 and modules
- [x] T013 Optimize performance for large XML payloads
- [x] T014 [P] Update documentation and usage examples in quickstart.md and README
- [x] T015 [P] Review code for Microsoft PowerShell 7.5.x best practices

## Parallel Execution Examples
- T003, T004, T005, T006, T007, T008 can be run in parallel ([P])
- T014, T015 can be run in parallel ([P])

## Dependency Notes
- Setup (T001-T003) must be completed before any tests or implementation
- All tests (T004-T008) must be written and fail before core implementation (T009-T011)
- Core implementation must be complete before integration/polish (T012-T015)

---

**Ready for execution.**
