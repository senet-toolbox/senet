const DateTime = @import("vapor").DateTime;
const Exception = @import("Dashboard.zig").Exception;
pub const exceptions_data = &.{
    Exception{
        .id = "a7dd7725-7774-4c91-a4e1-038356e7c3a9",
        .last_seen = DateTime.fromDayMonthYear(10, 6, 2026),
        .count = 10,
        .url = "/app/userdata",
        .user = .{
            .id = "1f0903af-4c72-41fc-9f66-4a7da00db9e1",
            .email = "vicrokx@gmail.com",
            .name = "Vic Rokx",
        },
    },
    Exception{
        .id = "b8ee8836-8885-5da2-b5f2-149467e8d4b0",
        .last_seen = DateTime.fromDayMonthYear(15, 6, 2026),
        .count = 47,
        .url = "/api/v1/orders",
        .user = .{
            .id = "2a1014bf-5d83-52fd-a077-5b8eb11eca2f",
            .email = "sarah.chen@techcorp.io",
            .name = "Sarah Chen",
        },
    },
    Exception{
        .id = "c9ff9947-9996-6eb3-c6g3-250578f9e5c1",
        .last_seen = DateTime.fromDayMonthYear(14, 6, 2026),
        .count = 3,
        .url = "/dashboard/analytics",
        .user = .{
            .id = "3b2125cg-6e94-63ge-b188-6c9fc22fdb3g",
            .email = "marcus.johnson@outlook.com",
            .name = "Marcus Johnson",
        },
    },
    Exception{
        .id = "d0gg0058-0007-7fc4-d7h4-361689g0f6d2",
        .last_seen = DateTime.fromDayMonthYear(12, 6, 2026),
        .count = 156,
        .url = "/api/v2/payments/process",
        .user = .{
            .id = "4c3236dh-7f05-74hf-c299-7d0gd33gec4h",
            .email = "elena.rodriguez@gmail.com",
            .name = "Elena Rodriguez",
        },
    },
    Exception{
        .id = "e1hh1169-1118-8gd5-e8i5-472790h1g7e3",
        .last_seen = DateTime.fromDayMonthYear(11, 6, 2026),
        .count = 22,
        .url = "/users/profile/settings",
        .user = .{
            .id = "5d4347ei-8g16-85ig-d300-8e1he44hfd5i",
            .email = "james.kim@company.net",
            .name = "James Kim",
        },
    },
    Exception{
        .id = "f2ii2270-2229-9he6-f9j6-583801i2h8f4",
        .last_seen = DateTime.fromDayMonthYear(9, 6, 2026),
        .count = 8,
        .url = "/api/auth/refresh",
        .user = .{
            .id = "6e5458fj-9h27-96jh-e411-9f2if55ige6j",
            .email = "amanda.patel@startup.co",
            .name = "Amanda Patel",
        },
    },
    Exception{
        .id = "g3jj3381-3330-0if7-g0k7-694912j3i9g5",
        .last_seen = DateTime.fromDayMonthYear(8, 6, 2026),
        .count = 91,
        .url = "/webhooks/stripe",
        .user = .{
            .id = "7f6569gk-0i38-07ki-f522-0g3jg66jhf7k",
            .email = "tom.wilson@enterprise.org",
            .name = "Tom Wilson",
        },
    },
    Exception{
        .id = "h4kk4492-4441-1jg8-h1l8-705023k4j0h6",
        .last_seen = DateTime.fromDayMonthYear(7, 6, 2026),
        .count = 5,
        .url = "/app/notifications/push",
        .user = .{
            .id = "8g7670hl-1j49-18lj-g633-1h4kh77kig8l",
            .email = "nina.foster@gmail.com",
            .name = "Nina Foster",
        },
    },
    Exception{
        .id = "i5ll5503-5552-2kh9-i2m9-816134l5k1i7",
        .last_seen = DateTime.fromDayMonthYear(6, 6, 2026),
        .count = 234,
        .url = "/api/v1/inventory/sync",
        .user = .{
            .id = "9h8781im-2k50-29mk-h744-2i5li88ljh9m",
            .email = "david.zhang@logistics.com",
            .name = "David Zhang",
        },
    },
    Exception{
        .id = "j6mm6614-6663-3li0-j3n0-927245m6l2j8",
        .last_seen = DateTime.fromDayMonthYear(5, 6, 2026),
        .count = 17,
        .url = "/search/products",
        .user = .{
            .id = "0i9892jn-3l61-30nl-i855-3j6mj99mki0n",
            .email = "rachel.green@retail.io",
            .name = "Rachel Green",
        },
    },
    Exception{
        .id = "k7nn7725-7774-4mj1-k4o1-038356n7m3k9",
        .last_seen = DateTime.fromDayMonthYear(4, 6, 2026),
        .count = 63,
        .url = "/api/reports/generate",
        .user = .{
            .id = "1j0903ko-4m72-41om-j966-4k7nk00nlj1o",
            .email = "michael.brown@analytics.net",
            .name = "Michael Brown",
        },
    },
    Exception{
        .id = "l8oo8836-8885-5nk2-l5p2-149467o8n4l0",
        .last_seen = DateTime.fromDayMonthYear(3, 6, 2026),
        .count = 2,
        .url = "/admin/users/bulk-import",
        .user = .{
            .id = "2k1014lp-5n83-52pn-k077-5l8ol11omk2p",
            .email = "lisa.taylor@admin.org",
            .name = "Lisa Taylor",
        },
    },
    Exception{
        .id = "m9pp9947-9996-6ol3-m6q3-250578p9o5m1",
        .last_seen = DateTime.fromDayMonthYear(2, 6, 2026),
        .count = 445,
        .url = "/api/v3/messaging/send",
        .user = .{
            .id = "3l2125mq-6o94-63qo-l188-6m9pm22pnl3q",
            .email = "alex.murphy@comms.co",
            .name = "Alex Murphy",
        },
    },
    Exception{
        .id = "n0qq0058-0007-7pm4-n7r4-361689q0p6n2",
        .last_seen = DateTime.fromDayMonthYear(1, 6, 2026),
        .count = 29,
        .url = "/checkout/validate",
        .user = .{
            .id = "4m3236nr-7p05-74rp-m299-7n0qn33qom4r",
            .email = "sophia.lee@ecommerce.com",
            .name = "Sophia Lee",
        },
    },
    Exception{
        .id = "o1rr1169-1118-8qn5-o8s5-472790r1q7o3",
        .last_seen = DateTime.fromDayMonthYear(31, 5, 2026),
        .count = 78,
        .url = "/api/files/upload",
        .user = .{
            .id = "5n4347os-8q16-85sq-n300-8o1ro44rpn5s",
            .email = "chris.davis@storage.io",
            .name = "Chris Davis",
        },
    },
};
