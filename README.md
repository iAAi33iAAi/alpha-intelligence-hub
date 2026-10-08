# Alpha Intelligence Hub

**Repository consolidation and integration scaffold**

## Current repository state

The live repository contains init-hub.sh, docker-compose.yml, Makefile, requirements.txt, constitution material, and license material.

The Docker Compose file references directories such as ai/openclaw, platform, blockchain/world-tribe, and core/safety-kernel. Those directories are created or populated by the consolidation process; they are not all present in the current repository tree.

## What this repository is

Alpha Intelligence Hub is a planned aggregation layer for multiple repositories, including OpenClaw, Safety Kernel, Undermoon/AETHEL Grid, World-Tribe Protocol, ALEXARAC, and project-mono.

init-hub.sh is intended to assemble those components into the target monorepo layout.

## Deployment status

The current repository is not evidence of a completed production monorepo.

The Compose topology describes target integrations such as an OpenClaw gateway, treasury service, World-Tribe dashboard, Safety Kernel service, AETHEL validator, ALEXARAC UI, and platform dashboard.

Those services should be considered target integrations until the assembled tree has been created and independently built/tested.

## Recommended use

Treat this repository as the integration blueprint and migration scaffold.

Before claiming a service is production-ready, verify that the referenced source tree exists, the service builds from the current commit, tests pass in CI, deployment controls are configured, and cross-repository interfaces are validated.

## License

See LICENSE.