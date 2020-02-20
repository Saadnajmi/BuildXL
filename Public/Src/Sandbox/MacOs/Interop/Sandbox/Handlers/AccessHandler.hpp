// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

#ifndef AccessHandler_hpp
#define AccessHandler_hpp

#include "ESSandbox.h"
#include "Checkers.hpp"

enum ReportResult
{
    kReported,
    kSkipped,
    kFailed
};

typedef bool (Handler)(void *data);

struct AccessHandler
{
private:

    const char *IgnoreDataPartitionPrefix(const char* path);
    const char *kDataPartitionPrefix = "/System/Volumes/Data/";
    const size_t kAdjustedPrefixLength = strlen("/System/Volumes/Data");
    
    ESSandbox *sandbox_;

    std::shared_ptr<SandboxedProcess> process_;

    ReportResult ReportFileOpAccess(FileOperation operation,
                                    PolicyResult policy,
                                    AccessCheckResult accessCheckResult,
                                    pid_t processID);

    inline void SetProcess(std::shared_ptr<SandboxedProcess> process) { process_ = process; }

protected:

    inline ESSandbox* GetSandbox()                        const { return sandbox_; }
    inline std::shared_ptr<SandboxedProcess> GetProcess() const { return process_; }
    inline std::shared_ptr<SandboxedPip> GetPip()         const { return process_->GetPip(); }

    PolicySearchCursor FindManifestRecord(const char *absolutePath, size_t pathLength = -1);
    
    /*!
     * Copies 'process_->getPath()' into 'report->path'.
     */
    void SetProcessPath(AccessReport *report);

    /*!
     * Template for checking and reporting file accesses.
     *
     * The key used for looking up if the operation was already reported is "<operation>,<path>".
     *
     * @param operation Operation to be executed
     * @param path Absolute path against which the operation is to be executed
     * @param checker Checker function to apply to policy
     * @param msg The EndpointSecurity message containing all necessary details about the observed event
     * @param isDir Indicates if the report is being generated for a directory or file
     */
    AccessCheckResult CheckAndReportInternal(FileOperation operation,
                                     const char *path,
                                     CheckFunc checker,
                                     const es_message_t *msg,
                                     bool isDir);

    inline AccessCheckResult CheckAndReport(FileOperation operation, const char *path, CheckFunc checker, const es_message_t *msg)
    {
        return CheckAndReportInternal(operation, path, checker, msg, false);
    }

    inline AccessCheckResult CheckAndReport(FileOperation operation, const char *path, CheckFunc checker, const es_message_t *msg, bool isDir)
    {
        return CheckAndReportInternal(operation, path, checker, msg, isDir);
    }

public:

    AccessHandler(ESSandbox *sandbox)
    {
        sandbox_           = sandbox;
        process_           = nullptr;
    }

    ~AccessHandler()
    {
        sandbox_ = nullptr;
        process_ = nullptr;
    }

    /*!
     * Attempts to find a tracked ProcessObject instance that corresponds to a given 'pid'.
     * If successful, initializes this object with the found ProcessObject.
     *
     * IMPORTANT: This should be the first method to call after upon constructor this object.
     *            Whenever the initialization fails, this object should not be used futher.
     *
     * @param pid Process ID to try to find.
     * @result Indicates whether the initialization was successful.
     */
    bool TryInitializeWithTrackedProcess(pid_t pid);

    inline bool HasTrackedProcess()             const { return process_ != nullptr; }
    inline pid_t GetProcessId()                 const { return GetPip()->GetProcessId(); }
    inline pipid_t GetPipId()                   const { return GetPip()->GetPipId(); }
    inline int GetProcessTreeSize()             const { return GetPip()->GetTreeSize(); }
    inline FileAccessManifestFlag GetFamFlags() const { return GetPip()->GetFamFlags(); }

    PolicyResult PolicyForPath(const char *absolutePath);

    bool ReportProcessTreeCompleted(pid_t processId);
    bool ReportProcessExited(pid_t childPid);
    bool ReportChildProcessSpawned(pid_t childPid);
};

#endif /* AccessHandler_hpp */
