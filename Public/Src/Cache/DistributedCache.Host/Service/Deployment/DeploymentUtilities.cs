// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading;
using System.Threading.Tasks;
using BuildXL.Cache.ContentStore.Hashing;
using BuildXL.Cache.ContentStore.Interfaces.FileSystem;
using BuildXL.Cache.ContentStore.Interfaces.Secrets;
using BuildXL.Cache.ContentStore.Stores;
using BuildXL.Cache.ContentStore.Utils;
using BuildXL.Cache.Host.Configuration;
using static BuildXL.Cache.Host.Configuration.DeploymentManifest;

namespace BuildXL.Cache.Host.Service
{
    /// <summary>
    /// Utilities for interacting with deployment root populated by <see cref="DeploymentIngester"/>
    /// </summary>
    public static class DeploymentUtilities
    {
        /// <summary>
        /// Options used when deserializing deployment configuration
        /// </summary>
        public static JsonSerializerOptions ConfigurationSerializationOptions { get; } = new JsonSerializerOptions()
        {
            AllowTrailingCommas = true,
            ReadCommentHandling = JsonCommentHandling.Skip,
            Converters =
            {
                new TimeSpanJsonConverter(),
                new StringConvertibleSettingJsonConverterFactory(),
                new BoolJsonConverter(),
                new JsonStringEnumConverter()
            }
        };

        /// <summary>
        /// Special synthesized drop url for config files added by DeploymentRunner
        /// </summary>
        public static Uri ConfigDropUri { get; } = new Uri("config://files/");

        /// <summary>
        /// Options used when reading deployment configuration
        /// </summary>
        public static JsonDocumentOptions ConfigurationDocumentOptions { get; } = new JsonDocumentOptions()
        {
            AllowTrailingCommas = true,
            CommentHandling = JsonCommentHandling.Skip
        };

        /// <summary>
        /// Relative path to root of CAS for deployment files
        /// </summary>
        private static RelativePath CasRelativeRoot { get; } = new RelativePath("cas");

        /// <summary>
        /// Relative path to deployment manifest reference file from deployment root
        /// </summary>
        private static RelativePath DeploymentManifestIdRelativePath { get; } = new RelativePath("DeploymentManifestId.txt");

        /// <summary>
        /// Relative path to deployment manifest from deployment root
        /// </summary>
        private static RelativePath DeploymentManifestRelativePath { get; } = new RelativePath("DeploymentManifest.json");

        /// <summary>
        /// File name of deployment configuration in synthesized config drop
        /// </summary>
        public static string DeploymentConfigurationFileName { get; } = "DeploymentConfiguration.json";

        /// <summary>
        /// Gets the relative from deployment root to the file with given hash in CAS
        /// </summary>
        public static RelativePath GetContentRelativePath(ContentHash hash)
        {
            return CasRelativeRoot / FileSystemContentStoreInternal.GetPrimaryRelativePath(hash);
        }

        /// <summary>
        /// Gets the absolute path to the CAS root given the deployment root
        /// </summary>
        public static AbsolutePath GetCasRootPath(AbsolutePath deploymentRoot)
        {
            return deploymentRoot / CasRelativeRoot;
        }

        /// <summary>
        /// Gets the absolute path to the deployment manifest
        /// </summary>
        public static AbsolutePath GetDeploymentManifestPath(AbsolutePath deploymentRoot)
        {
            return deploymentRoot / DeploymentManifestRelativePath;
        }

        /// <summary>
        /// Gets the absolute path to the deployment manifest reference file
        /// </summary>
        public static AbsolutePath GetDeploymentManifestIdPath(AbsolutePath deploymentRoot)
        {
            return deploymentRoot / DeploymentManifestIdRelativePath;
        }

        /// <summary>
        /// Gets the absolute path to the deployment configuration under the deployment root
        /// </summary>
        public static AbsolutePath GetDeploymentConfigurationPath(AbsolutePath deploymentRoot, DeploymentManifest manifest)
        {
            var configFileSpec = manifest.GetDeploymentConfigurationSpec();
            return deploymentRoot / GetContentRelativePath(new ContentHash(configFileSpec.Hash));
        }

        /// <summary>
        /// Gets the file spec for the deployment configuration file
        /// </summary>
        public static FileSpec GetDeploymentConfigurationSpec(this DeploymentManifest manifest)
        {
            var configDropLayout = manifest.Drops[ConfigDropUri.OriginalString];
            return configDropLayout[DeploymentConfigurationFileName];
        }

        /// <summary>
        /// Serialize the value to json using <see cref="ConfigurationSerializationOptions"/>
        /// </summary>
        public static string JsonSerialize<T>(T value)
        {
            return JsonSerializer.Serialize<T>(value, ConfigurationSerializationOptions);
        }

        /// <summary>
        /// Deserialize the value to json using <see cref="ConfigurationSerializationOptions"/>
        /// </summary>
        public static T JsonDeserialize<T>(string value)
        {
            return JsonSerializer.Deserialize<T>(value, ConfigurationSerializationOptions);
        }

#pragma warning disable AsyncFixer03 // Fire & forget async void methods
        public static async void WatchFileAsync(string path, CancellationToken token, TimeSpan pollingInterval, Action onChanged, Action<Exception> onError)
#pragma warning restore AsyncFixer03 // Fire & forget async void methods
        {
            int retries;
            var info = getChangeInfo(path);
            while (true)
            {
                try
                {
                    await Task.Delay(pollingInterval, token);

                    var newInfo = getChangeInfo(path);
                    if (newInfo != info)
                    {
                        info = newInfo;
                        onChanged();
                    }
                }
                catch (OperationCanceledException)
                {
                    return;
                }
                catch (Exception ex)
                {
                    retries--;
                    if (retries == 0)
                    {
                        onError(ex);
                    }
                }
            }

            (long Length, DateTime LastWriteTimeUtc, DateTime CreationTimeUtc) getChangeInfo(string path)
            {
                var fileInfo = new System.IO.FileInfo(path);
                var result = (fileInfo.Length, fileInfo.LastWriteTimeUtc, fileInfo.CreationTimeUtc);

                // On success, reset number of retries
                retries = 5;
                return result;
            }
        }

        /// <summary>
        /// Computes an hexidecimal content id for the given string
        /// </summary>
        public static string ComputeContentId(string value)
        {
            return HashInfoLookup.GetContentHasher(HashType.Murmur).GetContentHash(Encoding.UTF8.GetBytes(value)).ToHex();
        }

        /// <summary>
        /// Gets a json preprocessor for the given host parameters
        /// </summary>
        public static JsonPreprocessor GetHostJsonPreprocessor(HostParameters parameters)
        {
            return new JsonPreprocessor(
                constraintDefinitions: new Dictionary<string, string>()
                    {
                        { "Stamp", parameters.Stamp },
                        { "MachineFunction", parameters.MachineFunction },
                        { "Region", parameters.Region },
                        { "Ring", parameters.Ring },
                        { "Environment", parameters.Environment },
                        { "Env", parameters.Environment },
                        { "Machine", parameters.Machine },

                        // Backward compatibility where machine function was not
                        // its own constraint
                        { "Feature", parameters.MachineFunction == null ? null : "MachineFunction_" + parameters.MachineFunction },
                    }
                    .Where(e => !string.IsNullOrEmpty(e.Value))
                    .Select(e => new ConstraintDefinition(e.Key, new[] { e.Value })),
                replacementMacros: new Dictionary<string, string>()
                    {
                        { "Env", parameters.Environment },
                        { "Environment", parameters.Environment },
                        { "Machine", parameters.Machine },
                        { "Stamp", parameters.Stamp },
                        { "StampId", parameters.Stamp },
                        { "Region", parameters.Region },
                        { "RegionId", parameters.Region },
                        { "Ring", parameters.Ring },
                        { "RingId", parameters.Ring },
                        { "ServiceDir", parameters.ServiceDir },
                    }
                .Where(e => !string.IsNullOrEmpty(e.Value))
                .ToDictionary(e => e.Key, e => e.Value));
        }

        private class BoolJsonConverter : JsonConverter<bool>
        {
            public override bool Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
            {
                switch (reader.TokenType)
                {
                    case JsonTokenType.String:
                        return bool.Parse(reader.GetString());
                    case JsonTokenType.True:
                        return true;
                    case JsonTokenType.False:
                        return false;
                }

                throw new JsonException();
            }

            public override void Write(Utf8JsonWriter writer, bool value, JsonSerializerOptions options)
            {
                writer.WriteBooleanValue(value);
            }
        }

        private class TimeSpanJsonConverter : JsonConverter<TimeSpan>
        {
            public override TimeSpan Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
            {
                var timeSpanString = reader.GetString();
                if (TimeSpanSetting.TryParseReadableTimeSpan(timeSpanString, out var result))
                {
                    return result;
                }

                return TimeSpan.Parse(timeSpanString);
            }

            public override void Write(Utf8JsonWriter writer, TimeSpan value, JsonSerializerOptions options)
            {
                writer.WriteStringValue(value.ToString());
            }
        }

        private class StringConvertibleSettingJsonConverterFactory : JsonConverterFactory
        {
            public override bool CanConvert(Type typeToConvert)
            {
                return typeToConvert.IsValueType && typeof(IStringConvertibleSetting).IsAssignableFrom(typeToConvert);
            }

            public override JsonConverter CreateConverter(Type typeToConvert, JsonSerializerOptions options)
            {
                return (JsonConverter)Activator.CreateInstance(typeof(Converter<>).MakeGenericType(typeToConvert));
            }

            private class Converter<T> : JsonConverter<T>
                where T : struct, IStringConvertibleSetting
            {
                private readonly T _defaultValue = default;

                public override T Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
                {
                    var stringValue = reader.GetString();
                    return (T)_defaultValue.ConvertFromString(stringValue);
                }

                public override void Write(Utf8JsonWriter writer, T value, JsonSerializerOptions options)
                {
                    writer.WriteStringValue(value.ConvertToString());
                }
            }
        }
    }
}
