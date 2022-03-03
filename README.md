This repository contains the necessary code for building Onezone packages.
Onezone is part of [Onedata](http://onedata.org) - the global data management system.

## Submodules

The following submodules are used in the repository:



| Submodule | URL      | Description |
|----------------------|---------------------|-------------------------|
| **Bamboo scripts** | https://github.com/onedata/bamboos | Bamboos contains common scripts used in Continuous Integration processes that use the Bamboo platform. |
| **Cluster Manager** | https://github.com/onedata/cluster-manager | Common Onedata component shared between Onezone and Oneprovider, which monitors and controls Onedata worker processes at site level. |
| **Onezone worker** | https://github.com/onedata/oz-worker | Main Onezone functional component, based on the **Cluster Worker** framework. |
| **Onepanel** | https://github.com/onedata/onepanel | The Web GUI component |

In order to initialize all submodules please use:
```bash
make submodules
```
instead of directly invoking Git `submodule` commands.

## Building

In order to build onezone packages and docker images invoke:

```bash
make
```

The building is done in docker containers. The builders docker images are available at [Docker Hub](https://hub.docker.com/u/onedata/). 
The build process itself is fully based on Docker containers, so no other prerequisites other than Docker should be necessary. In case of problems with Docker cache, please set `NO_CACHE=1` environment variable.

## Support

Please use [GitHub issues](https://github.com/onedata/onedata/issues) mechanism as the main channel for reporting bugs and requesting support or new features.

## Copyright and license

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Acknowledgements
This work was supported in part by 2017's research funds in the scope of the co-financed international projects framework (project no. 3711/H2020/2017/2).

This work is co-funded by the EOSC-hub project (Horizon 2020) under Grant number 777536.
