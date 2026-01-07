const std = @import("std");
const Vapor = @import("vapor");
const Color = Vapor.Types.Color;
pub const Mode = enum {
    light,
    dark,
};

pub const ElementType = enum(u8) {
    Rectangle,
    Text,
    Image,
    FlexBox,
    TextField,
    Button,
    Block,
    Box,
    Header,
    Svg,
    Link,
    EmbedLink,
    List,
    ListItem,
    _If,
    Hooks,
    Layout,
    Page,
    Bind,
    Dialog,
    DialogBtnShow,
    DialogBtnClose,
    Draggable,
    RedirectLink,
    Select,
    SelectItem,
    CtxButton,
    EmbedIcon,
    Icon,
    Label,
    Form,
    TextFmt,
    Table,
    TableRow,
    TableCell,
    TableHeader,
    TableBody,
    TextArea,
    Canvas,
    SubmitButton,
    HooksCtx,
    JsonEditor,
    HtmlText,
    Code,
    Span,
    LazyImage,
    Intersection,
    PreImage,
    TextGradient,
    Gradient,
    Virtualize,
    ButtonCycle,
    Graphic,
    Heading,
    Video,
    Noop,
    TableHead,
    Anchor,
};

pub const ThemeTokens = enum(u8) {
    none,
    border_color,
    text_color,
    background,
    primary,
    secondary,
    border_cache_color,
    btn_color,
    tint,
    dark_tint,
    text_tint_color,
    alternate_tint,
    btn_tint,
    dark_text,
    form_input_border_color,
    danger,
    alternate_background,
    alternate_border_color,
    alternate_text_color,
    logo,
    gradient_start_0stop_color,
    gradient_start_100stop_color,
    gradient_end_0stop_color,
    gradient_end_100stop_color,
    icon_color,
    image_bg,
    code_background,
    highlight_color,
    border_color_light,
    grid_color,
    code_text_color,
    code_function_color,
    code_keyword_color,
    disabled,
    light_text,
    code_tint_color,
    code_comment_color,
    code_string_color,
    code_type_color,
    code_component_color,
    code_operator_color,
    code_identifier_color,
};

pub const IconTokens = struct {
    web: ?[]const u8 = null,
    svg: ?[]const u8 = null,
    pub const list_task = &IconTokens{ .web = "bi bi-view-list", .svg = "\u{f0e1}" };
    pub const cloud_download_fill = &IconTokens{ .web = "bi bi-cloud-download-fill", .svg = "\u{f0e2}" };
    pub const plus = &IconTokens{ .web = "bi bi-plus", .svg = "\u{f0fe}" };
    pub const arrow_right = &IconTokens{ .web = "bi bi-arrow-right", .svg = "\u{f0e9}" };
    pub const clipboard = &IconTokens{ .web = "bi bi-clipboard", .svg = "\u{f0ea}" };
    pub const check = &IconTokens{ .web = "bi bi-check", .svg = "\u{f0e7}" };
    pub const home = &IconTokens{ .web = "bi bi-house", .svg = "\u{f0e3}" };
    pub const cloud_moon = &IconTokens{ .web = "bi bi-cloud-moon", .svg = "\u{f0e6}" };
    pub const search = &IconTokens{ .web = "bi bi-search", .svg = "\u{f0e8}" };
    pub const command = &IconTokens{ .web = "bi bi-command", .svg = "\u{f0e4}" };
    pub const fire = &IconTokens{ .web = "bi bi-fire", .svg = "\u{f0e5}" };
    pub const book = &IconTokens{ .web = "bi bi-book", .svg = "\u{f0e8}" };
    pub const mortarboard = &IconTokens{ .web = "bi bi-mortarboard", .svg = "\u{f0e8}" };
    pub const diagram_3 = &IconTokens{ .web = "bi bi-diagram-3", .svg = "\u{f0e8}" };
    pub const github = &IconTokens{ .web = "bi bi-github", .svg = "\u{f0e8}" };
    pub const discord = &IconTokens{ .web = "bi bi-discord", .svg = "\u{f0e8}" };
    pub const lock = &IconTokens{ .web = "bi bi-lock", .svg = "\u{f0e8}" };
    pub const unlock = &IconTokens{ .web = "bi bi-unlock", .svg = "\u{f0e8}" };
    pub const eye = &IconTokens{ .web = "bi bi-eye", .svg = "\u{f0e8}" };
    pub const signpost = &IconTokens{ .web = "bi bi-signpost", .svg = "\u{f0e8}" };
    pub const columns = &IconTokens{ .web = "bi bi-columns", .svg = "\u{f0e8}" };
    pub const paint_bucket = &IconTokens{ .web = "bi bi-paint-bucket", .svg = "\u{f0e8}" };
    pub const tools = &IconTokens{ .web = "bi bi-tools", .svg = "\u{f0e8}" };
    pub const house = &IconTokens{ .web = "bi bi-house", .svg = "\u{f0e8}" };
    pub const cloud = &IconTokens{ .web = "bi bi-cloud", .svg = "\u{f0e8}" };
    pub const moon = &IconTokens{ .web = "bi bi-moon", .svg = "\u{f0e8}" };
    pub const sun = &IconTokens{ .web = "bi bi-sun", .svg = "\u{f0e8}" };
    pub const arrow_repeat = &IconTokens{ .web = "bi bi-arrow-repeat", .svg = "\u{f0e8}" };
    pub const list = &IconTokens{ .web = "bi bi-list", .svg = "\u{f0e8}" };
    pub const cursor = &IconTokens{ .web = "bi bi-cursor", .svg = "\u{f0e8}" };
    pub const hourglass_split = &IconTokens{ .web = "bi bi-hourglass-split", .svg = "\u{f0e8}" };
    pub const ethernet = &IconTokens{ .web = "bi bi-ethernet", .svg = "\u{f0e8}" };
    pub const filetype_js = &IconTokens{ .web = "bi bi-filetype-js", .svg = "\u{f0e8}" };
    pub const filetype_json = &IconTokens{ .web = "bi bi-filetype-json", .svg = "\u{f0e8}" };
    pub const exclamation_triangle = &IconTokens{ .web = "bi bi-exclamation-triangle", .svg = "\u{f0e8}" };
    pub const award = &IconTokens{ .web = "bi bi-award", .svg = "\u{f0e8}" };
    pub const motherboard = &IconTokens{ .web = "bi bi-motherboard", .svg = "\u{f0e8}" };
    pub const x_lg = &IconTokens{ .web = "bi bi-x-lg", .svg = "\u{f0e8}" };
    pub const arrow_return_left = &IconTokens{ .web = "bi bi-arrow-return-left", .svg = "\u{f0e8}" };
    pub const arrow_return_right = &IconTokens{ .web = "bi bi-arrow-return-right", .svg = "\u{f0e8}" };
    pub const device_hdd_fill = &IconTokens{ .web = "bi bi-device-hdd-fill", .svg = "\u{f0e8}" };
    pub const heart_balloon = &IconTokens{ .web = "bi bi-balloon-heart", .svg = "\u{f0e8}" };
    pub const screw_driver = &IconTokens{ .web = "bi bi-screwdriver", .svg = "\u{f0e8}" };
    pub const memory = &IconTokens{ .web = "bi bi-memory", .svg = "\u{f0e8}" };
    pub const grip_horizontal = &IconTokens{ .web = "bi bi-grip-horizontal", .svg = "\u{f0e8}" };
    pub const bug = &IconTokens{ .web = "bi bi-bug", .svg = "\u{f0e8}" };
    pub const check_circle = &IconTokens{ .web = "bi bi-check-circle", .svg = "\u{f0e8}" };
    pub const exclamation_circle = &IconTokens{ .web = "bi bi-exclamation-circle", .svg = "\u{f0e8}" };
    pub const info_circle = &IconTokens{ .web = "bi bi-info-circle", .svg = "\u{f0e8}" };
    pub const chevron_down = &IconTokens{ .web = "bi bi-chevron-down", .svg = "\u{f0e8}" };
    pub const chevron_up = &IconTokens{ .web = "bi bi-chevron-up", .svg = "\u{f0e8}" };
    pub const chevron_left = &IconTokens{ .web = "bi bi-chevron-left", .svg = "\u{f0e8}" };
    pub const chevron_right = &IconTokens{ .web = "bi bi-chevron-right", .svg = "\u{f0e8}" };
    pub const three_dots = &IconTokens{ .web = "bi bi-three-dots", .svg = "\u{f0e8}" };
    pub const sort_alpha_down = &IconTokens{ .web = "bi bi-sort-alpha-down", .svg = "\u{f0e8}" };
    pub const sort_alpha_up = &IconTokens{ .web = "bi bi-sort-alpha-up-alt", .svg = "\u{f0e8}" };
    pub const box_arrow_down = &IconTokens{ .web = "bi bi-box-arrow-down", .svg = "\u{f0e8}" };
    pub const filetype_csv = &IconTokens{ .web = "bi bi-filetype-csv", .svg = "\u{f0e8}" };
    pub const funnel = &IconTokens{ .web = "bi bi-funnel", .svg = "\u{f0e8}" };
    pub const trash = &IconTokens{ .web = "bi bi-trash", .svg = "\u{f0e8}" };
    pub const pencil = &IconTokens{ .web = "bi bi-pencil", .svg = "\u{f0e8}" };
    pub const lucide_search = &IconTokens{ .web = "lucide-search", .svg = 
        \\<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-search-icon lucide-search"><path d="m21 21-4.34-4.34"/><circle cx="11" cy="11" r="8"/></svg> 
    };
    pub const microscope = &IconTokens{ .web = "fa-solid fa-microscope", .svg = "\u{f0e8}" };
    pub const soundwave = &IconTokens{ .web = "bi bi-soundwave", .svg = "\u{f0e8}" };
    pub const send = &IconTokens{ .web = "bi bi-send", .svg = "\u{f0e8}" };
    pub const upload = &IconTokens{ .web = "bi bi-upload", .svg = "\u{f0e8}" };
    pub const account = &IconTokens{ .web = "bi bi-person-circle", .svg = "\u{f0e8}" };
    pub const check2_all = &IconTokens{ .web = "bi bi-check2-all", .svg = "\u{f0e8}" };
    pub const google = &IconTokens{ .web = "bi bi-google", .svg = "\u{f0e8}" };
    pub const apple = &IconTokens{ .web = "bi bi-apple", .svg = "\u{f0e8}" };
    pub const person_rolodex = &IconTokens{ .web = "bi bi-person-rolodex", .svg = "\u{f0e8}" };
    pub const film = &IconTokens{ .web = "bi bi-film", .svg = "\u{f0e8}" };
    pub const react = &IconTokens{ .web = "fa-brands fa-react", .svg = "\u{f0e8}" };
};
