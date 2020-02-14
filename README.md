# UblSharp

[![Build status](https://ci.appveyor.com/api/projects/status/rlhygf9fm4w5l0e4/branch/master?svg=true)](https://ci.appveyor.com/project/ublsharp/ublsharp/branch/master)
[![MyGet](https://img.shields.io/myget/ublsharp/v/ublsharp.svg)](https://www.myget.org/gallery/ublsharp)
[![NuGet](https://img.shields.io/nuget/v/ublsharp.svg)](https://www.nuget.org/packages/ublsharp)

UblSharp is a C# / .NET / XML library for working with OASIS UBL 2.0 and 2.1 documents.

It supports all .NET full framework versions from .NET 2.0 - 4.6 and .NET Standard 1.0 and higher. See 'Available packages' below for a table of available packages and framework compatibility.

## Installation

Use the nuget packages. See the table below for an overview of available packages.

For example, using the Visual Studio package manager console:

    Install-Package UblSharp
    Install-Package UblSharp.Validation

Or using the dotnet cli:

    dotnet add package UblSharp

### Available packages

| Package                                                                           | .NET Support                         | Description                                                                                                                                                   |
| --------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [UblSharp](https://www.nuget.org/packages/UblSharp)                               | net20 - net46,<br /> netstandard1.0+ | Contains all UBL 2.0/2.1 common, aggregate and document types, annotated with System.Xml.* attributes. Also contains some basic serialization functions.      |
| [UblSharp.Validation](https://www.nuget.org/packages/UblSharp.Validation)         | net20 - net46, netstandard2.0*        | Contains validation functions to validate XML documents and UblSharp (.NET) objects using the OASIS UBL 2.1 xsd specifications.                               |
| [UblSharp.SEeF](https://www.nuget.org/packages/UblSharp.SEeF)                     | net20 - net46,<br /> netstandard1.0+ | Additional types to support ['Standaard Energie eFactuur (SEeF)'](https://energie-efactuur.nl) UBL documents.                                                 |
| [UblSharp.SCSN](https://www.nuget.org/packages/UblSharp.SCSN)                     | net20 - net46,<br /> netstandard1.0+ | Additional types to support ['Smart Connected Supplier Network (SCSN)'](https://smartindustry.nl/fieldlabs/8-smart-connected-supplier-network) UBL documents. |
| [UblSharp.Generator.Core](https://www.nuget.org/packages/UblSharp.Generator.Core) | net46                                | The code generator library used to generate C# classes from XSD schemas.                                                                                      |

> \* Validation is not available on netstandard1.0, because System.Xml.Schema and validation is only available on desktop .net and netstandard2.0 and higher.

## Credits

- The (test) generator of UblSharp was taken from https://github.com/Gammern/ubllarsen (a lot has changed since).

## License

[The MIT License (MIT)](LICENSE)
