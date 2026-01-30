# Changelog

All notable changes to the **TitanJS** local deployment and Docker environment will be documented in this file.

## [26.13.3] - 2026-01-30

### Fixed
- **Action Discovery & Registration**: Resolved "Action hello not found" errors in Dev Mode. The fix includes:
    - Ensuring the global `defineAction` wrapper is used in the bundler to correctly handle request lifecycle.
    - Synchronizing the bundler's source directory with the project's folder structure (`app/src/actions`).
- **Dev Mode Stability**: Fixed a race condition where `titan dev` could leave ghost server processes, causing port binding failures.
- **Template Fallback**: Improved action template loading to support both local (`./static/...`) and Docker (`./app/static/...`) path structures.

## [26.13.2] - 2026-01-30

### Fixed
- **Native Extension Segfault**: Resolved a critical issue where the server would crash (Exit 139) during asynchronous `drift()` calls. This was fixed by correctly binding the `TitanRuntime` pointer to the V8 isolate data slot 0, allowing native extensions to safely interact with the runtime.
- **HTTPS Support in Docker**: Added `ca-certificates` to the production Docker image. Previously, `t.fetch` calls to external APIs would fail due to missing root certificates in the minimal Debian image.
- **Port Mapping**: Corrected the `Dockerfile` to expose port `5100` (matching the application's default) instead of the generic `3000`.

### Added
- **Production-Ready Docker Environment**: 
    - Switched to `debian:stable-slim` for a smaller, faster production image.
    - Optimized build stages to reduce final image size and improve performance.
- **V8 Isolate Data Binding**: Implemented `TitanRuntime::bind_to_isolate()` to facilitate safe communication between Rust and native V8 extensions.

### Optimized
- **Dockerfile Build Performance**: Combined redundant `RUN` instructions and removed extensive debug logging during the extension extraction phase to keep deployment logs clean and concise.
- **Removed Debug Artifacts**: Cleaned up internal `println!` debug statements and temporary test logs in action files (`dtest.js`).

## [1.0.0] - 2026-01-30

### Initial Release
- Basic TitanJS support for local and Dockerized environments.
- Support for `drift()` asynchronous execution model.
- Native extension loading from `.ext` and `node_modules`.
