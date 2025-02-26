const std = @import("std");
const nw = @import("root").neonwood;

const ui = nw.ui;
const platform = nw.platform;
const core = nw.core;

const assets = nw.assets;
const c = nw.graphics.c;
const NodeHandle = ui.NodeHandle;

pub const GameContext = struct {
    pub var NeonObjectTable: nw.core.RttiData = nw.core.RttiData.from(@This());

    allocator: std.mem.Allocator,
    debugOpen: bool = true,

    text: NodeHandle = .{},
    fps: NodeHandle = .{},
    panel: NodeHandle = .{},
    time: f64 = 0,

    fpsText: ?[]u8 = null,

    pub fn init(allocator: std.mem.Allocator) !*@This() {
        var self = try allocator.create(@This());
        self.* = .{ .allocator = allocator };
        return self;
    }

    pub fn deinit(self: *@This()) void {
        if (self.fpsText) |text| {
            self.allocator.free(text);
        }
    }

    pub fn tick(self: *@This(), dt: f64) void {
        self.time += dt;

        if (self.time > 5.0) {
            self.time = 0;
        }

        if (self.fpsText) |t| {
            self.allocator.free(t);
        }
        self.fpsText = std.fmt.allocPrint(self.allocator, "fps: {d:.2}", .{1.0 / dt}) catch unreachable;

        var ctx = ui.getContext();

        // holy crap that's bad i need a better way to automate this.
        ctx.get(self.fps).text = ui.papyrus.LocText.fromUtf8(self.fpsText.?);
    }

    pub fn prepare_game(self: *@This()) !void {
        try assets.load(assets.MakeImportRef("Texture", "t_sampleImage", "content/textures/singleSpriteTest.png"));

        var ctx = ui.getContext();
        ctx.drawDebug = true;

        self.panel = try ctx.addPanel(.{});
        ctx.getPanel(self.panel).hasTitle = true;
        ctx.getPanel(self.panel).titleSize = 20;
        ctx.getPanel(self.panel).titleColor = BurnStyle.Bright1;
        ctx.get(self.panel).text = ui.papyrus.MakeText("Ui demo program: Hello world.");
        ctx.get(self.panel).pos = .{ .x = 0, .y = 0 };
        ctx.get(self.panel).size = .{ .x = 800, .y = 900 };
        ctx.get(self.panel).style.borderColor = BurnStyle.Diminished;
        ctx.get(self.panel).style.backgroundColor = BurnStyle.LightGrey;

        const text = try ctx.addText(self.panel, ipsum);
        ctx.getText(text).textSize = 48;
        ctx.get(text).pos = .{ .x = 32, .y = 64 };
        ctx.get(text).size = .{ .x = 600, .y = 600 };
        self.text = text;

        try ctx.events.installMouseOverEvent(self.panel, .mouseOver, null, &onMouseOver);
        try ctx.events.installMouseOverEvent(self.panel, .mouseOff, null, &onMouseOff);

        const fps = try ctx.addText(self.panel, "fps: {}");
        ctx.get(fps).style.foregroundColor = ui.papyrus.ModernStyle.Orange;
        ctx.get(fps).pos = .{ .x = 32, .y = 12 };
        ctx.get(fps).size = .{ .x = 700, .y = 500 };
        self.fps = fps;

        const unk = try ctx.addPanel(.{});
        ctx.get(unk).pos = .{ .x = 800, .y = 0 };
        ctx.get(unk).size = .{ .x = 800, .y = 900 };
        ctx.get(unk).style.borderColor = BurnStyle.Diminished;
        ctx.get(unk).style.backgroundColor = BurnStyle.LightGrey;
        ctx.getPanel(unk).hasTitle = true;

        try ctx.events.installMouseOverEvent(unk, .mouseOver, null, &onMouseOver);
        try ctx.events.installMouseOverEvent(unk, .mouseOff, null, &onMouseOff);

        try ctx.events.installOnPressedEvent(unk, .onPressed, .Mouse1, null, &pressedUnk);

        ctx.getPanel(unk).layoutMode = .Vertical;

        for (0..3) |i| {
            _ = i;
            const unk2 = try ctx.addPanel(unk);
            ctx.get(unk2).justify = .Left;
            ctx.get(unk2).pos = .{ .x = 0, .y = 0 };
            ctx.get(unk2).size = .{ .x = 150, .y = 75 };
            ctx.get(unk2).style.backgroundColor = BurnStyle.LightGrey;
            try ctx.events.installOnPressedEvent(unk2, .onPressed, .Mouse1, null, &onUnk2);
            try ctx.events.installOnPressedEvent(unk2, .onReleased, .Mouse1, null, &onUnk2);
            try ctx.events.installMouseOverEvent(unk2, .mouseOff, null, &onUnk2MouseOff);

            const unk2Text = try ctx.addText(unk2, "click me!");
            ctx.get(unk2Text).pos = .{ .x = 5, .y = 5 };
            ctx.get(unk2Text).size = .{ .x = 150, .y = 75 };
            ctx.getText(unk2Text).textSize = 32;
        }

        for (0..2) |i| {
            const unk2 = try ctx.addPanel(unk);
            ctx.get(unk2).justify = .Center;
            ctx.get(unk2).pos = .{ .x = 10 * @as(f32, @floatFromInt(i)), .y = 0 };
            ctx.get(unk2).size = .{ .x = 200, .y = 75 };
            ctx.get(unk2).style.backgroundColor = BurnStyle.LightGrey;
            try ctx.events.installOnPressedEvent(unk2, .onPressed, .Mouse1, null, &onUnk2);
            try ctx.events.installOnPressedEvent(unk2, .onReleased, .Mouse1, null, &onUnk2);
            try ctx.events.installMouseOverEvent(unk2, .mouseOff, null, &onUnk2MouseOff);

            const unk2Text = try ctx.addText(unk2, "click me!");
            ctx.get(unk2Text).pos = .{ .x = 5, .y = 5 };
            ctx.get(unk2Text).size = .{ .x = 150, .y = 75 };
            ctx.getText(unk2Text).textSize = 32;
        }

        for (0..3) |i| {
            _ = i;
            const unk2 = try ctx.addPanel(unk);
            ctx.get(unk2).justify = .Right;
            ctx.get(unk2).pos = .{ .x = 0, .y = 0 };
            ctx.get(unk2).size = .{ .x = 150, .y = 75 };
            ctx.get(unk2).style.backgroundColor = BurnStyle.Diminished;
            ctx.getPanel(unk2).rounding = .{
                .tl = 10.0,
                .tr = 10.0,
                .br = 10.0,
                .bl = 10.0,
            };
            try ctx.events.installOnPressedEvent(unk2, .onPressed, .Mouse1, null, &onUnk2);
            try ctx.events.installOnPressedEvent(unk2, .onReleased, .Mouse1, null, &onUnk2);
            try ctx.events.installMouseOverEvent(unk2, .mouseOff, null, &onUnk2MouseOff);

            const unk2Text = try ctx.addText(unk2, "click me!");
            ctx.get(unk2Text).pos = .{ .x = 5, .y = 5 };
            ctx.get(unk2Text).size = .{ .x = 150, .y = 75 };
            ctx.getText(unk2Text).textSize = 32;
        }

        ctx.printTree(.{});
    }
};

const BurnStyle = ui.papyrus.BurnStyle;

fn onUnk2(node: ui.NodeHandle, eventType: ui.PressedEventType, _: ?*anyopaque) ui.EventHandlerError!void {
    var ctx = ui.getContext();

    if (eventType == .onPressed) {
        nw.core.engine_logs("I GOT CLICKED!!!");
        ctx.get(node).style.backgroundColor = BurnStyle.DarkSlateGrey;
        ui.getContext().drawDebug = !ui.getContext().drawDebug;
    }

    if (eventType == .onReleased) {
        ctx.get(node).style.backgroundColor = BurnStyle.LightGrey;
    }
}

fn onUnk2MouseOff(node: ui.NodeHandle, _: ?*anyopaque) ui.EventHandlerError!void {
    _ = node;
}

fn pressedUnk(node: ui.NodeHandle, eventType: ui.PressedEventType, _: ?*anyopaque) ui.EventHandlerError!void {
    if (eventType == .onPressed) {
        nw.core.engine_log("clicked on {any}", .{node});
    }
}

fn onMouseOver(node: ui.NodeHandle, _: ?*anyopaque) ui.EventHandlerError!void {
    nw.core.engine_log("Mouse over over {any}", .{node});
}

fn onMouseOff(node: ui.NodeHandle, _: ?*anyopaque) ui.EventHandlerError!void {
    nw.core.engine_log("Mouse hover off {any}", .{node});
}

const ipsum =
    \\ Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque gravida nec urna at porta. Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi non felis nisi. Aliquam lectus enim, cursus a mollis sed, aliquam ut risus. Nam dolor urna, fermentum consectetur enim vitae, tempus scelerisque urna. Vestibulum quam sem, faucibus ac volutpat ut, semper in ipsum. Maecenas ornare lectus massa, in lacinia nulla feugiat et. Vestibulum blandit justo at ipsum aliquet, consectetur ultrices libero finibus. Vestibulum ut risus ac metus gravida aliquet. Quisque vel neque eu nisl consectetur iaculis id tincidunt odio. Maecenas rhoncus tristique ullamcorper. Vivamus egestas massa in nulla malesuada ullamcorper. Nullam sed nibh id lacus rutrum interdum a ut ex. Mauris nec odio tempor, pretium arcu et, auctor purus.
    \\ Morbi imperdiet sapien eros, at mollis velit efficitur ac. Ut dictum sapien erat, nec pulvinar justo congue at. Integer ac fringilla mauris. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla lacinia arcu et dignissim bibendum. Cras feugiat consequat ante ac fermentum. Ut luctus ante quis est efficitur laoreet. Donec consequat, nisl vel fringilla condimentum, purus leo finibus dolor, imperdiet rutrum risus orci non sapien. Phasellus in maximus augue. Praesent rhoncus sagittis mi vitae elementum. Integer id blandit diam. Sed ut augue id orci venenatis suscipit nec at velit. Vestibulum luctus pretium nisl, quis pretium neque tristique a. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Interdum et malesuada fames ac ante ipsum primis in faucibus. Suspendisse in pretium sapien.
    \\ Sed non interdum tellus. Quisque id ipsum ut arcu fringilla auctor non et nulla. Maecenas convallis, eros sit amet dapibus consectetur, ante risus placerat diam, vel porta felis nisi eget nisi. Sed justo turpis, accumsan eget nunc non, condimentum consequat quam. Vivamus varius nibh ex, eu luctus tellus tempor sed. In egestas ultricies massa, in pulvinar nulla. Phasellus sit amet erat sit amet massa ultrices finibus. Nullam elementum odio non auctor finibus. Phasellus ultrices, purus nec semper finibus, nunc libero fermentum odio, non aliquam risus risus eget ipsum. Nam urna ligula, vestibulum et arcu et, egestas sollicitudin justo.
    \\ Donec cursus placerat massa et vulputate. Duis egestas malesuada erat, quis finibus tellus finibus vitae. Ut malesuada blandit ultrices. Maecenas faucibus volutpat risus, in fringilla libero. Etiam pharetra interdum mi, malesuada sagittis neque feugiat at. Nullam pellentesque ultricies consequat. Ut consectetur, orci id gravida pellentesque, tortor ante fringilla dui, at condimentum neque ligula sed eros. Cras vulputate velit urna, vitae volutpat enim varius quis. Curabitur lorem mi, viverra vel tellus vehicula, eleifend viverra mauris. Proin fringilla eleifend elit, sed dapibus purus porttitor non.
    \\ Maecenas vitae nibh id leo laoreet luctus. In hac habitasse platea dictumst. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec vitae lorem mollis nisl hendrerit rhoncus. Nullam convallis tincidunt massa, ut interdum arcu elementum elementum. Nulla facilisi. Praesent molestie lacinia elit. Pellentesque consequat tincidunt ipsum, vel auctor dui mattis non. Donec vel sem vel dolor viverra feugiat eget ac sem. Vestibulum eget magna massa. Aliquam eget malesuada neque. Integer sodales pulvinar elit id luctus. Phasellus ultricies magna sed pellentesque pretium. Phasellus et nibh ac dui tempor porttitor nec id libero.
    \\ Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer tristique turpis et bibendum interdum. Sed ut viverra sem. Phasellus et sapien quis odio euismod hendrerit sit amet id purus. Ut convallis ac elit nec convallis. Nunc interdum sed elit id mollis. Nullam molestie pretium pretium. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Vestibulum congue orci ut metus lacinia, non gravida odio tristique. Aliquam.
;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const cleanupStatus = gpa.deinit();
        if (cleanupStatus == .leak) {
            std.debug.print("gpa cleanup leaked memory\n", .{});
        }
    }
    const allocator = std.heap.c_allocator;

    nw.graphics.setStartupSettings("maxObjectCount", 10);
    try nw.start_everything(allocator, .{ .windowName = "NeonWood: ui" });
    defer nw.shutdown_everything(allocator);
    try nw.run_no_input_tickable(GameContext);
}
