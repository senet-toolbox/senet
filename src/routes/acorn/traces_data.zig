const DateTime = @import("vapor").DateTime;

pub const Severity = enum {
    debug,
    info,
    warning,
    @"error",
    critical,
    fatal,
};

pub const Environment = enum {
    development,
    staging,
    production,
    canary,
};

pub const Trace = struct {
    id: []const u8,
    exception_id: []const u8,
    timestamp: DateTime,
    severity: Severity,
    environment: Environment,
    service_name: []const u8,
    service_version: []const u8,
    hostname: []const u8,
    request_id: []const u8,
    duration_ms: u64,
    memory_usage_bytes: u64,
    cpu_percent: f32,
    http_status: u16,
    error_code: []const u8,
    message: []const u8,
    buf: []const u8,
};

pub const traces_data = &.{
    Trace{
        .id = "tr-001-a7dd7725-0001",
        .exception_id = "a7dd7725-7774-4c91-a4e1-038356e7c3a9",
        .timestamp = DateTime.fromDayMonthYear(10, 6, 2026),
        .severity = .@"error",
        .environment = .production,
        .service_name = "user-service",
        .service_version = "2.14.3",
        .hostname = "prod-user-01.us-east-1.internal",
        .request_id = "req-8f3a2b1c-4d5e-6f7a-8b9c-0d1e2f3a4b5c",
        .duration_ms = 234,
        .memory_usage_bytes = 156_274_688,
        .cpu_percent = 23.5,
        .http_status = 500,
        .error_code = "ERR_NULL_PTR",
        .message = "NullPointerException while fetching user profile",
        .buf =
        \\error: NullPointerException at 0x7fff5fbff8c0
        \\  at UserDataController.fetchProfile (src/controllers/user.zig:142:23)
        \\  at Router.handleRequest (src/router.zig:89:15)
        \\  at Server.processConnection (src/server.zig:234:9)
        \\  at EventLoop.run (src/event_loop.zig:56:17)
        ,
    },
    Trace{
        .id = "tr-002-b8ee8836-0001",
        .exception_id = "b8ee8836-8885-5da2-b5f2-149467e8d4b0",
        .timestamp = DateTime.fromDayMonthYear(15, 6, 2026),
        .severity = .critical,
        .environment = .production,
        .service_name = "order-service",
        .service_version = "3.2.1",
        .hostname = "prod-order-03.us-west-2.internal",
        .request_id = "req-1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
        .duration_ms = 30_045,
        .memory_usage_bytes = 234_881_024,
        .cpu_percent = 12.8,
        .http_status = 504,
        .error_code = "ERR_DB_TIMEOUT",
        .message = "Database connection timeout after 30000ms",
        .buf =
        \\error: ConnectionTimeout after 30000ms
        \\  at Database.query (src/db/postgres.zig:301:31)
        \\  at OrderRepository.findById (src/repos/order.zig:67:12)
        \\  at OrderService.getOrder (src/services/order.zig:45:8)
        \\  at ApiHandler.handleGetOrder (src/api/v1/orders.zig:112:19)
        ,
    },
    Trace{
        .id = "tr-003-c9ff9947-0001",
        .exception_id = "c9ff9947-9996-6eb3-c6g3-250578f9e5c1",
        .timestamp = DateTime.fromDayMonthYear(14, 6, 2026),
        .severity = .@"error",
        .environment = .production,
        .service_name = "analytics-service",
        .service_version = "1.8.0",
        .hostname = "prod-analytics-02.eu-west-1.internal",
        .request_id = "req-2b3c4d5e-6f7a-8b9c-0d1e-2f3a4b5c6d7e",
        .duration_ms = 1_892,
        .memory_usage_bytes = 4_294_967_296,
        .cpu_percent = 98.2,
        .http_status = 500,
        .error_code = "ERR_OOM",
        .message = "Out of memory during analytics aggregation",
        .buf =
        \\error: OutOfMemory - failed to allocate 4096 bytes
        \\  at Allocator.alloc (std/mem/Allocator.zig:23:13)
        \\  at ArrayList.ensureCapacity (std/array_list.zig:178:24)
        \\  at AnalyticsEngine.aggregate (src/analytics/engine.zig:445:7)
        \\  at DashboardController.renderAnalytics (src/controllers/dashboard.zig:78:11)
        ,
    },
    Trace{
        .id = "tr-004-d0gg0058-0001",
        .exception_id = "d0gg0058-0007-7fc4-d7h4-361689g0f6d2",
        .timestamp = DateTime.fromDayMonthYear(12, 6, 2026),
        .severity = .critical,
        .environment = .production,
        .service_name = "payment-service",
        .service_version = "4.1.7",
        .hostname = "prod-payment-01.us-east-1.internal",
        .request_id = "req-3c4d5e6f-7a8b-9c0d-1e2f-3a4b5c6d7e8f",
        .duration_ms = 2_341,
        .memory_usage_bytes = 89_128_960,
        .cpu_percent = 15.3,
        .http_status = 402,
        .error_code = "ERR_PAYMENT_DECLINED",
        .message = "Card declined due to insufficient funds",
        .buf =
        \\error: PaymentProcessingError - Card declined (insufficient_funds)
        \\  at StripeClient.chargeCard (src/integrations/stripe.zig:189:27)
        \\  at PaymentService.processPayment (src/services/payment.zig:234:14)
        \\  at PaymentController.handleCharge (src/api/v2/payments.zig:56:9)
        \\  at Router.dispatch (src/router.zig:102:21)
        ,
    },
    Trace{
        .id = "tr-005-e1hh1169-0001",
        .exception_id = "e1hh1169-1118-8gd5-e8i5-472790h1g7e3",
        .timestamp = DateTime.fromDayMonthYear(11, 6, 2026),
        .severity = .warning,
        .environment = .production,
        .service_name = "user-service",
        .service_version = "2.14.3",
        .hostname = "prod-user-02.us-east-1.internal",
        .request_id = "req-4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a",
        .duration_ms = 156,
        .memory_usage_bytes = 67_108_864,
        .cpu_percent = 8.7,
        .http_status = 400,
        .error_code = "ERR_VALIDATION",
        .message = "Invalid email format in profile update",
        .buf =
        \\error: ValidationError - Invalid email format
        \\  at Validator.validateEmail (src/utils/validator.zig:67:19)
        \\  at UserProfile.update (src/models/user_profile.zig:134:8)
        \\  at SettingsController.saveSettings (src/controllers/settings.zig:89:12)
        \\  at AuthMiddleware.withUser (src/middleware/auth.zig:45:5)
        ,
    },
    Trace{
        .id = "tr-006-f2ii2270-0001",
        .exception_id = "f2ii2270-2229-9he6-f9j6-583801i2h8f4",
        .timestamp = DateTime.fromDayMonthYear(9, 6, 2026),
        .severity = .warning,
        .environment = .production,
        .service_name = "auth-service",
        .service_version = "2.0.5",
        .hostname = "prod-auth-01.us-east-1.internal",
        .request_id = "req-5e6f7a8b-9c0d-1e2f-3a4b-5c6d7e8f9a0b",
        .duration_ms = 89,
        .memory_usage_bytes = 45_088_768,
        .cpu_percent = 5.2,
        .http_status = 401,
        .error_code = "ERR_TOKEN_EXPIRED",
        .message = "JWT token expired, refresh required",
        .buf =
        \\error: TokenExpired - JWT token expired at 1718956800
        \\  at JwtDecoder.verify (src/auth/jwt.zig:78:33)
        \\  at AuthService.refreshToken (src/services/auth.zig:156:11)
        \\  at AuthController.handleRefresh (src/api/auth.zig:201:17)
        \\  at RateLimiter.check (src/middleware/rate_limit.zig:34:9)
        ,
    },
    Trace{
        .id = "tr-007-g3jj3381-0001",
        .exception_id = "g3jj3381-3330-0if7-g0k7-694912j3i9g5",
        .timestamp = DateTime.fromDayMonthYear(8, 6, 2026),
        .severity = .critical,
        .environment = .production,
        .service_name = "webhook-service",
        .service_version = "1.3.2",
        .hostname = "prod-webhook-01.us-east-1.internal",
        .request_id = "req-6f7a8b9c-0d1e-2f3a-4b5c-6d7e8f9a0b1c",
        .duration_ms = 45,
        .memory_usage_bytes = 33_554_432,
        .cpu_percent = 3.1,
        .http_status = 401,
        .error_code = "ERR_WEBHOOK_SIG",
        .message = "Webhook signature verification failed",
        .buf =
        \\error: WebhookSignatureInvalid - HMAC verification failed
        \\  at Crypto.verifyHmac (src/utils/crypto.zig:112:25)
        \\  at StripeWebhook.validateSignature (src/webhooks/stripe.zig:45:8)
        \\  at WebhookController.handleStripe (src/controllers/webhook.zig:67:14)
        \\  at Server.handlePost (src/server.zig:189:22)
        ,
    },
    Trace{
        .id = "tr-008-h4kk4492-0001",
        .exception_id = "h4kk4492-4441-1jg8-h1l8-705023k4j0h6",
        .timestamp = DateTime.fromDayMonthYear(7, 6, 2026),
        .severity = .warning,
        .environment = .production,
        .service_name = "notification-service",
        .service_version = "2.7.1",
        .hostname = "prod-notify-02.us-west-2.internal",
        .request_id = "req-7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d",
        .duration_ms = 1_234,
        .memory_usage_bytes = 78_643_200,
        .cpu_percent = 11.4,
        .http_status = 410,
        .error_code = "ERR_APNS_UNREGISTERED",
        .message = "Push notification failed - device unregistered",
        .buf =
        \\error: PushNotificationFailed - APNs returned status 410 (Unregistered)
        \\  at ApnsClient.send (src/integrations/apns.zig:234:18)
        \\  at NotificationService.sendPush (src/services/notification.zig:89:7)
        \\  at NotificationController.dispatch (src/controllers/notification.zig:123:11)
        \\  at BackgroundWorker.process (src/workers/background.zig:56:9)
        ,
    },
    Trace{
        .id = "tr-009-i5ll5503-0001",
        .exception_id = "i5ll5503-5552-2kh9-i2m9-816134l5k1i7",
        .timestamp = DateTime.fromDayMonthYear(6, 6, 2026),
        .severity = .critical,
        .environment = .production,
        .service_name = "inventory-service",
        .service_version = "3.5.0",
        .hostname = "prod-inventory-01.eu-central-1.internal",
        .request_id = "req-8b9c0d1e-2f3a-4b5c-6d7e-8f9a0b1c2d3e",
        .duration_ms = 5_678,
        .memory_usage_bytes = 512_000_000,
        .cpu_percent = 45.6,
        .http_status = 409,
        .error_code = "ERR_SYNC_CONFLICT",
        .message = "Inventory sync version mismatch detected",
        .buf =
        \\error: InventorySyncConflict - Version mismatch (expected: 42, got: 41)
        \\  at InventorySync.reconcile (src/sync/inventory.zig:312:29)
        \\  at SyncService.fullSync (src/services/sync.zig:178:15)
        \\  at InventoryController.triggerSync (src/api/v1/inventory.zig:89:8)
        \\  at CronScheduler.execute (src/scheduler/cron.zig:67:12)
        ,
    },
    Trace{
        .id = "tr-010-j6mm6614-0001",
        .exception_id = "j6mm6614-6663-3li0-j3n0-927245m6l2j8",
        .timestamp = DateTime.fromDayMonthYear(5, 6, 2026),
        .severity = .@"error",
        .environment = .production,
        .service_name = "search-service",
        .service_version = "2.1.4",
        .hostname = "prod-search-03.us-east-1.internal",
        .request_id = "req-9c0d1e2f-3a4b-5c6d-7e8f-9a0b1c2d3e4f",
        .duration_ms = 3_456,
        .memory_usage_bytes = 268_435_456,
        .cpu_percent = 67.8,
        .http_status = 500,
        .error_code = "ERR_ES_INDEX",
        .message = "Elasticsearch index not found",
        .buf =
        \\error: ElasticsearchQueryError - index_not_found_exception: no such index [products_v2]
        \\  at ElasticClient.search (src/integrations/elasticsearch.zig:145:21)
        \\  at SearchService.searchProducts (src/services/search.zig:234:9)
        \\  at SearchController.handleQuery (src/controllers/search.zig:56:14)
        \\  at CacheMiddleware.checkCache (src/middleware/cache.zig:78:7)
        ,
    },
    Trace{
        .id = "tr-011-k7nn7725-0001",
        .exception_id = "k7nn7725-7774-4mj1-k4o1-038356n7m3k9",
        .timestamp = DateTime.fromDayMonthYear(4, 6, 2026),
        .severity = .@"error",
        .environment = .production,
        .service_name = "report-service",
        .service_version = "1.9.2",
        .hostname = "prod-report-01.us-west-2.internal",
        .request_id = "req-0d1e2f3a-4b5c-6d7e-8f9a-0b1c2d3e4f5a",
        .duration_ms = 60_001,
        .memory_usage_bytes = 1_073_741_824,
        .cpu_percent = 89.3,
        .http_status = 504,
        .error_code = "ERR_REPORT_TIMEOUT",
        .message = "Report generation exceeded time limit",
        .buf =
        \\error: ReportGenerationTimeout - Report exceeded 60s time limit
        \\  at ReportGenerator.generate (src/reports/generator.zig:445:33)
        \\  at ReportService.createReport (src/services/report.zig:189:11)
        \\  at ReportController.handleGenerate (src/api/reports.zig:112:8)
        \\  at AsyncExecutor.runWithTimeout (src/async/executor.zig:67:19)
        ,
    },
    Trace{
        .id = "tr-012-l8oo8836-0001",
        .exception_id = "l8oo8836-8885-5nk2-l5p2-149467o8n4l0",
        .timestamp = DateTime.fromDayMonthYear(3, 6, 2026),
        .severity = .warning,
        .environment = .staging,
        .service_name = "admin-service",
        .service_version = "2.3.0",
        .hostname = "staging-admin-01.us-east-1.internal",
        .request_id = "req-1e2f3a4b-5c6d-7e8f-9a0b-1c2d3e4f5a6b",
        .duration_ms = 8_923,
        .memory_usage_bytes = 134_217_728,
        .cpu_percent = 34.2,
        .http_status = 400,
        .error_code = "ERR_CSV_PARSE",
        .message = "CSV parsing error at row 1847",
        .buf =
        \\error: CsvParseError - Unexpected number of columns at row 1847 (expected: 12, got: 11)
        \\  at CsvParser.parseRow (src/utils/csv.zig:89:27)
        \\  at BulkImporter.importUsers (src/admin/bulk_import.zig:156:14)
        \\  at AdminController.handleBulkImport (src/controllers/admin.zig:234:9)
        \\  at FileUploadMiddleware.process (src/middleware/upload.zig:45:11)
        ,
    },
    Trace{
        .id = "tr-013-m9pp9947-0001",
        .exception_id = "m9pp9947-9996-6ol3-m6q3-250578p9o5m1",
        .timestamp = DateTime.fromDayMonthYear(2, 6, 2026),
        .severity = .fatal,
        .environment = .production,
        .service_name = "messaging-service",
        .service_version = "4.0.3",
        .hostname = "prod-messaging-02.eu-west-1.internal",
        .request_id = "req-2f3a4b5c-6d7e-8f9a-0b1c-2d3e4f5a6b7c",
        .duration_ms = 15_234,
        .memory_usage_bytes = 2_147_483_648,
        .cpu_percent = 92.1,
        .http_status = 503,
        .error_code = "ERR_QUEUE_FULL",
        .message = "Message queue at capacity, rejecting new messages",
        .buf =
        \\error: MessageQueueFull - RabbitMQ channel blocked (capacity: 10000)
        \\  at RabbitClient.publish (src/integrations/rabbitmq.zig:178:22)
        \\  at MessagingService.sendMessage (src/services/messaging.zig:301:8)
        \\  at MessagingController.handleSend (src/api/v3/messaging.zig:89:15)
        \\  at CircuitBreaker.execute (src/resilience/circuit_breaker.zig:56:7)
        ,
    },
    Trace{
        .id = "tr-014-n0qq0058-0001",
        .exception_id = "n0qq0058-0007-7pm4-n7r4-361689q0p6n2",
        .timestamp = DateTime.fromDayMonthYear(1, 6, 2026),
        .severity = .warning,
        .environment = .production,
        .service_name = "checkout-service",
        .service_version = "3.1.8",
        .hostname = "prod-checkout-01.us-east-1.internal",
        .request_id = "req-3a4b5c6d-7e8f-9a0b-1c2d-3e4f5a6b7c8d",
        .duration_ms = 234,
        .memory_usage_bytes = 56_623_104,
        .cpu_percent = 7.8,
        .http_status = 422,
        .error_code = "ERR_CHECKOUT_VALIDATION",
        .message = "Checkout validation failed - missing shipping address",
        .buf =
        \\error: CheckoutValidationError - Shipping address required for physical items
        \\  at CheckoutValidator.validateCart (src/checkout/validator.zig:234:19)
        \\  at CheckoutService.validate (src/services/checkout.zig:145:12)
        \\  at CheckoutController.handleValidate (src/controllers/checkout.zig:67:8)
        \\  at SessionMiddleware.withSession (src/middleware/session.zig:89:14)
        ,
    },
    Trace{
        .id = "tr-015-o1rr1169-0001",
        .exception_id = "o1rr1169-1118-8qn5-o8s5-472790r1q7o3",
        .timestamp = DateTime.fromDayMonthYear(31, 5, 2026),
        .severity = .@"error",
        .environment = .production,
        .service_name = "storage-service",
        .service_version = "2.5.6",
        .hostname = "prod-storage-03.us-west-2.internal",
        .request_id = "req-4b5c6d7e-8f9a-0b1c-2d3e-4f5a6b7c8d9e",
        .duration_ms = 4_567,
        .memory_usage_bytes = 167_772_160,
        .cpu_percent = 28.9,
        .http_status = 413,
        .error_code = "ERR_FILE_TOO_LARGE",
        .message = "File upload exceeded maximum size limit",
        .buf =
        \\error: FileUploadError - Exceeded max file size (limit: 10MB, received: 47MB)
        \\  at MultipartParser.parseChunk (src/utils/multipart.zig:312:25)
        \\  at FileService.handleUpload (src/services/file.zig:189:9)
        \\  at FileController.upload (src/api/files.zig:56:11)
        \\  at StreamHandler.processStream (src/http/stream.zig:234:17)
        ,
    },
};

