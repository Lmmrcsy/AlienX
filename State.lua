local State = {}

State.Auto = {
    Crate = false,
    Oil = false,
    Upgrade = false,
}

State.Teleport = {
    Follow = false,
    Spectate = false,
    TargetPlayer = nil,
}

State.ESP = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Tracers = false,
    Health = false,
    Chams = false,
    PlayerCount = false,
    Color = Color3.fromRGB(255,255,255),
}

return State