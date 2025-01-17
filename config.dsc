// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

config({
    // No orphan projects are owned by this configuration.
    projects: [],

    // Packages that define the build extent.
    modules: [
        ...globR(d`Public/Src`, "module.config.dsc"),
        ...globR(d`Public/Sdk/UnitTests`, "module.config.dsc"),
        ...globR(d`Private/Wdg`, "module.config.dsc"),
        ...globR(d`Private/QTest`, "module.config.dsc"),
        ...globR(d`Private/InternalSdk`, "module.config.dsc"),
        ...globR(d`Private/Tools`, "module.config.dsc"),
        ...globR(d`Public/Sdk/SelfHost`, "module.config.dsc"),
    ],

    frontEnd: {
        enabledPolicyRules: [
            "NoTransformers",
        ]
    },

    resolvers: [
        // These are the new cleaned up Sdk's
        {
            kind: "DScript",
            modules: [
                f`Public/Sdk/Public/Prelude/package.config.dsc`, // Prelude cannot be named module because it is a v1 module
                f`Public/Sdk/Public/Transformers/package.config.dsc`, // Transformers cannot be renamed yet because office relies on the filename
                ...globR(d`Public/Sdk`, "module.config.dsc"),
            ]
        },
        {
            // The credential provider should be set by defining the env variable NUGET_CREDENTIALPROVIDERS_PATH.
            kind: "Nuget",

            // Temporarily skip sign nuget packages. 
            // Todo: Enable sign after adding configuration to selectively sign nuget packages
            // esrpSignConfiguration :  Context.getCurrentHost().os === "win" && Environment.getFlag("ENABLE_ESRP") ? {
            //     signToolPath: p`${Environment.expandEnvironmentVariablesInString(Environment.getStringValue("SIGN_TOOL_PATH"))}`,
            //     signToolConfiguration: Environment.getPathValue("ESRP_SESSION_CONFIG"),
            //     signToolEsrpPolicy: Environment.getPathValue("ESRP_POLICY_CONFIG"),
            //     signToolAadAuth: p`${Context.getMount("SourceRoot").path}/Secrets/CodeSign/EsrpAuthentication.json`,
            // } : undefined,

            repositories: importFile(f`config.microsoftInternal.dsc`).isMicrosoftInternal
                ? {
                    // If nuget resolver failed to download VisualCpp tool, then download it
                    // manually from "BuildXL.Selfhost" feed into some folder, and specify
                    // that folder as the value of "MyInternal" feed below.
                    // "MyInternal": "E:/BuildXLInternalRepos/NuGetInternal",
                    // CODESYNC: bxl.sh, Shared\Scripts\bxl.ps1
                    "BuildXL.Selfhost": "https://pkgs.dev.azure.com/cloudbuild/_packaging/BuildXL.Selfhost/nuget/v3/index.json",
                    // Note: From a compliance point of view it is important that MicrosoftInternal has a single feed.
                    // If you need to consume packages make sure they are upstreamed in that feed.
                  }
                : {
                    "buildxl-selfhost" : "https://pkgs.dev.azure.com/ms/BuildXL/_packaging/BuildXL.Selfhost/nuget/v3/index.json",
                    "nuget.org" : "https://api.nuget.org/v3/index.json",
                    "dotnet-arcade" : "https://dotnetfeed.blob.core.windows.net/dotnet-core/index.json",
                  },

            packages: [
                { id: "NLog", version: "4.7.7" },
                { id: "CLAP", version: "4.6" },
                { id: "CLAP-DotNetCore", version: "4.6" },

                { id: "RuntimeContracts", version: "0.5.0" }, // Be very careful with updating this version, because CloudBuild and other repository needs to be updated as will
                { id: "RuntimeContracts.Analyzer", version: "0.4.3" }, // The versions are different because the analyzer has higher version for now.

                { id: "Microsoft.NETFramework.ReferenceAssemblies.net472", version: "1.0.0" },

                { id: "System.Diagnostics.DiagnosticSource", version: "7.0.2" },

                // Roslyn
                // The old compiler used by integration tests only.
                { id: "Microsoft.Net.Compilers", version: "4.0.1" }, // Update Public/Src/Engine/UnitTests/Engine/Test.BuildXL.Engine.dsc if you change the version of Microsoft.Net.Compilers.
                { id: "Microsoft.NETCore.Compilers", version: "4.0.1" },
                // The package with an actual csc.dll
                { id: "Microsoft.Net.Compilers.Toolset", version: "4.8.0" },

                // These packages are used by log generators and because they're old
                // we can't use the latest language features there.
                { id: "Microsoft.CodeAnalysis.Common", version: "3.5.0" },
                { id: "Microsoft.CodeAnalysis.CSharp", version: "3.5.0" },
                { id: "Microsoft.CodeAnalysis.VisualBasic", version: "3.5.0" },
                { id: "Microsoft.CodeAnalysis.Workspaces.Common", version: "3.5.0",
                    dependentPackageIdsToSkip: ["SQLitePCLRaw.bundle_green", "System.Composition"],
                    dependentPackageIdsToIgnore: ["SQLitePCLRaw.bundle_green", "System.Composition"],
                },
                { id: "Microsoft.CodeAnalysis.CSharp.Workspaces", version: "3.5.0" },

                // VBCSCompilerLogger needs the latest version (.net 5), but we haven't completed the migration to net 5 for
                // the rest of the codebase yet
                // Note: if any of the CodeAnalysis packages get upgraded, any new
                // switch introduced in the compiler command line argument supported by
                // the new version needs to be evaluated and incorporated into VBCSCompilerLogger.cs
                { id: "Microsoft.CodeAnalysis.Common", version: "3.8.0", alias: "Microsoft.CodeAnalysis.Common.ForVBCS"},
                { id: "Microsoft.CodeAnalysis.CSharp", version: "3.8.0", alias: "Microsoft.CodeAnalysis.CSharp.ForVBCS",
                    dependentPackageIdsToSkip: ["Microsoft.CodeAnalysis.Common"] },
                { id: "Microsoft.CodeAnalysis.VisualBasic", version: "3.8.0", alias: "Microsoft.CodeAnalysis.VisualBasic.ForVBCS",
                    dependentPackageIdsToSkip: ["Microsoft.CodeAnalysis.Common"]},
                { id: "Microsoft.CodeAnalysis.Workspaces.Common", version: "3.8.0", alias: "Microsoft.CodeAnalysis.Workspaces.Common.ForVBCS",
                    dependentPackageIdsToSkip: ["SQLitePCLRaw.bundle_green", "System.Composition"],
                    dependentPackageIdsToIgnore: ["SQLitePCLRaw.bundle_green", "System.Composition"],
                },
                { id: "Microsoft.CodeAnalysis.CSharp.Workspaces", version: "3.8.0", alias: "Microsoft.CodeAnalysis.CSharp.Workspaces.ForVBCS" },
                { id: "Humanizer.Core", version: "2.2.0" },

                // Old code analysis libraries, for tests only
                { id: "Microsoft.CodeAnalysis.Common", version: "2.10.0", alias: "Microsoft.CodeAnalysis.Common.Old" },
                { id: "Microsoft.CodeAnalysis.CSharp", version: "2.10.0", alias: "Microsoft.CodeAnalysis.CSharp.Old" },
                { id: "Microsoft.CodeAnalysis.VisualBasic", version: "2.10.0", alias: "Microsoft.CodeAnalysis.VisualBasic.Old" },

                // Roslyn Analyzers
                { id: "Microsoft.CodeAnalysis.Analyzers", version: "3.3.1" },
                { id: "Microsoft.CodeAnalysis.FxCopAnalyzers", version: "2.6.3" },
                { id: "Microsoft.CodeQuality.Analyzers", version: "2.3.0-beta1" },
                { id: "Microsoft.NetFramework.Analyzers", version: "2.3.0-beta1" },
                { id: "Microsoft.NetCore.Analyzers", version: "2.3.0-beta1" },
                { id: "Microsoft.CodeAnalysis.NetAnalyzers", version: "5.0.3"},

                { id: "AsyncFixer", version: "1.6.0" },
                { id: "ErrorProne.NET.CoreAnalyzers", version: "0.6.1-beta.1" },
                { id: "protobuf-net.BuildTools", version: "3.0.101" },
                { id: "Microsoft.VisualStudio.Threading.Analyzers", version: "17.6.40"},
                { id: "Text.Analyzers", version: "2.3.0-beta1" },
                { id: "Microsoft.CodeAnalysis.PublicApiAnalyzers", version: "3.3.4" },

                // MEF
                { id: "Microsoft.Composition", version: "1.0.30" },
                { id: "System.Composition.AttributedModel", version: "1.0.31" },
                { id: "System.Composition.Convention", version: "1.0.31" },
                { id: "System.Composition.Hosting", version: "1.0.31" },
                { id: "System.Composition.Runtime", version: "1.0.31" },
                { id: "System.Composition.TypedParts", version: "1.0.31" },

                { id: "Microsoft.Diagnostics.Tracing.EventSource.Redist", version: "1.1.28" },
                { id: "Microsoft.Diagnostics.Tracing.TraceEvent", version: "3.0.7" },
                { id: "Microsoft.Extensions.Globalization.CultureInfoCache", version: "1.0.0-rc1-final" },
                { id: "Microsoft.Extensions.MemoryPool", version: "1.0.0-rc1-final" },
                { id: "Microsoft.Extensions.PlatformAbstractions", version: "1.1.0" },
                { id: "Microsoft.Extensions.Http", version: "7.0.0" },

                { id: "Microsoft.Tpl.Dataflow", version: "4.5.24" },
                { id: "Microsoft.TypeScript.Compiler", version: "1.8" },
                { id: "Microsoft.WindowsAzure.ConfigurationManager", version: "1.8.0.0" },
                { id: "Newtonsoft.Json", version: "13.0.3" },
                { id: "Newtonsoft.Json.Bson", version: "1.0.1" },
                { id: "System.Reflection.Metadata", version: "7.0.0" },
                // The VBCS logger is used by QuickBuild and runs in the context of old VS installations, so it cannot use a higher version
                // Please do not upgrade this dll (or if you do, make sure this happens in coordination with the QuickBuild team)
                { id: "System.Reflection.Metadata", version: "5.0.0", alias: "System.Reflection.Metadata.ForVBCS" },

                { id: "System.Threading.Tasks.Dataflow", version: "7.0.0" },

                // Nuget
                { id: "NuGet.Packaging", version: "6.9.1" },
                { id: "NuGet.Configuration", version: "6.9.1" },
                { id: "NuGet.Common", version: "6.9.1" },
                { id: "NuGet.Protocol", version: "6.9.1" },
                { id: "NuGet.Versioning", version: "6.9.1" }, 
                { id: "NuGet.CommandLine", version: "6.9.1" },
                { id: "NuGet.Frameworks", version: "6.9.1"}, // needed for qtest on .net core

                // ProjFS (virtual file system)
                { id: "Microsoft.Windows.ProjFS", version: "1.2.19351.1" },

                // RocksDb
                { id: "RocksDbSharp", version: "8.1.1-20240419.2", alias: "RocksDbSharpSigned" },
                { id: "RocksDbNative", version: "8.1.1-20240419.2" },

                { id: "JsonDiffPatch.Net", version: "2.1.0" },

                // Event hubs
                { id: "Microsoft.Azure.Amqp", version: "2.6.1" },
                { id: "Azure.Core.Amqp", version: "1.3.0"},
                { id: "Azure.Messaging.EventHubs", version: "5.9.0" },
                { id: "Microsoft.Azure.KeyVault.Core", version: "1.0.0" },
                { id: "Microsoft.IdentityModel.Logging", version: "7.2.0" },
                { id: "Microsoft.IdentityModel.Tokens", version: "7.2.0" },
                { id: "System.IdentityModel.Tokens.Jwt", version: "7.2.0"},
                { id: "Microsoft.IdentityModel.JsonWebTokens", version: "7.2.0" },

                // Key Vault
                { id: "Azure.Security.KeyVault.Secrets", version: "4.5.0" },
                { id: "Azure.Security.KeyVault.Certificates", version: "4.5.1" },
                { id: "Azure.Identity", version: "1.11.0" },
                { id: "Microsoft.Identity.Client", version: "4.60.1" },
                { id: "Microsoft.IdentityModel.Abstractions", version: "7.2.0" },
                { id: "Microsoft.Identity.Client.Extensions.Msal", version: "4.60.1" },
                { id: "Azure.Core", version: "1.38.0" },
                { id: "System.Memory.Data", version: "1.0.2" },
                { id: "System.ClientModel", version: "1.0.0" },

                // Authentication
                { id: "Microsoft.Identity.Client.Broker", version: "4.55.0" },
                { id: "Microsoft.Identity.Client.NativeInterop", version: "0.13.8" },
                
                // Package sets
                ...importFile(f`config.nuget.vssdk.dsc`).pkgs,
                ...importFile(f`config.nuget.aspNetCore.dsc`).pkgs,
                ...importFile(f`config.nuget.dotnetcore.dsc`).pkgs,
                ...importFile(f`config.nuget.grpc.dsc`).pkgs,
                ...importFile(f`config.microsoftInternal.dsc`).pkgs,

                // Azure Blob Storage SDK V12
                { id: "Azure.Storage.Blobs", version: "12.16.0" },
                { id: "Azure.Storage.Common", version: "12.15.0" },
                { id: "System.IO.Hashing", version: "6.0.0" },
                { id: "Azure.Storage.Blobs.Batch", version: "12.10.0" },
                { id: "Azure.Storage.Blobs.ChangeFeed", version: "12.0.0-preview.34" },

                // xUnit
                { id: "xunit.abstractions", version: "2.0.3" },
                { id: "xunit.assert", version: "2.5.3" },
                { id: "xunit.extensibility.core", version: "2.5.3" },
                { id: "xunit.extensibility.execution", version: "2.5.3" },
                { id: "xunit.runner.console", version: "2.5.3" },
                { id: "xunit.runner.visualstudio", version: "2.5.3" },
                { id: "xunit.runner.utility", version: "2.5.3" },
                { id: "xunit.runner.reporters", version: "2.5.3" },
                { id: "Microsoft.DotNet.XUnitConsoleRunner", version: "2.5.1-beta.19270.4" },

                // microsoft test platform
                { id: "Microsoft.TestPlatform.TestHost", version: "16.4.0"},
                { id: "Microsoft.TestPlatform.ObjectModel", version: "16.4.0"},
                { id: "Microsoft.NET.Test.Sdk", version: "15.9.0" },
                { id: "Microsoft.CodeCoverage", version: "15.9.0" },

                { id: "System.Private.Uri", version: "4.3.2" },

                // CloudStore dependencies
                { id: "DeduplicationSigned", version: "1.0.14" },
                { id: "Microsoft.Bcl", version: "1.1.10" },
                { id: "Microsoft.Bcl.Async", version: "1.0.168" },
                { id: "Microsoft.Bcl.AsyncInterfaces", version: "7.0.0" },
                { id: "Microsoft.Bcl.Build", version: "1.0.14" },
                
                { id: "Pipelines.Sockets.Unofficial", version: "2.2.0" },
                { id: "System.Diagnostics.PerformanceCounter", version: "5.0.0" },
                { id: "System.Threading.Channels", version: "7.0.0" },

                { id: "System.Linq.Async", version: "4.0.0"},
                { id: "Polly", version: "7.2.1" },
                { id: "Polly.Contrib.WaitAndRetry", version: "1.1.1" },

                // Azurite node app compiled to standalone executable
                // Sources for this package are: https://github.com/Azure/Azurite
                // This packaged is produced by the pipeline: https://dev.azure.com/mseng/Domino/_build?definitionId=13199
                { id: "BuildXL.Azurite.Executables", version: "1.0.0-CI-20230614-171424" },

                // Testing
                { id: "System.Security.Cryptography.ProtectedData", version: "7.0.0"},
                { id: "System.Configuration.ConfigurationManager", version: "7.0.0"},
                { id: "System.Diagnostics.EventLog", version: "7.0.0" },
                { id: "FluentAssertions", version: "5.3.0" },

                { id: "DotNet.Glob", version: "2.0.3" },
                { id: "Minimatch", version: "1.1.0.0" },
                { id: "Microsoft.ApplicationInsights", version: "2.21.0", dependentPackageIdsToIgnore: ["System.RunTime.InteropServices"] },
                { id: "Microsoft.ApplicationInsights.Agent.Intercept", version: "2.0.7" },
                { id: "Microsoft.ApplicationInsights.DependencyCollector", version: "2.3.0" },
                { id: "Microsoft.ApplicationInsights.PerfCounterCollector", version: "2.3.0" },
                { id: "Microsoft.ApplicationInsights.WindowsServer", version: "2.3.0" },
                { id: "Microsoft.ApplicationInsights.WindowsServer.TelemetryChannel", version: "2.3.0" },
                { id: "System.Security.Cryptography.Xml", version: "4.7.1" },
                { id: "System.Text.Encodings.Web", version: "7.0.0" },
                { id: "System.Security.Permissions", version: "7.0.0" },
                { id: "System.Windows.Extensions", version: "7.0.0" },
                { id: "System.Drawing.Common", version: "7.0.0" },
                { id: "Microsoft.Win32.SystemEvents", version: "7.0.0" },
                { id: "System.Security.Cryptography.Pkcs", version: "7.0.2" },

                { id: "ILRepack", version: "2.0.16" },

                // VS language service
                { id: "System.Runtime.Analyzers", version: "1.0.1" },
                { id: "System.Runtime.InteropServices.Analyzers", version: "1.0.1" },
                { id: "System.Security.Cryptography.Hashing.Algorithms.Analyzers", version: "1.1.0" },
                { id: "Validation", version: "2.5.42"},

                // VSTS managed API
                { id: "Microsoft.TeamFoundationServer.Client", version: "16.170.0"},
                { id: "Microsoft.TeamFoundation.DistributedTask.WebApi", version: "16.170.0",
                    dependentPackageIdsToSkip: ["*"] },
                { id: "Microsoft.TeamFoundation.DistributedTask.Common.Contracts", version: "16.170.0"},

                // MSBuild. These should be used for compile references only, as at runtime one can only practically use MSBuilds from Visual Studio / dotnet CLI
                { id: "Microsoft.Build", version: "17.7.2" },
                { id: "Microsoft.Build.Runtime", version: "17.7.2" },
                { id: "Microsoft.Build.Tasks.Core", version: "17.7.2" },
                { id: "Microsoft.Build.Utilities.Core", version: "17.0.0" },
                { id: "Microsoft.Build.Framework", version: "17.7.2" },
                { id: "Microsoft.NET.StringTools", version: "1.0.0" },
                { id: "Microsoft.Build.Locator", version: "1.5.5" },
                { id: "System.Reflection.MetadataLoadContext", version: "7.0.0"},    

                { id: "System.Resources.Extensions", version: "4.6.0-preview9.19411.4",
                    dependentPackageIdsToSkip: ["System.Memory"]},

                // Buffers and Memory
                { id: "System.Buffers", version: "4.5.1" }, /* Change Sync: BuildXLSdk.cacheBindingRedirects() */ // A different version, because StackExchange.Redis uses it.
                { id: "System.Memory", version: "4.5.5" }, /* Change Sync: BuildXLSdk.cacheBindingRedirects() */
                { id: "System.Runtime.CompilerServices.Unsafe", version: "6.0.0" }, /* Change Sync: BuildXLSdk.cacheBindingRedirects() */
                { id: "System.IO.Pipelines", version: "7.0.0-rc.1.22426.10" },
                { id: "System.Numerics.Vectors", version: "4.5.0" }, /* Change Sync: BuildXLSdk.cacheBindingRedirects() */

                // Extra dependencies to make MSBuild work
                { id: "Microsoft.VisualStudio.Setup.Configuration.Interop", version: "3.2.2146"},
                { id: "System.CodeDom", version: "4.4.0"},
                { id: "System.Text.Encoding.CodePages", version: "4.5.1" },

                // Used for MSBuild input/output prediction
                { id: "Microsoft.Build.Prediction", version: "0.3.0" },

                { id: "SharpZipLib", version: "1.3.3" },

                { id: "ObjectLayoutInspector", version: "0.1.4" },

                // Ninja JSON graph generation helper
                { id: "BuildXL.Tools.Ninjson", version: "1.11.6", osSkip: [ "macOS" ] },
                { id: "BuildXL.Tools.AppHostPatcher", version: "1.0.0" },

                // Azure Communication
                { id: "Microsoft.Rest.ClientRuntime", version: "2.3.24",
                    dependentPackageIdsToSkip: ["Microsoft.NETCore.Runtime"],
                    dependentPackageIdsToIgnore: ["Microsoft.NETCore.Runtime"],
                },
                { id: "Microsoft.Rest.ClientRuntime.Azure", version: "3.3.19" },

                // ANTLR
                { id: "Antlr4.Runtime.Standard", version: "4.7.2" },

                // For C++ testing
                { id: "boost", version: "1.71.0.0" },

                // Needed for SBOM Generation
                { id: "Microsoft.Extensions.Logging.Abstractions", version: "8.0.0" },
                { id: "packageurl-dotnet", version: "1.1.0" },
                { id: "System.Reactive", version: "4.4.1" },

                // CredScan
                { id: "Crc32.NET", version: "1.2.0" },

                // Windows CoW on ReFS
                { id: "CopyOnWrite", version: "0.3.8" },

                // Windows SDK
                // CODESYNC: This version should be updated together with the version number in Public/Sdk/Experimental/Msvc/WindowsSdk/windowsSdk.dsc
                { id: "Microsoft.Windows.SDK.cpp", version: "10.0.22621.755", osSkip: [ "macOS", "unix" ] },
                { id: "Microsoft.Windows.SDK.CPP.x86", version: "10.0.22621.755", osSkip: [ "macOS", "unix" ] },
                { id: "Microsoft.Windows.SDK.CPP.x64", version: "10.0.22621.755", osSkip: [ "macOS", "unix" ] },
            ],

            doNotEnforceDependencyVersions: true,
        },

        importFile(f`config.microsoftInternal.dsc`).resolver,

        // .NET Runtimes.
        { kind: "SourceResolver", modules: [f`Public\Sdk\SelfHost\Libraries\Dotnet-Runtime-6-External\module.config.dsc`] },
        { kind: "SourceResolver", modules: [f`Public\Sdk\SelfHost\Libraries\Dotnet-Runtime-7-External\module.config.dsc`] },
        { kind: "SourceResolver", modules: [f`Public\Sdk\SelfHost\Libraries\Dotnet-Runtime-8-External\module.config.dsc`] },

        {
            kind: "Download",

            downloads: [
                // XNU kernel sources
                {
                    moduleName: "Apple.Darwin.Xnu",
                    url: "https://github.com/apple/darwin-xnu/archive/xnu-4903.221.2.tar.gz",
                    hash: "VSO0:D6D26AEECA99240D2D833B6B8B811609B9A6E3516C0EE97A951B64F9AA4F90F400",
                    archiveType: "tgz",
                },

                // DotNet Core Runtime 8.0.5
                {
                    moduleName: "DotNet-Runtime.win-x64.8.0", 
                    url: "https://download.visualstudio.microsoft.com/download/pr/77650902-a341-4f4c-934f-db7056cbfa78/176d961f8bbc798596f8d498ede4cc73/dotnet-runtime-8.0.5-win-x64.zip",
                    hash: "VSO0:516C33A4FCC0F7239C490C2B35B007C7617C2BAB3078325B139A05FA30F05FCC00",
                    archiveType: "zip",
                },
                {
                    moduleName: "DotNet-Runtime.osx-x64.8.0",
                    url: "https://download.visualstudio.microsoft.com/download/pr/0dabe69f-fa99-4b53-96d1-9f9791bb0b6b/f72acbfd3b0e60528d9494b43bcf21ca/dotnet-runtime-8.0.5-osx-x64.tar.gz",
                    hash: "VSO0:E15F74130A2723AA4DF40B345F913861280499CE2DEDF32671014D8644E7520900",
                    archiveType: "tgz",
                },
                {
                    moduleName: "DotNet-Runtime.linux-x64.8.0",
                    url: "https://download.visualstudio.microsoft.com/download/pr/baeb5da3-4b77-465b-8816-b29f0bc3e1a9/b04b17a2aae79e5f5635a3ceffbd4645/dotnet-runtime-8.0.5-linux-x64.tar.gz",
                    hash: "VSO0:D4C467B54EE3BE77932D350B9A7A3BCABA3D8B95DCFA5D6ABE7E825589D5330E00",
                    archiveType: "tgz",
                },

                // DotNet Core Runtime 7.0.19
                {
                    moduleName: "DotNet-Runtime.win-x64.7.0", 
                    url: "https://download.visualstudio.microsoft.com/download/pr/32f909df-fc73-439b-a8e1-55f18bfac3fb/e071d418324b9083629379f3ac6fd07a/dotnet-runtime-7.0.19-win-x64.zip",
                    hash: "VSO0:E4EC76FCB875EAA156A7A81EB59BE3AC06D7A766B079707C40A29EF75A4563E100",
                    archiveType: "zip",
                },
                {
                    moduleName: "DotNet-Runtime.osx-x64.7.0",
                    url: "https://download.visualstudio.microsoft.com/download/pr/92c2b6d8-783f-4a48-8575-e001296d4a54/c11d13f994d5016fc13d5c9a81e394f0/dotnet-runtime-7.0.19-osx-x64.tar.gz",
                    hash: "VSO0:62021BDB718C0C82F0F4361142EA0B43F0B2D9ACCE20A9B7DB9C8651C155A18F00",
                    archiveType: "tgz",
                },
                {
                    moduleName: "DotNet-Runtime.linux-x64.7.0",
                    url: "https://download.visualstudio.microsoft.com/download/pr/09ab2389-5bab-4d45-9a91-a56ff322e83c/2f8192a98b6887c7f12b0d2dc4a06247/dotnet-runtime-7.0.19-linux-x64.tar.gz",
                    hash: "VSO0:F9268D23C35BE8DC97B4603CFF405EAE84D421817FADA72D5ACB1E9BAC4EC2AC00",
                    archiveType: "tgz",
                },

                // DotNet Core Runtime 6.0.30
                {
                    moduleName: "DotNet-Runtime.win-x64.6.0.201", 
                    url: "https://download.visualstudio.microsoft.com/download/pr/4cbb8ef9-bdab-4c78-a09a-bc44fdd4574f/15fe579eb104fb9c3254540075e423b8/dotnet-runtime-6.0.30-win-x64.zip",
                    hash: "VSO0:237C323F44C6CBEA00A509AAFC2CFF41807FF6F8CF0A91CE7B66C2C0FB66602800",
                    archiveType: "zip",
                },
                {
                    moduleName: "DotNet-Runtime.osx-x64.6.0.201",
                    url: "https://download.visualstudio.microsoft.com/download/pr/aee516fe-b6d8-40db-b284-1a287f7cd5ce/c217b7cdbcac883886169b82bcc2b7d8/dotnet-runtime-6.0.30-osx-x64.tar.gz",
                    hash: "VSO0:37489FCEE1941DD4346B6C626A8BCB78A58676D51E9868E5464150D12DD68D5C00",
                    archiveType: "tgz",
                },
                {
                    moduleName: "DotNet-Runtime.linux-x64.6.0.201",
                    url: "https://download.visualstudio.microsoft.com/download/pr/a80ab89d-9f64-47b9-bba5-907a4cdaf457/c5714a6e605ef86293a5145d8ea72f39/dotnet-runtime-6.0.30-linux-x64.tar.gz",
                    hash: "VSO0:A6883B9D84F5FD671E22FED36644230CD3A2CEC788B795B46A2BBDB6195051D600",
                    archiveType: "tgz",
                },

                // The following are needed for dotnet core MSBuild test deployments
                {
                    moduleName: "DotNet-Runtime.win-x64.2.2.2",
                    url: "https://download.visualstudio.microsoft.com/download/pr/97b97652-4f74-4866-b708-2e9b41064459/7c722daf1a80a89aa8c3dec9103c24fc/dotnet-runtime-2.2.2-linux-x64.tar.gz",
                    hash: "VSO0:6E5172671364C65B06C9940468A62BAF70EE27392CB2CA8B2C8BFE058CCD088300",
                    archiveType: "tgz",
                },
                // NodeJs
                {
                    moduleName: "NodeJs.win-x64",
                    url: "https://nodejs.org/dist/v18.6.0/node-v18.6.0-win-x64.zip",
                    hash: "VSO0:EA729EEA528055396523F3F5BD61EDD769C251EB7B4483AABFEB511333E60AA000",
                    archiveType: "zip",
                },
                {
                    moduleName: "NodeJs.osx-x64",
                    url: "https://nodejs.org/dist/v18.6.0/node-v18.6.0-darwin-x64.tar.gz",
                    hash: "VSO0:653B5954AD06BB6C9B7141853649602790FCB0031B81FDB82241333E2EE1350200",
                    archiveType: "tgz",
                },
                {
                    moduleName: "NodeJs.linux-x64",
                    url: "https://nodejs.org/dist/v18.6.0/node-v18.6.0-linux-x64.tar.gz",
                    hash: "VSO0:15A59CD4CC7C08A91FDF0C028F1C1129DC4B635749514739E1B2C6224E6420FB00",
                    archiveType: "tgz",
                },
                {
                    moduleName: "YarnTool",
                    extractedValueName: "yarnPackage",
                    url: 'https://registry.npmjs.org/yarn/-/yarn-1.22.19.tgz',
                    archiveType: "tgz"
                },
                {
                    moduleName: "MinGit.win-x64",
                    url: 'https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/MinGit-2.43.0-64-bit.zip',
                    hash: 'VSO0:15D4663615814ADAE92F449B78A2668C515BD475DFDAC30384EFF84C8413546700',
                    archiveType: "zip"
                }
            ],
        },
    ],

    qualifiers: {
        defaultQualifier: {
            configuration: "debug",
            targetFramework: "net8.0",
            targetRuntime:
                Context.getCurrentHost().os === "win" ? "win-x64" :
                Context.getCurrentHost().os === "macOS" ? "osx-x64" : "linux-x64",
        },
        namedQualifiers: {
            Debug: {
                configuration: "debug",
                targetFramework: "net8.0",
                targetRuntime: "win-x64",
            },
            DebugNet472: {
                configuration: "debug",
                targetFramework: "net472",
                targetRuntime: "win-x64",
            },
            DebugNet8: {
                configuration: "debug",
                targetFramework: "net8.0",
                targetRuntime: "win-x64",
            },
            DebugNet7: {
                configuration: "debug",
                targetFramework: "net7.0",
                targetRuntime: "win-x64",
            },
            DebugDotNet6: {
                configuration: "debug",
                targetFramework: "net6.0",
                targetRuntime: "win-x64",
            },
            DebugDotNetCoreMac: {
                configuration: "debug",
                targetFramework: "net8.0",
                targetRuntime: "osx-x64",
            },
            DebugDotNetCoreMacNet8: {
                configuration: "debug",
                targetFramework: "net8.0",
                targetRuntime: "osx-x64",
            },
            DebugLinux: {
                configuration: "debug",
                targetFramework: "net8.0",
                targetRuntime: "linux-x64",
            },
            DebugLinuxNet8: {
                configuration: "debug",
                targetFramework: "net8.0",
                targetRuntime: "linux-x64",
            },
            // Release
            Release: {
                configuration: "release",
                targetFramework: "net8.0",
                targetRuntime: "win-x64",
            },
            ReleaseNet472: {
                configuration: "release",
                targetFramework: "net472",
                targetRuntime: "win-x64",
            },
            ReleaseNet8: {
                configuration: "release",
                targetFramework: "net8.0",
                targetRuntime: "win-x64",
            },
            ReleaseNet7: {
                configuration: "release",
                targetFramework: "net7.0",
                targetRuntime: "win-x64",
            },
            ReleaseDotNet6: {
                configuration: "release",
                targetFramework: "net6.0",
                targetRuntime: "win-x64",
            },
            ReleaseDotNetCoreMac: {
                configuration: "release",
                targetFramework: "net8.0",
                targetRuntime: "osx-x64",
            },
            ReleaseDotNetCoreMacNet8: {
                configuration: "release",
                targetFramework: "net8.0",
                targetRuntime: "osx-x64",
            },
            ReleaseLinux: {
                configuration: "release",
                targetFramework: "net8.0",
                targetRuntime: "linux-x64",
            },
            ReleaseLinuxNet8: {
                configuration: "release",
                targetFramework: "net8.0",
                targetRuntime: "linux-x64",
            },
        }
    },

    mounts: [
        ...importFile(f`unix.mounts.dsc`).mounts,
        {
            name: a`DeploymentRoot`,
            path: p`Out/Bin`,
            trackSourceFileChanges: true,
            isWritable: true,
            isReadable: true,
            isScrubbable: true,
        },
        {
            name: a`CgNpmRoot`,
            path: p`cg/npm`,
            trackSourceFileChanges: true,
            isWritable: false,
            isReadable: true
        },
        {
            // Special scrubbable mount with the content that can be cleaned up by running bxl.exe /scrub
            name: a`ScrubbableDeployment`,
            path: Context.getCurrentHost().os !== "macOS" ? p`Out/Objects/TempDeployment` : p`Out/Objects.noindex/TempDeployment`,
            trackSourceFileChanges: true,
            isWritable: true,
            isReadable: true,
            isScrubbable: true,
        },
        {
            name: a`SdkRoot`,
            path: p`Public/Sdk/Public`,
            trackSourceFileChanges: true,
            isWritable: false,
            isReadable: true,
        },
        {
            name: a`Example`,
            path: p`Example`,
            trackSourceFileChanges: true,
            isWritable: false,
            isReadable: true
        },
        {
            name: a`Sandbox`,
            path: p`Public/Src/Sandbox`,
            trackSourceFileChanges: true,
            isWritable: false,
            isReadable: true
        },
        ...(Environment.getStringValue("BUILDXL_DROP_CONFIG") !== undefined ? 
        [
            {
                // Path used in CloudBuild for things like drop configuration files. These files should not be tracked.
                name: a`CloudBuild`,
                path: Environment.getPathValue("BUILDXL_DROP_CONFIG").parent,
                trackSourceFileChanges: false,
                isWritable: false,
                isReadable: true
            }
        ] : []),
        {
            name: a`ThirdParty_mono`,
            path: p`third_party/mono@abad3612068e7333956106e7be02d9ce9e346f92`,
            trackSourceFileChanges: true,
            isWritable: false,
            isReadable: true
        },
        ...(Environment.hasVariable("TOOLPATH_GUARDIAN") ? 
        [
            {
                name: a`GuardianDrop`,
                path: Environment.getPathValue("TOOLPATH_GUARDIAN").parent,
                isReadable: true,
                isWritable: true,
                trackSourceFileChanges: true
            }
        ] : []),
        ...(Environment.hasVariable("ESRP_POLICY_CONFIG") ?
        [
            {
                name: a`EsrpPolicyConfig`,
                path: Environment.getPathValue("ESRP_POLICY_CONFIG").parent,
                isReadable: true,
                isWritable: false,
                trackSourceFileChanges: true
            }
        ] : []),
        ...(Environment.hasVariable("ESRP_SESSION_CONFIG") ? 
        [
            { 
                name: a`EsrpSessionConfig`,
                path: Environment.getPathValue("ESRP_SESSION_CONFIG").parent,
                isReadable: true,
                isWritable: false,
                trackSourceFileChanges: true
            }
        ] : [])
    ],

    searchPathEnumerationTools: [
        r`cl.exe`,
        r`lib.exe`,
        r`link.exe`,
        r`sn.exe`,
        r`csc.exe`,
        r`BuildXL.LogGen.exe`,
        r`csc.exe`,
        r`ccrefgen.exe`,
        r`ccrewrite.exe`,
        r`FxCopCmd.exe`,
        r`NuGet.exe`
    ],

    ide: {
        // Let the /VS flag generate the projects in the source tree so that add/remove C# file works properly.
        canWriteToSrc: true,
        dotSettingsFile: f`Public/Sdk/SelfHost/BuildXL/BuildXL.sln.DotSettings`,
    },

    cacheableFileAccessAllowlist: Context.getCurrentHost().os !== "win" ? [] : [
        // Allow the debugger to be able to be launched from BuildXL Builds
        {
            name: "JitDebugger",
            toolPath: f`${Environment.getDirectoryValue("SystemRoot")}/system32/vsjitdebugger.exe`,
            pathRegex: `.*${Environment.getStringValue("CommonProgramFiles").replace("\\", "\\\\")}\\\\Microsoft Shared\\\\VS7Debug\\\\.*`
        },
        // cl.exe may write temporary files under its working directory
        {
            name: "cl.exe",
            toolPath: a`cl.exe`,
            pathRegex: ".*.tmp"
        }
    ]
});