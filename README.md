<!--

This source file is part of the Intake based on the Stanford Spezi Template Application project

SPDX-FileCopyrightText: 2023 Stanford University

SPDX-License-Identifier: MIT

-->

# CS342 2024 Intake

[![Build and Test](https://github.com/CS342/2024-Intake/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/CS342/2024-Intake/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/CS342/2024-Intake/graph/badge.svg?token=4sfQqouZCe)](https://codecov.io/gh/CS342/2024-Intake)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10521599.svg)](https://doi.org/10.5281/zenodo.10521599)

This repository contains the CS342 2024 Intake application.
The CS342 2024 Intake application is using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication).

> [!NOTE]  
> Do you want to try out the CS342 2024 Intake application? You can download it to your iOS device using [TestFlight](https://testflight.apple.com/join/Yp0Y24xT)!


## CS342 2024 Intake Features


The medication feature is described in greater detail below. The allergies feature autofills the users allergies, along witht he reactions for each allergy. The menstrual history feature only displays if the user is a women and shows the start and end date of the users last period. The smoking history feature provides information about the users smoking habits. Finally, the scrollable summary is described in greater detail below.

The medical history, allergies, and surgeries all use SpeziLLM to filter the data to only include the relevant information from the health records.

The medical history, surgery, and allergy views all use SpeziLLM to allow the user to ask questions about that corresponding section, with an added ability to add entries to your form through the LLM chat.


## Contributing

*Ensure that you add an adequate contribution section to this README.*


## License

This project is licensed under the MIT License. See [Licenses](LICENSES) for more information.
