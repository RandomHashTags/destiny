//
//  HTTPRequestMethod.swift
//
//
//  Created by Evan Anderson on 1/4/25.
//

import DestinyBlueprint
import SwiftSyntax

// MARK: HTTPRequestMethod
// Why use this over the apple/swift-http-types?
//  - this one performs about the same and doesn't waste memory when stored in other values.
//  - this memory layout is 1,1,1 vs `HTTPRequest.Method`'s 8,16,16 (alignment, size, stride)

// TODO: move to own repo?

/// HTTP request methods.
/// 
/// Missing a method? Request it [here](https://github.com/RandomHashTags/destiny/discussions/new?category=request-feature).
public enum HTTPRequestMethod : String, Sendable {
    //
    //
    // MARK: Standard
    //
    //

    /// Establishes a tunnel to the server specified by the target resource.
    /// 
    /// - Common Usages:
    ///   - SSL/TLS requests through a proxy
    case connect

    /// Removes a specified resource from the server.
    case delete

    /// Retrieves data from a specified resource. As a safe and idempotent request, it shouldn't change server state and can be repeated without side effects.
    case get

    /// Similar to `get` but without the response body.
    /// 
    /// - Common Usages:
    ///   - checking whether a resource exists
    ///   - fetching metadata
    case head

    /// Returns the HTTP methods that the server supports for a specific resource.
    /// 
    /// - Common Usages:
    ///   - pre-flight checks for CORS (Cross-Origin Resource Sharing)
    case options

    /// Partially updates an existing resource. Unlike `put`, it only replaces the specified fields.
    case patch

    /// Submits data to be processed to a specified resource. Can cause changes on the server, such as creating new resources.
    case post

    /// Replaces all current representations of the target resource with the uploaded content. Being idempotent, multiple calls with the same data will have the same effect.
    case put

    /// Echoes back the received request.
    /// 
    /// - Common Usages:
    ///   - debugging
    case trace

    /// Manages access control lists for a resource.
    case acl

    /// Manage baselines of a resource, enabling version tracking.
    case baselineControl

    /// Cancels an ongoing task.
    case cancel

    /// Finalizes a resource version and makes the new version available.
    case checkin

    /// Checks out a resource for editing.
    case checkout

    /// Copies a resource from one URI to another.
    case copy

    /// Associates a label with a specific version of a resource.
    case label

    /// Establishes a relationship between two resources.
    case link

    /// Locks a resource to prevent modification by others.
    case lock

    /// Merges changes made to a resource in different versions.
    case merge

    /// Sends messages between endpoints.
    /// 
    /// - Common Usages:
    ///   - protocols (like SIP)
    case message

    /// Creates a new activity.
    /// 
    /// - Common Usages:
    ///   - version control systems
    case mkactivity

    /// Creates a new collection (directory, folder, etc) at the target location.
    case mkcol

    /// Creates a redirect reference resource that behaves as a symbolic link to another resource.
    case mkredirectref

    /// Creates a new workspace for version-controlled resources.
    case mkworkspace

    /// Moves a resource from one URI to another.
    case move

    /// Sends updates or notifications regarding a subscribed resource.
    case notify

    /// Alters the order of resources within a collection.
    case orderpatch

    /// Retrieves properties, stored as metadata, from a resource.
    case propfind

    /// Updates the properties of a resource.
    case proppatch

    /// Obtain information about a resource's history.
    case report

    /// Subscribes to updates from a resource.
    /// 
    /// - Common Usages:
    ///   - presence systems
    case subscribe

    /// Cancels the effect of a previous `checkout`, essentially undoing it.
    case uncheckout

    /// Removes a relationship between two resources.
    case unlink

    /// Unlocks a resource that is locked.
    case unlock

    /// Cancels a subscription to a resource.
    case unsubscribe

    /// Updates a resource.
    case update

    /// Updates the target of a redirect reference resource.
    case updateredirectref

    /// Puts a resource under version control.
    case versionControl

    //
    //
    // MARK: Non-standard
    //
    //

    /// Announce new information about a resource.
    /// 
    /// - Common Usages:
    ///   - multimedia streaming
    ///   - RTSP
    case announce

    /// Adds new content to an existing resource, appending data rather than replacing it.
    case append

    /// Initiate or manage an authentication task.
    /// 
    /// - Common Usages:
    ///   - APIs with custom auth workflows
    case authenticate

    /// Manage and authorize access to a resource or service.
    case authorization

    /// Initiates the backup of a resource or system state.
    /// 
    /// - Common Usages:
    ///   - API management tools
    ///   - cloud services
    ///   - data storage
    case backup

    /// Bundle multiple requests into a single HTTP request.
    /// 
    /// - Common Usages:
    ///   - API gateway systems
    case batch

    /// Create multiple bindings to a single resource.
    case bind

    /// Check the state or health of a resource, system, or service.
    /// 
    /// - Common Usages:
    ///   - health check in monitoring tools
    case check

    /// Clears or removes data associated with a resource.
    /// 
    /// - Common Usages:
    ///   - caching systems
    ///   - transactional APIs
    case clear

    /// Clones an existing resource.
    /// 
    /// - Common Usages:
    ///   - version control systems
    ///   - systems managing infrastructure as code
    case clone

    /// Closes a session or connection between the client and server.
    /// 
    /// - Common Usages:
    ///   - persistent protocols (WebSockets or streaming protocols)
    case close

    /// Marks a task or operation as complete.
    /// 
    /// - Common Usages:
    ///   - long-running jobs or workflows
    case complete

    /// Converts a resource from one format or type to another.
    /// 
    /// - Common Usages:
    ///   - systems dealing with file formats or data transformations
    case convert

    // TODO: add documentation for `curate`
    case curate

    /// Similar to `disable`, but can be more specific to features, services, or user accounts.
    case deactivate

    /// Reduces the availability of a resource.
    /// 
    /// - Common Usages:
    ///   - quota/rate-limiting
    case deplete

    /// Triggers the deployment of a resource or application.
    /// 
    /// - Common Usages:
    ///   - continuous/integration deployment systems
    case deploy

    /// The opposite of `register`, it removes a client, device, or resource from a server or system.
    /// 
    /// - Common Usages:
    ///   - protocols (like SIP)
    case deregister

    /// Describe media content.
    /// 
    /// - Common Usages:
    ///   - streaming protocols like RTSP (Real-Time Streaming Protocol)
    case describe
    
    /// Delivers a resource.
    /// 
    /// - Common Usages:
    ///   - messaging/delivery APIs
    case deliver

    /// Disables a feature, resource, or operation on the server.
    /// 
    /// - Common Usages:
    ///   - API or system management platforms
    case disable

    /// Sends or dispatches a resource.
    /// 
    /// - Common Usages:
    ///   - job processing systems
    ///   - task queues
    case dispatch

    // TODO: add documentation for `draft`
    case draft

    /// Outputs detailed information about a resource.
    /// 
    /// - Common Usages:
    ///   - debugging
    case dump

    /// Enables a feature, resource, or operation; opposite of `disable`.
    case enable

    /// Set up a connection or session between the client and server.
    case establish

    /// Executes a command or task.
    /// 
    /// - Common Usages:
    ///   - remote command execution
    ///   - server management
    ///   - job control systems
    case execute

    /// Expands or reveals more details about a resource.
    /// 
    /// - Common Usages:
    ///   - APIs that return nested or related data
    case expand

    /// Fetch data from a resource, often more granular than a `get` request.
    /// 
    /// - Common Usages:
    ///   - specific protocols or APIs
    case fetch

    /// Completes an operation or transaction.
    /// 
    /// - Common Usages:
    ///   - APIs dealing with financial operations (payment gateways)
    case finalize

    /// Forces an operation to proceed, bypassing certain checks or validations.
    case force

    /// Freezes a resource or state, preventing it from changing.
    /// 
    /// - Common Usages:
    ///   - Systems that need to maintain the consistency of a resource
    case freeze

    /// Initiates or completes a handshake task between client and server.
    /// 
    /// - Common Usages:
    ///   - WebSocket or custom communication protocols
    case handshake

    /// Places a temporary hold on a resource, preventing it from being modified by others.
    case hold

    /// Send mid-session information.
    /// 
    /// - Common Usages:
    ///   - certain protocols (like SIP)
    case info

    /// Prepare a resource or system for operation.
    /// 
    /// - Common Usages:
    ///   - cloud systems
    ///   - custom workflows
    case initialize

    /// Installs a resource or component.
    /// 
    /// - Common Usages:
    ///   - package management systems
    ///   - cloud provisioning tools
    case install

    /// Invite clients to participate in a session.
    /// 
    /// - Common Usages:
    ///   - protocols like SIP (Session Initiation Protocol)
    case invite

    /// Joins two or more resources or sessions.
    /// 
    /// - Common Usages:
    ///   - handling merging datasets or combining operations
    case join

    /// Moves a resource from one environment or system to another.
    /// 
    /// - Common Usages:
    ///   - cloud/infrastructure management
    case migrate

    // TODO: add documentation for `mkcalendar`
    case mkcalendar

    // TOOD: add documentation for `msearch`
    case msearch

    /// Sends a notification or event to all connected clients or listeners.
    /// 
    /// - Common Usages:
    ///   - real-time systems
    ///   - notification APIs
    case notifyall

    /// Notify about file changes.
    /// 
    /// - Common Usages:
    ///   - file-monitoring
    ///   - event-driven systems
    case notifyFile

    /// Opens a resource or connection.
    /// 
    /// - Common Usages:
    ///   - managing persistent or long-running connections (WebSockets)
    case open

    /// Send messages to an outbox.
    /// 
    /// - Common Usages:
    ///   - messaging
    ///   - email APIs
    case outbox

    /// Requests or provides partial data.
    /// 
    /// - Common Usages:
    ///   - managing incremental updates
    ///   - data transfers
    case partial

    /// Variation of `patch` to apply partial updates to a resource.
    case partialUpdate

    /// Variation of `patch` to apply updates involving form data.
    /// 
    /// - Common Usages:
    ///   - APIs
    case patchForm

    /// Updates specific parts of a resource.
    /// 
    /// - Common Usages:
    ///   - multipart data (file uploading)
    case patchMultipart

    /// Pauses media playback.
    /// 
    /// - Common Usages:
    ///   - streaming protocols like RTSP or HLS (HTTP Live Streaming)
    case pause

    /// Check if a service or resource is alive.
    /// 
    /// - Common Usages:
    ///   - monitoring systems
    case ping

    /// Acknowledge a `ping` request.
    /// 
    /// - Common Usages:
    ///   - protocols that support heartbeats or keep-alive mechanisms
    case pingAck

    /// Starts the playback of media content specified in the request.
    /// 
    /// - Common Usages:
    ///   - RTSP
    case play

    /// Checks the status of a resource or task repeatedly at intervals.
    /// 
    /// - Common Usages:
    ///   - systems where asynchronous results are expected
    case poll

    /// Prepares a resource for future action.
    /// 
    /// - Common Usages:
    ///   - payment systems
    case prepare

    /// Provision a resource, such as a virtual machine or a container.
    /// 
    /// - Common Usages:
    ///   - network/cloud services
    case provision

    /// Purge cached content.
    /// 
    /// - Common Usages:
    ///   - caching proxy
    case purge

    /// Query against a resource.
    /// 
    /// - Common Usages
    ///   - databases
    ///   - APIs
    case query

    /// Rebinds a resource from one location to another.
    case rebind

    /// Redirects the client to a different URL.
    /// 
    /// - Common Usages:
    ///   - load balancers
    ///   - media streaming systems
    case redirect

    /// Start recording media.
    /// 
    /// - Common Usages:
    ///   - RTSP
    case record

    /// Attempts to recover a failed or corrupted resource.
    /// 
    /// - Common Usages:
    ///   - disaster recovery
    ///   - system restoration tools
    case recover

    /// Refer another resource or contact for redirection or action.
    /// 
    /// - Common Usages:
    ///   - SIP
    case refer

    /// Registers content with a server (user agent, device, etc).
    /// 
    /// - Common Usages:
    ///   - SIP or similar systems
    case register

    /// Explicitly rejects an operation or resource request.
    case reject

    /// Reloads the current resource or configuration.
    /// 
    /// - Common Usages:
    ///   - content delivery networks (CDNs)
    ///   - system management tools
    case reload

    /// Initiates replication of a resource.
    /// 
    /// - Common Usages:
    ///   - distributed systems
    ///   - data synchronization services
    case replicate

    /// Temporarily reserve a resource for a client.
    /// 
    /// - Common Usages:
    ///   - booking systems
    case reserve

    /// Resets a resource, session, or task.
    /// 
    /// - Common Usages:
    ///   - systems managing long-running tasks
    ///   - networking protocols
    case reset

    /// Restart a resource, session, or task.
    /// 
    /// - Common Usages:
    ///   - systems managing long-running tasks
    case restart

    /// Restores a resource from a previous backup.
    /// 
    /// - Common Usages:
    ///   - data backup and recovery
    case restore

    /// Resumes a paused operation.
    /// 
    /// - Common Usages:
    ///   - long-running tasks
    case resume

    /// Attempts to re-run a failed operation.
    /// 
    /// - Common Usages:
    ///   - APIs that support retries for failed transactions
    case retry

    /// Retries a failed operation with a specified limit of retry attempts.
    case retryCount

    /// Rewinds a resource or task to a previous point.
    /// 
    /// - Common Usages:
    ///   - streaming
    ///   - long-running tasks
    case rewind

    /// Rolls back a resource to a previous state or version.
    case rollback

    /// Rotates resources or logs.
    /// 
    /// - Common Usages:
    ///   - logging systems
    ///   - key rotation for security systems
    case rotate

    /// Search for resources that match specific criteria.
    case search

    /// Search for resources across multiple collections.
    /// 
    /// - Common Usages:
    ///   - APIs
    case searchall

    /// Initialize the setup of a session for media streaming.
    /// 
    /// - Common Usages:
    ///   - RTSP
    case setup

    /// Terminates a system, service, or resource.
    /// 
    /// - Common Usages:
    ///   - server management
    ///   - API-based workflows
    case shutdown

    /// Skips over a part of a task or operation.
    /// 
    /// - Common Usages:
    ///   - tasks/workflows with multiple steps
    case skip

    // TODO: add documentation for `source`
    case source

    /// Divides a resource or job into smaller parts.
    /// 
    /// - Common Usages:
    ///   - distributed systems
    ///   - tasks that involve large datasets
    case split

    /// Temporarily stores a resource or state for later use.
    /// 
    /// - Common Usages:
    ///   - version control systems
    ///   - development tools
    case stash

    /// Stops a resource or task.
    /// 
    /// - Common Usages:
    ///   - long-running tasks/workflows
    ///   - streaming systems
    case stop

    /// Submits a resource or data set to a service or system for processing.
    case submit

    /// Temporarily halts an operation, session, or task; similar to `pause` but can be broader.
    /// 
    /// - Common Usages:
    ///   - background tasks
    ///   - long-running tasks
    case suspend

    /// Synchronize resources between systems.
    /// 
    /// - Common Usages:
    ///   - file systems
    ///   - data replication services
    case sync

    /// Syncs the state of a resource between clients and servers.
    /// 
    /// - Common Usages:
    ///   - distributed systems
    ///   - collaborative applications
    case syncstate

    /// Terminates a media session.
    /// 
    /// - Common Usages:
    ///   - streaming protocols (RTSP)
    case teardown

    /// Allows a resource to resume changes after being frozen; opposite of `freeze`.
    case thaw

    /// Manage tickets for events or access to resources.
    case ticket

    /// Removes multiple bindings from a single resource.
    case unbind

    /// Removes a block on a resource or task.
    /// 
    /// - Common Usages:
    ///   - messaging systems
    ///   - network protocols
    ///   - user management
    case unblock

    /// Reverts or removes a previously deployed resource.
    /// 
    /// - Common Usages:
    ///   - cloud management systems
    ///   - deployment pipelines
    case undeploy

    /// Removes a previously installed resource or component.
    /// 
    /// - Common Usages:
    ///   - package management
    ///   - system provisioning
    case uninstall

    /// Upgrades a connection (such as upgrading HTTP to WebSocket) or a resource to a newer version.
    /// 
    /// - Common Usages:
    ///   - cloud services
    ///   - network protocols
    case upgrade

    /// Removes a previously set property or flag from a resource.
    /// 
    /// - Common Usages:
    ///   - APIs
    ///   - system management protocols
    case unset

    /// Validates a resource.
    /// 
    /// - Common Usages:
    ///   - APIs that check whether a resource conforms to specific criteria
    case validate

    /// Verify the integrity or authenticity of a resource.
    /// 
    /// - Common Usages:
    ///   - APIs related to digital signatures, security, or blockchain systems
    case verify
}

// MARK: Raw Name
extension HTTPRequestMethod {
    @inlinable
    public var rawName : InlineArray<20, UInt8> {
        switch self {
        case .acl: #inlineArray(count: 20, "ACL")
        case .announce: #inlineArray(count: 20, "ANNOUNCE")
        case .append: #inlineArray(count: 20, "APPEND")
        case .authenticate: #inlineArray(count: 20, "AUTHENTICATE")
        case .authorization: #inlineArray(count: 20, "AUTHORIZATION")
        case .baselineControl: #inlineArray(count: 20, "BASELINE-CONTROL")
        case .backup: #inlineArray(count: 20, "BACKUP")
        case .batch: #inlineArray(count: 20, "BATCH")
        case .bind: #inlineArray(count: 20, "BIND")
        case .cancel: #inlineArray(count: 20, "CANCEL")
        case .check: #inlineArray(count: 20, "CHECK")
        case .checkin: #inlineArray(count: 20, "CHECKIN")
        case .checkout: #inlineArray(count: 20, "CHECKOUT")
        case .clear: #inlineArray(count: 20, "CLEAR")
        case .clone: #inlineArray(count: 20, "CLONE")
        case .close: #inlineArray(count: 20, "CLOSE")
        case .complete: #inlineArray(count: 20, "COMPLETE")
        case .connect: #inlineArray(count: 20, "CONNECT")
        case .convert: #inlineArray(count: 20, "CONVERT")
        case .copy: #inlineArray(count: 20, "COPY")
        case .curate: #inlineArray(count: 20, "CURATE")
        case .deactivate: #inlineArray(count: 20, "DEACTIVATE")
        case .delete: #inlineArray(count: 20, "DELETE")
        case .deliver: #inlineArray(count: 20, "DELIVER")
        case .deplete: #inlineArray(count: 20, "DEPLETE")
        case .deploy: #inlineArray(count: 20, "DEPLOY")
        case .deregister: #inlineArray(count: 20, "DEREGISTER")
        case .describe: #inlineArray(count: 20, "DESCRIBE")
        case .disable: #inlineArray(count: 20, "DISABLE")
        case .dispatch: #inlineArray(count: 20, "DISPATCH")
        case .draft: #inlineArray(count: 20, "DRAFT")
        case .dump: #inlineArray(count: 20, "DUMP")
        case .enable: #inlineArray(count: 20, "ENABLE")
        case .establish: #inlineArray(count: 20, "ESTABLISH")
        case .execute: #inlineArray(count: 20, "EXECUTE")
        case .expand: #inlineArray(count: 20, "EXPAND")
        case .fetch: #inlineArray(count: 20, "FETCH")
        case .finalize: #inlineArray(count: 20, "FINALIZE")
        case .force: #inlineArray(count: 20, "FORCE")
        case .freeze: #inlineArray(count: 20, "FREEZE")
        case .get: #inlineArray(count: 20, "GET")
        case .handshake: #inlineArray(count: 20, "HANDSHAKE")
        case .head: #inlineArray(count: 20, "HEAD")
        case .hold: #inlineArray(count: 20, "HOLD")
        case .info: #inlineArray(count: 20, "INFO")
        case .initialize: #inlineArray(count: 20, "INITIALIZE")
        case .install: #inlineArray(count: 20, "INSTALL")
        case .invite: #inlineArray(count: 20, "INVITE")
        case .join: #inlineArray(count: 20, "JOIN")
        case .label: #inlineArray(count: 20, "LABEL")
        case .link: #inlineArray(count: 20, "LINK")
        case .lock: #inlineArray(count: 20, "LOCK")
        case .merge: #inlineArray(count: 20, "MERGE")
        case .message: #inlineArray(count: 20, "MESSAGE")
        case .migrate: #inlineArray(count: 20, "MIGRATE")
        case .mkactivity: #inlineArray(count: 20, "MKACTIVITY")
        case .mkcalendar: #inlineArray(count: 20, "MKCALENDAR")
        case .mkcol: #inlineArray(count: 20, "MKCOL")
        case .mkredirectref: #inlineArray(count: 20, "MKREDIRECTREF")
        case .mkworkspace: #inlineArray(count: 20, "MKWORKSPACE")
        case .move: #inlineArray(count: 20, "MOVE")
        case .msearch: #inlineArray(count: 20, "MSEARCH")
        case .notify: #inlineArray(count: 20, "NOTIFY")
        case .notifyall: #inlineArray(count: 20, "NOTIFYALL")
        case .notifyFile: #inlineArray(count: 20, "NOTIFY-FILE")
        case .open: #inlineArray(count: 20, "OPEN")
        case .options: #inlineArray(count: 20, "OPTIONS")
        case .orderpatch: #inlineArray(count: 20, "ORDERPATCH")
        case .outbox: #inlineArray(count: 20, "OUTBOX")
        case .partial: #inlineArray(count: 20, "PARTIAL")
        case .partialUpdate: #inlineArray(count: 20, "PARTIAL-UPDATE")
        case .patch: #inlineArray(count: 20, "PATCH")
        case .patchForm: #inlineArray(count: 20, "PATCH-FORM")
        case .patchMultipart: #inlineArray(count: 20, "PATCH-MULTIPART")
        case .pause: #inlineArray(count: 20, "PAUSE")
        case .ping: #inlineArray(count: 20, "PING")
        case .pingAck: #inlineArray(count: 20, "PING-ACK")
        case .play: #inlineArray(count: 20, "PLAY")
        case .poll: #inlineArray(count: 20, "POLL")
        case .post: #inlineArray(count: 20, "POST")
        case .prepare: #inlineArray(count: 20, "PREPARE")
        case .propfind: #inlineArray(count: 20, "PROPFIND")
        case .proppatch: #inlineArray(count: 20, "PROPPATCH")
        case .provision: #inlineArray(count: 20, "PROVISION")
        case .put: #inlineArray(count: 20, "PUT")
        case .purge: #inlineArray(count: 20, "PURGE")
        case .query: #inlineArray(count: 20, "QUERY")
        case .rebind: #inlineArray(count: 20, "REBIND")
        case .record: #inlineArray(count: 20, "RECORD")
        case .recover: #inlineArray(count: 20, "RECOVER")
        case .redirect: #inlineArray(count: 20, "REDIRECT")
        case .refer: #inlineArray(count: 20, "REFER")
        case .register: #inlineArray(count: 20, "REGISTER")
        case .reject: #inlineArray(count: 20, "REJECT")
        case .reload: #inlineArray(count: 20, "RELOAD")
        case .replicate: #inlineArray(count: 20, "REPLICATE")
        case .report: #inlineArray(count: 20, "REPORT")
        case .reserve: #inlineArray(count: 20, "RESERVE")
        case .reset: #inlineArray(count: 20, "RESET")
        case .restart: #inlineArray(count: 20, "RESTART")
        case .restore: #inlineArray(count: 20, "RESTORE")
        case .resume: #inlineArray(count: 20, "RESUME")
        case .retry: #inlineArray(count: 20, "RETRY")
        case .retryCount: #inlineArray(count: 20, "RETRY-COUNT")
        case .rewind: #inlineArray(count: 20, "REWIND")
        case .rollback: #inlineArray(count: 20, "ROLLBACK")
        case .rotate: #inlineArray(count: 20, "ROTATE")
        case .search: #inlineArray(count: 20, "SEARCH")
        case .searchall: #inlineArray(count: 20, "SEARCHALL")
        case .setup: #inlineArray(count: 20, "SETUP")
        case .shutdown: #inlineArray(count: 20, "SHUTDOWN")
        case .skip: #inlineArray(count: 20, "SKIP")
        case .split: #inlineArray(count: 20, "SPLIT")
        case .source: #inlineArray(count: 20, "SOURCE")
        case .stash: #inlineArray(count: 20, "STASH")
        case .stop: #inlineArray(count: 20, "STOP")
        case .submit: #inlineArray(count: 20, "SUBMIT")
        case .subscribe: #inlineArray(count: 20, "SUBSCRIBE")
        case .suspend: #inlineArray(count: 20, "SUSPEND")
        case .sync: #inlineArray(count: 20, "SYNC")
        case .syncstate: #inlineArray(count: 20, "SYNCSTATE")
        case .teardown: #inlineArray(count: 20, "TEARDOWN")
        case .thaw: #inlineArray(count: 20, "THAW")
        case .ticket: #inlineArray(count: 20, "TICKET")
        case .trace: #inlineArray(count: 20, "TRACE")
        case .unbind: #inlineArray(count: 20, "UNBIND")
        case .unblock: #inlineArray(count: 20, "UNBLOCK")
        case .uncheckout: #inlineArray(count: 20, "UNCHECKOUT")
        case .undeploy: #inlineArray(count: 20, "UNDEPLOY")
        case .uninstall: #inlineArray(count: 20, "UNINSTALL")
        case .unlink: #inlineArray(count: 20, "UNLINK")
        case .unlock: #inlineArray(count: 20, "UNLOCK")
        case .unset: #inlineArray(count: 20, "UNSET")
        case .unsubscribe: #inlineArray(count: 20, "UNSUBSCRIBE")
        case .update: #inlineArray(count: 20, "UPDATE")
        case .updateredirectref: #inlineArray(count: 20, "UPDATEREDIRECTREF")
        case .upgrade: #inlineArray(count: 20, "UPGRADE")
        case .validate: #inlineArray(count: 20, "VALIDATE")
        case .verify: #inlineArray(count: 20, "VERIFY")
        case .versionControl: #inlineArray(count: 20, "VERSION-CONTROL")
        }
    }
}

// MARK: Raw Name String
extension HTTPRequestMethod {
    @inlinable
    public var rawNameString : String {
        return rawName.string()
    }
}

// MARK: Debug description
extension HTTPRequestMethod : CustomDebugStringConvertible  {
    @inlinable
    public var debugDescription : String {
        "HTTPRequestMethod." + rawValue
    }
}

// MARK: Parse by literal
extension HTTPRequestMethod {
    /// - Complexity: O(1)
    @inlinable
    public static func parse(_ literal: String) -> Self? {
        switch literal {
        case "get", "GET":         .get
        case "head", "HEAD":       .head
        case "post", "POST":       .post
        case "put", "PUT":         .put
        case "delete", "DELETE":   .delete
        case "connect", "CONNECT": .connect
        case "options", "OPTIONS": .options
        case "trace", "TRACE":     .trace
        case "patch", "PATCH":     .patch
        default:                   nil
        }
    }
}

// MARK: Parse by SIMD
extension HTTPRequestMethod { // TODO: make a `simd` computed property
    @inlinable
    public static func parse(_ key: SIMD8<UInt8>) -> Self? {
        switch key {
        case Self.getSIMD:     .get
        case Self.headSIMD:    .head
        case Self.postSIMD:    .post
        case Self.putSIMD:     .put
        case Self.deleteSIMD:  .delete
        case Self.connectSIMD: .connect
        case Self.optionsSIMD: .options
        case Self.traceSIMD:   .trace
        case Self.patchSIMD:   .patch
        default:               nil
        }
    }
    public static let getSIMD:SIMD8<UInt8> = SIMD8<UInt8>(71, 69, 84, 0, 0, 0, 0, 0)
    public static let headSIMD:SIMD8<UInt8> = SIMD8<UInt8>(72, 69, 65, 68, 0, 0, 0, 0)
    public static let postSIMD:SIMD8<UInt8> = SIMD8<UInt8>(80, 79, 83, 84, 0, 0, 0, 0)
    public static let putSIMD:SIMD8<UInt8> = SIMD8<UInt8>(80, 85, 84, 0, 0, 0, 0, 0)
    public static let deleteSIMD:SIMD8<UInt8> = SIMD8<UInt8>(68, 69, 76, 69, 84, 69, 0, 0)
    public static let connectSIMD:SIMD8<UInt8> = SIMD8<UInt8>(67, 79, 78, 78, 69, 67, 84, 0)
    public static let optionsSIMD:SIMD8<UInt8> = SIMD8<UInt8>(79, 80, 84, 73, 79, 78, 83, 0)
    public static let traceSIMD:SIMD8<UInt8> = SIMD8<UInt8>(84, 82, 65, 67, 69, 0, 0, 0)
    public static let patchSIMD:SIMD8<UInt8> = SIMD8<UInt8>(80, 65, 84, 67, 72, 0, 0, 0)
}

#if canImport(SwiftSyntax)
// MARK: SwiftSyntax
extension HTTPRequestMethod {
    public init?(expr: ExprSyntaxProtocol) {
        guard let string = expr.memberAccess?.declName.baseName.text ?? expr.stringLiteral?.string.lowercased() else {
            return nil
        }
        if let value = Self(rawValue: string) {
            self = value
        } else {
            switch string {
            case "baseline-control": self = .baselineControl
            case "notify-file": self = .notifyFile
            case "partial-update": self = .partialUpdate
            case "patch-form": self = .patchForm
            case "patch-multipart": self = .patchMultipart
            case "retry-count": self = .retryCount
            case "version-control": self = .versionControl
            default: return nil
            }
        }
    }
}
#endif