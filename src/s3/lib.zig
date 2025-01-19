/// S3 Client Library for Zig
///
/// This library provides a simple interface for interacting with Amazon S3 and S3-compatible services.
/// It supports basic operations like creating/deleting buckets and uploading/downloading objects.
///
/// Basic usage:
/// ```zig
/// const S3Client = @import("s3").S3Client;
/// const S3Config = @import("s3").S3Config;
///
/// // Initialize client
/// var client = try S3Client.init(allocator, .{
///     .access_key_id = "your-key",
///     .secret_access_key = "your-secret",
///     .region = "us-east-1",
/// });
/// defer client.deinit();
///
/// // Use the client
/// try client.createBucket("my-bucket");
/// try client.putObject("my-bucket", "hello.txt", "Hello, S3!");
/// ```
const std = @import("std");
const client = @import("client/implementation.zig");
const bucket_ops = @import("bucket/operations.zig");
const object_ops = @import("object/operations.zig");

/// Possible errors that can occur during S3 operations.
/// These errors cover both AWS-specific issues and general HTTP/network problems.
pub const S3Error = error{
    /// Invalid AWS credentials or signature
    InvalidCredentials,
    /// Network or connection failure
    ConnectionFailed,
    /// Requested bucket does not exist
    BucketNotFound,
    /// Requested object does not exist
    ObjectNotFound,
    /// Unexpected response from S3 service
    InvalidResponse,
    /// Error during request signing
    SignatureError,
    /// Memory allocation failure
    OutOfMemory,
};

/// Re-export configuration type
pub const S3Config = client.S3Config;

/// Main client interface that provides S3 operations.
/// This struct wraps the internal implementation and provides a clean public API.
pub const S3Client = struct {
    /// Internal client implementation
    inner: *client.S3Client,

    /// Initialize a new S3 client with the given configuration.
    /// Memory is allocated for the client and must be freed with deinit.
    ///
    /// Parameters:
    ///   - allocator: Memory allocator for the client
    ///   - config: S3 configuration including credentials
    ///
    /// Returns: Initialized S3Client
    ///
    /// Errors:
    ///   - OutOfMemory: If client allocation fails
    pub fn init(allocator: std.mem.Allocator, config: S3Config) !S3Client {
        return S3Client{
            .inner = try client.S3Client.init(allocator, config),
        };
    }

    /// Clean up resources used by the client.
    /// This must be called when done with the client to avoid memory leaks.
    pub fn deinit(self: *S3Client) void {
        self.inner.deinit();
    }

    // Re-export bucket operations as methods
    /// Create a new bucket. See bucket/operations.zig for details.
    pub fn createBucket(self: *S3Client, bucket_name: []const u8) !void {
        return bucket_ops.createBucket(self.inner, bucket_name);
    }

    /// Delete an existing bucket. See bucket/operations.zig for details.
    pub fn deleteBucket(self: *S3Client, bucket_name: []const u8) !void {
        return bucket_ops.deleteBucket(self.inner, bucket_name);
    }

    // Re-export object operations as methods
    /// Upload an object to S3. See object/operations.zig for details.
    pub fn putObject(self: *S3Client, bucket_name: []const u8, key: []const u8, data: []const u8) !void {
        return object_ops.putObject(self.inner, bucket_name, key, data);
    }

    /// Download an object from S3. See object/operations.zig for details.
    pub fn getObject(self: *S3Client, bucket_name: []const u8, key: []const u8) ![]const u8 {
        return object_ops.getObject(self.inner, bucket_name, key);
    }

    /// Delete an object from S3. See object/operations.zig for details.
    pub fn deleteObject(self: *S3Client, bucket_name: []const u8, key: []const u8) !void {
        return object_ops.deleteObject(self.inner, bucket_name, key);
    }
};
