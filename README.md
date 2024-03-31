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
The CS342 2024 Intake application is using the [Spezi](https://github.com/StanfordSpezi/Spezi) ecosystem and builds on top of the [Stanford Spezi Template Application](https://github.com/StanfordSpezi/SpeziTemplateApplication). This app allows the user to manually fill out the form from scratch or connect their health records using HealthKit, in which case the form will be autofilled based on their health records.

> [!NOTE]  
> Do you want to try out the CS342 2024 Intake application? You can download it to your iOS device using [TestFlight](https://testflight.apple.com/join/Yp0Y24xT)!


## CS342 2024 Intake Features

There are 8 main features in this app: Chief Complaint, Medical history, Surgical History, Medications, Allergiers, Menstrual History, Smoking History and Scrollable Summary. The chief complaint is described in greater detail below. The medical history feature autofills the users past and present conditions, denoting which of them are still active. The surgical history feature autofills the users past surgeries, with the corresponding date of the surgery. The medication feature is described in greater detail below. The allergies feature autofills the users allergies, along witht he reactions for each allergy. The menstrual history feature only displays if the user is a women and shows the start and end date of the users last period. The smoking history feature provides information about the users smoking habits. Finally, the scrollable summary is described in greater detail below.

The medical history, allergies, and surgeries all use [SpeziLLM](https://github.com/StanfordSpezi/SpeziLLM) to filter the data to only include the relevant information from the health records.

The medical history, surgery, and allergy views all use [SpeziLLM](https://github.com/StanfordSpezi/SpeziLLM) to allow the user to click the chat button in the to and ask questions about that corresponding section, with an added ability to add entries to your form through the LLM chat.

|![Screenshot displaying the chief complaint view.](Intake/Resources/Screenshots/chiefComplaint.png#gh-light-mode-only) ![Screenshot displaying the chief complaint view.](Intake/Resources/Screenshots/chiefComplaint.png#gh-dark-mode-only)|![Screenshot displaying the medication view.](Intake/Resources/Screenshots/medication.png#gh-light-mode-only)![Screenshot displaying the medication view.](Intake/Resources/Screenshots/medication.png#gh-dark-mode-only)|![Screenshot displaying the summary view.](Intake/Resources/Screenshots/summary.png#gh-light-mode-only)![Screenshot displaying the summary view.](Intake/Resources/Screenshots/summary.png#gh-dark-mode-only)
|:--:|:--:|:--:|

The image on the left is the chief complaint feature which uses [SpeziLLM](https://github.com/StanfordSpezi/SpeziLLM) to chat with the user about the reason for their visit. It asks specifically tailored questions based on the users response, and then forumalizes a chief complaint for the user once it has enough information to do so.

The image in the middle is the medication feature which uses [SpeziMedication](https://github.com/StanfordSpezi/SpeziMedication) to gather all the necessary information about the medications the user is taking. It includes information about name of medication, dosgage, frequency, and schedule of taking the medicine. If you click the the + button in the top right, it will allow you to add a new medication. For this app, we have only allowed the user to choose between 10 medications, so that it can work with [SpeziMedication](https://github.com/StanfordSpezi/SpeziMedication), but the other features allow you enter any entry. 

The image on the right is the summary page, which gives the user a summary for all the information it has gathered in the form. Any of the edit buttons will take the user back to that feature, so they can edit their information. This particular user did not have any surgeries, so it is left blank. The share button at the bottom allows the user to export this information into a pdf format that they can then send to their doctor. Additionally, once you share the form, it gets stored on the users phone, so the next time the user open the app, they have the ability to automatically load their most recent form and come straight to this page without having to go through the form again if nothing has changed.


## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first. You can find a list of contributors in the [Contributors.md](https://github.com/CS342/2024-Intake/blob/main/CONTRIBUTORS.md) file


## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziOnboarding/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterLight.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/FooterDark.png#gh-dark-mode-only)
