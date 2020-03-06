# Changelog

All notable changes to this project will be documented in this file.

The format is mainly based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

* Added: Schema tests for class-based DSC resources
* Added: Show the output path for the local deployed module (task deploy)
* Changed: Move xml resource files (Format.ps1xml, Types.ps1xml) to the root
* Changed: Allow multiple local deploy paths (PowerShell and Windows PowerShell)
* Fixed: For local deploy, start with 0.0.0 if module does not exist

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
