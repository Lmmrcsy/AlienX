local Services = {}

Services.Players = game:GetService("Players")
Services.RunService = game:GetService("RunService")
Services.UserInputService = game:GetService("UserInputService")
Services.VirtualInputManager = game:GetService("VirtualInputManager")
Services.TweenService = game:GetService("TweenService")
Services.ReplicatedStorage = game:GetService("ReplicatedStorage")
Services.Workspace = workspace
Services.Camera = workspace.CurrentCamera

Services.LocalPlayer = Services.Players.LocalPlayer

return Services
