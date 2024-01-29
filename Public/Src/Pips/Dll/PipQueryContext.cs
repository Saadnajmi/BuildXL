// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace BuildXL.Pips
{
    /// <summary>
    /// Enumeration of callsites to GetPip that might cause a Pip to get deserialized
    /// </summary>
    /// <remarks>
    /// This is used to compute overall statistics on what operations caused Pips to get deserialized (which is something to be avoided)
    /// </remarks>
    public enum PipQueryContext : byte
    {
#pragma warning disable 1591
        PipGraphRetrieveAllPips,
        PipGraphRetrievePipsOfType,
        PipGraphRetrieveScheduledPips,
        PipGraphRetrievePipsByStateOfType,
        PipGraphGetPipFromUInt32,
        PipGraphGetPipForWorkerService,
        PipGraphGetPipForDistributingPipExecutor,
        PipGraphGetPipDependenciesOfNode,
        PipGraphGetPipsDependentUponNode,
        PipGraphGetProducingPips,
        PipGraphGetConsumingPips,
        PipGraphGetPipsPerSpecFile,
        PipGraphTryFindProducer,
        PipGraphAddPipToPipDependency,
        PipGraphAddServicePipDependency,
        PipGraphQueryFileArtifactPipDataWriteFile,
        PipGraphQueryFileArtifactPipDataCopyFile,
        PipGraphGetProducingPip,
        PipGraphListSealedDirectoryContents,
        PipGraphIsValidInputFileArtifact1,
        PipGraphIsValidInputFileArtifact2,
        PipGraphIsValidInputFileArtifact3,
        PipGraphIsValidOutputFileArtifactSealing1,
        PipGraphIsValidOutputFileArtifactSealing2,
        PipGraphIsValidOutputFileArtifactRewrite1,
        PipGraphIsValidOutputFileArtifactRewrite2,
        PipGraphIsValidOutputFileArtifactRewrite3,
        PipGraphIsValidOutputDirectory1,
        PipGraphFilterNodes,
        SchedulerOnPipCompleted,
        SchedulerSchedulePipIfReady,
        SchedulerReportSkippedPip,
        SchedulerTryMaterializePipDependenciesAsyncCopyFile,
        SchedulerTryMaterializePipDependenciesAsyncIpcPip,
        SchedulerInternalTryMaterializePipOutputsAsync,
        SchedulerGetAndRecordFileContentHashAsync,
        SchedulerInternalTryComputePipFingerprintAsync1,
        SchedulerInternalTryComputePipFingerprintAsync2,
        SchedulerInternalTryComputePipFingerprintAsync3,
        SchedulerInternalTryComputePipFingerprintAsync4,
        SchedulerOnEstablishingPipFingerprintCompleted,
        SchedulerInternalTryMaterializePipOutputsTopDownAsync,
        SchedulerOnMaterializingPipOutputs1,
        SchedulerOnMaterializingPipOutputs2,
        SchedulerOnMaterializingPipOutputs3,
        SchedulerInvalidateMaterializedPipOutputs1,
        SchedulerInvalidateMaterializedPipOutputs2,
        SchedulerInvalidateMaterializedPipOutputs3,
        SchedulerFileContentManagerHostMaterializeFile,
        SchedulerMaterializePipOutputs2,
        SchedulerMaterializePipOutputs3,
        SchedulerExecutePips,
        SchedulerReplayProcessWithWarnings,
        SchedulerOnPipSemaphoreQueued,
        SchedulerOnPipSemaphoreDequeued,
        SchedulerInternalTryComputePipFingerprintAsync,
        SchedulerAreInputsPresentForSkipDependencyBuild,
        SchedulerPartialGraphReload,
        SchedulerExecuteSealDirectoryPip,
        SealedDirectoryTableTryFindDirectoryArtifactContainingFileArtifact,
        ViewerAnalyzer,
        LoggingUncacheableProcessImpact,
        HandlePipStepOnWorker,
        LoggingPipFailedOnWorker,
        Test,
        PipQueueGetCpuQueueProcessResources,
        FileMonitoringViolationAnalyzerClassifyAndReportAggregateViolations,
        SchedulerCloudBuildLogging,
        IdeGenerator,
        RunnablePip,
        CollectPipInputsToMaterializeForIPC,
        PipGraphPostValidation,
        FingerprintStore,
        PipGraphGetSealDirectoryByKind,
        GetSealDirectoryFingerprint,
        Explorer,
        PreserveOutput,
        CacheMaterializationError,
        VisualStudioDebugView,
        PathSetAugmentation,
        DumpPipLiteAnalyzer,
        End // This must be the last entry
#pragma warning restore 1591
    }
}
