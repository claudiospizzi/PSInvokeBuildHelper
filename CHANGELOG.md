﻿# Changelog

All notable changes to this project will be documented in this file.

The format is mainly based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

* Changed: Update module schema checks for PowerShell VS code formatting

## 3.0.0 - 2022-12-09

* Added: Support for Pester integration tests located in `/Tests/Integration`
* Changed: Optimize the Pester unit test location and only use `/Tests/Unit` if available instead always using all tests in `/Tests`
* Changed: Rename tasks with their configuration by applying the suffix `Test` for all Pester test commands
* Fixed: Fix the argument completer for the `Invoke-BuildIsolated` command

## 2.7.0 - 2022-12-06

* Added: Support for Pester v5 tests invocation

## 2.6.0 - 2021-06-04

* Added: README check for the contribute section
* Added: Detect the primary branch name: master or main
* Added: Exclude filters for schema and analyzer tests
* Added: Update assembly version in Set-ModuleVersion too

## 2.5.0 - 2020-09-01

* Changed: Exclude the test PSReviewUnusedParameter in the script analyzer task
* Changed: Remote the 'PowerShell Interactive' task in launch.json

## 2.4.0 - 2020-06-17

* Added: New task ZipFile for local deployment to a ZIP file in the bin folder
* Changed: The temporary debug script should be used by the VS Code debug task

## 2.3.0 - 2020-06-02

* Added: Default parameter set for Set-ModuleVersion to query caller
* Fixed: Only update psd1 module version once in Set-ModuleVersion

## 2.2.0 - 2020-04-24

* Added: New cmdlets Get-IBHFileEncoding and Set-ModuleVersion
* Added: Check file encoding during the meta tests
* Added: Check for token before using them in Repository and Gallery task

## 2.1.0 - 2020-03-06

* Added: Schema tests for class-based DSC resources
* Added: Show the output path for the local deployed module (task deploy)
* Changed: Move xml resource files (Format.ps1xml, Types.ps1xml) to the root
* Changed: Allow multiple local deploy paths (PowerShell and Windows PowerShell)
* Fixed: For local deploy, start with 0.0.0 if module does not exist
* Fixed: Fake the output as 0 passed tests if no Pester tests were found

## 2.0.0 - 2019-11-07

* Added: Invoke-BuildIsolated command for isolated builds
* Added: Build tasks for C# .NET Framework class libraries
* Added: New task Deploy added for deployment of a module to the local system
* Added: Schema test for the .debug.ps1 file
* Added: Schema tests for the (helper) function files and export definitions
* Added: Schema tests for encoding, white space and indentation character
* Added: Skip tests, if no functions or helpers are defined
* Added: Approve test to verify the solutions version
* Changed: Verify task now allows newer revisions for InvokeBuildHelper
* Changed: Move asserts from Gallery to Approve task
* Fixed: Fix regex on repo detection

## 1.0.0 - 2019-10-23

* Added: Initial version
