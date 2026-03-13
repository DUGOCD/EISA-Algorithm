# EISA: Elite-Inspired Sociocultural Algorithm

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![MATLAB](https://img.shields.io/badge/MATLAB-R2021a%2B-orange.svg)](https://www.mathworks.com/)

This repository contains the official MATLAB implementation of the **Elite-Inspired Sociocultural Algorithm (EISA)**, as proposed in the paper: 
*"An Elite-Inspired Intelligent Optimization Framework for Complex Engineering Design and UAV Path Planning"*.

## Overview
Intelligent optimization remains a critical challenge in modern engineering design and planning. EISA is a novel optimization approach inspired by sociocultural mechanisms in human societies. It integrates intra-group collaboration, inter-group cooperation, and a dual-phase inter-group competition mechanism within a hierarchical structure to maintain a dynamic balance between global exploration and local exploitation. 

This repository provides the source code for EISA, along with 9 comparative state-of-the-art metaheuristic algorithms and 4 comprehensive benchmark suites.

## Included Algorithms
The framework includes the proposed **EISA** and the following 9 advanced comparative algorithms:
* ETO, AO, SSA, ALA, IVY, WMA, ESOA, BTO, CTCM

## Benchmark Suites
The code seamlessly integrates the following mathematical benchmark suites for comprehensive evaluation:
1. **Classical 23 Test Functions** (F1 - F23)
2. **CEC-2019** (10 Functions)
3. **CEC-2020** (10 Functions, Dim = 20)
4. **CEC-2022** (12 Functions, Dim = 20)

## How to Run the Code

The main entry point for the simulation is the `main.m` script. We have designed a highly simplified interface to switch between different benchmark suites.

### Step-by-Step Instructions:
1. Open MATLAB and set the current folder to the directory containing the downloaded repository.
2. Open the `main.m` file.
3. Locate the `Suite_Choice` variable at the very top of the script (around Line 10).
4. Change the value of `Suite_Choice` to select your desired test suite:
   ```matlab
   Suite_Choice = 1; % Run Classical 23 Test Functions
   Suite_Choice = 2; % Run CEC-2019
   Suite_Choice = 3; % Run CEC-2020
   Suite_Choice = 4; % Run CEC-2022
